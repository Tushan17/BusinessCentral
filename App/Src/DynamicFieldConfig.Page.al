page 50002 "Dynamic Field Config"
{
    Caption = 'Dynamic Field Configuration';
    PageType = List;
    SourceTable = "Dynamic Field Config";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Fields)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the table this field belongs to.';
                    Editable = false;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the table.';
                    Editable = false;
                }
                field("Field ID"; Rec."Field ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the numeric ID of the field.';
                    Editable = false;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the internal name of the field.';
                    Editable = false;
                }
                field("Default Caption"; Rec."Default Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default caption of the field as defined in the table.';
                    Editable = false;
                }
                field("Field Type"; Rec."Field Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the data type of the field.';
                    Editable = false;
                }
                field("Field Class"; Rec."Field Class")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the field is Normal, FlowField, or FlowFilter.';
                    Editable = false;
                }
                field("Sequence No."; Rec."Sequence No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the display order of this field. Lower numbers appear first. Visible fields are mapped to buffer columns 1-10 in this order.';
                }
                field(Visible; Rec.Visible)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this field is shown on the dynamic page. Up to 10 visible fields are supported.';
                }
                field("Caption Override"; Rec."Caption Override")
                {
                    ApplicationArea = All;
                    ToolTip = 'Overrides the default field caption shown on the dynamic page. Leave empty to use the default caption.';
                }
                field("Style Expression"; Rec."Style Expression")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the style for this column. Valid values: Standard, StandardAccent, Strong, StrongAccent, Attention, AttentionAccent, Favorable, Unfavorable, Ambiguous, Subordinate.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetupDefaultConfig)
            {
                Caption = 'Auto-Setup Fields';
                ApplicationArea = All;
                Image = Setup;
                ToolTip = 'Automatically create field configuration entries for all Normal fields in the selected table using FieldRef. This replaces any existing configuration for that table.';

                trigger OnAction()
                var
                    DynPageMgt: Codeunit "Dynamic Page Mgt.";
                    TableId: Integer;
                begin
                    if Rec."Table ID" = 0 then
                        Error('Please position on a record with a valid Table ID first.');
                    TableId := Rec."Table ID";
                    DynPageMgt.SetupDefaultConfig(TableId);
                    Rec.SetRange("Table ID", TableId);
                    CurrPage.Update(false);
                    Message('Field configuration set up for table %1 (%2).', TableId, DynPageMgt.GetTableName(TableId));
                end;
            }
        }
    }
}
