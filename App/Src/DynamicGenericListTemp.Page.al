page 50003 "Dynamic Generic List (Temp)"
{
    Caption = 'Dynamic Generic List (Temporary)';
    PageType = List;
    SourceTable = Integer;
    SourceTableTemporary = true;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            group(TableSelection)
            {
                ShowCaption = false;
                field(SelectedTableIdCtrl; SelectedTableId)
                {
                    Caption = 'Table ID';
                    ApplicationArea = All;
                    ToolTip = 'Enter the ID of the table to display (e.g. 50001 for Main Table, 50000 for My Table). Press Load Data to populate the list.';
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
                    ToolTip = 'Shows the name of the currently selected table.';
                }
            }
            repeater(Records)
            {
                field(Col1; gField1)
                {
                    ApplicationArea = All;
                    CaptionClass = Col1CaptionClass;
                    Visible = Col1Visible;
                    StyleExpr = Col1Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the first configured field.';
                }
                field(Col2; gField2)
                {
                    ApplicationArea = All;
                    CaptionClass = Col2CaptionClass;
                    Visible = Col2Visible;
                    StyleExpr = Col2Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the second configured field.';
                }
                field(Col3; gField3)
                {
                    ApplicationArea = All;
                    CaptionClass = Col3CaptionClass;
                    Visible = Col3Visible;
                    StyleExpr = Col3Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the third configured field.';
                }
                field(Col4; gField4)
                {
                    ApplicationArea = All;
                    CaptionClass = Col4CaptionClass;
                    Visible = Col4Visible;
                    StyleExpr = Col4Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the fourth configured field.';
                }
                field(Col5; gField5)
                {
                    ApplicationArea = All;
                    CaptionClass = Col5CaptionClass;
                    Visible = Col5Visible;
                    StyleExpr = Col5Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the fifth configured field.';
                }
                field(Col6; gField6)
                {
                    ApplicationArea = All;
                    CaptionClass = Col6CaptionClass;
                    Visible = Col6Visible;
                    StyleExpr = Col6Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the sixth configured field.';
                }
                field(Col7; gField7)
                {
                    ApplicationArea = All;
                    CaptionClass = Col7CaptionClass;
                    Visible = Col7Visible;
                    StyleExpr = Col7Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the seventh configured field.';
                }
                field(Col8; gField8)
                {
                    ApplicationArea = All;
                    CaptionClass = Col8CaptionClass;
                    Visible = Col8Visible;
                    StyleExpr = Col8Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the eighth configured field.';
                }
                field(Col9; gField9)
                {
                    ApplicationArea = All;
                    CaptionClass = Col9CaptionClass;
                    Visible = Col9Visible;
                    StyleExpr = Col9Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the ninth configured field.';
                }
                field(Col10; gField10)
                {
                    ApplicationArea = All;
                    CaptionClass = Col10CaptionClass;
                    Visible = Col10Visible;
                    StyleExpr = Col10Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the tenth configured field.';
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
                ToolTip = 'Load all records from the selected table into the list using RecordRef and FieldRef. Each row in the repeater corresponds to one source record; field values are read dynamically via FieldRef in OnAfterGetRecord.';
                trigger OnAction()
                begin
                    if SelectedTableId = 0 then
                        Error('Please enter a Table ID before loading data.');
                    RefreshData();
                end;
            }
            action(ViewRecord)
            {
                Caption = 'View Record';
                ApplicationArea = All;
                Image = View;
                ToolTip = 'Open the selected record in a card page to see all configured field values read via RecordRef.';
                trigger OnAction()
                var
                    CardPage: Page "Dynamic Generic Card (Temp)";
                begin
                    if Rec.Number = 0 then
                        Error('There is no record selected.');
                    CardPage.InitCard(Rec.Number, SelectedTableId);
                    CardPage.RunModal();
                end;
            }
            action(SetupConfig)
            {
                Caption = 'Auto-Setup Fields';
                ApplicationArea = All;
                Image = Setup;
                ToolTip = 'Automatically enumerate all Normal fields in the selected table via FieldRef and create default configuration entries. Replaces any existing configuration.';
                trigger OnAction()
                begin
                    if SelectedTableId = 0 then
                        Error('Please enter a Table ID first.');
                    DynPageMgt.SetupDefaultConfig(SelectedTableId);
                    Message('Field configuration set up for %1 (%2).', SelectedTableName, SelectedTableId);
                    RefreshData();
                end;
            }
            action(ConfigureFields)
            {
                Caption = 'Configure Fields';
                ApplicationArea = All;
                Image = FieldList;
                ToolTip = 'Open the field configuration page to control which fields are visible, their captions, and style expressions.';
                trigger OnAction()
                var
                    FieldConfig: Record "Dynamic Field Config";
                    FieldConfigPage: Page "Dynamic Field Config";
                begin
                    if SelectedTableId = 0 then
                        Error('Please enter a Table ID first.');
                    FieldConfig.SetRange("Table ID", SelectedTableId);
                    FieldConfigPage.SetTableView(FieldConfig);
                    FieldConfigPage.RunModal();
                    RefreshData();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SelectedTableId := Database::"Main Table";
        UpdateTableName();
        RefreshData();
    end;

    /// <summary>
    /// OnAfterGetRecord fires for every repeater row. Rec.Number (1-based) identifies which
    /// source record to read. A persistent global RecordRef is kept open across rows for
    /// efficient sequential navigation; random access is handled by seeking from the start.
    /// </summary>
    trigger OnAfterGetRecord()
    var
        FieldRef: FieldRef;
        ConfigIdx: Integer;
    begin
        ClearFieldValues();
        if (SelectedTableId = 0) or (gConfigCount = 0) then
            exit;

        // Navigate gSrcRecRef to the correct source record for this row
        if not gSrcRecRef.IsOpen then begin
            gSrcRecRef.Open(SelectedTableId);
            if not gSrcRecRef.FindSet() then begin
                gSrcRecRef.Close();
                exit;
            end;
            gSrcCurrentRow := 1;
        end else
            if Rec.Number = 1 then begin
                // Rewind to first record
                if not gSrcRecRef.FindSet() then
                    exit;
                gSrcCurrentRow := 1;
            end else
                if Rec.Number = gSrcCurrentRow + 1 then begin
                    // Sequential next — most common case
                    if gSrcRecRef.Next() = 0 then
                        exit;
                    gSrcCurrentRow := Rec.Number;
                end else begin
                    // Random access — rewind and skip
                    if not gSrcRecRef.FindSet() then
                        exit;
                    if Rec.Number > 1 then
                        gSrcRecRef.Next(Rec.Number - 1);
                    gSrcCurrentRow := Rec.Number;
                end;

        // Read visible field values from the source record via FieldRef
        for ConfigIdx := 1 to gConfigCount do begin
            FieldRef := gSrcRecRef.Field(gVisibleFieldIds[ConfigIdx]);
            SetFieldValue(ConfigIdx, Format(FieldRef.Value));
        end;
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
        gVisibleFieldIds: array[10] of Integer;
        gConfigCount: Integer;
        gField1: Text[250];
        gField2: Text[250];
        gField3: Text[250];
        gField4: Text[250];
        gField5: Text[250];
        gField6: Text[250];
        gField7: Text[250];
        gField8: Text[250];
        gField9: Text[250];
        gField10: Text[250];
        Col1CaptionClass: Text[250];
        Col2CaptionClass: Text[250];
        Col3CaptionClass: Text[250];
        Col4CaptionClass: Text[250];
        Col5CaptionClass: Text[250];
        Col6CaptionClass: Text[250];
        Col7CaptionClass: Text[250];
        Col8CaptionClass: Text[250];
        Col9CaptionClass: Text[250];
        Col10CaptionClass: Text[250];
        Col1Visible: Boolean;
        Col2Visible: Boolean;
        Col3Visible: Boolean;
        Col4Visible: Boolean;
        Col5Visible: Boolean;
        Col6Visible: Boolean;
        Col7Visible: Boolean;
        Col8Visible: Boolean;
        Col9Visible: Boolean;
        Col10Visible: Boolean;
        Col1Style: Text[50];
        Col2Style: Text[50];
        Col3Style: Text[50];
        Col4Style: Text[50];
        Col5Style: Text[50];
        Col6Style: Text[50];
        Col7Style: Text[50];
        Col8Style: Text[50];
        Col9Style: Text[50];
        Col10Style: Text[50];

    local procedure RefreshData()
    var
        FieldConfig: Record "Dynamic Field Config";
        RecCount: Integer;
        RowNum: Integer;
    begin
        if SelectedTableId = 0 then
            exit;

        // Auto-setup config if none exists for this table
        FieldConfig.SetRange("Table ID", SelectedTableId);
        if not FieldConfig.FindFirst() then
            DynPageMgt.SetupDefaultConfig(SelectedTableId);

        // Reset source RecordRef so OnAfterGetRecord re-opens it
        if gSrcRecRef.IsOpen then
            gSrcRecRef.Close();
        gSrcCurrentRow := 0;

        // Load visible field IDs via codeunit
        DynPageMgt.GetVisibleFieldIds(SelectedTableId, gVisibleFieldIds, gConfigCount);
        UpdateColumnConfig();

        // Populate the temporary Integer table with one row per source record (Number=1..N)
        Rec.DeleteAll();
        RecCount := DynPageMgt.GetTableRecordCount(SelectedTableId);
        for RowNum := 1 to RecCount do begin
            Rec.Init();
            Rec.Number := RowNum;
            Rec.Insert();
        end;

        CurrPage.Update(false);
    end;

    local procedure UpdateTableName()
    begin
        if SelectedTableId <> 0 then
            SelectedTableName := CopyStr(DynPageMgt.GetTableName(SelectedTableId), 1, MaxStrLen(SelectedTableName))
        else
            SelectedTableName := '';
    end;

    local procedure UpdateColumnConfig()
    begin
        Col1CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 1), 1, MaxStrLen(Col1CaptionClass));
        Col2CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 2), 1, MaxStrLen(Col2CaptionClass));
        Col3CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 3), 1, MaxStrLen(Col3CaptionClass));
        Col4CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 4), 1, MaxStrLen(Col4CaptionClass));
        Col5CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 5), 1, MaxStrLen(Col5CaptionClass));
        Col6CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 6), 1, MaxStrLen(Col6CaptionClass));
        Col7CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 7), 1, MaxStrLen(Col7CaptionClass));
        Col8CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 8), 1, MaxStrLen(Col8CaptionClass));
        Col9CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 9), 1, MaxStrLen(Col9CaptionClass));
        Col10CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 10), 1, MaxStrLen(Col10CaptionClass));

        Col1Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 1);
        Col2Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 2);
        Col3Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 3);
        Col4Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 4);
        Col5Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 5);
        Col6Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 6);
        Col7Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 7);
        Col8Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 8);
        Col9Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 9);
        Col10Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 10);

        Col1Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 1), 1, MaxStrLen(Col1Style));
        Col2Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 2), 1, MaxStrLen(Col2Style));
        Col3Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 3), 1, MaxStrLen(Col3Style));
        Col4Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 4), 1, MaxStrLen(Col4Style));
        Col5Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 5), 1, MaxStrLen(Col5Style));
        Col6Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 6), 1, MaxStrLen(Col6Style));
        Col7Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 7), 1, MaxStrLen(Col7Style));
        Col8Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 8), 1, MaxStrLen(Col8Style));
        Col9Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 9), 1, MaxStrLen(Col9Style));
        Col10Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 10), 1, MaxStrLen(Col10Style));
    end;

    local procedure ClearFieldValues()
    begin
        gField1 := '';
        gField2 := '';
        gField3 := '';
        gField4 := '';
        gField5 := '';
        gField6 := '';
        gField7 := '';
        gField8 := '';
        gField9 := '';
        gField10 := '';
    end;

    local procedure SetFieldValue(Position: Integer; FieldValue: Text)
    begin
        case Position of
            1:
                gField1 := CopyStr(FieldValue, 1, MaxStrLen(gField1));
            2:
                gField2 := CopyStr(FieldValue, 1, MaxStrLen(gField2));
            3:
                gField3 := CopyStr(FieldValue, 1, MaxStrLen(gField3));
            4:
                gField4 := CopyStr(FieldValue, 1, MaxStrLen(gField4));
            5:
                gField5 := CopyStr(FieldValue, 1, MaxStrLen(gField5));
            6:
                gField6 := CopyStr(FieldValue, 1, MaxStrLen(gField6));
            7:
                gField7 := CopyStr(FieldValue, 1, MaxStrLen(gField7));
            8:
                gField8 := CopyStr(FieldValue, 1, MaxStrLen(gField8));
            9:
                gField9 := CopyStr(FieldValue, 1, MaxStrLen(gField9));
            10:
                gField10 := CopyStr(FieldValue, 1, MaxStrLen(gField10));
        end;
    end;
}
