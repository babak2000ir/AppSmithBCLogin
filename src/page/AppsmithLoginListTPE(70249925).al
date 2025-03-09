namespace TransPerEn.AppSmithBCLogin;

page 70249925 "Appsmith Login List TPE"
{
    Caption = 'Appsmith Login List';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Appsmith Login TPE";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {

                field("Login Source"; Rec."Login Source")
                {
                    ToolTip = 'Specifies the value of the Login Source field.', Comment = '%';
                }
                field("Source No."; Rec."Source No.")
                {
                    ToolTip = 'Specifies the value of the Source No. field.', Comment = '%';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ToolTip = 'Specifies the value of the Email field.', Comment = '%';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetPassword)
            {
                ApplicationArea = All;
                Caption = 'Set Password';
                ToolTip = 'Set the password for the user';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    Message('SetPassword');
                end;
            }
        }
    }
}