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
        field(30; "Password Hash"; Text[80])
        {
            Caption = 'Password';
            ExtendedDatatype = Masked;
            DataClassification = SystemMetadata;
        }
        field(31; "Password Salt"; Text[80])
        {
            ExtendedDatatype = Masked;
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure GetName(): Text
    var
        Customer: Record "Customer";
        Vendor: Record "Vendor";
        Contact: Record "Contact";
        Employee: Record "Employee";
    begin
        case "Login Source" of
            "Login Source"::Customer:
                begin
                    Customer.Get("Source No.");
                    exit(Customer."Name");
                end;
            "Login Source"::Vendor:
                begin
                    Vendor.Get("Source No.");
                    exit(Vendor."Name");
                end;
            "Login Source"::Contact:
                begin
                    Contact.Get("Source No.");
                    exit(Contact."Name");
                end;
            "Login Source"::Employee:
                begin
                    Employee.Get("Source No.");
                    exit(Employee.FullName());
                end;
        end;
    end;

}