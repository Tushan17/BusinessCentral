table 50002 "Dynamic Field Config"
{
    Caption = 'Dynamic Field Config';
    DataClassification = CustomerContent;
    LookupPageId = "Dynamic Field Config";
    DrillDownPageId = "Dynamic Field Config";

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            NotBlank = true;
        }
        field(2; "Field ID"; Integer)
        {
            Caption = 'Field ID';
            NotBlank = true;
        }
        field(3; "Field Name"; Text[100])
        {
            Caption = 'Field Name';
        }
        field(4; "Table Name"; Text[100])
        {
            Caption = 'Table Name';
        }
        field(5; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            MinValue = 1;
        }
        field(6; Visible; Boolean)
        {
            Caption = 'Visible';
            InitValue = true;
        }
        field(7; "Caption Override"; Text[100])
        {
            Caption = 'Caption Override';
            ToolTip = 'Leave empty to use the default field caption. Enter a custom caption to override it.';
        }
        field(8; "Style Expression"; Text[50])
        {
            Caption = 'Style Expression';
            ToolTip = 'Valid values: Standard, StandardAccent, Strong, StrongAccent, Attention, AttentionAccent, Favorable, Unfavorable, Ambiguous, Subordinate.';
        }
        field(9; "Default Caption"; Text[100])
        {
            Caption = 'Default Caption';
        }
        field(10; "Field Type"; Text[30])
        {
            Caption = 'Field Type';
        }
        field(11; "Field Class"; Text[20])
        {
            Caption = 'Field Class';
        }
    }

    keys
    {
        key(PK; "Table ID", "Field ID")
        {
            Clustered = true;
        }
        key(TableSequence; "Table ID", "Sequence No.")
        {
        }
        key(TableVisible; "Table ID", Visible, "Sequence No.")
        {
        }
    }
}
