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

                field("Login Secret Key"; Rec."Login Secret Key")
                {
                    ToolTip = 'Specifies the value of the Login Secret Key field.', Comment = '%';
                    ApplicationArea = All;
                }

                field("Token Validity"; Rec."Token Validity")
                {
                    ToolTip = 'Specifies the value of the Token Validity (Minutes) field.', Comment = '%';
                    ApplicationArea = All;
                }
            }
        }
    }
}