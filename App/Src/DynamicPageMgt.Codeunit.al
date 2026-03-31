codeunit 50001 "Dynamic Page Mgt."
{
    /// <summary>
    /// Creates a default Dynamic Field Config for every Normal field in the given table.
    /// Uses FieldRef to enumerate fields dynamically.
    /// First 10 Normal fields are set Visible = true; others Visible = false.
    /// </summary>
    procedure SetupDefaultConfig(TableId: Integer)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldConfig: Record "Dynamic Field Config";
        SeqNo: Integer;
        FldIdx: Integer;
    begin
        FieldConfig.Reset();
        FieldConfig.SetRange("Table ID", TableId);
        FieldConfig.DeleteAll();

        RecRef.Open(TableId);
        SeqNo := 0;
        for FldIdx := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(FldIdx);
            if FieldRef.Class = FieldClass::Normal then begin
                SeqNo += 1;
                FieldConfig.Init();
                FieldConfig."Table ID" := TableId;
                FieldConfig."Field ID" := FieldRef.Number;
                FieldConfig."Field Name" := CopyStr(FieldRef.Name, 1, MaxStrLen(FieldConfig."Field Name"));
                FieldConfig."Default Caption" := CopyStr(FieldRef.Caption, 1, MaxStrLen(FieldConfig."Default Caption"));
                FieldConfig."Table Name" := CopyStr(RecRef.Caption, 1, MaxStrLen(FieldConfig."Table Name"));
                FieldConfig."Sequence No." := SeqNo;
                FieldConfig.Visible := SeqNo <= 10;
                FieldConfig."Field Type" := CopyStr(Format(FieldRef.Type), 1, MaxStrLen(FieldConfig."Field Type"));
                FieldConfig."Field Class" := CopyStr(Format(FieldRef.Class), 1, MaxStrLen(FieldConfig."Field Class"));
                FieldConfig.Insert();
            end;
        end;
        RecRef.Close();
    end;

    /// <summary>
    /// Collects the Field IDs of the first 10 visible configured fields for the table,
    /// ordered by Sequence No. Pages use these IDs to read values via FieldRef in OnAfterGetRecord.
    /// </summary>
    procedure GetVisibleFieldIds(TableId: Integer; var FieldIds: array[10] of Integer; var FieldCount: Integer)
    var
        FieldConfig: Record "Dynamic Field Config";
    begin
        FieldCount := 0;
        FieldConfig.Reset();
        FieldConfig.SetRange("Table ID", TableId);
        FieldConfig.SetRange(Visible, true);
        FieldConfig.SetCurrentKey("Table ID", "Sequence No.");
        if FieldConfig.FindSet() then
            repeat
                FieldCount += 1;
                if FieldCount <= 10 then
                    FieldIds[FieldCount] := FieldConfig."Field ID";
            until (FieldConfig.Next() = 0) or (FieldCount >= 10);
    end;

    /// <summary>
    /// Returns the total number of records in the given table by opening it with RecordRef.
    /// Used by pages to know how many Integer rows to generate/filter for the repeater.
    /// </summary>
    procedure GetTableRecordCount(TableId: Integer): Integer
    var
        RecRef: RecordRef;
        RecCount: Integer;
    begin
        if TableId = 0 then
            exit(0);
        RecRef.Open(TableId);
        RecCount := RecRef.Count();
        RecRef.Close();
        exit(RecCount);
    end;

    /// <summary>
    /// Returns the CaptionClass expression for the Nth visible column of the given table.
    /// Using class '1,1,Caption' causes BC to render Caption as the column header.
    /// Returns '' if no config exists for that position.
    /// </summary>
    procedure GetColumnCaptionClass(TableId: Integer; Position: Integer): Text
    var
        FieldConfig: Record "Dynamic Field Config";
        ColCaption: Text[100];
    begin
        if not GetVisibleFieldConfig(TableId, Position, FieldConfig) then
            exit('');
        if FieldConfig."Caption Override" <> '' then
            ColCaption := FieldConfig."Caption Override"
        else
            ColCaption := FieldConfig."Default Caption";
        exit('1,1,' + ColCaption);
    end;

    /// <summary>
    /// Returns the style expression for the Nth visible column of the given table.
    /// </summary>
    procedure GetColumnStyle(TableId: Integer; Position: Integer): Text
    var
        FieldConfig: Record "Dynamic Field Config";
    begin
        if not GetVisibleFieldConfig(TableId, Position, FieldConfig) then
            exit('');
        exit(FieldConfig."Style Expression");
    end;

    /// <summary>
    /// Returns true if the Nth column position has a visible field configured for the table.
    /// </summary>
    procedure IsColumnVisible(TableId: Integer; Position: Integer): Boolean
    var
        FieldConfig: Record "Dynamic Field Config";
    begin
        exit(GetVisibleFieldConfig(TableId, Position, FieldConfig));
    end;

    /// <summary>
    /// Returns the caption/name of a table by opening it with RecordRef.
    /// </summary>
    procedure GetTableName(TableId: Integer): Text
    var
        RecRef: RecordRef;
        TableName: Text;
    begin
        if TableId = 0 then
            exit('');
        RecRef.Open(TableId);
        TableName := RecRef.Caption;
        RecRef.Close();
        exit(TableName);
    end;

    /// <summary>
    /// Internal: finds the Dynamic Field Config record for the Nth visible field (ordered by Sequence No.)
    /// for the given table. Returns true if found.
    /// </summary>
    local procedure GetVisibleFieldConfig(TableId: Integer; Position: Integer; var FoundConfig: Record "Dynamic Field Config"): Boolean
    var
        FieldConfig: Record "Dynamic Field Config";
        Count: Integer;
    begin
        FieldConfig.Reset();
        FieldConfig.SetRange("Table ID", TableId);
        FieldConfig.SetRange(Visible, true);
        FieldConfig.SetCurrentKey("Table ID", "Sequence No.");
        Count := 0;
        if FieldConfig.FindSet() then
            repeat
                Count += 1;
                if Count = Position then begin
                    FoundConfig := FieldConfig;
                    exit(true);
                end;
            until FieldConfig.Next() = 0;
        exit(false);
    end;
}
