public virtual without sharing class UVS_CreateSAMCompany_WS {

    //Added 02/16/2015 Virendra I-144303 IssueQA_ For the Existing SAM_Cust_ID Account, the New location in not creating in SAM.
    public static string CallWS (string bsnpId, string companyName, string salesSource, string potentialSalesType, string sicCode, string rideUserId, boolean isForceInsert,
                                List<CreateSAMCompany.DCSAMCompanyContact> companyContact, List<CreateSAMCompany.DCSAMCompanyAddress> companyAddress, List<CreateSAMCompany.DCSAMCompanyPhone> companyPhone, String samCustId) {

        system.debug(LoggingLevel.INFO, 'aaaaaaaa inside ws companyAddress:' + companyAddress);

        //Create criteria
        CreateSAMCompany.SAMCompanyCollectionRequestCriteria requestCriteria = new CreateSAMCompany.SAMCompanyCollectionRequestCriteria();
        requestCriteria.BSNP_ID = bsnpId;
        requestCriteria.Name = companyName;
        requestCriteria.SalesSource = salesSource;
        requestCriteria.PotentialSalesType = potentialSalesType;
        requestCriteria.SICCode = sicCode;
        requestCriteria.RIDEUserId = rideUserId;
        requestCriteria.Mode = isForceInsert == true ? 'DUPEOVERRIDE' : '';
        // Hari Krishnan (2014-02-15): I-144303 - Addition of new request parameter CUST_NO
        requestCriteria.CUST_NO = SamCustId;
        
        try
        {
            /*
            requestCriteria.ContactsJson = '[{\'attributes\':{\'type\':\'Contact\',\'url\':\'/services/data/v30.0/sobjects/Contact/a0LJ000000J8K7SMAV\'},\'Location\':\'1000\',\'Name\':\'Bugs Bunny\',\'JobTitle\':\'Wascally Wabbit\',\'AreaCode\':\'305\',\'Exchange\':\'345\',\'LineNumber\':\'6789\',\'Extension\':\'3456\',\'CountryName\':\'UNITED STATES\',\'InternationalNumber\':\'...\',\'FaxAreaCode\':\'786\',\'FaxExchange\':\'456\',\'FaxLineNumber\':\'7890\',\'EmailAddress\':\'a@place.com\'}]';
            requestCriteria.AddressesJson = '[{\'attributes\':{\'type\':\'Address\',\'url\':\'/services/data/v30.0/sobjects/Address/a0LJ000000J8K7SMAV\'},\'Type\':\'10\',\'Line1\':\'123 My Lane\',\'Line2\':null,\'City\':\'Miami\',\'State\':\'FL\',\'PostalZipCode\':\'33123\',\'PostalZip4Code\':null,\'CountryName\':\'UNITED STATES\',\'Location\':\'1000\',\'ZipNonUS\':null}]';
            requestCriteria.PhonesJson = '[{\'attributes\':{\'type\':\'Phone\',\'url\':\'/services/data/v30.0/sobjects/Phone/a0LJ000000J8K7SMAV\'},\'Type\':\'10\',\'AreaCode\':\'305\',\'Exchange\':\'123\',\'LineNumber\':\'1234\',\'Extension\':null,\'CountryName\':\'UNITED STATES\',\'InternationalNumber\':\'...\',\'Location\':\'1000\'},{\'attributes\':{\'type\':\'Phone\',\'url\':\'/services/data/v30.0/sobjects/Phone/a0LJ000000J8K7SMAV\'},\'Type\':\'20\',\'AreaCode\':\'305\',\'Exchange\':\'234\',\'LineNumber\':\'5678\',\'Extension\':\'2345\',\'CountryName\':\'UNITED STATES\',\'InternationalNumber\':\'...\',\'Location\':\'1000\'}]';
            */

            String ContactsJson = JSON.serialize(companyContact);
            ContactsJson = ContactsJson.replace('""', 'null');
            requestCriteria.ContactsJson = ContactsJson;

            String AddressesJson = JSON.serialize(companyAddress);
            AddressesJson = AddressesJson.replace('Type_x', 'Type');
            AddressesJson = AddressesJson.replace('""', 'null');
            requestCriteria.AddressesJson = AddressesJson;

            String PhonesJson = JSON.serialize(companyPhone);
            PhonesJson = PhonesJson.replace('Type_x', 'Type');
            PhonesJson = PhonesJson.replace('""', 'null');
            requestCriteria.PhonesJson = PhonesJson;

            system.debug(LoggingLevel.INFO, 'aaaaaaaaaaaaaaaaaa ContactsJson:' + ContactsJson);
            system.debug(LoggingLevel.INFO, 'aaaaaaaaaaaaaaaaaa AddressesJson:' + AddressesJson);
            system.debug(LoggingLevel.INFO, 'aaaaaaaaaaaaaaaaaa PhonesJson:' + PhonesJson);

        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.ERROR, 'aaaaaaaaaaaaaaaaaa JSON Results Message: ' + ex.getMessage());
            system.debug(LoggingLevel.ERROR, 'aaaaaaaaaaaaaaaaaa JSON Results Exception: ' + ex.getStackTraceString());
            throw ex;
        }

        // Create soap request
        CreateSAMCompany.CreateSAMCompanySoap createSAMCompanySoap = new CreateSAMCompany.CreateSAMCompanySoap();
        CreateSAMCompany.CRMCredential credential = new CreateSAMCompany.CRMCredential();
        credential.UserName = '';
        credential.Password = '';
        credential.SecurityToken = '';
        createSAMCompanySoap.timeout_x = 120000;//RyderGlobalVariables.WS_TIMEOUT;
        createSAMCompanySoap.endpoint_x = RyderGlobalVariables.RYDER_WS_ENDPOINT + RyderGlobalVariables.CREATE_SAM_COMPANY;

        // Declare opportunity collection
        List<CreateSAMCompany.DCSAMCompanyCollection> lSAMCompanyCollections = null;

        try
        {
            // Make a soap request
            system.debug(LoggingLevel.INFO, 'aaaaaaaaaaaaaaaaaa requestCriteria:' + requestCriteria);

            CreateSAMCompany.DCSAMCompanyCollection sAMCompanyCollection = new CreateSAMCompany.DCSAMCompanyCollection();
            if(!Test.isRunningTest())
            {
                sAMCompanyCollection = createSAMCompanySoap.ProcessRequest(credential, requestCriteria);
                system.debug(LoggingLevel.INFO, 'aaaaaaaaaaaaaaaaaa sAMCompanyCollection:' + sAMCompanyCollection);
            }
            else
            {
                sAMCompanyCollection = null;
            }

            system.debug(LoggingLevel.INFO, 'aaaaaaaaaaaaaaaaaa sAMCompanyCollection.XmlResponse:' + sAMCompanyCollection.XmlResponse);

            return sAMCompanyCollection.XmlResponse;
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.ERROR, 'Error making Soap request for CreateSAMCompany exception: ' + ex.getMessage());
            throw ex;
        }

    }

}