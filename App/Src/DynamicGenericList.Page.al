page 50005 "Dynamic Generic List"
{
    Caption = 'Dynamic Generic List';
    PageType = List;
    SourceTable = Integer;
    SourceTableTemporary = false;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            group(TableSelector)
            {
                ShowCaption = false;
                field(SelectedTableIdCtrl; SelectedTableId)
                {
                    Caption = 'Table ID';
                    ApplicationArea = All;
                    ToolTip = 'Enter the ID of any Business Central table to display its records. Press Load Data to populate the list.';
                    trigger OnValidate()
                    begin
                        UpdateTableName();
                    end;
                }
                field(SelectedTableNameCtrl; SelectedTableName)
                {
                    Caption = 'Table Name';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Name of the currently selected source table, resolved dynamically via RecordRef.Caption.';
                }
            }
            repeater(Records)
            {
                field(RowNoCtrl; Rec.Number)
                {
                    Caption = 'Row';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'The 1-based row number. Maps directly to the source record position when iterated via RecordRef.FindSet / Next.';
                }
                field(RecordSummaryCtrl; gRecordSummary)
                {
                    Caption = 'Record Summary';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'A preview of the first field values of this source record, built dynamically via RecordRef and FieldRef — no hardcoded field names or numbers.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LoadData)
            {
                Caption = 'Load Data';
                ApplicationArea = All;
                Image = Refresh;
                ToolTip = 'Filters the Integer source table to Number = 1..RecordCount for the selected table. Field values are then read per row via RecordRef/FieldRef in OnAfterGetRecord.';
                trigger OnAction()
                begin
                    if SelectedTableId = 0 then
                        Error('Please enter a Table ID before loading data.');
                    RefreshFilter();
                end;
            }
            action(ViewRecord)
            {
                Caption = 'View Record';
                ApplicationArea = All;
                Image = View;
                ToolTip = 'Opens the selected record in a field-viewer page. Each row shows one field name and value, read dynamically via FieldRef — the layout adapts automatically to whichever table is loaded.';
                trigger OnAction()
                var
                    CardPage: Page "Dynamic Generic Card";
                begin
                    if (Rec.Number = 0) or (SelectedTableId = 0) then
                        Error('There is no record selected.');
                    CardPage.InitCard(Rec.Number, SelectedTableId);
                    CardPage.RunModal();
                end;
            }
            action(ConfigureFields)
            {
                Caption = 'Configure Fields';
                ApplicationArea = All;
                Image = FieldList;
                ToolTip = 'Opens the Dynamic Field Config page for this table. Note: this is optional metadata — Load Data and View Record work directly via RecordRef/FieldRef without requiring any config.';
                trigger OnAction()
                var
                    FieldConfig: Record "Dynamic Field Config";
                    FieldConfigPage: Page "Dynamic Field Config";
                begin
                    if SelectedTableId = 0 then
                        Error('Please enter a Table ID first.');
                    FieldConfig.SetRange("Table ID", SelectedTableId);
                    if not FieldConfig.FindFirst() then
                        DynPageMgt.SetupDefaultConfig(SelectedTableId);
                    FieldConfigPage.SetTableView(FieldConfig);
                    FieldConfigPage.RunModal();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SelectedTableId := Database::"Main Table";
        UpdateTableName();
        RefreshFilter();
    end;

    /// <summary>
    /// OnAfterGetRecord fires for every repeater row. Rec.Number (1-based) is the row index.
    /// Uses a persistent global RecordRef (gSrcRecRef) for efficient sequential navigation:
    ///   Row 1      → FindSet()
    ///   Row N+1    → Next()  (most common — sequential scroll)
    ///   Row N (random) → FindSet() + Next(N-1)
    /// Field values are read directly via gSrcRecRef.Field(gNormalFieldIds[i]) — fully dynamic.
    /// The first 5 Normal field values are concatenated as the record summary.
    /// </summary>
    trigger OnAfterGetRecord()
    var
        FieldRef: FieldRef;
        Summary: Text;
        FldIdx: Integer;
        FieldsShown: Integer;
    begin
        gRecordSummary := '';
        if (SelectedTableId = 0) or (gNormalFieldCount = 0) then
            exit;
        if not SeekSourceRecord(Rec.Number) then
            exit;

        // Build a summary of the first 5 Normal field values, separated by ' | '
        Summary := '';
        FldIdx := 1;
        FieldsShown := 0;
        while (FldIdx <= gNormalFieldCount) and (FieldsShown < 5) do begin
            FieldRef := gSrcRecRef.Field(gNormalFieldIds[FldIdx]);
            if FieldsShown > 0 then
                Summary += ' | ';
            Summary += Format(FieldRef.Value);
            FieldsShown += 1;
            FldIdx += 1;
        end;
        gRecordSummary := CopyStr(Summary, 1, MaxStrLen(gRecordSummary));
    end;

    trigger OnClosePage()
    begin
        if gSrcRecRef.IsOpen then
            gSrcRecRef.Close();
    end;

    var
        DynPageMgt: Codeunit "Dynamic Page Mgt.";
        SelectedTableId: Integer;
        SelectedTableName: Text[100];
        gSrcRecRef: RecordRef;
        gSrcCurrentRow: Integer;
        gNormalFieldIds: array[200] of Integer;
        gNormalFieldCount: Integer;
        gRecordSummary: Text[2048];

    local procedure RefreshFilter()
    var
        RecCount: Integer;
    begin
        if SelectedTableId = 0 then
            exit;

        // Reset source RecordRef so OnAfterGetRecord re-opens it cleanly
        if gSrcRecRef.IsOpen then
            gSrcRecRef.Close();
        gSrcCurrentRow := 0;

        // Enumerate all Normal fields of the selected table via RecordRef/FieldRef
        DynPageMgt.BuildNormalFieldIds(SelectedTableId, gNormalFieldIds, gNormalFieldCount);

        // Filter Integer source to exactly RecCount rows: one per source record
        RecCount := DynPageMgt.GetTableRecordCount(SelectedTableId);
        if RecCount > 0 then
            Rec.SetRange(Number, 1, RecCount)
        else
            Rec.SetRange(Number, 0, 0);

        CurrPage.Update(false);
    end;

    local procedure UpdateTableName()
    begin
        if SelectedTableId <> 0 then
            SelectedTableName := CopyStr(DynPageMgt.GetTableName(SelectedTableId), 1, MaxStrLen(SelectedTableName))
        else
            SelectedTableName := '';
    end;

    /// <summary>
    /// Navigates the global source RecordRef to the record at position RowNum.
    /// Sequential access (RowNum = gSrcCurrentRow + 1) uses a single Next() call.
    /// Random access rewinds with FindSet() then skips with Next(RowNum - 1).
    /// Returns false if the record cannot be reached (e.g. table is empty).
    /// </summary>
    local procedure SeekSourceRecord(RowNum: Integer): Boolean
    begin
        if not gSrcRecRef.IsOpen then begin
            gSrcRecRef.Open(SelectedTableId);
            if not gSrcRecRef.FindSet() then begin
                gSrcRecRef.Close();
                exit(false);
            end;
            gSrcCurrentRow := 1;
        end else
            if RowNum = 1 then begin
                if not gSrcRecRef.FindSet() then
                    exit(false);
                gSrcCurrentRow := 1;
            end else
                if RowNum = gSrcCurrentRow + 1 then begin
                    if gSrcRecRef.Next() = 0 then
                        exit(false);
                    gSrcCurrentRow := RowNum;
                end else begin
                    // Random access: rewind and skip to target row
                    if not gSrcRecRef.FindSet() then
                        exit(false);
                    if RowNum > 1 then
                        gSrcRecRef.Next(RowNum - 1);
                    gSrcCurrentRow := RowNum;
                end;
        exit(true);
    end;
}
