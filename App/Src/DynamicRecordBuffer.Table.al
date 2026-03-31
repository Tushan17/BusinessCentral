table 50003 "Dynamic Record Buffer"
{
    Caption = 'Dynamic Record Buffer';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        field(3; "Record Key"; Text[1024])
        {
            Caption = 'Record Key';
        }
        field(4; Field1; Text[2048])
        {
            Caption = 'Field 1';
        }
        field(5; Field2; Text[2048])
        {
            Caption = 'Field 2';
        }
        field(6; Field3; Text[2048])
        {
            Caption = 'Field 3';
        }
        field(7; Field4; Text[2048])
        {
            Caption = 'Field 4';
        }
        field(8; Field5; Text[2048])
        {
            Caption = 'Field 5';
        }
        field(9; Field6; Text[2048])
        {
            Caption = 'Field 6';
        }
        field(10; Field7; Text[2048])
        {
            Caption = 'Field 7';
        }
        field(11; Field8; Text[2048])
        {
            Caption = 'Field 8';
        }
        field(12; Field9; Text[2048])
        {
            Caption = 'Field 9';
        }
        field(13; Field10; Text[2048])
        {
            Caption = 'Field 10';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(TableKey; "Table ID", "Entry No.")
        {
        }
    }
}
