codeunit 70249925 "Appsmith helper API TPE"
{
    procedure GetToken(UserEmail: Text; UserPassword: Text): Text
    var
        AppsmithLogin: Record "Appsmith Login TPE";
    begin
        AppsmithLogin.Reset();
        AppsmithLogin.SetRange("E-Mail", UserEmail);
        //AppsmithLogin.SetRange("Password", UserPassword);
        if AppsmithLogin.FindFirst() then
            exit(this.GenerateToken(AppsmithLogin));
        Error('User not found');
    end;

    local procedure GenerateToken(AppsmithLogin: Record "Appsmith Login TPE"): Text
    var
        CryptoMgmt: Codeunit "Cryptography Management";
        Base64Convert: Codeunit "Base64 Convert";
        Header: Text;
        Payload: Text;
        Signature: Text;
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        PayloadTemplateLbl: Label '{"iss":"%1","sub":"%2","aud":"%3","exp":%4}', Locked = true;
    begin
        Header := Base64Convert.ToBase64('{"alg":"HS256","typ": "JWT"}');
        Payload := Base64Convert.ToBase64(StrSubstNo(PayloadTemplateLbl,
                                CompanyProperty.ID(),
                                AppsmithLogin.SystemId,
                                '',
                                this.GetExpiry()));

        Signature := CryptoMgmt.GenerateHashAsBase64String(Header + '.' + Payload, HashAlgorithmType::SHA256);

        exit(Header + '.' + Payload + '.' + Signature);
    end;

    local procedure GetExpiry(): BigInteger
    var
        lDateTime: DateTime;
    begin
        lDateTime := CurrentDateTime();
        exit(this.GetTimestamp(CreateDateTime(CalcDate('<+2D>', DT2Date(lDateTime)), DT2Time(lDateTime))));
    end;

    local procedure GetTimestamp(pDateTime: DateTime): BigInteger
    var
        Epoch: DateTime;
        Duration: Duration;
        Timestamp: BigInteger;
    begin
        Epoch := CreateDateTime(19700101D, 0T);

        Duration := pDateTime - Epoch;
        Timestamp := Duration;

        exit(Timestamp);
    end;
}