page 50004 "Dynamic Generic Card (Temp)"
{
    Caption = 'Dynamic Generic Card (Temporary)';
    PageType = Card;
    SourceTable = Integer;
    SourceTableTemporary = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(TableInfo)
            {
                Caption = 'Table Information';
                field(TableIdCtrl; gTableId)
                {
                    Caption = 'Table ID';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the ID of the source table whose record is being displayed.';
                }
                field(TableNameCtrl; gTableName)
                {
                    Caption = 'Table Name';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the name of the source table.';
                }
                field(RowNumCtrl; gRowNum)
                {
                    Caption = 'Row Number';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the 1-based position of this record within the source table result set.';
                }
            }
            group(FieldValues)
            {
                Caption = 'Field Values';
                field(Col1; gField1)
                {
                    ApplicationArea = All;
                    CaptionClass = Col1CaptionClass;
                    Visible = Col1Visible;
                    StyleExpr = Col1Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the first configured field, read via FieldRef.';
                }
                field(Col2; gField2)
                {
                    ApplicationArea = All;
                    CaptionClass = Col2CaptionClass;
                    Visible = Col2Visible;
                    StyleExpr = Col2Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the second configured field, read via FieldRef.';
                }
                field(Col3; gField3)
                {
                    ApplicationArea = All;
                    CaptionClass = Col3CaptionClass;
                    Visible = Col3Visible;
                    StyleExpr = Col3Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the third configured field, read via FieldRef.';
                }
                field(Col4; gField4)
                {
                    ApplicationArea = All;
                    CaptionClass = Col4CaptionClass;
                    Visible = Col4Visible;
                    StyleExpr = Col4Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the fourth configured field, read via FieldRef.';
                }
                field(Col5; gField5)
                {
                    ApplicationArea = All;
                    CaptionClass = Col5CaptionClass;
                    Visible = Col5Visible;
                    StyleExpr = Col5Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the fifth configured field, read via FieldRef.';
                }
                field(Col6; gField6)
                {
                    ApplicationArea = All;
                    CaptionClass = Col6CaptionClass;
                    Visible = Col6Visible;
                    StyleExpr = Col6Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the sixth configured field, read via FieldRef.';
                }
                field(Col7; gField7)
                {
                    ApplicationArea = All;
                    CaptionClass = Col7CaptionClass;
                    Visible = Col7Visible;
                    StyleExpr = Col7Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the seventh configured field, read via FieldRef.';
                }
                field(Col8; gField8)
                {
                    ApplicationArea = All;
                    CaptionClass = Col8CaptionClass;
                    Visible = Col8Visible;
                    StyleExpr = Col8Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the eighth configured field, read via FieldRef.';
                }
                field(Col9; gField9)
                {
                    ApplicationArea = All;
                    CaptionClass = Col9CaptionClass;
                    Visible = Col9Visible;
                    StyleExpr = Col9Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the ninth configured field, read via FieldRef.';
                }
                field(Col10; gField10)
                {
                    ApplicationArea = All;
                    CaptionClass = Col10CaptionClass;
                    Visible = Col10Visible;
                    StyleExpr = Col10Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the tenth configured field, read via FieldRef.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ConfigureFields)
            {
                Caption = 'Configure Fields';
                ApplicationArea = All;
                Image = FieldList;
                ToolTip = 'Open the field configuration page to control which fields are visible, their captions, and style expressions.';
                trigger OnAction()
                var
                    FieldConfig: Record "Dynamic Field Config";
                    FieldConfigPage: Page "Dynamic Field Config";
                begin
                    if gTableId = 0 then
                        exit;
                    FieldConfig.SetRange("Table ID", gTableId);
                    FieldConfigPage.SetTableView(FieldConfig);
                    FieldConfigPage.RunModal();
                    UpdateColumnConfig();
                    LoadFieldValues();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    /// <summary>
    /// Called from the list page before RunModal. Stores the source table ID and row number,
    /// inserts a single Integer row (Number=1) so the card has a source record, then reads
    /// the actual field values from the source table via RecordRef and FieldRef.
    /// </summary>
    procedure InitCard(RowNum: Integer; TableId: Integer)
    begin
        gTableId := TableId;
        gRowNum := RowNum;
        gTableName := CopyStr(DynPageMgt.GetTableName(TableId), 1, MaxStrLen(gTableName));
        Rec.Init();
        Rec.Number := 1;
        if Rec.Insert() then;
        UpdateColumnConfig();
        LoadFieldValues();
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
        gVisibleFieldIds: array[10] of Integer;
        gConfigCount: Integer;
        gField1: Text[250];
        gField2: Text[250];
        gField3: Text[250];
        gField4: Text[250];
        gField5: Text[250];
        gField6: Text[250];
        gField7: Text[250];
        gField8: Text[250];
        gField9: Text[250];
        gField10: Text[250];
        Col1CaptionClass: Text[250];
        Col2CaptionClass: Text[250];
        Col3CaptionClass: Text[250];
        Col4CaptionClass: Text[250];
        Col5CaptionClass: Text[250];
        Col6CaptionClass: Text[250];
        Col7CaptionClass: Text[250];
        Col8CaptionClass: Text[250];
        Col9CaptionClass: Text[250];
        Col10CaptionClass: Text[250];
        Col1Visible: Boolean;
        Col2Visible: Boolean;
        Col3Visible: Boolean;
        Col4Visible: Boolean;
        Col5Visible: Boolean;
        Col6Visible: Boolean;
        Col7Visible: Boolean;
        Col8Visible: Boolean;
        Col9Visible: Boolean;
        Col10Visible: Boolean;
        Col1Style: Text[50];
        Col2Style: Text[50];
        Col3Style: Text[50];
        Col4Style: Text[50];
        Col5Style: Text[50];
        Col6Style: Text[50];
        Col7Style: Text[50];
        Col8Style: Text[50];
        Col9Style: Text[50];
        Col10Style: Text[50];

    /// <summary>
    /// Opens the source table via RecordRef, navigates to the gRowNum-th record,
    /// and populates gField1..gField10 with the formatted field values via FieldRef.
    /// </summary>
    local procedure LoadFieldValues()
    var
        FieldRef: FieldRef;
        ConfigIdx: Integer;
    begin
        ClearFieldValues();
        if (gTableId = 0) or (gRowNum = 0) then
            exit;

        DynPageMgt.GetVisibleFieldIds(gTableId, gVisibleFieldIds, gConfigCount);
        if gConfigCount = 0 then
            exit;

        if gSrcRecRef.IsOpen then
            gSrcRecRef.Close();
        gSrcRecRef.Open(gTableId);
        if not gSrcRecRef.FindSet() then begin
            gSrcRecRef.Close();
            exit;
        end;
        if gRowNum > 1 then
            gSrcRecRef.Next(gRowNum - 1);

        for ConfigIdx := 1 to gConfigCount do begin
            FieldRef := gSrcRecRef.Field(gVisibleFieldIds[ConfigIdx]);
            SetFieldValue(ConfigIdx, Format(FieldRef.Value));
        end;
    end;

    local procedure ClearFieldValues()
    begin
        gField1 := '';
        gField2 := '';
        gField3 := '';
        gField4 := '';
        gField5 := '';
        gField6 := '';
        gField7 := '';
        gField8 := '';
        gField9 := '';
        gField10 := '';
    end;

    local procedure SetFieldValue(Position: Integer; FieldValue: Text)
    begin
        case Position of
            1:
                gField1 := CopyStr(FieldValue, 1, MaxStrLen(gField1));
            2:
                gField2 := CopyStr(FieldValue, 1, MaxStrLen(gField2));
            3:
                gField3 := CopyStr(FieldValue, 1, MaxStrLen(gField3));
            4:
                gField4 := CopyStr(FieldValue, 1, MaxStrLen(gField4));
            5:
                gField5 := CopyStr(FieldValue, 1, MaxStrLen(gField5));
            6:
                gField6 := CopyStr(FieldValue, 1, MaxStrLen(gField6));
            7:
                gField7 := CopyStr(FieldValue, 1, MaxStrLen(gField7));
            8:
                gField8 := CopyStr(FieldValue, 1, MaxStrLen(gField8));
            9:
                gField9 := CopyStr(FieldValue, 1, MaxStrLen(gField9));
            10:
                gField10 := CopyStr(FieldValue, 1, MaxStrLen(gField10));
        end;
    end;

    local procedure UpdateColumnConfig()
    begin
        Col1CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(gTableId, 1), 1, MaxStrLen(Col1CaptionClass));
        Col2CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(gTableId, 2), 1, MaxStrLen(Col2CaptionClass));
        Col3CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(gTableId, 3), 1, MaxStrLen(Col3CaptionClass));
        Col4CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(gTableId, 4), 1, MaxStrLen(Col4CaptionClass));
        Col5CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(gTableId, 5), 1, MaxStrLen(Col5CaptionClass));
        Col6CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(gTableId, 6), 1, MaxStrLen(Col6CaptionClass));
        Col7CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(gTableId, 7), 1, MaxStrLen(Col7CaptionClass));
        Col8CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(gTableId, 8), 1, MaxStrLen(Col8CaptionClass));
        Col9CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(gTableId, 9), 1, MaxStrLen(Col9CaptionClass));
        Col10CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(gTableId, 10), 1, MaxStrLen(Col10CaptionClass));

        Col1Visible := DynPageMgt.IsColumnVisible(gTableId, 1);
        Col2Visible := DynPageMgt.IsColumnVisible(gTableId, 2);
        Col3Visible := DynPageMgt.IsColumnVisible(gTableId, 3);
        Col4Visible := DynPageMgt.IsColumnVisible(gTableId, 4);
        Col5Visible := DynPageMgt.IsColumnVisible(gTableId, 5);
        Col6Visible := DynPageMgt.IsColumnVisible(gTableId, 6);
        Col7Visible := DynPageMgt.IsColumnVisible(gTableId, 7);
        Col8Visible := DynPageMgt.IsColumnVisible(gTableId, 8);
        Col9Visible := DynPageMgt.IsColumnVisible(gTableId, 9);
        Col10Visible := DynPageMgt.IsColumnVisible(gTableId, 10);

        Col1Style := CopyStr(DynPageMgt.GetColumnStyle(gTableId, 1), 1, MaxStrLen(Col1Style));
        Col2Style := CopyStr(DynPageMgt.GetColumnStyle(gTableId, 2), 1, MaxStrLen(Col2Style));
        Col3Style := CopyStr(DynPageMgt.GetColumnStyle(gTableId, 3), 1, MaxStrLen(Col3Style));
        Col4Style := CopyStr(DynPageMgt.GetColumnStyle(gTableId, 4), 1, MaxStrLen(Col4Style));
        Col5Style := CopyStr(DynPageMgt.GetColumnStyle(gTableId, 5), 1, MaxStrLen(Col5Style));
        Col6Style := CopyStr(DynPageMgt.GetColumnStyle(gTableId, 6), 1, MaxStrLen(Col6Style));
        Col7Style := CopyStr(DynPageMgt.GetColumnStyle(gTableId, 7), 1, MaxStrLen(Col7Style));
        Col8Style := CopyStr(DynPageMgt.GetColumnStyle(gTableId, 8), 1, MaxStrLen(Col8Style));
        Col9Style := CopyStr(DynPageMgt.GetColumnStyle(gTableId, 9), 1, MaxStrLen(Col9Style));
        Col10Style := CopyStr(DynPageMgt.GetColumnStyle(gTableId, 10), 1, MaxStrLen(Col10Style));
    end;
}
