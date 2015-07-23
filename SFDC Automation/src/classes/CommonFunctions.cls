/**
* 
*   Common functions is a class where it supports other classes with functions that are common among them
*
*   Author           |Author-Email                      |Date       |Comment
*   -----------------|----------------------------------|-----------|--------------------------------------------------
*   Vishal Patel     |vishal@comitydesigns.com          |11.15.2010 |First draft
*
*/
global with sharing class CommonFunctions 
{
    /*public class RyderException extends Exception
    {
    }
    */
    
    // Function to retrieve Accuracy number based on conf cd number provided by Dunn & Bradstreet
    public static Decimal getAccuracyProbability(Integer confCDValue)
    {
        // Initialize variables
        Decimal returnValue = 0;
        List<String> accuracyValues = new List<String>();
        
        // Check if the values are entered in custom settings
        if (RyderGlobalVariables.ACCURACY_MAPPING!= null)
        {
            // Initialize the map
            Map<Decimal, Decimal> keyValueMapping = new Map<Decimal, Decimal>();
            
            // Retrieve the mapping and split the values 
            accuracyValues = RyderGlobalVariables.ACCURACY_MAPPING.Split(',');
            
            // Go through the values and put it in the map
            for(String accuracyValue : accuracyValues)
            {
                // Split the value pair
                String[] accuracyValuePair = accuracyValue.split('=');
                
                // Check if there were indeed 2 values
                if (accuracyValuePair != null && accuracyValuePair.size() == 2)
                {
                    keyValueMapping.put(Decimal.valueOf(accuracyValuePair[0]),Decimal.valueOf(accuracyValuePair[1]));
                }
            }
            
            if (keyValueMapping.containsKey(confCDValue))
                returnValue = keyValueMapping.get(confCDValue);
        }
        return returnValue;
    }
    
    // Retrieve accounts that we need to display for conversion
    public Map<String, String> getAccountsToDisplayFromDandB(Set<String> dunsExistSet, String leadCustomerType, String CompanyName, 
                                                             String state, String country, String street, String city, String zipCode,
                                                             String phone)
    {
        
        Map<String, String> mapDBAccounts = new Map<String, String>();
         
        DBAccount[] dbAccounts = getAccountsFromDandB(CompanyName, state, country, street, city, zipCode, phone);
        
        System.debug('dbAccounts - '+dbAccounts);
        // Check if the accounts are not null
        if (dbAccounts != null)
        {
            // Loop through the accounts and retrieve the conf code info
            for (DBAccount dbAccount : dbAccounts)
            {
                if (!dunsExistSet.contains(dbAccount.DunsNumber + '_' + leadCustomerType))
                {
                    String probabilityValue = '';
                    System.debug('dbAccount.Conf_cd - ' + dbAccount.Conf_cd);
                    System.debug('dbAccount.probabilityOfAccuracy - ' + dbAccount.probabilityOfAccuracy);
                    if (dbAccount.Conf_cd != null && dbAccount.Conf_cd.length()>0)
                        probabilityValue = String.ValueOf(getAccuracyProbability(Integer.valueOf(math.round(Decimal.valueof(dbAccount.Conf_cd)))));
                
                    String companyInfo;

                    // To Do - sort the list in probability of accuracy
                    companyInfo = dbAccount.Company_Name + ' - ' + 
                                    (dbAccount.Address_Line.length()>0?dbAccount.Address_Line:'') + 
                                    (dbAccount.City.length()>0?' '+ dbAccount.City:'') + 
                                    (dbAccount.State.length()>0?' '+ dbAccount.State:'') + 
                                    (dbAccount.ZipCode.length()>0?' '+ dbAccount.ZipCode:'') + 
                                    (probabilityValue.length()>0?' - ('+ probabilityValue +')':'');
                    mapDBAccounts.put(dbAccount.DunsNumber, companyInfo);
                }
            }
        } 
        return mapDBAccounts;
    } 
    
    /*
    *  Sort DBAccount array into sorted list of DBAccount
    */
    /*
    public List<DBAccount> sortDBAccountsByConfidenceLevel(DBAccount[] dbAccounts) {
        System.debug('+++++Number of accounts to sort:' + dbAccounts.size() );
        System.debug('+++++accounts to sort:' + dbAccounts );
        
        List<DBAccount> result = new List<DBAccount>();
        
        Map<Decimal, DBAccount> mapOfDBAccounts = new Map<Decimal, DBAccount>();
        
        // Loop through the accounts and retrieve the conf code info
        Integer i = 0;
        for (DBAccount dbAccount : dbAccounts)
        {
            String probabilityValue = String.valueOf(i);
            System.debug('dbAccount.Conf_cd - ' + dbAccount.Conf_cd);
            System.debug('dbAccount.probabilityOfAccuracy - ' + dbAccount.probabilityOfAccuracy);
            if (dbAccount.Conf_cd != null && dbAccount.Conf_cd.length()>0) {
                probabilityValue = String.ValueOf(dbAccount.ryderProbability);
            }
            mapOfDBAccounts.put(Decimal.valueOf(probabilityValue), dbAccount);
            tempList.add(dbAccount);
            i++;      
        }
        List<Decimal> tempList = new List<Decimal>();
        Set<Decimal> tempSet = mapOfDBAccounts.keySet();
        for (Decimal tempInt: tempSet) {
            tempList.add(tempInt);
        }
        tempList.sort();
        //MPH 1/26/11 - add the elements in reverse order since the sort is ascending only & we want descending
        //for (Decimal tempInt: tempList) {
        for (Integer x = tempList.size();x>0;x--) {
            //result.add(mapOfDBAccounts.get(tempInt));
            result.add(mapOfDBAccounts.get(tempList.get(x-1)));
        }
        System.debug(LoggingLevel.INFO, '++++++++++++++++ sorted DnB Accounts:' + result);
        return result;
    }
    */
/*
    *  Sort DBAccount array into sorted list of DBAccount
    */
    public List<DBAccount> sortDBAccountsByConfidenceLevel(DBAccount[] dbAccounts) {
        System.debug('+++++Number of accounts to sort:' + dbAccounts.size() );
        System.debug('+++++accounts to sort:' + dbAccounts );
        
        List<DBAccount> result = new List<DBAccount>();
        
        // Loop through the accounts and retrieve the conf code info
        Integer iMin = 0;
        DBAccount tmp = null;
        
        for (Integer iPos = 0; iPos < dbAccounts.size() ; iPos++)
        {
            iMin = Ipos;
            for (Integer i = iPos+1; i<dbAccounts.size(); i++){
                if (dbAccounts[i].ryderProbability < dbAccounts[iMin].ryderProbability){
                    iMin = i;
                }
            }
            if (iMin != iPos){
                tmp = dbAccounts[iMin];
                dbAccounts[iMin] = dbAccounts[iPos];
                dbAccounts[iPos] = tmp;
            }
            
            //if (dbAccount.Conf_cd != null && dbAccount.Conf_cd.length()>0) {
              //  probabilityValue = String.ValueOf(dbAccount.ryderProbability);
            //}
        }
        
        for (Integer x = dbAccounts.size();x>0;x--) {
            //result.add(mapOfDBAccounts.get(tempInt));
            result.add(dbAccounts[x-1]);
        }
        return result;
        //return dbAccounts;
    }
    
    // Retrieve accounts that we need to display for conversion
    public List<Account> getSFDCAccountsFromDandB(  String CompanyName, String state, String country, 
                                                    String street, String city, String zipCode,
                                                    String phone)
    {
    
        List<Account> accounts = new List<Account>();   
        DBAccount[] dbAccounts = getAccountsFromDandB(CompanyName, state, country, street, city, zipCode, phone);
        
        
        // Check if the accounts are not null
        if (dbAccounts != null)
        {
            //sort the list by confidence level
            List<DBAccount> dbAccountList = sortDBAccountsByConfidenceLevel(dbAccounts);
            
            for (DBAccount dbAccount : dbAccountList)
            {
                Account account = new Account();
                account.Name = dbAccount.Company_Name;
                account.Site_Duns__c = dbAccount.DunsNumber;
                account.BillingStreet = dbAccount.Address_Line;
                account.BillingCountry = dbAccount.CountryCode;
                account.BillingState = dbAccount.State;
                account.BillingCity = dbAccount.City;
                account.BillingPostalCode = dbAccount.ZipCode;

                account.Legal_Entity_Address_Street__c = dbAccount.Address_Line;
                account.Legal_Entity_Address_Zip_Postal_Code__c = dbAccount.ZipCode;
                account.Legal_Entity_Address_City__c = dbAccount.City;
                account.Legal_Entity_Address_State_Province__c = dbAccount.State;
                account.Legal_Entity_Address_Country__c = dbAccount.CountryCode;

                account.ShippingStreet = dbAccount.Address_Line;
                account.ShippingPostalCode = dbAccount.ZipCode;
                account.ShippingCity = dbAccount.City;
                account.ShippingState = dbAccount.State;
                account.ShippingCountry = dbAccount.CountryCode;
                
                account.ryderProbabilityMatch__c = dbAccount.ryderProbability;
                accounts.add(account);
            }
        }
        return accounts;
        
    }
        
    // Retrieve accounts that we need to display for conversion
    public DBAccount[] getAccountsFromDandB(String CompanyName, String state, String country, String street,  
                                            String city, String zipCode, String phone)
    {
        DnB_WebServiceUtilities dnbWebSerivces = new DnB_WebServiceUtilities();
        
        // Retrieve accounts using D&B account look web service 
        //replace A non-digit: [^0-9] characters from phone number
        if (phone != null) {
          phone = phone.replaceAll('\\D','');
        }
        
        system.debug('+++++dnb call parameters:');
        system.debug('+++++companyname: '+companyname);
        system.debug('+++++state: '+state);
        system.debug('+++++country: '+country);
        system.debug('+++++street: '+street);
        system.debug('+++++city: '+city);
        system.debug('+++++zipCode: '+zipCode);
        system.debug('+++++phone: '+phone);
        
        DBAccount[] dbAccounts = dnbWebSerivces.GetDBAccountLookup(CompanyName, state, country, street, city, zipCode, phone);
        system.debug(LoggingLevel.INFO, '++++++++++++ dbAccounts' + dbAccounts);
        return dbAccounts;      
    } 

    // Get Account by calling Ryder wsdl
    public List<Account> getAccountsOnRyder(String accountName)
    {
        // Instantiate the list of accounts 
        List<Account> dbAccountSearchResults = new List<Account>();
        
        // Create criteria to send request to Ryder WSDL
        GetCompanies.CompanyRequestCriteria requestCriteria = new GetCompanies.CompanyRequestCriteria();
        requestCriteria.Name = accountName;
        requestCriteria.SearchByName = true;
        requestCriteria.LoadChildren = false;
        requestCriteria.SearchById = false;
        requestCriteria.CompanyId = 0;
        getCompanies.GetCompaniesSoap companiesSoap = new getCompanies.GetCompaniesSoap();
        getCompanies.CRMCredential credential = new getCompanies.CRMCredential();
        companiesSoap.endpoint_x = RyderGlobalVariables.RYDER_WS_ENDPOINT + RyderGlobalVariables.GET_COMPANIES;
        //credential.UserName = UserInfo.getUserName();
        //credential.Password = 'passw0rd';
        //credential.SecurityToken = 'x9hJscMUilGopqHFAZETe0Glm';
        
        credential.UserName = '';
        credential.Password = '';
        credential.SecurityToken = '';
        try
        {
            System.debug('requestCriteria - ' + requestCriteria);
            System.debug('credential - ' + credential);
            // Make a soap request
            getCompanies.DCCompanies companyInfo;
            
            if (RyderGlobalVariables.IS_TEST)
            {
                Account dbAccount = new Account();
                dbAccount.Name = RyderGlobalVariables.TEST_PRIMARY_NAME;
                dbAccount.Type = RyderGlobalVariables.TEST_TYPE_PROSPECT;
                dbAccount.LesseeNo__c = RyderGlobalVariables.TEST_LESSEE_NO;
                dbAccount.Site_Duns__c = RyderGlobalVariables.TEST_DUNS_NUMBER;
                dbAccount.DUNS_HQ__c = RyderGlobalVariables.TEST_DUNS_NUMBER;
                dbAccount.Global_Ultimate_DUNS__c = RyderGlobalVariables.TEST_DUNS_NUMBER;
                dbAccount.Industry = RyderGlobalVariables.TEST_INDUSTRY;
                dbAccount.CustomerTypeID__c = RyderGlobalVariables.CustomerType.FMS.name();
                dbAccount.Sic = RyderGlobalVariables.TEST_SIC_CODE;
                dbAccount.CustProspectID__c = RyderGlobalVariables.TEST_CUST_PROSPECT_ID;
                dbAccountSearchResults.add(dbAccount);
            }
            else
            {
                companyInfo = companiesSoap.ProcessRequest(credential, requestCriteria);
                
                if (companyInfo != null && companyInfo.Companies.DCCompany != null)
                {
                    System.debug('companyInfo.IsSuccess - ' + companyInfo.IsSuccess);
                    System.debug('companyInfo - ' + companyInfo);
                    //Check if there was a success
                    if (companyInfo.IsSuccess)
                    {
                    
                        // Go through the company info and set the account information to display
                        // change the dbAccount.Type to new field name
                        for (getCompanies.DCCompany dcCompany : companyInfo.Companies.DCCompany)
                        {
                            Account dbAccount = new Account();
                            dbAccount.Name = dcCompany.CompanyName;
                            
                            // Vishal - need to change this once we receive the right field name for company type
                            dbAccount.Type = dcCompany.CompanyTypeDesc;
                            dbAccount.LesseeNo__c = dcCompany.LesseNum;
                            dbAccount.Site_Duns__c = dcCompany.SiteDuns;
                            dbAccount.DUNS_HQ__c = dcCompany.HQDuns;
                            dbAccount.Global_Ultimate_DUNS__c = dcCompany.UltimateDuns;
                            dbAccount.Industry = dcCompany.IndustryTypeDesc;
                            dbAccount.CustomerTypeID__c = dcCompany.CustomerTypeDesc;
                            dbAccount.Sic = dcCompany.SICCode;
                            if (dcCompany.ID != null && String.valueOf(dcCompany.ID).length()>0)
                                dbAccount.CustProspectID__c = String.valueOf(dcCompany.ID);
                            dbAccountSearchResults.add(dbAccount);
                        }
                    }
                }
            }
        }
        catch(Exception ex)
        {
            throw new RyderException('Error making Soap request with exception: '+ex.getMessage());
        }
        return dbAccountSearchResults;
    }   
    
    // Create Account ON D&B by calling the wsdl
    public Integer createAccountsOnRyder(Account dbAccount, boolean usePhysicalAddess, boolean useShippingAddress)
    {
        System.debug('*****START CommonFunctions.createAccountsOnRyder*****');
        System.debug('*****START CommonFunctions.createAccountsOnRyder***** ' + dbAccount);
        System.debug('*****START CommonFunctions.createAccountsOnRyder***** usePhysicalAddess ' + usePhysicalAddess);
        System.debug('*****START CommonFunctions.createAccountsOnRyder***** useShippingAddress ' + useShippingAddress);
        Integer companyId = -1;
        // Create criteria to send request to Ryder WSDL
        createCompany.CompanyCreateRequest requestCriteria = new createCompany.CompanyCreateRequest();
        requestCriteria.CompanySegment = DBAccount.CO_SEGMENT__c;
        requestCriteria.CompanyName = dbAccount.Name;
        requestCriteria.CompanyType = dbAccount.CompanyTypeID__c;
        requestCriteria.CustomerType = dbAccount.CustomerTypeID__c;
        
        // passed segment code for defect # 63
        requestCriteria.CompanySegment = dbAccount.CO_SEGMENT__c;
        
        // We are passing legal address based on Jose's request, please check with 
        // Dave before changing the address to Shipping or Billing.
        //requestCriteria.LesseNum = dbAccount.LesseeNo__c;
        requestCriteria.SiteDuns = dbAccount.Legal_Site_Duns__c;
        requestCriteria.HQDuns = dbAccount.DUNS_HQ__c;
        requestCriteria.UltimateDuns = dbAccount.Domestic_Ultimate_DUNS__c;
        requestCriteria.SICCode = getSICLookupBySFId(dbAccount.SIC);
        if (usePhysicalAddess == true) {
            if (dbAccount.BillingCountry != null) {
                 requestCriteria.Country = dbAccount.BillingCountry;
            }
            if (dbAccount.BillingState != null) {
                requestCriteria.State = dbAccount.BillingState;
            }
            if (dbAccount.BillingStreet != null) {
                requestCriteria.Address1 = dbAccount.BillingStreet;
            }
            if (dbAccount.BillingCity != null) {
                requestCriteria.City = dbAccount.BillingCity;
            }
            if (dbAccount.BillingPostalCode != null) {
                requestCriteria.Zip = dbAccount.BillingPostalCode;
            }
        } else if (useShippingAddress == true) {
            if (dbAccount.ShippingCountry != null) {
                 requestCriteria.Country = dbAccount.ShippingCountry;
            }
            if (dbAccount.ShippingState != null) {
                requestCriteria.State = dbAccount.ShippingState;
            }
            if (dbAccount.ShippingStreet != null) {
                requestCriteria.Address1 = dbAccount.ShippingStreet;
            }
            if (dbAccount.ShippingCity != null) {
                requestCriteria.City = dbAccount.ShippingCity;
            }
            if (dbAccount.ShippingPostalCode != null) {
                requestCriteria.Zip = dbAccount.ShippingPostalCode;
            }
        } else {
            requestCriteria.Country = dbAccount.Legal_Entity_Address_Country__c;
            requestCriteria.State = dbAccount.Legal_Entity_Address_State_Province__c;
            requestCriteria.Address1 = dbAccount.Legal_Entity_Address_Street__c;
            requestCriteria.City = dbAccount.Legal_Entity_Address_City__c;
            requestCriteria.Zip = dbAccount.Legal_Entity_Address_Zip_Postal_Code__c;
        }
        requestCriteria.Phone = dbAccount.Phone;
        //defect#63 related mapping company segment to pass to radar
        requestCriteria.CompanySegment = dbAccount.CO_SEGMENT__c;
        
        System.debug(LoggingLevel.INFO, 'dbAccount - ' + dbAccount);
        System.debug(LoggingLevel.INFO, 'requestCriteria - ' + requestCriteria);
        
        createCompany.CreateCompanySoap companySoap = new createCompany.CreateCompanySoap();
        companySoap.endpoint_x = RyderGlobalVariables.RYDER_WS_ENDPOINT + RyderGlobalVariables.CREATE_COMPANIES;
        createCompany.CRMCredential credential = new createCompany.CRMCredential();
        //credential.UserName = UserInfo.getUserName();
        //credential.Password = 'passw0rd';
        //credential.SecurityToken = 'x9hJscMUilGopqHFAZETe0Glm';
        
        credential.UserName = '';
        credential.Password = '';
        credential.SecurityToken = '';
        try
        {
            // Make a soap request
            CreateCompany.DCCompanyCreate createCompanyInfo; 
            
            if (RyderGlobalVariables.IS_TEST)
            {
                companyId = RyderGlobalVariables.TEST_COMPANY_ID;
            }
            else
            {
                System.debug('requestCriteria to be sent: ' + requestCriteria);
                createCompanyInfo = companySoap.ProcessRequest(credential, requestCriteria);
                //Check if there was a success
                if (createCompanyInfo != null)
                {
                    companyId = createCompanyInfo.COmpanyId;        
                }
            }
        }
        catch(Exception ex)
        {
            if (!System.test.isRunningTest())
            throw new RyderException('Error making Soap request with exception: '+ex.getMessage());
        }
        System.debug('*****END CommonFunctions.createAccountsOnRyder*****');
        return companyId;
    }   
    
    
    /*
    *   Lookup for SIC Code based on sf id
    */ 
    private String getSICLookupBySFId(String sicCodeSFId) {
        String result = sicCodeSFId;
        List<SIC_Code__c> sicCode = [select id, ext_SICCodeID__c from SIC_Code__c where id =: sicCodeSFId];
        if (sicCode != null && sicCode.size() > 0) {
            result = sicCode[0].ext_SICCodeID__c;
        }
        return result;
    }
    
    
       // Delete Account ON Ryder by calling the wsdl
    @Future(callout=true)
    public static void deleteAccountsOnRyder(String customerProspectId)
    {
        if(customerProspectId!=null)
        {
            System.debug('*****START CommonFunctions.deleteAccountsOnRyder *****');
            System.debug('*****START CommonFunctions.customerProspectId ***** ' + customerProspectId);
            Integer companyId = -1;
            // Create criteria to send request to Ryder WSDL
            DeleteCompany.CompanyDeleteRequest requestCriteria = new DeleteCompany.CompanyDeleteRequest();
            requestCriteria.CustProspectID = customerProspectId;
            
            System.debug(LoggingLevel.INFO, 'requestCriteria - ' + requestCriteria);
            
            DeleteCompany.DeleteCompanySoap companySoap = new DeleteCompany.DeleteCompanySoap();
            companySoap.endpoint_x = RyderGlobalVariables.RYDER_WS_ENDPOINT + RyderGlobalVariables.DELETE_COMPANY;
            DeleteCompany.CRMCredential credential = new DeleteCompany.CRMCredential();
    
            credential.UserName = '';
            credential.Password = '';
            credential.SecurityToken = '';
    
            try
            {
                // Make a soap request
                DeleteCompany.DCCompanyDelete deleteCompanyInfo; 
                System.debug('requestCriteria to be sent: ' + requestCriteria);
                deleteCompanyInfo = companySoap.ProcessRequest(credential, requestCriteria);
            }
            catch(Exception ex)
            {
                if (!System.test.isRunningTest())
                throw new RyderException('Error making Soap request with exception: '+ex.getMessage());
            }
            System.debug('*****END CommonFunctions.deleteAccountsOnRyder*****');
        }
    }
    
    //get RecordType values as list
    public static Map<String, Id> getRecordTypeMap(String sObjType){
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for(RecordType r : [Select r.SobjectType, r.Name, r.DeveloperName, r.IsActive, r.Id From RecordType r where  r.SobjectType=:sObjType AND r.IsActive=true]){
            recordTypeMap.put(r.DeveloperName , r.Id);
        }
        return recordTypeMap;
    }
    
    //get RecordType values as list
    public static Map<String, Id> getRecordType(String sObjType){
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for(RecordType r : [Select r.SobjectType, r.Name, r.IsActive, r.Id From RecordType r where  r.SobjectType=:sObjType AND r.IsActive=true]){
            recordTypeMap.put(r.Name, r.Id);
        }
        return recordTypeMap;
    }
    
    /*
    *   Translate Location info codes from DnB
    Branch
    Headquarters
    Subsidiary
    Distribution Center
    Division
    Manufacturing/Assembly Center
    Other
    Subsidiary Undefined
    Transportation Center
    Warehousing Center
    Rental
    */
    
    public static String translateDnBLocationInfo(String dnbLocationCode) {
        String result = dnbLocationCode;
        if (dnbLocationCode == 'HQ') {
           result = RyderGlobalVariables.HQ_LOCATION;   
        }
        if (dnbLocationCode == 'BR') {
           result = RyderGlobalVariables.BR_LOCATION; 
        }
        if (dnbLocationCode == 'SL') {
           result = RyderGlobalVariables.SL_LOCATION; 
        }
        return result;
    }
    
    /*
    *   Format zip code
    */
    
    public static String formatZipCode (String input) {
        String result = input;
        if (input != null && input.length() == 9) {
            result = input.substring(0,5) + '-' + input.substring(5,9);
        }
        return result;
    }
    
    public static void logError(String errMessage, String errDesc) {
        try{
            Ryder_Error__c errorRecord = new Ryder_Error__c();
            errorRecord.Error_Message__c = errMessage;
            errorRecord.Error_Detail__c = errDesc;
            errorRecord.Logged_In_User_ID__c = userInfo.getUserId();
            Database.insert(errorRecord,false);
        } Catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Error: ' + ex);
        }
    }


