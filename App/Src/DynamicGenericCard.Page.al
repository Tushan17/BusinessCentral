page 50006 "Dynamic Generic Card"
{
    Caption = 'Dynamic Generic Card';
    PageType = List;
    SourceTable = Integer;
    SourceTableTemporary = false;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(RecordInfo)
            {
                Caption = 'Source Record';
                field(TableIdCtrl; gTableId)
                {
                    Caption = 'Table ID';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'ID of the source table whose record is being displayed.';
                }
                field(TableNameCtrl; gTableName)
                {
                    Caption = 'Table Name';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Name of the source table, resolved via RecordRef.Caption.';
                }
                field(RowNumCtrl; gRowNum)
                {
                    Caption = 'Row Number';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Position of this record in the source table result set.';
                }
            }
            repeater(Fields)
            {
                field(FieldCaptionCtrl; gFieldCaption)
                {
                    Caption = 'Field';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Field name read from FieldRef.Caption. Adapts automatically to whatever table is displayed — no hardcoded field list.';
                }
                field(FieldValueCtrl; gFieldValue)
                {
                    Caption = 'Value';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Field value for this source record, read via Format(FieldRef.Value). One row per Normal field — the number of rows adapts to the table.';
                }
            }
        }
    }

    /// <summary>
    /// Called by the list page before RunModal.
    ///
    /// Steps:
    /// 1. Calls BuildNormalFieldIds to enumerate all Normal fields of TableId via
    ///    RecordRef.FieldIndex / FieldRef.Class — no hardcoded field numbers.
    ///    Result stored in gNormalFieldIds[1..gNormalFieldCount].
    ///
    /// 2. Opens the source RecordRef and navigates to the RowNum-th record
    ///    using FindSet() + Next(RowNum - 1).
    ///
    /// 3. Filters the Integer source to Number = 1..gNormalFieldCount, so the repeater
    ///    has exactly one row per Normal field — fully dynamic, regardless of table schema.
    /// </summary>
    procedure InitCard(RowNum: Integer; TableId: Integer)
    begin
        gTableId := TableId;
        gRowNum := RowNum;
        gTableName := CopyStr(DynPageMgt.GetTableName(TableId), 1, MaxStrLen(gTableName));

        // Enumerate all Normal fields via RecordRef/FieldRef — no Field1..Field10
        DynPageMgt.BuildNormalFieldIds(gTableId, gNormalFieldIds, gNormalFieldCount);

        // Open source RecordRef and navigate to the selected record
        if gSrcRecRef.IsOpen then
            gSrcRecRef.Close();
        gSrcRecRef.Open(gTableId);
        if gSrcRecRef.FindSet() then
            if RowNum > 1 then
                gSrcRecRef.Next(RowNum - 1);

        // Each Integer row (Number=N) maps to the Nth Normal field of the source record
        if gNormalFieldCount > 0 then
            Rec.SetRange(Number, 1, gNormalFieldCount)
        else
            Rec.SetRange(Number, 0, 0);
    end;

    /// <summary>
    /// OnAfterGetRecord: Rec.Number is the 1-based index of the field to display.
    ///
    /// gNormalFieldIds[Rec.Number] gives the Field Number for that position,
    /// looked up in O(1) via gSrcRecRef.Field(). FieldRef.Caption provides the
    /// field name and Format(FieldRef.Value) provides the field value — both
    /// fully dynamic regardless of which table and record are selected.
    /// </summary>
    trigger OnAfterGetRecord()
    var
        FieldRef: FieldRef;
    begin
        gFieldCaption := '';
        gFieldValue := '';
        if not gSrcRecRef.IsOpen then
            exit;
        if (Rec.Number < 1) or (Rec.Number > gNormalFieldCount) then
            exit;
        FieldRef := gSrcRecRef.Field(gNormalFieldIds[Rec.Number]);
        gFieldCaption := CopyStr(FieldRef.Caption, 1, MaxStrLen(gFieldCaption));
        gFieldValue := CopyStr(Format(FieldRef.Value), 1, MaxStrLen(gFieldValue));
    end;

    trigger OnClosePage()
    begin
        if gSrcRecRef.IsOpen then
            gSrcRecRef.Close();
    end;

    var
        DynPageMgt: Codeunit "Dynamic Page Mgt.";
        gTableId: Integer;
        gRowNum: Integer;
        gTableName: Text[100];
        gSrcRecRef: RecordRef;
        gNormalFieldIds: array[200] of Integer;
        gNormalFieldCount: Integer;
        gFieldCaption: Text[100];
        gFieldValue: Text[250];
}
