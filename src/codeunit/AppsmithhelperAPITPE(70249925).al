codeunit 70249925 "Appsmith helper API TPE"
{
    var
        AppsmithSetup: Record "Appsmith Setup TPE";
        CryptoMgmt: Codeunit "Cryptography Management";
        Base64Convert: Codeunit "Base64 Convert";
        TypeHelper: Codeunit "Type Helper";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        HeaderLbl: Label '{"alg":"HS256","typ": "JWT"}', Locked = true;

    procedure GetToken(UserEmail: Text; UserPassword: Text): Text
    var
        AppsmithLogin: Record "Appsmith Login TPE";
    begin
        this.AppsmithSetup.Get();
        this.AppsmithSetup.TestField("Login Secret Key");

        AppsmithLogin.Reset();
        AppsmithLogin.SetRange("E-Mail", UserEmail);
        AppsmithLogin.SetRange("Password", UserPassword);
        if AppsmithLogin.FindFirst() then
            exit(this.GenerateToken(AppsmithLogin));
        Error('User not found');
    end;

    procedure VerifyToken(Token: Text; Subject: guid): Boolean
    var
        Header: Text;
        Payload: Text;
        TokenSignature: Text;
        CalculatedSignature: Text;
        TokenParts: List of [Text];
        JOPayload: JsonObject;
        JToken: JsonToken;
        ExpiaryDT: DateTime;
        lSubject: guid;
    begin
        TokenParts := Token.Split('.');
        if TokenParts.Count <> 3 then
            exit(false);

        Header := this.Base64Convert.FromBase64(this.UrlSafeReverse(TokenParts.Get(1)));
        if Header <> this.HeaderLbl then
            exit(false);
        Payload := this.Base64Convert.FromBase64(this.UrlSafeReverse(TokenParts.Get(2)));
        TokenSignature := TokenParts.Get(3);
        CalculatedSignature := this.GenerateSignature(TokenParts.Get(1), TokenParts.Get(2));

        if TokenSignature <> CalculatedSignature then
            exit(false);

        //Check Payload
        JOPayload.ReadFrom(Payload);

        //Chec Issuer
        JOPayload.Get('iss', JToken);
        if JToken.AsValue().AsText() <> CompanyProperty.ID() then
            exit(false);

        //Check Audience
        JOPayload.Get('aud', JToken);
        if JToken.AsValue().AsText() <> UserSecurityId() then
            exit(false);

        //Check Expiry
        JOPayload.Get('exp', JToken);
        ExpiaryDT := this.TypeHelper.EvaluateUnixTimestamp(JToken.AsValue().AsBigInteger());
        if ExpiaryDT < CurrentDateTime() then
            exit(false);

        //Return Subject
        JOPayload.Get('sub', JToken);
        lSubject := JToken.AsValue().AsText();
        if Subject <> lSubject then
            exit(false);

        exit(true);
    end;

    local procedure GenerateToken(AppsmithLogin: Record "Appsmith Login TPE"): Text
    var
        Header: Text;
        Payload: Text;
        Signature: Text;
        PayloadTemplateLbl: Label '{"iss":"%1","sub":"%2","aud":"%3","exp":%4}', Locked = true;
    begin
        Header := this.ToBase64UrlSafe(this.HeaderLbl);
        Payload := this.ToBase64UrlSafe(StrSubstNo(PayloadTemplateLbl,
                                            CompanyProperty.ID(),
                                            AppsmithLogin.SystemId,
                                            UserSecurityId(),
                                            this.GetExpiry()));

        Signature := this.GenerateSignature(Header, Payload);

        exit(Header + '.' + Payload + '.' + Signature);
    end;

    local procedure GenerateSignature(Header: Text; Payload: Text): Text
    begin
        exit(this.UrlSafe(this.CryptoMgmt.GenerateHashAsBase64String(Header + '.' + Payload, '@!Samp$leKey*&', this.HashAlgorithmType::SHA256)));
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
        Timestamp := Duration div 1000;

        exit(Timestamp);
    end;

    local procedure ToBase64UrlSafe(Input: Text): Text
    begin
        exit(this.UrlSafe(this.Base64Convert.ToBase64(Input)));
    end;

    local procedure UrlSafe(Input: Text): Text
    begin
        exit(DelChr(ConvertStr(Input, '+/', '-_'), '=', '='));
    end;

    local procedure UrlSafeReverse(Input: Text): Text
    begin
        exit(this.PadUrlSafeBase64String(ConvertStr(Input, '-_', '+/')));
    end;

    procedure PadUrlSafeBase64String(Input: Text): Text
    begin
        case (4 - StrLen(Input) mod 4)
        of
            1:
                Input += '=';
            2:
                Input += '==';
            3:
                Input += '===';
        end;

        exit(Input);
    end;
}