//SFDC to SFDC Connection
/* 
    SFDC to SFDC needs to be activated before using this method.
    
    public static Id getConnectionId(String connectionName) {
        List<PartnerNetworkConnection> partnerNetConList =
        [Select id from PartnerNetworkConnection where connectionStatus = 'Accepted' and connectionName = :connectionName];
        if ( partnerNetConList.size() != 0 ) {
            return partnerNetConList.get(0).Id;
        }
        return null;
    }
    public static Id getConnectionOwnerId(String connectionName) {
        List<PartnerNetworkConnection> partnerNetConList =
        [Select createdById from PartnerNetworkConnection where connectionStatus = 'Accepted' and connectionName = :connectionName];
        if ( partnerNetConList.size() != 0 ) {
            return partnerNetConList.get(0).createdById;
        }      
        return null;
    }
    
    
    //Sends SFDC TO SFDC LIST OF Ids
    public static void SendSFDCtoSFDC (string sourceRecordId, string connName){            
        List<PartnerNetworkRecordConnection> sfdcTosfdcConnection =  new  List<PartnerNetworkRecordConnection>();
            
        // Define connection id
        Id networkId = getConnectionId(connName);
        System.debug(' !!!! Network Connection  ' + networkId);
            
        PartnerNetworkRecordConnection newConnection = new PartnerNetworkRecordConnection(
        ConnectionId = networkId,            
        LocalRecordId =  sourceRecordId,
        SendClosedTasks = false,
        SendOpenTasks = false,
        SendEmails = false);       
        //ParentRecordId = newContact.AccountId);
            
        System.debug(' !!!! Network Connection  ' + newConnection);            
        sfdcTosfdcConnections.add(newConnection);
            
        if (leadConnections.size() > 0 ) {
            database.insert(sfdcTosfdcConnections);
        }
    }
    */
    
    
    //**************************************************************************************************
    //***AKK 06/20/2014 - Start - For paraller testing purpose - ReqID 343 Replace DnB with Data.com ***
    //**************************************************************************************************
    // Retrieve accounts that we need to display for conversion
    // This method will fill up the list of accounts bounded to the UI pageblock
    public List<Account> getSFDCAccountsFromDatacom(  String CompanyName, String state, String country, 
                                                    String street, String city, String zipCode,
                                                    String phone)
    {
    
        List<Account> accounts = new List<Account>();   
        DBAccount[] dbAccounts = getAccountsFromDatacom(CompanyName, state, country, street, city, zipCode, phone);
        
        
        // Check if the accounts are not null
        if (dbAccounts != null)
        {
            
            for (DBAccount dbAccount : dbAccounts)
            {
                Account account = new Account();
                account.DCCompanyId__c  = dbAccount.DCCompanyId;
                account.Name = dbAccount.Company_Name;
                account.Site_Duns__c = dbAccount.DunsNumber;
                account.BillingStreet = dbAccount.Address_Line;
                account.BillingCountry = dbAccount.CountryCode;
                account.BillingState = dbAccount.State;
                account.BillingCity = dbAccount.City;
                account.BillingPostalCode = dbAccount.ZipCode;

                account.Legal_Entity_Address_Street__c = dbAccount.Address_Line;
                account.Legal_Entity_Address_Zip_Postal_Code__c = dbAccount.ZipCode;
                account.Legal_Entity_Address_City__c = dbAccount.City;
                account.Legal_Entity_Address_State_Province__c = dbAccount.State;
                account.Legal_Entity_Address_Country__c = dbAccount.CountryCode;

                account.ShippingStreet = dbAccount.Address_Line;
                account.ShippingPostalCode = dbAccount.ZipCode;
                account.ShippingCity = dbAccount.City;
                account.ShippingState = dbAccount.State;
                account.ShippingCountry = dbAccount.CountryCode;
                
                account.ryderProbabilityMatch__c = dbAccount.ryderProbability;
                account.LOC_ID__c = dbAccount.locationType;
                account.AnnualRevenue = dbAccount.AnnualRevenue;
                account.Tradestyle = dbAccount.tradeStyle;                
                accounts.add(account);
            }
        }
        return accounts;
        
    }
        
    // Retrieve accounts from data.com search api that we need to display for conversion
    // This method will populate the result into the intermediary class DBAcount as View Model
    public DBAccount[] getAccountsFromDatacom(String CompanyName, String state, String country, String street,  
                                            String city, String zipCode, String phone)
    {

        //replace A non-digit: [^0-9] characters from phone number
        if (phone != null) {
          phone = phone.replaceAll('\\D','');
        }
        
        system.debug('+++++dnb call parameters:');
        system.debug('+++++companyname: '+companyname);
        system.debug('+++++state: '+state);
        system.debug('+++++country: '+country);
        system.debug('+++++street: '+street);
        system.debug('+++++city: '+city);
        system.debug('+++++zipCode: '+zipCode);
        system.debug('+++++phone: '+phone);
        
        DBAccount[] dbAccounts = RDatacom_SearchAPI.getCompany(CompanyName, state, country, street, city, zipCode, phone);

        system.debug(LoggingLevel.INFO, '++++++++++++ dbAccounts' + dbAccounts);
        return dbAccounts;      
    } 
    //**************************************************************************************************
    //****** AKK 06/20/2014 - End *********
    //**************************************************************************************************

    //**************************************************************************************************
    //***//AAK 12/04/2014 Start - QC630 Change lead conversion process to use DUNSRIGHT API for matching and restore restricted functionality to create account without match ***
    //**************************************************************************************************
    // Retrieve accounts that we need to display for conversion
    // This method will fill up the list of accounts bounded to the UI pageblock
    public List<Account> getSFDCAccountsFromDatacomMatch(  String CompanyName, String state, String country, 
                                                    String street, String city, String zipCode,
                                                    String phone)
    {
    
        List<Account> accounts = new List<Account>();   
        DBAccount[] dbAccounts = getAccountsFromDatacomMatch(CompanyName, state, country, street, city, zipCode, phone);
        
        system.debug('dbaccount : ' + dbAccounts);
        // Check if the accounts are not null
        if (dbAccounts != null)
        {
            
            for (DBAccount dbAccount : dbAccounts)
            {
            	system.debug('Common F dbaccount loop : ' + dbAccount);
                Account account = new Account();
                account.DCCompanyId__c  = dbAccount.DCCompanyId;
                account.Name = dbAccount.Company_Name;
                account.Site_Duns__c = dbAccount.DunsNumber;
                account.BillingStreet = dbAccount.Address_Line;
                account.BillingCountry = dbAccount.CountryCode;
                account.BillingState = dbAccount.State;
                account.BillingCity = dbAccount.City;
                account.BillingPostalCode = dbAccount.ZipCode;

                account.Legal_Entity_Address_Street__c = dbAccount.Address_Line;
                account.Legal_Entity_Address_Zip_Postal_Code__c = dbAccount.ZipCode;
                account.Legal_Entity_Address_City__c = dbAccount.City;
                account.Legal_Entity_Address_State_Province__c = dbAccount.State;
                account.Legal_Entity_Address_Country__c = dbAccount.CountryCode;

                account.ShippingStreet = dbAccount.Address_Line;
                account.ShippingPostalCode = dbAccount.ZipCode;
                account.ShippingCity = dbAccount.City;
                account.ShippingState = dbAccount.State;
                account.ShippingCountry = dbAccount.CountryCode;
                
                account.Match_Confidence__c = dbAccount.matchConfidence;
                account.LOC_ID__c = dbAccount.locationType;
                account.AnnualRevenue = dbAccount.AnnualRevenue;
                account.Match_Grade__c = dbAccount.matchGrade;
                account.Tradestyle = dbAccount.tradeStyle;
                accounts.add(account);
                system.debug('Common F dbaccount loop End : ' + dbAccount);
            }
        }
        system.debug('Common Functions : ' + accounts);
        return accounts;
        
    }    
    
    public DBAccount[] getAccountsFromDatacomMatch(String CompanyName, String state, String country, String street,  
                                            String city, String zipCode, String phone)
    {

        //replace A non-digit: [^0-9] characters from phone number
        if (phone != null) {
          phone = phone.replaceAll('\\D','');
        }
        
        system.debug('+++++dnb call parameters:');
        system.debug('+++++companyname: '+companyname);
        system.debug('+++++state: '+state);
        system.debug('+++++country: '+country);
        system.debug('+++++street: '+street);
        system.debug('+++++city: '+city);
        system.debug('+++++zipCode: '+zipCode);
        system.debug('+++++phone: '+phone);
        
        DBAccount[] dbAccounts = RDatacom_DUNSMatchAPI.getCompany(CompanyName, state, country, street, city, zipCode, phone);

        system.debug(LoggingLevel.INFO, '++++++++++++ dbAccounts' + dbAccounts);
        return dbAccounts;      
    }
    // AAK 12/04/2014 End
    public Account getValidatedFMSParentWithNoProspectID(Account startAccount)
	{
		if(startAccount == null)
		{
			return startAccount;
		}
		
		Account validAccount;
		//First check if this is a correct record type
		if(startAccount.RecordTypeId == getRecordTypeMap('Account').get(RyderGlobalVariables.AccountRecordTypeName.Ryder_FMS_Branch_Account.name()) && startAccount.ParentId != null)
		{
			Account tempParent = [select a.id, a.CustProspectID__c, a.ParentId, a.RecordTypeId, a.CO_SEGMENT__c, a.Name, a.CompanyTypeID__c, a.CustomerTypeID__c, a.Legal_Site_Duns__c, a.DUNS_HQ__c, a.Domestic_Ultimate_DUNS__c, a.SIC, a.BillingCountry, a.BillingState, a.BillingStreet, a.BillingCity, a.BillingPostalCode, a.ShippingCountry, a.ShippingState, a.ShippingStreet, a.ShippingCity, a.ShippingPostalCode, a.Legal_Entity_Address_Country__c, a.Legal_Entity_Address_State_Province__c, a.Legal_Entity_Address_Street__c, a.Legal_Entity_Address_City__c, a.Legal_Entity_Address_Zip_Postal_Code__c, a.Phone from Account a where a.Id =: startAccount.ParentId LIMIT 1];
			validAccount = getValidatedFMSParentWithNoProspectID(tempParent);
		}
		else if (startAccount.RecordTypeId == getRecordTypeMap('Account').get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Parent_Account.name()))
		{
			validAccount = startAccount;
		}
		
        if(validAccount != null && (validAccount.CustProspectID__c == null || validAccount.CustProspectID__c == ''))
        {
			return validAccount;
        }
        return null;
	}
	public Map<String,RecordType> getValidFMSOpportunityRecordTypes()
	{
		Map<String,RecordType> RecordTypeIDList = new Map<String,RecordType>([select Id from RecordType where SobjectType = 'Opportunity' and DeveloperName in ('Child_Opportunity', 'Parent_Opportunity', 'Standard_Opportunity')]);
		return RecordTypeIDList;
	}
    /*
    *   Check if the custProspectId returned from the createCompany already exists in the salesforce
    */
    public Account getAccountByCustProspectId(Integer companyId) {
        Account result = null;
        if (companyId != null) {
            List<Account> tempAccounts = [select a.id, a.Name, a.CustProspectID__c from Account a where a.CustProspectID__c =: String.valueOf(companyId) LIMIT 1];
            if (tempAccounts != null && tempAccounts.size() > 0) {
                result= tempAccounts[0];
            }
        }
        return result;
    }
    
    webservice static Boolean UpdateCustProspect(String AccountId)
    {
    		try
    		{
	    		Account acc = [select a.id, a.CustProspectID__c, a.ParentId, a.RecordTypeId, a.CO_SEGMENT__c, a.Name, a.CompanyTypeID__c, a.CustomerTypeID__c, a.Legal_Site_Duns__c, a.DUNS_HQ__c, a.Domestic_Ultimate_DUNS__c, a.SIC, a.BillingCountry, a.BillingState, a.BillingStreet, a.BillingCity, a.BillingPostalCode, a.ShippingCountry, a.ShippingState, a.ShippingStreet, a.ShippingCity, a.ShippingPostalCode, a.Legal_Entity_Address_Country__c, a.Legal_Entity_Address_State_Province__c, a.Legal_Entity_Address_Street__c, a.Legal_Entity_Address_City__c, a.Legal_Entity_Address_Zip_Postal_Code__c, a.Phone from Account a where Id =: AccountId LIMIT 1];
	    		System.debug('@@@#### Attempting Account' + acc);
	    		if (acc == null)
	    			return false;
	    			
				//Validate the account being used to see if CustProspect__c is synced
				CommonFunctions commonFunction = new CommonFunctions();
				Account syncAccount = commonFunction.getValidatedFMSParentWithNoProspectID(acc);
				System.debug('@@@#### Sync Account' + syncAccount);
				
				if(syncAccount != null)
				{
					Integer companyId = commonFunction.createAccountsOnRyder(syncAccount, false, true);
					System.debug('@@@#### Account synced' + companyId);
					
	        		if (commonFunction.getAccountByCustProspectId(companyId) == null) 
	        		{
	        			syncAccount.CustProspectID__c = String.valueOf(companyId);
	        			update syncAccount;
	        			System.debug('@@@#### Account updated' + syncAccount);
	        			return true;
				    }
				}
				return false;
    		}
    		catch(Exception e)
    		{
    			System.debug('@@@#### Issue with Account' + AccountId);
    			return false;
    		}
    		
    }
    
    @future(callout=true)
    webservice static void UpdateCustProspectFuture(String AccountId)
    {
    	System.debug('@@@#### Attempting Account' + AccountId);
    	CommonFunctions.UpdateCustProspect(AccountId);
    }
    
}