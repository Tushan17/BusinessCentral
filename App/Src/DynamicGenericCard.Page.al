page 50006 "Dynamic Generic Card"
{
    Caption = 'Dynamic Generic Card';
    PageType = Card;
    SourceTable = "Dynamic Record Buffer";
    SourceTableTemporary = false;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(TableInfo)
            {
                Caption = 'Table Information';
                field(TableIdCtrl; Rec."Table ID")
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
                    if Rec."Table ID" = 0 then
                        exit;
                    FieldConfig.SetRange("Table ID", Rec."Table ID");
                    FieldConfigPage.SetTableView(FieldConfig);
                    FieldConfigPage.RunModal();
                    UpdateColumnConfig(Rec."Table ID");
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateColumnConfig(Rec."Table ID");
        gTableName := CopyStr(DynPageMgt.GetTableName(Rec."Table ID"), 1, MaxStrLen(gTableName));
    end;

    var
        DynPageMgt: Codeunit "Dynamic Page Mgt.";
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

    local procedure UpdateColumnConfig(TableId: Integer)
    begin
        Col1CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(TableId, 1), 1, MaxStrLen(Col1CaptionClass));
        Col2CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(TableId, 2), 1, MaxStrLen(Col2CaptionClass));
        Col3CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(TableId, 3), 1, MaxStrLen(Col3CaptionClass));
        Col4CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(TableId, 4), 1, MaxStrLen(Col4CaptionClass));
        Col5CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(TableId, 5), 1, MaxStrLen(Col5CaptionClass));
        Col6CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(TableId, 6), 1, MaxStrLen(Col6CaptionClass));
        Col7CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(TableId, 7), 1, MaxStrLen(Col7CaptionClass));
        Col8CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(TableId, 8), 1, MaxStrLen(Col8CaptionClass));
        Col9CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(TableId, 9), 1, MaxStrLen(Col9CaptionClass));
        Col10CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(TableId, 10), 1, MaxStrLen(Col10CaptionClass));

        Col1Visible := DynPageMgt.IsColumnVisible(TableId, 1);
        Col2Visible := DynPageMgt.IsColumnVisible(TableId, 2);
        Col3Visible := DynPageMgt.IsColumnVisible(TableId, 3);
        Col4Visible := DynPageMgt.IsColumnVisible(TableId, 4);
        Col5Visible := DynPageMgt.IsColumnVisible(TableId, 5);
        Col6Visible := DynPageMgt.IsColumnVisible(TableId, 6);
        Col7Visible := DynPageMgt.IsColumnVisible(TableId, 7);
        Col8Visible := DynPageMgt.IsColumnVisible(TableId, 8);
        Col9Visible := DynPageMgt.IsColumnVisible(TableId, 9);
        Col10Visible := DynPageMgt.IsColumnVisible(TableId, 10);

        Col1Style := CopyStr(DynPageMgt.GetColumnStyle(TableId, 1), 1, MaxStrLen(Col1Style));
        Col2Style := CopyStr(DynPageMgt.GetColumnStyle(TableId, 2), 1, MaxStrLen(Col2Style));
        Col3Style := CopyStr(DynPageMgt.GetColumnStyle(TableId, 3), 1, MaxStrLen(Col3Style));
        Col4Style := CopyStr(DynPageMgt.GetColumnStyle(TableId, 4), 1, MaxStrLen(Col4Style));
        Col5Style := CopyStr(DynPageMgt.GetColumnStyle(TableId, 5), 1, MaxStrLen(Col5Style));
        Col6Style := CopyStr(DynPageMgt.GetColumnStyle(TableId, 6), 1, MaxStrLen(Col6Style));
        Col7Style := CopyStr(DynPageMgt.GetColumnStyle(TableId, 7), 1, MaxStrLen(Col7Style));
        Col8Style := CopyStr(DynPageMgt.GetColumnStyle(TableId, 8), 1, MaxStrLen(Col8Style));
        Col9Style := CopyStr(DynPageMgt.GetColumnStyle(TableId, 9), 1, MaxStrLen(Col9Style));
        Col10Style := CopyStr(DynPageMgt.GetColumnStyle(TableId, 10), 1, MaxStrLen(Col10Style));
    end;
}
