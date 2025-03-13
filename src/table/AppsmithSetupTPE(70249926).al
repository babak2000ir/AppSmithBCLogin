table 70249926 "Appsmith Setup TPE"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Login Secret Key"; Text[16])
        {
            NotBlank = true;
            ExtendedDatatype = Masked;

            trigger OnValidate()
            begin
                if xRec."Login Secret Key" <> '' then
                    if not Confirm('Are you sure you want to change the Login Secret Key?', true) then
                        Error('');
            end;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}