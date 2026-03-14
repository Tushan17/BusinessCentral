page 50000 "My Table List"
{
    Caption = 'My Table List';
    PageType = List;
    SourceTable = "My Table";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for this record.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the record.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the record.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity.';
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date the record was created.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewRecord)
            {
                Caption = 'New';
                ApplicationArea = All;
                Image = New;
                ToolTip = 'Create a new record.';

                trigger OnAction()
                begin
                    Rec.Init();
                    Rec.Insert(true);
                end;
            }
            action(ImportXML)
            {
                Caption = 'Import XML';
                ApplicationArea = All;
                Image = ImportExcel;
                ToolTip = 'Import records from an XML file using the Data Exchange Definition (MYTBL-XML).';

                trigger OnAction()
                var
                    MyTableImportMgt: Codeunit "My Table Import Mgt.";
                begin
                    MyTableImportMgt.ImportXMLFile();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
