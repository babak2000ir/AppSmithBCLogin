page 70249926 "AppSmith Setup TPE"
{
    PageType = Card;
    Caption = 'AppSmith Setup';
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Appsmith Setup TPE";

    layout
    {
        area(Content)
        {
            group(AppsmithLogin)
            {
                Caption = 'Appsmith Login';
                field("Appsmith Application User"; Rec."Appsmith Application User")
                {
                    ToolTip = 'Specifies the value of the Appsmith Application User field.', Comment = '%';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}