codeunit 50001 "Dynamic Page Mgt."
{
    /// <summary>
    /// Loads all records from the given table into the buffer using RecordRef and FieldRef.
    /// Works for both temporary (SourceTableTemporary = true) and permanent buffer records.
    /// Only fields marked Visible = true in Dynamic Field Config are loaded, up to 10 columns.
    /// </summary>
    procedure LoadTableIntoBuffer(TableId: Integer; var DynBuffer: Record "Dynamic Record Buffer")
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldConfigs: array[10] of Record "Dynamic Field Config";
        ConfigCount: Integer;
        EntryNo: Integer;
        ConfigIdx: Integer;
    begin
        CollectVisibleFieldConfigs(TableId, FieldConfigs, ConfigCount);
        if ConfigCount = 0 then
            exit;

        // Determine next EntryNo (preserves uniqueness when mixing multiple tables in same buffer)
        DynBuffer.Reset();
        if DynBuffer.FindLast() then
            EntryNo := DynBuffer."Entry No."
        else
            EntryNo := 0;

        // Open source table and iterate with RecordRef
        RecRef.Open(TableId);
        if RecRef.FindSet() then
            repeat
                EntryNo += 1;
                DynBuffer.Init();
                DynBuffer."Entry No." := EntryNo;
                DynBuffer."Table ID" := TableId;
                DynBuffer."Record Key" := CopyStr(RecRef.GetPosition(true), 1, MaxStrLen(DynBuffer."Record Key"));

                // Populate buffer columns from FieldRef values
                for ConfigIdx := 1 to ConfigCount do begin
                    FieldRef := RecRef.Field(FieldConfigs[ConfigIdx]."Field ID");
                    SetBufferFieldValue(DynBuffer, ConfigIdx, Format(FieldRef.Value));
                end;

                DynBuffer.Insert();
            until RecRef.Next() = 0;
        RecRef.Close();
    end;

    /// <summary>
    /// Loads a single record (identified by RecordKey) from the given table into the buffer.
    /// </summary>
    procedure LoadSingleRecordIntoBuffer(TableId: Integer; RecordKey: Text; var DynBuffer: Record "Dynamic Record Buffer")
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldConfigs: array[10] of Record "Dynamic Field Config";
        ConfigCount: Integer;
        EntryNo: Integer;
        ConfigIdx: Integer;
    begin
        CollectVisibleFieldConfigs(TableId, FieldConfigs, ConfigCount);
        if ConfigCount = 0 then
            exit;

        RecRef.Open(TableId);
        RecRef.SetPosition(RecordKey);
        if not RecRef.Find('=') then begin
            RecRef.Close();
            exit;
        end;

        DynBuffer.Reset();
        if DynBuffer.FindLast() then
            EntryNo := DynBuffer."Entry No."
        else
            EntryNo := 0;

        EntryNo += 1;
        DynBuffer.Init();
        DynBuffer."Entry No." := EntryNo;
        DynBuffer."Table ID" := TableId;
        DynBuffer."Record Key" := CopyStr(RecordKey, 1, MaxStrLen(DynBuffer."Record Key"));

        for ConfigIdx := 1 to ConfigCount do begin
            FieldRef := RecRef.Field(FieldConfigs[ConfigIdx]."Field ID");
            SetBufferFieldValue(DynBuffer, ConfigIdx, Format(FieldRef.Value));
        end;

        DynBuffer.Insert();
        RecRef.Close();
    end;

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
        // Remove existing config for this table
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
    /// Assigns FieldValue to the buffer column identified by Position (1-10).
    /// Centralises the case statement so both Load procedures share the same logic.
    /// </summary>
    local procedure SetBufferFieldValue(var DynBuffer: Record "Dynamic Record Buffer"; Position: Integer; FieldValue: Text)
    begin
        case Position of
            1:
                DynBuffer.Field1 := CopyStr(FieldValue, 1, MaxStrLen(DynBuffer.Field1));
            2:
                DynBuffer.Field2 := CopyStr(FieldValue, 1, MaxStrLen(DynBuffer.Field2));
            3:
                DynBuffer.Field3 := CopyStr(FieldValue, 1, MaxStrLen(DynBuffer.Field3));
            4:
                DynBuffer.Field4 := CopyStr(FieldValue, 1, MaxStrLen(DynBuffer.Field4));
            5:
                DynBuffer.Field5 := CopyStr(FieldValue, 1, MaxStrLen(DynBuffer.Field5));
            6:
                DynBuffer.Field6 := CopyStr(FieldValue, 1, MaxStrLen(DynBuffer.Field6));
            7:
                DynBuffer.Field7 := CopyStr(FieldValue, 1, MaxStrLen(DynBuffer.Field7));
            8:
                DynBuffer.Field8 := CopyStr(FieldValue, 1, MaxStrLen(DynBuffer.Field8));
            9:
                DynBuffer.Field9 := CopyStr(FieldValue, 1, MaxStrLen(DynBuffer.Field9));
            10:
                DynBuffer.Field10 := CopyStr(FieldValue, 1, MaxStrLen(DynBuffer.Field10));
        end;
    end;

    /// <summary>
    /// Collects up to 10 visible Dynamic Field Config entries for the given table,
    /// ordered by Sequence No. Shared by both Load procedures to avoid query duplication.
    /// </summary>
    local procedure CollectVisibleFieldConfigs(TableId: Integer; var FieldConfigs: array[10] of Record "Dynamic Field Config"; var ConfigCount: Integer)
    var
        FieldConfig: Record "Dynamic Field Config";
    begin
        FieldConfig.Reset();
        FieldConfig.SetRange("Table ID", TableId);
        FieldConfig.SetRange(Visible, true);
        FieldConfig.SetCurrentKey("Table ID", "Sequence No.");
        ConfigCount := 0;
        if FieldConfig.FindSet() then
            repeat
                ConfigCount += 1;
                if ConfigCount <= 10 then
                    FieldConfigs[ConfigCount] := FieldConfig;
            until (FieldConfig.Next() = 0) or (ConfigCount >= 10);
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

