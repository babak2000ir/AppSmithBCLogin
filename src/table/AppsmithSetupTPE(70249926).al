table 70249926 "Appsmith Setup TPE"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Appsmith Application User"; Guid)
        {
            DataClassification = ToBeClassified;
            TableRelation = User."User Security ID" where("License Type" = const(Application));
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