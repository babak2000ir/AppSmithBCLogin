codeunit 70249925 "Appsmith helper API TPE"
{
    var
        AppsmithMgmt: Codeunit "Appsmith Management TPE";

    procedure GetToken(UserEmail: Text; UserPassword: Text; UserSource: Enum "Login Source Type TPE"): Text
    var
        AppsmithLogin: Record "Appsmith Login TPE";
        LoginResponseLbl: Label '{"token":"%1",userId":"%2",userName":"%3"}', Locked = true;
    begin
        AppsmithLogin.Reset();
        AppsmithLogin.SetRange("Login Source", UserSource);
        AppsmithLogin.SetRange("E-Mail", UserEmail);
        AppsmithLogin.SetRange("Password Hash", this.AppsmithMgmt.GeneratePasswordHash(UserPassword, AppsmithLogin."Password Salt"));
        if AppsmithLogin.FindSet() then
            exit(StrSubstNo(LoginResponseLbl, this.AppsmithMgmt.GenerateToken(AppsmithLogin), AppsmithLogin.SystemId, AppsmithLogin.GetName()));
        Error('User not found');
    end;

    procedure VerifyToken(Token: Text; Subject: guid): Boolean
    begin
        exit(this.AppsmithMgmt.VerifyToken(Token, Subject));
    end;
}