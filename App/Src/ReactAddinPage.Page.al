page 50010 "React Addin Page"
{
    Caption = 'React Dashboard';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            // The usercontrol occupies the full page content area.
            // 'ReactAddinControl' is the internal name used in triggers;
            // "React Addin" is the controladdin object name.
            usercontrol(ReactAddinControl; "React Addin")
            {
                ApplicationArea = All;

                // -------------------------------------------------
                // Fired by the React app on first load
                // -------------------------------------------------
                trigger ControlAddInReady()
                begin
                    // Optionally push the first record to the dashboard
                    LoadFirstRecord();
                end;

                // -------------------------------------------------
                // User clicked Save inside React – write back to BC
                // -------------------------------------------------
                trigger OnSaveRecord(RecordJson: Text)
                var
                    mainTable: Record "Main Table";
                    jsonObj: JsonObject;
                    recordNo: Code[20];
                begin
                    if not jsonObj.ReadFrom(RecordJson) then begin
                        Message('Could not parse the record JSON from the dashboard.');
                        exit;
                    end;

                    recordNo := CopyStr(GetJsonText(jsonObj, 'No'), 1, MaxStrLen(mainTable."No."));

                    if mainTable.Get(recordNo) then begin
                        // Record already exists – update it
                        mainTable.Name := CopyStr(GetJsonText(jsonObj, 'Name'), 1, MaxStrLen(mainTable.Name));
                        mainTable.Description := CopyStr(GetJsonText(jsonObj, 'Description'), 1, MaxStrLen(mainTable.Description));
                        Evaluate(mainTable.Amount, GetJsonText(jsonObj, 'Amount'));
                        mainTable.Modify(true);
                        CurrPage.ReactAddinControl.SetStatus('Record updated successfully.');
                    end else begin
                        // New record – insert it
                        mainTable.Init();
                        mainTable."No." := recordNo;
                        mainTable.Name := CopyStr(GetJsonText(jsonObj, 'Name'), 1, MaxStrLen(mainTable.Name));
                        mainTable.Description := CopyStr(GetJsonText(jsonObj, 'Description'), 1, MaxStrLen(mainTable.Description));
                        Evaluate(mainTable.Amount, GetJsonText(jsonObj, 'Amount'));
                        mainTable.Insert(true);
                        CurrPage.ReactAddinControl.SetStatus('Record saved successfully.');
                    end;
                end;

                // -------------------------------------------------
                // User clicked "Open in BC" – open the card page
                // -------------------------------------------------
                trigger OnNavigateToRecord(RecordNo: Text)
                var
                    mainTable: Record "Main Table";
                begin
                    if mainTable.Get(RecordNo) then
                        Page.Run(Page::"Main Table List", mainTable);
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LoadRecord)
            {
                Caption = 'Load Record';
                ApplicationArea = All;
                Image = Refresh;
                ToolTip = 'Load the first Main Table record into the React dashboard.';

                trigger OnAction()
                begin
                    LoadFirstRecord();
                end;
            }
        }
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    local procedure LoadFirstRecord()
    var
        mainTable: Record "Main Table";
        jsonObj: JsonObject;
        jsonText: Text;
    begin
        mainTable.Reset();
        if not mainTable.FindFirst() then begin
            CurrPage.ReactAddinControl.SetStatus('No records found in Main Table.');
            exit;
        end;

        jsonObj.Add('No', mainTable."No.");
        jsonObj.Add('Name', mainTable.Name);
        jsonObj.Add('Description', mainTable.Description);
        jsonObj.Add('Amount', mainTable.Amount);
        jsonObj.Add('EntryDate', Format(mainTable."Entry Date", 0, '<Year4>-<Month,2>-<Day,2>'));

        jsonObj.WriteTo(jsonText);
        CurrPage.ReactAddinControl.LoadRecord(jsonText);
    end;

    local procedure GetJsonText(jsonObj: JsonObject; keyName: Text): Text
    var
        jsonToken: JsonToken;
    begin
        if jsonObj.Get(keyName, jsonToken) then
            exit(jsonToken.AsValue().AsText());
        exit('');
    end;
}
