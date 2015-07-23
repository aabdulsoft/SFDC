/**
* 
*   insertUpdateCompany trigger class insert/update if the values for the insert/update company has 
*   changed and notifies and updates accounts using webservice
*
*   Author           |Author-Email                      |Date       |Comment
*   -----------------|----------------------------------|-----------|--------------------------------------------------
*   Vishal Patel     |vishal@comitydesigns.com          |11.24.2010 |First draft
*
*/
public with sharing class insertUpdateCompany 
{

    // Insert the companies using future method
    @Future(callout=true)
    public static void insertCompanyOnRyder_future(Set<String> dunsNumbers, Map<String, String> mapParentDuns, String accountId)
    {
        insertCompanyOnRyder(dunsNumbers, mapParentDuns, accountId);        
    }

    // Insert the company on ryder and update the accounts
    public static void insertCompanyOnRyder(Set<String> dunsNumbers, Map<String, String> mapParentDuns, String accountId)
    {
        
        Account account = new Account();
        // Map the accounts 
        Map<String, Account> accounts = new Map<String, Account>();
        // Get the accounts to process 
        Account[] processAccounts = [SELECT a.addr_verified_date__c, a.Website, a.Type, a.Top10Account__c,a.Site_Duns__c, a.ShippingStreet, a.ShippingState, 
                            a.ShippingPostalCode, a.ShippingCountry, a.ShippingCity, a.STATUS_ACTIVE__c, a.Ryder_Specific_Loc_Type__c, a.RecordTypeId, a.Phone_2__c, 
                            a.Phone, a.ParentId, a.PO_NUMBER__c, a.OwnerId, a.NumberOfEmployees, a.Name, a.NATL_RNTL_CUST_ID__c, a.MasterRecordId, a.LesseeNo__c, 
                            a.Legal_Entity_Address_Zip_Postal_Code__c, a.Legal_Entity_Address_Street__c, a.Legal_Entity_Address_State_Province__c, a.Legal_Entity_Address_Country__c, 
                            a.Legal_Entity_Address_City__c, a.LastActivityDate, a.LOC_ID__c, a.Industry, a.Id, a.Global_Ultimate_DUNS__c, a.FormerCustomer__c, a.Fax, 
                            a.Domestic_Ultimate_DUNS__c, a.Description, a.DUNS_HQ__c, a.DB_Loc_Type__c, a.CustomerTypeID__c, a.CustProspectID__c, a.CurrencyIsoCode, 
                            a.Central_Decisionmaking__c, a.CUST_REPAIR_LIMIT__c, a.CO_SEGMENT__c, a.CO_RYDER_ANNSRY__c, a.CO_OWNER_ID__c, a.CO_ANNSRY__c, a.BillingStreet, 
                            a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity, a.BUSINESS_STATUS__c, a.BAD_ADDR_REASON__c, a.BAD_ADDR_DATE__c, 
                            a.BAD_ADDR_CD__c, a.BAD_ADDRESS_BIT__c, a.AnnualRevenue, a.Alias_Name__c, a.ADDR_ID__c, RecordType.Name, a.SIC,
                            a.CompanyTypeID__c, a.Legal_Site_Duns__c, a.Equifax_No__c, a.Legal_Equifax_No__c, a.Equifax_Street1__c, a.Equifax_Street2__c, a.Equifax_City__c, 
                            a.Equifax_State__c, a.Equifax_Country__c, a.Equifax_Zip_Postal_Code__c, a.Equifax_Phone__c, a.Equifax_Fax__c, a.Equifax_Email__c, a.Equifax_Company_Name__c
                            FROM Account a WHERE a.Site_Duns__c IN: dunsNumbers];
                            
        // Loop through the accounts and call out create company                            
        for (Account acct : processAccounts)
        {
            accounts.put(acct.Site_Duns__c, acct);
            if (acct.Id == accountId)
                account = acct;
        }
        //System.debug('Accounts - '+accounts);
        // Call the common function to create the account on ryder for the primary HQ for the branch
        CommonFunctions commonFunctions = new CommonFunctions();
        boolean usePhysicalAddr = false;
        if (account.id != null) {
            usePhysicalAddr = true;
        }
        Integer companyId = commonFunctions.createAccountsOnRyder(account, usePhysicalAddr, false);
        System.debug('companyId - ' + companyId);
            
        // Check if the record was created on Ryder
        if (companyId != -1)
        {
            System.debug('Accounts to update - '+accounts);

            // Set the parent id for the child and ryder id for the parent
            List<Account> acctsToUpdate = new List<Account>();
            for(Account newAcct : processAccounts)
            {
                System.debug('newAcct - '+newAcct);
                            
                // Check if the site duns and hq duns is the same and presume it is headquarters
                if (newAcct.Site_Duns__c == newAcct.DUNS_HQ__c)
                {
                    if (newAcct.CustProspectID__c != String.valueOf(companyId))
                    {
                        newAcct.CustProspectID__c = String.valueOf(companyId);
                        acctsToUpdate.add(newAcct);
                    }
                }
                else
                {
                    // Check if the parent exist for the child duns
                    if (mapParentDuns.containsKey(newAcct.DUNS_HQ__c))
                    {
                        // Get the parent account and save it in the child record
                        if (accounts.containsKey(mapParentDuns.get(newAcct.DUNS_HQ__c)))
                        {
                            newAcct.ParentId = accounts.get(mapParentDuns.get(newAcct.DUNS_HQ__c)).Id;
                            acctsToUpdate.add(newAcct);
                        }
                    }
                }
            }    
            // Update the account 
            if (acctsToUpdate.size()>0)
            {
                RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
                update acctsToUpdate;
            }
        }
    }

    // Update the companies using future method
    @Future(callout=true)
    public static void updateCompanyOnRyder_future(Set<Id> accountIds)
    {
        updateCompanyOnRyder(accountIds);       
    }
    
    // Update Companies
    public static void updateCompanyOnRyder(Set<Id> accountIds)
    {
        // Accounts that we need to update
        Account[] accounts = [SELECT Name, Type, LesseeNo__c, Industry, Site_Duns__c, Legal_Site_Duns__c, DUNS_HQ__c, Domestic_Ultimate_DUNS__c, 
                              Global_Ultimate_DUNS__c, NATL_RNTL_CUST_ID__c, LastModifiedBy.Name, Equifax_No__c, Legal_Equifax_No__c, Equifax_Street1__c, Equifax_Street2__c, Equifax_City__c, Equifax_State__c, Equifax_Country__c, 
        					  Equifax_Zip_Postal_Code__c, Equifax_Phone__c, Equifax_Fax__c, Equifax_Email__c, Equifax_Company_Name__c FROM Account WHERE Id IN :accountIds];
        
        // Create criteria to send request to Ryder WSDL
        updateCompany.CompanyUpdateRequest requestCriteria = new updateCompany.CompanyUpdateRequest();

        // Go through the accounts and update using the soap method
        for (Account account : accounts)
        {
            requestCriteria.CompanyName = account.Name;
            //requestCriteria.CompanyTypeId = dbAccount.Type;
            requestCriteria.LesseNum = account.LesseeNo__c;
            requestCriteria.SiteDuns = account.Legal_Site_Duns__c;
            requestCriteria.HQDuns = account.DUNS_HQ__c;
            requestCriteria.UltimateDuns = account.Domestic_Ultimate_DUNS__c;
            //requestCriteria.IndustryTypeId = dbAccount.Industry;
            requestCriteria.SICCode = account.Industry;
            //requestCriteria.Id = Integer.valueOf(account.CustProspectID__c);
            //requestCriteria.NationalCustFlag = account.NATL_RNTL_CUST_ID__c;
            requestCriteria.LastUpdateUser = account.LastModifiedBy.Name;

			//08/28/2012 Saad - added fields for Equifax            
            requestCriteria.EquifaxNo = account.Equifax_No__c;
            requestCriteria.LegalEquifaxNo = account.Legal_Equifax_No__c;
            requestCriteria.EquifaxStreet1 = account.Equifax_Street1__c;
            requestCriteria.EquifaxStreet2 = account.Equifax_Street2__c;
            requestCriteria.EquifaxState = account.Equifax_State__c;
            requestCriteria.EquifaxCity = account.Equifax_City__c;
            requestCriteria.EquifaxCountry = account.Equifax_Country__c;
            requestCriteria.EquifaxZipCode = account.Equifax_Zip_Postal_Code__c;
            requestCriteria.EquifaxPhone = account.Equifax_Phone__c;
            requestCriteria.EquifaxFax = account.Equifax_Fax__c;
            requestCriteria.EquifaxEmail = account.Equifax_Email__c;
            requestCriteria.EquifaxCompanyName = account.Equifax_Company_Name__c;

            UpdateCompany.UpdateCompanySoap companySoap = new UpdateCompany.UpdateCompanySoap();
            companySoap.timeout_x = RyderGlobalVariables.WS_TIMEOUT;
            companySoap.endpoint_x = RyderGlobalVariables.RYDER_WS_ENDPOINT + RyderGlobalVariables.UPDATE_COMPANIES;
            UpdateCompany.CRMCredential credential = new UpdateCompany.CRMCredential();
            //credential.UserName = UserInfo.getUserName();
            //credential.Password = 'passw0rd';
            //credential.SecurityToken = 'x9hJscMUilGopqHFAZETe0Glm';
            
            system.debug('requestCriteria.LegalEquifaxNo = ' + requestCriteria.LegalEquifaxNo);  
            system.debug('account.Legal_Equifax_No__c = ' + account.Legal_Equifax_No__c);
            
            credential.UserName = '';
            credential.Password = '';
            credential.SecurityToken = '';
            try
            {
                // Make a soap request
                UpdateCompany.DCCompanyUpdate updateCompanyInfo = companySoap.ProcessRequest(credential, requestCriteria);
                
                //Check if there was a success
                if (updateCompanyInfo != null)
                {
                    String companyId = String.valueOf(updateCompanyInfo.ID);        
                }
            }
            catch(Exception ex)
            {
                System.debug('Error while updating the company: ' + ex.getMessage());
            }
        }
                
    }
}