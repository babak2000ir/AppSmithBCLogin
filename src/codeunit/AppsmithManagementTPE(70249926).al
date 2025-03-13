codeunit 70249926 "Appsmith Management TPE"
{
    var
        AppsmithSetup: Record "Appsmith Setup TPE";
        CryptoMgmt: Codeunit "Cryptography Management";
        Base64Convert: Codeunit "Base64 Convert";
        TypeHelper: Codeunit "Type Helper";
        AppsmithSetupLoaded: Boolean;
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        HeaderLbl: Label '{"alg":"HS256","typ": "JWT"}', Locked = true;

    procedure GenerateSaltAndHashPassword(Password: Text; AppsmithUserLogin: Record "Appsmith Login TPE")
    var
        Salt: Text[80];
        SaltLength: Integer;
        Counter: Integer;

        CharacterSetLbl: Label '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!#$%&()*+,-./:;<=>?@[\]^_`{|}~', Locked = true;
        CharacterSet: Text;
    begin
        CharacterSet := CharacterSetLbl;
        // Generate a random salt (16 bytes for example)
        SaltLength := Random(80);
        //Generate a Saltlengh random string
        for Counter := 1 to SaltLength do
            Salt += CharacterSet[Random(StrLen(CharacterSet)) + 1];

        AppsmithUserLogin."Password Salt" := Salt;

        // Hash the password combined with the salt
        AppsmithUserLogin."Password Hash" := CryptoMgmt.GenerateHash(Salt + Password, this.HashAlgorithmType::SHA256).Substring(0, 80);
    end;

    procedure GeneratePasswordHash(Password: Text; Salt: Text[80]): Text
    begin
        exit(this.CryptoMgmt.GenerateHash(Salt + Password, this.HashAlgorithmType::SHA256));
    end;

    procedure GenerateToken(AppsmithLogin: Record "Appsmith Login TPE"): Text
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

    procedure GenerateSignature(Header: Text; Payload: Text): Text
    var
        SecretKey: SecretText;
    begin
        this.GetAppsmithSetup();
        SecretKey := this.AppsmithSetup."Login Secret Key";
        exit(this.UrlSafe(this.CryptoMgmt.GenerateHashAsBase64String(Header + '.' + Payload, SecretKey, this.HashAlgorithmType::SHA256)));
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
        UnauthorizedLbl: Label 'Unauthorized', Locked = true;
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
            Error(UnauthorizedLbl);

        //Check Audience
        JOPayload.Get('aud', JToken);
        if JToken.AsValue().AsText() <> UserSecurityId() then
            Error(UnauthorizedLbl);

        //Check Subject
        JOPayload.Get('sub', JToken);
        lSubject := JToken.AsValue().AsText();
        if Subject <> lSubject then
            Error(UnauthorizedLbl);

        //Check Expiry
        JOPayload.Get('exp', JToken);
        ExpiaryDT := this.TypeHelper.EvaluateUnixTimestamp(JToken.AsValue().AsBigInteger());
        if ExpiaryDT < CurrentDateTime() then
            exit(false);

        exit(true);
    end;

    procedure UrlSafeReverse(Input: Text): Text
    begin
        exit(this.PadUrlSafeBase64String(ConvertStr(Input, '-_', '+/')));
    end;

    local procedure UrlSafe(Input: Text): Text
    begin
        exit(DelChr(ConvertStr(Input, '+/', '-_'), '=', '='));
    end;

    local procedure GetAppsmithSetup()
    begin
        if not this.AppsmithSetupLoaded then begin
            this.AppsmithSetup.Get();
            this.AppsmithSetup.TestField("Login Secret Key");
            this.AppsmithSetupLoaded := true;
        end;
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

    local procedure PadUrlSafeBase64String(Input: Text): Text
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