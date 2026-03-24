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
            group(APIActions)
            {
                Caption = 'API';
                Image = Web;

                // GET (list) ──────────────────────────────────────────────────
                action(APIGetList)
                {
                    Caption = 'Fetch All from API';
                    ApplicationArea = All;
                    Image = RefreshLines;
                    ToolTip = 'Calls GET /api/mytable and upserts every returned record into My Table.';

                    trigger OnAction()
                    var
                        MyTableApiClient: Codeunit "My Table API Client";
                    begin
                        MyTableApiClient.GetList();
                        CurrPage.Update(false);
                    end;
                }

                // GET (single) ────────────────────────────────────────────────
                action(APIGetRecord)
                {
                    Caption = 'Fetch Record from API';
                    ApplicationArea = All;
                    Image = Find;
                    ToolTip = 'Calls GET /api/mytable/{no} and refreshes the selected record from the API.';

                    trigger OnAction()
                    var
                        MyTableApiClient: Codeunit "My Table API Client";
                    begin
                        MyTableApiClient.GetRecord(Rec."No.", Rec);
                        CurrPage.Update(false);
                    end;
                }

                // POST ────────────────────────────────────────────────────────
                action(APICreate)
                {
                    Caption = 'Create via API';
                    ApplicationArea = All;
                    Image = NewDocument;
                    ToolTip = 'Calls POST /api/mytable to create the selected record on the remote API.';

                    trigger OnAction()
                    var
                        MyTableApiClient: Codeunit "My Table API Client";
                    begin
                        MyTableApiClient.CreateRecord(Rec);
                    end;
                }

                // PUT ─────────────────────────────────────────────────────────
                action(APIUpdate)
                {
                    Caption = 'Update via API (PUT)';
                    ApplicationArea = All;
                    Image = Edit;
                    ToolTip = 'Calls PUT /api/mytable/{no} to fully replace the selected record on the remote API.';

                    trigger OnAction()
                    var
                        MyTableApiClient: Codeunit "My Table API Client";
                    begin
                        MyTableApiClient.UpdateRecord(Rec);
                    end;
                }

                // PATCH ───────────────────────────────────────────────────────
                action(APIPatch)
                {
                    Caption = 'Patch Quantity via API';
                    ApplicationArea = All;
                    Image = ChangeStatus;
                    ToolTip = 'Calls PATCH /api/mytable/{no} to update only the Quantity field on the remote API.';

                    trigger OnAction()
                    var
                        MyTableApiClient: Codeunit "My Table API Client";
                        PatchJson: Text;
                        JObject: JsonObject;
                    begin
                        JObject.Add('quantity', Rec.Quantity);
                        JObject.WriteTo(PatchJson);
                        MyTableApiClient.PatchRecord(Rec."No.", PatchJson);
                    end;
                }

                // DELETE ──────────────────────────────────────────────────────
                action(APIDelete)
                {
                    Caption = 'Delete via API';
                    ApplicationArea = All;
                    Image = Delete;
                    ToolTip = 'Calls DELETE /api/mytable/{no} to remove the selected record from the remote API.';

                    trigger OnAction()
                    var
                        MyTableApiClient: Codeunit "My Table API Client";
                    begin
                        MyTableApiClient.DeleteRecord(Rec."No.");
                    end;
                }
            }
        }
    }
}
