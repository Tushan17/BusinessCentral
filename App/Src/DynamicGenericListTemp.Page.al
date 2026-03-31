page 50003 "Dynamic Generic List (Temp)"
{
    Caption = 'Dynamic Generic List (Temporary)';
    PageType = List;
    SourceTable = "Dynamic Record Buffer";
    SourceTableTemporary = true;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            group(TableSelection)
            {
                ShowCaption = false;
                field(SelectedTableIdCtrl; SelectedTableId)
                {
                    Caption = 'Table ID';
                    ApplicationArea = All;
                    ToolTip = 'Enter the ID of the table to load data from (e.g., 50001 for Main Table, 50000 for My Table).';
                    trigger OnValidate()
                    begin
                        UpdateTableName();
                    end;
                }
                field(SelectedTableNameCtrl; SelectedTableName)
                {
                    Caption = 'Table Name';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Shows the name of the currently selected table.';
                }
            }
            repeater(Records)
            {
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
            action(LoadData)
            {
                Caption = 'Load Data';
                ApplicationArea = All;
                Image = Refresh;
                ToolTip = 'Load all records from the selected table into the list using RecordRef and FieldRef. Any existing data in the temporary buffer is replaced.';
                trigger OnAction()
                begin
                    if SelectedTableId = 0 then
                        Error('Please enter a Table ID before loading data.');
                    RefreshData();
                end;
            }
            action(ViewRecord)
            {
                Caption = 'View Record';
                ApplicationArea = All;
                Image = View;
                ToolTip = 'Open the selected record in a card page to see all configured field values.';
                trigger OnAction()
                var
                    CardPage: Page "Dynamic Generic Card (Temp)";
                begin
                    if Rec."Entry No." = 0 then
                        Error('There is no record selected.');
                    CardPage.InitFromBuffer(Rec, SelectedTableId);
                    CardPage.RunModal();
                end;
            }
            action(SetupConfig)
            {
                Caption = 'Auto-Setup Fields';
                ApplicationArea = All;
                Image = Setup;
                ToolTip = 'Automatically create default field configuration for the selected table by reading all Normal fields via FieldRef. Replaces any existing configuration.';
                trigger OnAction()
                var
                    DynPageMgt: Codeunit "Dynamic Page Mgt.";
                begin
                    if SelectedTableId = 0 then
                        Error('Please enter a Table ID first.');
                    DynPageMgt.SetupDefaultConfig(SelectedTableId);
                    Message('Field configuration set up for %1 (%2).', SelectedTableName, SelectedTableId);
                    RefreshData();
                end;
            }
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
                    if SelectedTableId = 0 then
                        Error('Please enter a Table ID first.');
                    FieldConfig.SetRange("Table ID", SelectedTableId);
                    FieldConfigPage.SetTableView(FieldConfig);
                    FieldConfigPage.RunModal();
                    RefreshData();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Default to Main Table on first open
        SelectedTableId := Database::"Main Table";
        UpdateTableName();
        UpdateColumnConfig();
        RefreshData();
    end;

    var
        DynPageMgt: Codeunit "Dynamic Page Mgt.";
        SelectedTableId: Integer;
        SelectedTableName: Text[100];
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

    local procedure RefreshData()
    var
        FieldConfig: Record "Dynamic Field Config";
    begin
        if SelectedTableId = 0 then
            exit;
        // Auto-setup config on first use for this table
        FieldConfig.SetRange("Table ID", SelectedTableId);
        if not FieldConfig.FindFirst() then
            DynPageMgt.SetupDefaultConfig(SelectedTableId);
        Rec.DeleteAll();
        DynPageMgt.LoadTableIntoBuffer(SelectedTableId, Rec);
        UpdateColumnConfig();
        CurrPage.Update(false);
    end;

    local procedure UpdateTableName()
    begin
        if SelectedTableId <> 0 then
            SelectedTableName := CopyStr(DynPageMgt.GetTableName(SelectedTableId), 1, MaxStrLen(SelectedTableName))
        else
            SelectedTableName := '';
    end;

    local procedure UpdateColumnConfig()
    begin
        Col1CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 1), 1, MaxStrLen(Col1CaptionClass));
        Col2CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 2), 1, MaxStrLen(Col2CaptionClass));
        Col3CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 3), 1, MaxStrLen(Col3CaptionClass));
        Col4CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 4), 1, MaxStrLen(Col4CaptionClass));
        Col5CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 5), 1, MaxStrLen(Col5CaptionClass));
        Col6CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 6), 1, MaxStrLen(Col6CaptionClass));
        Col7CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 7), 1, MaxStrLen(Col7CaptionClass));
        Col8CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 8), 1, MaxStrLen(Col8CaptionClass));
        Col9CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 9), 1, MaxStrLen(Col9CaptionClass));
        Col10CaptionClass := CopyStr(DynPageMgt.GetColumnCaptionClass(SelectedTableId, 10), 1, MaxStrLen(Col10CaptionClass));

        Col1Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 1);
        Col2Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 2);
        Col3Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 3);
        Col4Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 4);
        Col5Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 5);
        Col6Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 6);
        Col7Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 7);
        Col8Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 8);
        Col9Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 9);
        Col10Visible := DynPageMgt.IsColumnVisible(SelectedTableId, 10);

        Col1Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 1), 1, MaxStrLen(Col1Style));
        Col2Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 2), 1, MaxStrLen(Col2Style));
        Col3Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 3), 1, MaxStrLen(Col3Style));
        Col4Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 4), 1, MaxStrLen(Col4Style));
        Col5Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 5), 1, MaxStrLen(Col5Style));
        Col6Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 6), 1, MaxStrLen(Col6Style));
        Col7Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 7), 1, MaxStrLen(Col7Style));
        Col8Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 8), 1, MaxStrLen(Col8Style));
        Col9Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 9), 1, MaxStrLen(Col9Style));
        Col10Style := CopyStr(DynPageMgt.GetColumnStyle(SelectedTableId, 10), 1, MaxStrLen(Col10Style));
    end;
}
