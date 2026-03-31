codeunit 50001 "Dynamic Page Mgt."
{
    /// <summary>
    /// Creates a Dynamic Field Config entry for every Normal field in the given table,
    /// using RecordRef.FieldIndex and FieldRef to enumerate them without hardcoding.
    /// Replaces any existing config for the table.
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
                FieldConfig.Visible := true;
                FieldConfig."Field Type" := CopyStr(Format(FieldRef.Type), 1, MaxStrLen(FieldConfig."Field Type"));
                FieldConfig."Field Class" := CopyStr(Format(FieldRef.Class), 1, MaxStrLen(FieldConfig."Field Class"));
                FieldConfig.Insert();
            end;
        end;
        RecRef.Close();
    end;

    /// <summary>
    /// Enumerates all Normal fields of TableId using RecordRef.FieldIndex and FieldRef.Class,
    /// and populates FieldIds with their Field Numbers in declaration order.
    /// Pages use this once at load time to build gNormalFieldIds, then in OnAfterGetRecord
    /// they do gSrcRecRef.Field(gNormalFieldIds[Rec.Number]) — O(1) per row, no fixed field list.
    /// Supports up to 200 Normal fields per table; fields beyond that are silently ignored.
    /// </summary>
    procedure BuildNormalFieldIds(TableId: Integer; var FieldIds: array[200] of Integer; var FieldCount: Integer)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FldIdx: Integer;
    begin
        FieldCount := 0;
        if TableId = 0 then
            exit;
        RecRef.Open(TableId);
        for FldIdx := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(FldIdx);
            if FieldRef.Class = FieldClass::Normal then begin
                FieldCount += 1;
                if FieldCount <= 200 then
                    FieldIds[FieldCount] := FieldRef.Number;
            end;
        end;
        RecRef.Close();
    end;

    /// <summary>
    /// Returns the total number of records in the given table, read via RecordRef.Count().
    /// List pages use this to set the Integer source filter to Number = 1..RecordCount,
    /// ensuring exactly one repeater row per source record.
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
}
