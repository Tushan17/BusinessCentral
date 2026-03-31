page 50004 "Dynamic Generic Card (Temp)"
{
    Caption = 'Dynamic Generic Card (Temporary)';
    PageType = Card;
    SourceTable = "Dynamic Record Buffer";
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
                    ToolTip = 'Specifies the ID of the source table.';
                }
                field(TableNameCtrl; gTableName)
                {
                    Caption = 'Table Name';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the name of the source table.';
                }
                field(RecordKeyCtrl; Rec."Record Key")
                {
                    Caption = 'Record Key';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the primary key position of this record in the source table.';
                }
            }
            group(FieldValues)
            {
                Caption = 'Field Values';
                field(Col1; Rec.Field1)
                {
                    ApplicationArea = All;
                    CaptionClass = Col1CaptionClass;
                    Visible = Col1Visible;
                    StyleExpr = Col1Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the first configured field.';
                }
                field(Col2; Rec.Field2)
                {
                    ApplicationArea = All;
                    CaptionClass = Col2CaptionClass;
                    Visible = Col2Visible;
                    StyleExpr = Col2Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the second configured field.';
                }
                field(Col3; Rec.Field3)
                {
                    ApplicationArea = All;
                    CaptionClass = Col3CaptionClass;
                    Visible = Col3Visible;
                    StyleExpr = Col3Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the third configured field.';
                }
                field(Col4; Rec.Field4)
                {
                    ApplicationArea = All;
                    CaptionClass = Col4CaptionClass;
                    Visible = Col4Visible;
                    StyleExpr = Col4Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the fourth configured field.';
                }
                field(Col5; Rec.Field5)
                {
                    ApplicationArea = All;
                    CaptionClass = Col5CaptionClass;
                    Visible = Col5Visible;
                    StyleExpr = Col5Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the fifth configured field.';
                }
                field(Col6; Rec.Field6)
                {
                    ApplicationArea = All;
                    CaptionClass = Col6CaptionClass;
                    Visible = Col6Visible;
                    StyleExpr = Col6Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the sixth configured field.';
                }
                field(Col7; Rec.Field7)
                {
                    ApplicationArea = All;
                    CaptionClass = Col7CaptionClass;
                    Visible = Col7Visible;
                    StyleExpr = Col7Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the seventh configured field.';
                }
                field(Col8; Rec.Field8)
                {
                    ApplicationArea = All;
                    CaptionClass = Col8CaptionClass;
                    Visible = Col8Visible;
                    StyleExpr = Col8Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the eighth configured field.';
                }
                field(Col9; Rec.Field9)
                {
                    ApplicationArea = All;
                    CaptionClass = Col9CaptionClass;
                    Visible = Col9Visible;
                    StyleExpr = Col9Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the ninth configured field.';
                }
                field(Col10; Rec.Field10)
                {
                    ApplicationArea = All;
                    CaptionClass = Col10CaptionClass;
                    Visible = Col10Visible;
                    StyleExpr = Col10Style;
                    Editable = false;
                    ToolTip = 'Specifies the value of the tenth configured field.';
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
                    CurrPage.Update(false);
                end;
            }
        }
    }

    /// <summary>
    /// Called from Dynamic Generic List (Temp) to initialise this card page with the
    /// selected buffer record and the active table ID. The record is copied into the
    /// page's own temporary source table so it can be displayed.
    /// </summary>
    procedure InitFromBuffer(var SourceBuffer: Record "Dynamic Record Buffer"; TableId: Integer)
    begin
        gTableId := TableId;
        gTableName := CopyStr(DynPageMgt.GetTableName(TableId), 1, MaxStrLen(gTableName));
        Rec := SourceBuffer;
        if Rec.Insert() then;
        UpdateColumnConfig();
    end;

    var
        DynPageMgt: Codeunit "Dynamic Page Mgt.";
        gTableId: Integer;
        gTableName: Text[100];
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
