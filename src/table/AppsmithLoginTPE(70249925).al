table 70249925 "Appsmith Login TPE"
{
    DataClassification = ToBeClassified;
    Caption = 'Appsmith Login';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(10; "Login Source"; Enum "Login Source Type TPE")
        {
            DataClassification = SystemMetadata;
        }
        field(11; "Source No."; Code[20])
        {
            DataClassification = SystemMetadata;
            TableRelation = if ("Login Source" = const(Customer)) Customer."No." else if ("Login Source" = const(Vendor)) Vendor."No." else if ("Login Source" = const(Contact)) Contact."No." else if ("Login Source" = const(Employee)) Employee."No.";
        }
        field(20; "E-Mail"; Text[80])
        {
            Caption = 'Email';
            OptimizeForTextSearch = true;
            ExtendedDatatype = EMail;
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}