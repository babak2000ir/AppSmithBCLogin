codeunit 70249925 "Appsmith helper API TPE"
{
    var
        AppsmithMgmt: Codeunit "Appsmith Management TPE";

    procedure GetToken(UserEmail: Text; UserPassword: Text; UserSource: Text): Text
    var
        AppsmithLogin: Record "Appsmith Login TPE";
        UserSourceEnum: Enum "Login Source Type TPE";
        LoginResponseLbl: Label '{"token":"%1",userId":"%2",userName":"%3"}', Locked = true;
    begin
        Evaluate(UserSourceEnum, UserSource);

        AppsmithLogin.Reset();
        AppsmithLogin.SetRange("Login Source", UserSourceEnum);
        AppsmithLogin.SetRange("E-Mail", UserEmail);
        if AppsmithLogin.FindFirst() then
            if AppsmithLogin."Password Hash" = this.AppsmithMgmt.GeneratePasswordHash(UserPassword, AppsmithLogin."Password Salt") then
                exit(StrSubstNo(LoginResponseLbl, this.AppsmithMgmt.GenerateToken(AppsmithLogin), AppsmithLogin.SystemId, AppsmithLogin.GetName()));
        Error('User not found');
    end;

    procedure VerifyToken(Token: Text; Subject: guid): Boolean
    begin
        exit(this.AppsmithMgmt.VerifyToken(Token, Subject));
    end;
}