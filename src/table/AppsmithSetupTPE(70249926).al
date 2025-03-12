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