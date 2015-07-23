/**
* 
*   NewAccountController is a class that allows the user to convert account and associate it with D&B accounts.
*
*   Author           |Author-Email                      |Date       |Comment
*   -----------------|----------------------------------|-----------|--------------------------------------------------
*   Vishal Patel     |vishal@comitydesigns.com          |11.22.2010 |First draft
*   
*/
public without sharing class NewAccountController  
{
    private String leadId {get; set;}
    private List<SelectOption> optionsCountries = new List<SelectOption>(); 
    private Account recordOwner = new Account();
    private List<Account> accountExistInfo = new List<Account>();
    private List<Contact> contactExistInfo = new List<Contact>();
    private Map<String, Account> accountExistInfoMap = new Map<String, Account>();
    private Map<String, List<SFDCContact>> contactExistInfoMap = new Map<String, List<SFDCContact>>();
    private Map<String, Contact> contactMap = new Map<String, Contact>();
    private Boolean isBranch {get; set;}
    
    // Normal get/set of objects    
    public Account account {get; set;}
    public Contact contact {get; set;}
    public String pageTitle {get; set;}
    
    private Account orgAccount {get; set;}
    private Contact orgcontact {get; set;}

    public Account[] dbAccountSearchResults {get; set;}
    public List<SFDCAccount> sfdcAccountSearchResults {get; set;}
    public List<SFDCContact> sfdcContactSearchResults {get; set;}
    public List<DBAccount> dbAccount = new List<DBAccount>();
    public Map<String, Account> dbAccountSearchResultsMap = new Map<String, Account>();
    public String accountRyderId {get; set;}
    public String labelAccountCreation {get; set;}

    // Normal get/set of objects    
    public Lead lead {get; set;}
    public Account getRecordOwner() { return recordOwner; }

    //account to which user need to be added as team role.
    private String accountForTeamRole;
                    
    // Boolean values to support the page
    public Boolean foundRecords {get; private set;}
    public Boolean foundDBRecords {get; private set;}
    public Boolean foundContactRecords {get; private set;}
    public Boolean displayNewAccount {get; private set;}
    public Boolean fromLead {get; private set;}
    public Boolean disableCreateAccount {get; set;}
    public Boolean contactFound {get; set;}

    public Boolean canSelectAccountWithoutDnB {get; set;}
    
    // Values from the page
    public String accountSelected {get; set;}
    public String oldAccountSelected {get; set;}
    public String contactSelected {get; set;}
    public String accountCreateOrAttached {get; set;}
    private String strRecordTypeId;
    
    private Map<String, Id> accountRecordTypeMap;

    private String accountState;
    private String contactState;
    
    private String strAccountSOQL = 'Select a.addr_verified_date__c, a.Website, a.Type, a.Top10Account__c, a.Speed_Changes__c, ' 
    + 'a.Site_Duns__c, a.Sic, a.SIC_Code__c, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, a.ShippingCity, a.STATUS_ACTIVE__c,  '
    + 'a.Ryder_Specific_Loc_Type__c, a.Risk_ID__c, a.RiskStatusStable__c, a.RiskStatusNoStatus__c, a.RiskStatusGrowth__c, a.RiskStatusAtRisk__c, ' 
    + 'a.RecordTypeId, a.RYDER_LOC_TYPE__c, a.Phone_2__c, a.Phone, a.ParentId, a.Pager__c, a.PO_NUMBER__c, a.Other_Misc_Billing_Information__c,  '
    + 'a.Other_Instructions__c, a.NumberOfEmployees, a.NationalCustFlag__c, a.Name, a.NATL_RNTL_CUST_ID__c, a.MasterRecordId, a.LesseeNo__c,  '
    + 'a.Legal_Site_Duns__c, a.Legal_Entity_Address_Zip_Postal_Code__c, a.Legal_Entity_Address_Street__c,  '
    + 'a.Legal_Entity_Address_State_Province__c, a.Legal_Entity_Address_Country__c, a.Legal_Entity_Address_City__c, ' 
    + 'a.Legacy_Last_Modified_Date__c, a.Legacy_Last_Modified_By__c, a.LastActivityDate, a.LOC_ID__c, a.Industry, a.Id, ' 
    + 'a.Guarantor_Address_Zip_Postal_Code__c, a.Guarantor_Address_Street__c, a.Guarantor_Address_State_Province__c, ' 
    + 'a.Guarantor_Address_Country__c, a.Guarantor_Address_City__c, a.Growth_Status_Percent__c, a.Global_Ultimate_DUNS__c, a.GROWTH_ACC__c, ' 
    + 'a.FormerCustomer__c, a.Fax, a.Family_Company_id__c, a.Family_Company_Owner_id_del__c, a.Family_Company_Name__c, ' 
    + 'a.Domestic_Ultimate_DUNS__c, a.Description, a.DUNS_HQ__c, a.DNB_Subsidiary_Type__c, a.DB_Loc_Type__c, a.DBA__c, a.DBA_5__c, a.DBA_4__c, ' 
    + 'a.DBA_3__c, a.DBA_2__c, a.CustomerTypeID__c, a.CustProspectID__c, a.CurrencyIsoCode, a.Components_Not_Included__c, a.CompanyTypeID__c, ' 
    + 'a.Central_Decisionmaking__c, a.Cell__c, a.CUST_REPAIR_LIMIT__c, a.CR_STATUS_REASON__c, a.CO_SEGMENT__c, a.CO_RYDER_ANNSRY__c, ' 
    + 'a.CO_OWNER_ID__c, a.CO_ANNSRY__c, a.Billing_Phone__c, a.Billing_Fax__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, ' 
    + 'a.BillingCountry, a.BillingCity, a.BUSINESS_STATUS__c, a.BAD_ADDR_REASON__c, a.BAD_ADDR_DATE__c, a.BAD_ADDR_CD__c, ' 
    + 'a.BAD_ADDRESS_BIT__c, a.At_Risk__c, a.AnnualRevenue, a.Alias_Name__c, a.Additional_Comments__c, a.Account_Classification__c, ' 
    + 'a.ADDR_ID__c, a.OwnerId From Account a ';

    /**
     * NewAccountController acts as a constructor for the controller class.
     * Fetches the record details being referred in the context
     * 
     * @param        controller        
     * @return       void              
     */
    public NewAccountController(ApexPages.StandardController controller) 
    {
        System.debug('*********** Start NewAccountController **************');
        this.fromLead = false;
        this.disableCreateAccount = true;
        this.labelAccountCreation = RyderGlobalVariables.CREATE_ACCOUNT;
        this.canSelectAccountWithoutDnB = true;
        this.accountState = RyderGlobalVariables.LeadConversionAccountState.NewAccount.name();
        this.contactState = RyderGlobalVariables.LeadConversionContactState.NewContact.name();
        
        accountRecordTypeMap = CommonFunctions.getRecordTypeMap('Account');
        
        if (this.contact == null)
            this.contact = new Contact();
        
        if (oldAccountSelected == null)
            this.oldAccountSelected = '';
        String fromLeadStringValue = ApexPages.currentPage().getParameters().get('fromLead');
        System.debug('fromLeadStringValue - '+fromLeadStringValue);
        if (fromLeadStringValue != null) {
            System.debug('Setting from lead since fromLeadStringValue is not null');
            fromLead = Boolean.valueOf(fromLeadStringValue);
        }
        System.debug(' -----------------> fromLead IS ' + fromLead + this.fromLead);
        pageTitle = RyderGlobalVariables.CREATE_NEW_ACCOUNT_PAGE_TITLE;    
        if (fromLead)
        {   
            pageTitle = RyderGlobalVariables.LEAD_CONVERSION_PAGE_TITLE;
            System.debug('*********** Start From Lead **************');
            //this.lead = (Lead)controller.getRecord();
            
            // Get the lead for the id
            this.leadId = ApexPages.currentPage().getParameters().get('leadId');
            this.lead = [SELECT l.Website, l.VEHICLE_CNT__c, l.Type__c, l.Truck_Usages__c, l.Tractor_Estimate__c, l.Title, l.Suspect_Id__c, l.Street, l.Status_Active__c, 
                            l.Status, l.State, l.Site_Duns__c, l.Sic_Code_Desc__c, l.Segment__c, l.Salutation, l.SUSPECT_LOC_ID__c, l.SIC_CODE__c, l.Rating, 
                            l.RECEIVED_MAIL_FOR_LEAD_BIT__c, l.PostalCode, l.Phone, l.PHONE_EXTN__c, l.OwnerId, l.NumberOfEmployees, l.Nearest_Branch__c, l.Name, l.MasterRecordId, 
                            l.MGR_Email__c, l.MGR_TITLE__c, l.MGR_NAME__c, l.LeadSource, l.LastName, 
                            l.LOC_ID__c, l.IsUnreadByOwner, l.IsConverted, l.Industry, l.Id, l.Global_Ultimate_DUNS__c, l.FirstName, l.Final_Approval__c, l.EmailBouncedReason, 
                            l.EmailBouncedDate, l.Email, l.EXTRACT_NAME__c, l.ESTEQUIPTYPE__c, l.Duns_HQ__c, l.Domestic_Ultimate_DUNS__c, l.Distanct_to_Ryder_miles__c, 
                            l.Description, l.DM_Title__c, l.DM_Phone__c, l.DM_Name__c, l.DISPOSITION_CODE__c, l.DBD__c, l.DBD_NAME__c, l.CurrencyIsoCode, l.LastActivityDate,
                            l.Country, l.ConvertedOpportunityId, l.ConvertedDate, l.ConvertedContactId, l.ConvertedAccountId, l.Company, l.City, 
                            l.COMPTOROUTSOURCED__c, l.CFO_TITLE__c, l.CFO_NAME__c, l.CFO_Email__c, l.CALL_DATE__c, l.BDM__c, l.BDM_NAME__c, l.BDM_CODE__c, 
                            l.AnnualRevenue, l.APPROXSIZE__c, l.ADDR_ID__c, l.Customer_Type__c, l.Email_does_not_exist__c, l.National_Account_Flag__c, l.Data_Source__c
                        FROM Lead l WHERE Id =:this.leadId];
    
            recordOwner.OwnerId = this.lead.OwnerId;
            
            // New account to create
            this.account = new Account();
            this.account.Name = lead.Company;
            this.account.ShippingState = lead.State;
            this.account.ShippingCity = lead.City;
            this.account.ShippingCountry = lead.Country;
            this.account.ShippingStreet = lead.Street;
            this.account.ShippingPostalCode = lead.PostalCode;            
            this.account.CustomerTypeID__c = lead.Customer_Type__c;
            // copy the Segment Code and Company Type to Account from lead
            this.account.CO_SEGMENT__c = lead.Segment__c;
            // copy DUNS number entered from lead
            this.account.DUNS_HQ__c = lead.Duns_HQ__c;
            this.account.Site_Duns__c = lead.Site_Duns__c;
            this.account.Legal_Site_Duns__c = lead.Site_Duns__c;
            this.account.Domestic_Ultimate_DUNS__c = lead.Domestic_Ultimate_DUNS__c;
            this.account.Global_Ultimate_DUNS__c = lead.Global_Ultimate_DUNS__c;
            // map SIC code from lead to Account
            this.account.Sic = lead.SIC_Code__c;
            
            // Lead Field: National_Account_Flag  should map to Account Field: Account_Classification.   The lead field is a Boolean and the Account Classification is picklist, with value National.
            if (lead.National_Account_Flag__c == true) {
                this.account.Account_Classification__c  = RyderGlobalVariables.AccountClassification.National.name();
            }
            
            // this.account.SIC_Code__c = getSICLookupId(lead.SIC_Code__c);
            this.account.SIC_Code__c = lead.SIC_Code__c;
            // set owner id to be same as lead
            this.account.ownerId = lead.ownerId;
            // neelima- april 12 2012- added the new contact source field to differentiate contacts created by lead conversion and new contact button.
            this.contact.Contact_Source__c=(RyderGlobalVariables.ContactSource.Lead_Conversion.name()).replace('_',' ');
            this.contact.FirstName = lead.FirstName;
            this.contact.LastName = lead.LastName;
            this.contact.Phone = lead.Phone;
            this.contact.ownerId = lead.ownerId;
            if (lead.Email != null) {
                this.contact.Email = lead.Email;
            } else  {
                this.contact.Email_does_not_exist__c = true; 
                this.contact.Email_Does_Not_Exist_Reason__c = RyderGlobalVariables.I_WILL_UPDATE_LATER;
            }
            
            labelAccountCreation = RyderGlobalVariables.CONVERT_LEAD;
            
            System.debug(LoggingLevel.INFO, '+++++++++++ account set to : ' + account);
            
            System.debug('*********** End From Lead **************');
        }        
        else {
            this.account = (Account)controller.getRecord();
            // set correct recordtype id
            strRecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
            System.debug(LoggingLevel.INFO, '+++++++++++++++ strRecordTypeId: ' + strRecordTypeId);
            if (strRecordTypeId != null) {
                this.account.recordTypeId = strRecordTypeId;
            }
            //Added by Raja - 10/26/11
            //When account is created manually, owner needs to be set to logged in user
            this.account.ownerId = UserInfo.getUserId();
        }

        // Add initial item in the account
        addNewAccountItem();
        foundRecords = false;
        foundDBRecords = false;
        foundContactRecords = false;
        accountCreateOrAttached = '';
        // keep org set in case of rollback
        this.orgAccount = this.account.clone(false,true);
        this.orgContact = this.contact.clone(false,true);
        System.debug('*********** End NewAccountController **************');
    }
    
    /**
     * doSearch checks if the account exist in the account object before
     * checking D&B web services
     * @param        void        
     * @return       PageReference              
     */
    public PageReference doSearch()
    {
        try {
            System.debug('*********** Start DoSearch **************');
            System.debug(' -----------------> fromLead IS ' + fromLead + this.fromLead);
            displayNewAccount = false;
            disableCreateAccount = true;
            this.canSelectAccountWithoutDnB = true;
            // Check if the DnB account exist, if so we need to clear it for new values
            if (dbAccountSearchResults != null)
                dbAccountSearchResults.Clear();
                
            // Clear all the Salesforce results and repopulate with new values
            if (sfdcAccountSearchResults != null)
                sfdcAccountSearchResults.Clear();
            
            this.orgAccount.CustomerTypeID__c = this.account.CustomerTypeID__c;
            this.orgAccount.CompanyTypeID__c = this.account.CompanyTypeID__c;
        
            // Build the SOQL
            String accountSOQL = strAccountSOQL;
            String tmpName = account.name;
            tmpName = tmpName.replaceall(' ', '%');
            //String whereClause = 'WHERE a.Name Like \'%' + String.escapeSingleQuotes(account.Name) + '%\'';
            String whereClause = 'WHERE a.Name Like \'%' + String.escapeSingleQuotes(tmpName) + '%\'';
            whereClause += ' AND a.CustomerTypeID__c = \'' + String.escapeSingleQuotes(account.CustomerTypeID__c) + '\'';
            
            if (account.ShippingStreet != null)
                whereClause += ' AND a.ShippingStreet Like \'%' + String.escapeSingleQuotes(account.ShippingStreet) + '%\'';
                
            if (account.ShippingCity != null)
                whereClause += ' AND a.ShippingCity Like \'%' + String.escapeSingleQuotes(account.ShippingCity) + '%\'';
            if (account.ShippingState != null)
                whereClause += ' AND a.ShippingState Like \'%' + String.escapeSingleQuotes(account.ShippingState) + '%\'';
            if (account.ShippingPostalCode != null)
                whereClause += ' AND a.ShippingPostalCode Like \'%' + String.escapeSingleQuotes(account.ShippingPostalCode) + '%\'';
            if (account.ShippingCountry != null)
                whereClause += ' AND a.ShippingCountry Like \'%' + String.escapeSingleQuotes(account.ShippingCountry) + '%\'';
            
            accountSOQL += whereClause;
            accountSOQL += ' LIMIT ' + RyderGlobalVariables.NUMBER_OF_RECORDS_PER_SEARCH;
            System.debug('accountSOQL - ' + accountSOQL);   
            Account[] sfdcAccountResults = Database.query(accountSOQL);
            foundRecords = true;
            foundDBRecords = false;
            
            String customerTypeId = account.CustomerTypeID__c;
            Set<String> dunsExistSet = new Set<String>();
            
            accountSelected = '';
            oldAccountSelected = '';
            accountCreateOrAttached = '';
            // Add initial item in the account
            addNewAccountItem();
            // Check if the account search results
            if (sfdcAccountResults!= null && sfdcAccountResults.size()>0)
            {
                
                for(Account acct : sfdcAccountResults)
                {
                    SFDCAccount sfdcAccount = new SFDCAccount();
                    sfdcAccount.selected=false;
                    sfdcAccount.createOrAttach = RyderGlobalVariables.ATTACH_EXISTING_LABEL;
                    sfdcAccount.account=acct;
                    sfdcAccount.canBeSelected = true;
                    accountExistInfoMap.put(acct.Id, acct);
                    sfdcAccountSearchResults.Add(sfdcAccount);
                    if (acct.CustomerTypeID__c != null)
                    {
                        dunsExistSet.add(acct.Site_Duns__c + '_' + acct.CustomerTypeID__c);
                        dunsExistSet.add(acct.DUNS_HQ__c + '_' + acct.CustomerTypeID__c);
                    }
                }
                retrieveContacts();
                displayContactInfo();
            }
            try
            {
                if (dbAccountSearchResultsMap != null)
                    dbAccountSearchResultsMap.clear();
                else
                    dbAccountSearchResultsMap = new Map<String, Account>(); 
                
                if (dbAccount != null)
                    dbAccount.clear();
                else
                    dbAccount = new List<DBAccount>();
                
                CommonFunctions commonFunction = new CommonFunctions();
                // Create criteria to send request to Ryder WSDL
                dbAccountSearchResults = commonFunction.getSFDCAccountsFromDandB(account.Name, account.ShippingState, account.ShippingCountry,
                                                                                 account.ShippingStreet, account.ShippingCity, account.ShippingPostalCode,
                                                                                 contact.Phone);
                system.debug(LoggingLevel.INFO, '+++++++++++++++++ dbAccountSearchResults: ' + dbAccountSearchResults);
                if (dbAccountSearchResults != null && dbAccountSearchResults.size()>0)
                {
                    System.debug('Duns set - '+dunsExistSet);
                    foundDBRecords = true;
                    for (Account acct : dbAccountSearchResults)
                    {
                        System.debug('Check - ' + acct.Site_Duns__c + '_' + customerTypeId);
                        // Check if the duns and customer type id exist and eliminate those values
                        if (!dunsExistSet.contains(acct.Site_Duns__c + '_' + customerTypeId))
                        {
                            dbAccountSearchResultsMap.put(acct.Site_Duns__c, acct);
                            
                            DBAccount acctToDisplay = new DBAccount();
                            acctToDisplay.selected = false; 
                            acctToDisplay.Id = acct.Id;
                            acctToDisplay.Company_Name = acct.Name;
                            acctToDisplay.DunsNumber = acct.Site_Duns__c;
                            acctToDisplay.Address_Line = acct.Legal_Entity_Address_Street__c;
                            acctToDisplay.CountryCode = acct.Legal_Entity_Address_Country__c;
                            acctToDisplay.City = acct.Legal_Entity_Address_City__c;
                            acctToDisplay.State = acct.Legal_Entity_Address_State_Province__c;
                            acctToDisplay.ZipCode = acct.Legal_Entity_Address_Zip_Postal_Code__c;
                            acctToDisplay.CustomerType = acct.CustomerTypeID__c;
                            acctToDisplay.ryderProbability = acct.ryderProbabilityMatch__c;
                            if (acct.RyderProbabilityMatch__c > RyderGlobalVariables.CUT_OFF_ACCURACY_PROBABILITY) {
                                this.canSelectAccountWithoutDnB = false;
                            }
                            dbAccount.add(acctToDisplay);
                        }
                    }
                }
                // check if we have found DnB Account with matching accuracy probability > X then do not allow
                // user to create new account
                if (this.canSelectAccountWithoutDnB == false) {
                    for ( SFDCAccount tempAccount: sfdcAccountSearchResults){
                      if (tempAccount.createOrAttach == RyderGlobalVariables.CREATE_NEW_LABEL) {
                        tempAccount.canBeSelected = false;
                      }     
                    }
                }
            }
            catch(RyderException ex) {
                addErrors(ex.dbRequest + ex.dbResponse);
                ApexPages.Message msgError = new ApexPages.Message(ApexPages.Severity.Error, ex.errorMessage);  
                ApexPages.addMessage(msgError); 
            }
            catch(Exception ex)
            {
                addErrors(ex.getMessage());
                ApexPages.Message msgError = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());  
                ApexPages.addMessage(msgError);
                return null;
            }
                
            System.debug('sfdcAccountSearchResults = ' + sfdcAccountSearchResults);
            System.debug('dbAccountSearchResults = ' + dbAccountSearchResults);
            System.debug('foundRecords = ' + foundRecords);
            System.debug('foundDBRecords = ' + foundDBRecords);
            System.debug('Contact = ' + contact);
        } 
        catch(RyderException ex) {
            addErrors(ex.dbRequest + ex.dbResponse);
            ApexPages.Message msgError = new ApexPages.Message(ApexPages.Severity.Error, ex.errorMessage);  
            ApexPages.addMessage(msgError);
        }
        catch(Exception ex) {
        System.debug('Error - ' + ex);
        ApexPages.Message msgError = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());  
        ApexPages.addMessage(msgError);
        }
        System.debug('*********** End DoSearch **************');
        return null;
    }
    
    private void addErrors(String errorDetail) {
        String errMsg = 'Error converting lead or New Account creation.';
        if (this.fromLead) {
            errMsg = 'Error converting lead id:[' + this.lead.Id + '] Lead Name:[' + this.lead.Name + ']';
        }
        CommonFunctions.logError(errMsg, errorDetail);
    }
    
    /**
     * Cancel - returns the user to the lead screen
     * 
     * @return       PageReference      
     */
    public PageReference Cancel()
    {
        System.debug('*********** Start Cancel **************');
        PageReference pageRef =  new PageReference('/' + Schema.SObjectType.Account.getKeyPrefix() + '/o');
        if (this.fromLead) {
            pageRef =  new PageReference('/' + this.lead.id);   
        }
        
        pageRef.setRedirect(true);
        System.debug('*********** End Cancel **************');
        return pageRef;
    }    
    /**
     * CreateNewAccount - returns the user to the new Account screen
     * 
     * @return       PageReference      
     */
    public PageReference createNewAccount()
    {
        try {
        System.debug('*********** Start createNewAccount **************');
        System.debug(' -----------------> fromLead IS ' + fromLead + this.fromLead);
        System.debug(LoggingLevel.INFO, '******************* accountCreateOrAttached:' + accountCreateOrAttached);
        Boolean createNewAccountSuccessful = false;
        accountForTeamRole = null;
        if (this.fromLead && accountCreateOrAttached!=RyderGlobalVariables.CREATE_NEW_LABEL)
        {
            System.debug('Account selected - '+ accountSelected);
            System.debug('Contact selected - '+ contactSelected);
            createNewAccountSuccessful = Convert();
        }
        else
        {
            createNewAccountSuccessful = false;
            Boolean isRyderAccount = createCompany();
            if (account.id != null)
                createNewAccountSuccessful = true;
        }       
        if (createNewAccountSuccessful)
        {
            if (this.fromLead) {
                PageReference pageRef =  Page.LeadConversionResult;
                pageRef.getParameters().put('accountStatus', this.accountState);
                pageRef.getParameters().put('contactStatus', this.contactState);
                pageRef.getParameters().put('id', this.lead.id);
                pageRef.setRedirect(true);
                System.debug('*********** End Convert **************');
                return pageRef;
            } else {                PageReference pageRef =  new ApexPages.StandardController(account).view();
                pageRef.setRedirect(true);
                System.debug('*********** End Convert **************');
                return pageRef;
            }
        }
        System.debug(LoggingLevel.INFO, '************ account: ' + this.account);
        System.debug('*********** End createNewAccount **************');
        } catch(RyderException ex) {
            addErrors(ex.dbResponse);
            ApexPages.Message msgError = new ApexPages.Message(ApexPages.Severity.Error, ex.errorMessage);  
            ApexPages.addMessage(msgError); 
        } catch(Exception ex) {
            addErrors(ex.getMessage());
            ApexPages.Message msgError = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());  
            ApexPages.addMessage(msgError);
        }
        return null;            
    }    
        
    /**
     * getDBAccount retrieves accounts that are to be displayed on the screen
     * 
     * @param       void            
     * @return      List<DBAccount>
     */
    public List<DBAccount> getDBAccountToDisplay()
    {
        System.debug(' -----------------> fromLead IS ' + fromLead + this.fromLead);
        return dbAccount;
    }
                
    /**
     * getItemsCountries retrieve picklist values for populating countries
     * 
     * @param       void            
     * @return      List<SelectOption>
     */
    public List<SelectOption> getItemsCountries() 
    {
        System.debug('*********** Start getItemsCountries **************');
        if (optionsCountries.size()==0)
        {
            optionsCountries.add(new SelectOption(RyderGlobalVariables.COUNTRIES_USA, RyderGlobalVariables.COUNTRIES_USA));
            optionsCountries.add(new SelectOption(RyderGlobalVariables.COUNTRIES_CANADA, RyderGlobalVariables.COUNTRIES_CANADA_TEXT));
        }
        System.debug('*********** End getItemsCountries **************');
        return optionsCountries;
    }
                
    /**
     * assignAccount - assigns and retrieves contact for Salesforce account or assigns DunsNumber for account
     * 
     * @param       void            
     * @return      void
     */
    public void assignAccount()
    {
        System.debug('*********** Start assignAccount **************');
        System.debug('assignAccount accountSelected - '+accountSelected);
        System.debug('assignAccount oldAccountSelected - '+oldAccountSelected);
        System.debug('assignAccount accountCreateOrAttached - '+ accountCreateOrAttached);
        System.debug(' -----------------> fromLead IS ' + fromLead + this.fromLead);
        disableCreateAccount = true;
        if (oldAccountSelected == null || oldAccountSelected.length()==0)
        {
            disableCreateAccount = false;
            oldAccountSelected = accountSelected;
        }
        else
        {
            if (oldAccountSelected == accountSelected)
            {
                disableCreateAccount = true;
                oldAccountSelected = '';
            }
            else
            {
                oldAccountSelected = accountSelected;
                disableCreateAccount = false;
            }
        }
        displayContactInfo();       
        System.debug('*********** End assignAccount **************');
    }   

    
    /**
     * ConvertLead - converts lead to account and contact
     * 
     * @return       PageReference      
     */
    public Boolean Convert()
    {
        System.debug(' -----------------> fromLead IS ' + fromLead + this.fromLead);
        System.debug('*********** Start Convert **************');
        Boolean convertSuccessful = false; 
        contactFound = false;
        Boolean doNotCreateOppty = true;
        Boolean emailToOwner = false;
        Boolean replaceLeadSource = false;
        CommonFunctions commonFunction = new CommonFunctions(); 
        System.debug(LoggingLevel.INFO, '%%%%%%%%%%%%%%%%%%%% Account before convert: ' + account);
        try 
        {
            // Create company based on lead convert selected
            Boolean isRyderCompany = createCompany();
            System.debug(LoggingLevel.INFO, '%%%%%%%%%%%%%%%%%%%% Account after convert: ' + account);    
            // Check if the account id was retrieved        
            if (account.id != null)
            {
                Contact existingsameAccount;
                Contact existingPrimary;
                // neelima- april 11 2012 - existing contact check for contact to conform to unique email address requirement by Eloqua
                 if (contact.Email!=null) 
                 {
                    system.debug('from lead conversion');
                 existingsameAccount=DedupUtil.getContactFromSameAccount(contact.Email,account.Id);
                 existingPrimary=DedupUtil.getFMSDuplicateContacts(contact.Email);
                 system.debug('existingsameAccount' + existingsameAccount );
                  system.debug(' existingPrimary' +  existingPrimary);
                 // Neelima- 02/27/2012--if the existing contact is from the same account do not create the contact. Instead 
                 // use the existing contact for the lead conversion
                        if (existingsameAccount!=null )
                        {
                                contact=existingsameAccount;
                                contactFound=True;
                                // do not carry over lead source to contact as the contact already exists
                                replaceLeadSource = false;
                                this.contactState=RyderGlobalVariables.LeadConversionContactState.ExistingSFDCContact.name();
                                
                        } 
                        else if (existingPrimary!=null) 
                            {
                                contact.Is_Duplicate__c=true;
                                contact.Primary_Contact_Id__c=existingPrimary.Id;
                                //contact=existingCon;
                                //contactFound=True;
                                // do not carry over lead source to contact as the contact already exists
                                //replaceLeadSource = false;
                                //this.contactState=RyderGlobalVariables.LeadConversionContactState.ExistingSFDCContact.name();
                                //system.debug('Existing contact' + existingCon);
                            }
                 
                 }
                // Add the contact
                if (contactFound == false)
                {
                    // contact = new contact(firstname=contact.FirstName, lastname=contact.LastName,accountid=account.id, ownerId = lead.ownerId);
                    contact.accountid=account.id;
                    contact.ownerId = lead.ownerId;
                    replaceLeadSource = true;
                   
                    
                    //by Franklin Suazo 04/22/2012: Fill out Marketing Automation Address
                    contact.Marketing_City__c = contact.MailingCity;
                    contact.Marketing_Cell_Phone__c = contact.CELL__c;    
                    contact.Marketing_Country__c = contact.MailingCountry;
                    contact.Marketing_Fax__c = contact.Fax;
                    contact.Marketing_Home_Phone__c = contact.HomePhone;
                    contact.Marketing_State__c = contact.MailingState;
                    contact.Marketing_Street__c = contact.MailingStreet;
                    contact.Marketing_Zip__c = contact.MailingPostalCode;
                    contact.Data_Source__c = lead.Data_Source__c;  
                                      
                    
                    System.debug(LoggingLevel.INFO, 'Contact that would be added:' + contact);
                    insert contact;
                    this.contactState = RyderGlobalVariables.LeadConversionContactState.CreatedContact.name();
                    System.debug('Added new contact');
                }
                addAccountTeams(account);
                //addToAccountTeam(accountForTeamRole);
                               
                
                Database.LeadConvert converter = new Database.LeadConvert();
                converter.setLeadId(lead.id);
                converter.setAccountId(account.id);
                // neelima - April 12, 2012
               // Set the contact id  only if it is a new contact
               // if(contactFound == false) 
                converter.setContactId(contact.id);
                converter.setOverwriteLeadSource(replaceLeadSource);
                converter.setDoNotCreateOpportunity(doNotCreateOppty);
                String ownerId = recordOwner.OwnerId;
                converter.setOwnerId(ownerId); 
                    system.debug('contact' + contact);          

//                04/25/12 Raja Changed to get lead converted status based on lead status. Record type could be used as well                
//                converter.setConvertedStatus(RyderGlobalVariables.CONVERTED_STATUS);

                converter.setConvertedStatus(RyderGlobalVariables.getConvertedLeadStatus(lead.Status));
                converter.setSendNotificationEmail(emailToOwner);
                System.debug(LoggingLevel.INFO, 'Lead Convertor: Lead:' + lead);
                System.debug(LoggingLevel.INFO, 'Lead Convertor: Account:' + account);
                System.debug(LoggingLevel.INFO, 'Lead Convertor: Contact:' + contact);
                System.debug(LoggingLevel.INFO, 'converter - '+converter);
                Database.Leadconvertresult convertResult = Database.convertLead(converter);
                 
                if(!convertResult.isSuccess())
                {
                    System.debug('Conversion Failed');
                    // Get the first save result error
                    Database.Error err = convertResult.getErrors()[0];
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, RyderGlobalVariables.ERROR_CONVERTING_LEADS + err.getMessage() + '\n');
                    ApexPages.addmessage(errorMsg);
                }
                else{
                    System.debug('Conversion successful');
                    convertSuccessful = true;
                     UpdateCompetitorVehicles.updateCompetitorVehiclesOnLeads(convertResult); 
                     System.debug('updateCompetitorVehiclesOnLeads complete');
                    }
            }
        } catch(RyderException ex) {
            addErrors(ex.dbResponse);
            ApexPages.Message msgError = new ApexPages.Message(ApexPages.Severity.Error, ex.errorMessage);  
            ApexPages.addMessage(msgError);
            convertSuccessful = false;
            rollbackAccountConversion(); 
        }
        catch(Exception ex)
        {
             // Vishal 12/13/2010 - To do when the web method on web service gets implemented
            //if (isRyderCompany && account.id != null)
            //commonFunctions.createAccountsFailed(account.Id);
           addErrors(ex.getMessage());
           ApexPages.addMessages(ex);
           convertSuccessful = false;
           rollbackAccountConversion();
        }     
        System.debug('*********** End Convert **************');
        return convertSuccessful;
    }
    
    /*
    * If lead owner and account owners are different add lead owner to be part of account team for child and parent
    */
    private void addAccountTeams(Account account) {
       if (account.OwnerId != recordOwner.OwnerId) { 
                addToAccountTeam(account.Id);
       }
       if (account.ParentId != null) {
         // if parent account exists and parent account owner is different then lead owner
         // add lead owner to parent account's team also.
         Account parentAccount = [select id, ownerId from Account where id =: account.parentId];
         if (parentAccount.OwnerId != recordOwner.OwnerId) { 
                addToAccountTeam(parentAccount.Id);
         }   
       }
    }
    
    /*
    *   Add lead owner to parent account so owner has visibility to the account.
    */
    private void addToAccountTeam(String parentAccountId) {
        if (parentAccountId != null) {
            AccountTeamMember temp = new AccountTeamMember();
            temp.UserId = recordOwner.OwnerId;
            temp.TeamMemberRole = translateAccountTeamRole(recordOwner.OwnerId); 
            temp.AccountId = parentAccountId;
            insert temp;
            System.debug(LoggingLevel.INFO, '&&&&&&&&&&&&&&&& Account team member added:' + temp);
            System.debug(LoggingLevel.INFO, '&&&&&&&&&&&&&&&& Account team member parentAccountId:' + parentAccountId);
            System.debug(LoggingLevel.INFO, '&&&&&&&&&&&&&&&& Account team member recordOwner.OwnerId:' + recordOwner.OwnerId);
            // now retrieve the account share and update Oppty and Case level access.
            List<AccountShare> shareTemp = [Select a.UserOrGroupId, 
              a.RowCause, a.OpportunityAccessLevel, a.ContactAccessLevel, a.CaseAccessLevel, a.AccountId, 
              a.AccountAccessLevel 
              From AccountShare a where a.userOrGroupId =:recordOwner.OwnerId and a.RowCause = 'Team' and a.AccountId =: parentAccountId LIMIT 1];
              if (shareTemp != null && shareTemp.size() > 0) {
                   shareTemp[0].AccountAccessLevel=RyderGlobalVariables.WRITE_ACCESS;
                   shareTemp[0].OpportunityAccessLevel = RyderGlobalVariables.WRITE_ACCESS;
                   shareTemp[0].CaseAccessLevel = RyderGlobalVariables.READ_ACCESS;
                   update shareTemp[0];
              } else {
                // Do nothing as account might be already shared by either OWD or some other sharing rules.
              }
        }
    }
    
    /*
    *   Translate Account team role based on profile as below
        In that case, we want to add the owner of the lead to the account team.
            If the profile of the owner is BDM or CDM, the Team Role would be Local Account Manager.
            If profile is National, the Team Role would be National Account Manager.
            If the profile of the owner is Rental, the Team Role needs to be National Rental Manager (which doesn’t exist yet, please create).
    */
    private String translateAccountTeamRole(String userId) {
        String result = '';
       System.debug('*********** Start translateAccountTeamRole UserId**************' + userId );
        String userProfileName = [select id, name from profile where id in (Select u.profileId From User u where u.id =:userId)].name;
        System.debug('*********** userProfileName**************' + userProfileName );
        Ryder_Account_Team_Role_Map__c accountRole = Ryder_Account_Team_Role_Map__c.getValues(userProfileName);
        System.debug('*********** accountRole1**************' + accountRole);
        if (accountRole == null) {
            accountRole = Ryder_Account_Team_Role_Map__c.getValues(RyderGlobalVariables.DEFAULT_ACCOUNT_ROLE_MAP);
             System.debug('*********** accountRole2**************' + accountRole);
        }
        result = accountRole.Account_Team_Role__c;
         System.debug('*********** accountRole.Account_Team_Role__c**************' + accountRole.Account_Team_Role__c);
        return result;
    }
    
    // Create account creation process that either creates account on the Ryder
    //TODO: Remove the boolean flag from being returned
    private Boolean createCompany()
    {
        System.debug('*********** Start createCompany **************');
        System.debug(' -----------------> fromLead IS ' + fromLead + this.fromLead);
        Boolean isRyderCompany = false;
        
        // Choosing an existing account
        if (accountExistInfoMap.containsKey(accountSelected))
        {
            // Existing account and contact info
            account = accountExistInfoMap.get(accountSelected);
            // if lead's owner is not the owner or the account 
            this.accountState = RyderGlobalVariables.LeadConversionAccountState.ExistingSFDCAcct.name();
            /*
            if (account.OwnerId != recordOwner.OwnerId) { 
                accountForTeamRole = account.Id;
            }
            */
            System.debug(LoggingLevel.INFO, '+++++++++++ account set to : ' + account);
            if (contactMap.containsKey(contactSelected))
            {
                contact = contactMap.get(contactSelected); 
                contactFound = true;
                this.contactState = RyderGlobalVariables.LeadConversionContactState.ExistingSFDCContact.name();
                System.debug('Attached existing contact');
            }
            System.debug('Attached existing account');
        } else {
                //check if DUNS number already exists as account in the system
                // Tied to bug #21 in QC.];
                List<Account> existingDUNSAccounts = null;
                if (accountSelected != null && accountSelected.length() > 0 && accountSelected != RyderGlobalVariables.CREATE_NEW) {
                    existingDUNSAccounts = [Select a.addr_verified_date__c, a.Website, a.Type, 
                    a.Top10Account__c, a.Speed_Changes__c, a.Site_Duns__c, a.Sic, a.SIC_Code__c, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, 
                    a.ShippingCountry, a.ShippingCity, a.STATUS_ACTIVE__c, a.Ryder_Specific_Loc_Type__c, a.Risk_ID__c, a.RiskStatusStable__c, 
                    a.RiskStatusNoStatus__c, a.RiskStatusGrowth__c, a.RiskStatusAtRisk__c, a.RecordTypeId, a.RYDER_LOC_TYPE__c, a.Phone_2__c, 
                    a.Phone, a.ParentId, a.Pager__c, a.PO_NUMBER__c, a.Other_Misc_Billing_Information__c, a.Other_Instructions__c, 
                    a.NumberOfEmployees, a.NationalCustFlag__c, a.Name, a.NATL_RNTL_CUST_ID__c, a.MasterRecordId, a.LesseeNo__c, 
                    a.Legal_Site_Duns__c, a.Legal_Entity_Address_Zip_Postal_Code__c, a.Legal_Entity_Address_Street__c, 
                    a.Legal_Entity_Address_State_Province__c, a.Legal_Entity_Address_Country__c, a.Legal_Entity_Address_City__c, 
                    a.Legacy_Last_Modified_Date__c, a.Legacy_Last_Modified_By__c, a.LastActivityDate, a.LOC_ID__c, a.Industry, a.Id, 
                    a.Guarantor_Address_Zip_Postal_Code__c, a.Guarantor_Address_Street__c, a.Guarantor_Address_State_Province__c, 
                    a.Guarantor_Address_Country__c, a.Guarantor_Address_City__c, a.Growth_Status_Percent__c, a.Global_Ultimate_DUNS__c, 
                    a.GROWTH_ACC__c, a.FormerCustomer__c, a.Fax, a.Family_Company_id__c, a.Family_Company_Owner_id_del__c, 
                    a.Family_Company_Name__c, a.Domestic_Ultimate_DUNS__c, a.Description, a.DUNS_HQ__c, a.DNB_Subsidiary_Type__c, 
                    a.DB_Loc_Type__c, a.DBA__c, a.DBA_5__c, a.DBA_4__c, a.DBA_3__c, a.DBA_2__c, a.CustomerTypeID__c, a.CustProspectID__c, 
                    a.CurrencyIsoCode, a.Components_Not_Included__c, a.CompanyTypeID__c, a.Central_Decisionmaking__c, a.Cell__c, 
                    a.CUST_REPAIR_LIMIT__c, a.CR_STATUS_REASON__c, a.CO_SEGMENT__c, a.CO_RYDER_ANNSRY__c, a.CO_OWNER_ID__c, a.CO_ANNSRY__c, 
                    a.Billing_Phone__c, a.Billing_Fax__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, 
                    a.BillingCity, a.BUSINESS_STATUS__c, a.BAD_ADDR_REASON__c, a.BAD_ADDR_DATE__c, a.BAD_ADDR_CD__c, a.BAD_ADDRESS_BIT__c, 
                    a.At_Risk__c, a.AnnualRevenue, a.Alias_Name__c, a.Additional_Comments__c, a.Account_Classification__c, a.ADDR_ID__c , a.OwnerId
                    From Account a where (a.Site_Duns__c =: accountSelected or  (a.DUNS_HQ__c =: accountSelected and a.ParentId != null)) and a.CustomerTypeID__c =:account.CustomerTypeID__c LIMIT 1]; //added logic to match on companyTypeId along with duns numbers
                }
                 // Neelima-04/20- added a.ParentId != null in the above where condition.
                if (existingDUNSAccounts != null && existingDUNSAccounts.size() > 0) {
                    System.debug(LoggingLevel.INFO, 'Found matching account: ' + account);
                    account = existingDUNSAccounts[0];
                    /*
                    if (account.OwnerId != recordOwner.OwnerId) { 
                        accountForTeamRole = account.Id;
                    }
                    */
                    this.accountState = RyderGlobalVariables.LeadConversionAccountState.ExistingSFDCAcct.name();
                } else  {
                
                // Check if it is a Duns number we are trying to add 
                if (accountSelected != RyderGlobalVariables.CREATE_NEW)
                {
                    //Changed by: Raja Sampath
                    //Change Date: 10/10/11
                    //Change for National Rental
                    //Conditionally calling new method if customer type is FMS Rental
                    //isRyderCompany = createDnBAccount();
                    if (account.CustomerTypeID__c=='FMS Rental')
                    {
                        isRyderCompany = createDnBAccountForRental();
                    }
                    else
                    {
                        isRyderCompany = createDnBAccount();
                    } 
                }               
                else
                {
                    //Changed by: Raja Sampath
                    //Change Date: 10/10/11
                    //Change for National Rental, added check for FMS Rental and skip calling radar for rental accounts
                    //Condtional Code added
                    
                    if (account.CustomerTypeID__c=='FMS Rental')
                    {
                                account.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Rental_Account.name());
                                // since account is missing DnB information
                                account.Missing_DNB__c = true;
                                insert account;
                                System.debug('Added new account');
                    }
                    else
                    {
                    //End Change for National rental
                    
                        // Create a record on Ryder for Duns number = null, i.e. non DnB account
                        CommonFunctions commonFunction = new CommonFunctions();
                        Integer companyId = commonFunction.createAccountsOnRyder(account, false, true);
                        System.debug('companyId - ' + companyId);
        
                        // Check if the record was created on Ryder and now insert the account on SFDC
                        if (companyId != -1)
                        {
                            System.debug('Account to insert without DUNS - '+account);
                            Account matchingCustProspectAccount = getAccountByCustProspectId(companyId);
                            if (matchingCustProspectAccount == null) {
                                account.CustProspectID__c = String.valueOf(companyId);
                                account.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Parent_Account.name());
                                // since account is missing DnB information
                                account.Missing_DNB__c = true;
                                insert account;
                                System.debug('Added new account');
                                
                                 // This is required for contacts not converted from lead
                                /*
                                    REMOVED as New Account creation does not create any contact - 2/2/11
                                if (this.fromLead == true && account.id != null)
                                {
                                    contact = new contact(firstname=contact.FirstName, lastname=contact.LastName,accountid=account.id);
                                    insert contact;
                                    System.debug('Added new contact');
                                }
                                */
                            } else {
                                String errMsg = RyderGlobalVariables.DUPLICATE_CUST_PROSPECT_ACCOUNT;
                                errMsg +=  matchingCustProspectAccount.Name;
                                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, errMsg);
                                ApexPages.addmessage(errorMsg);
                                System.debug(LoggingLevel.INFO, errMsg);
                            }
                        }
                    //Changed by: Raja Sampath
                    //Change Date: 10/10/11
                    //Change for National Rental, added check for FMS Rental and skip calling radar for rental accounts
                    //Condtional Code added - end condition
                    }
                    //End of national rental change
                }
            }
        }
        
        System.debug('*********** End createCompany **************');
        return isRyderCompany;
    }

    /*
    *   Check if the custProspectId returned from the createCompany already exists in the salesforce
    */
    private Account getAccountByCustProspectId(Integer companyId) {
        Account result = null;
        if (companyId != null) {
            List<Account> tempAccounts = [select a.id, a.Name, a.CustProspectID__c from Account a where a.CustProspectID__c =: String.valueOf(companyId) LIMIT 1];
            if (tempAccounts != null && tempAccounts.size() > 0) {
                result= tempAccounts[0];
            }
        }
        return result;
    }
        
    /**
     * assignContact - Assign Contact to global variable contactSelected that can be created or attached to existing 
     * 
     * @param       void            
     * @return      Account
     */
    public void assignContact()
    {
               
    }

    /**
     * createDnBAccount - Create a DnB account and insert account hierarchy in Salesforce
     * 
     * @param       void            
     * @return      Account
     */
    private Boolean createDnBAccount()
    {
        System.debug('*********** Start createDnBAccount **************');
        // Initialize the variables
        Map<String, Account> accounts = new Map<String, Account>(); 
        Map<String, String> mapParentDuns = new Map<String, String>(); 

        Boolean isRyderCompany = false;
        System.debug('About to add Duns to Ryder - ' + accountSelected);
        Boolean gotHQ = false;
        Integer i = 0;
        Account acct;
        Account headquarter;
        boolean existingHeadQuarter = false;
        Set<String> dunsNumbers = new Set<String>();        
        // VERY IMPORTANT - Do not change the logic or steps here because we run into a problem of transaction lock
        // Go through the loop and see to find the hierarchy and get the Head Quarters for ryder
        while (gotHQ == false)
        {
            System.debug(LoggingLevel.INFO, 'inside gotHQ = false');
            this.isBranch = false;
            
            // If it is the first one we pass the one that user selected else pass the parent info
            if (i==0)
            {
                // For first time user is passing SiteDUNS as accountSelected.
                acct = getCorporateLinkage(accountSelected);
                //Changed by: Raja Sampath
                //Change Date: 10/10/11
                //Change for National Rental. Set Record Type in this logic instead of getCorporateLinkageMethod
                if(this.isBranch==true)
                {
                    acct.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_FMS_Branch_Account.name());
                }
                else
                {
                    acct.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Parent_Account.name());
                }
                //End Change for National Rental
                                    
                System.debug(LoggingLevel.INFO, '+++++++++++ acct from getCorporateLinkage: ' + acct);
                // VISHAL 12/13/2010 - THIS NEED TO BE RE_VISITED because current implementation only allows  
                // FMS child to have FMS parent and RIL to only have RIL parent
                acct.CustomerTypeID__c = account.CustomerTypeID__c;
                acct.CompanyTypeID__c = account.CompanyTypeID__c;
                acct.CO_SEGMENT__c = account.CO_SEGMENT__c;
                // Lead Field: National_Account_Flag  should map to Account Field: Account_Classification.   The lead field is a Boolean and the Account Classification is picklist, with value National.
                if (this.fromLead == true && lead.National_Account_Flag__c == true) {
                    acct.Account_Classification__c  = RyderGlobalVariables.AccountClassification.National.name();
                }
                
                // Assign the account to the main account selected 
                account = acct;
                this.accountState = RyderGlobalVariables.LeadConversionAccountState.MatchFromDnB.name();
                System.debug(LoggingLevel.INFO, '+++++++++++ account set to information coming from DnB : ' + account);
                
            }
            else
            {
                acct = getCorporateLinkage(acct.DUNS_HQ__c);
                System.debug(LoggingLevel.INFO, '+++++++++++ acct from getCorporateLinkage2: ' + acct);
                // VISHAL 12/13/2010 - THIS NEED TO BE RE_VISITED because current implementation only allows  
                // FMS child to have FMS parent and RIL to only have RIL parent
                
                //Changed by: Raja Sampath
                //Change Date: 10/10/11
                //Change for National Rental. Set Record Type in this logic instead of getCorporateLinkageMethod
                if(this.isBranch==true)
                {
                    acct.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_FMS_Branch_Account.name());
                }
                else
                {
                    acct.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Parent_Account.name());
                }
                //End Change for National Rental
                
                acct.CustomerTypeID__c = account.CustomerTypeID__c;
                acct.CompanyTypeID__c = account.CompanyTypeID__c;
                if (this.fromLead) {
                    acct.CO_SEGMENT__c = lead.Segment__c;
                    // Lead Field: National_Account_Flag  should map to Account Field: Account_Classification.   The lead field is a Boolean and the Account Classification is picklist, with value National.
                    if (lead.National_Account_Flag__c == true) {
                        acct.Account_Classification__c  = RyderGlobalVariables.AccountClassification.National.name();
                    }
                } else {
                    acct.CO_SEGMENT__c = account.CO_SEGMENT__c;
                }
                gotHQ = true;
            }
            
            
            System.debug('Branch Indicator - ' + this.isBranch);
            
            // Prior to writing this code, i made a decision to retrieve the 
            // highest HQ information but since that is not the case we 
            // just get the immediate parent
            // Check if the branch is not a branch or if we did not retrieve anything
            if (this.isBranch==false || gotHQ == true || acct.Site_Duns__c==null)
            {
                // if we did get information then we should have received the HQ info
                if (this.isBranch == false || gotHQ == true)
                {
                    gotHQ = true;
                    headquarter = acct;
                }
            }
                    
            // Since we have site info we need to insert that data
            if (acct.Site_Duns__c!=null)
            {
                
                dunsNumbers.add(acct.Site_Duns__c);
                if (this.fromLead) {
                    acct.ownerId = this.lead.ownerId;
                }
                else
                {
                    //Added by Raja - 10/26/11
                    //Manual account creation - Assign current logged in user as account owner
                    acct.OwnerId = Userinfo.getUserId();
                }
                // VERY IMPORTANT - this flag means that the parent can be of type RIL or FMS, if you need to have 
                // FMS as HQ and all child as FMS then change the logic below:
                // as mapParentDuns.put(acct.Site_Duns__c+'_'+acct.CustomerTypeId__c, acct.DUNS_HQ__c);
                mapParentDuns.put(acct.Site_Duns__c+(this.isBranch==true?'_'+acct.CustomerTypeId__c:''), this.isBranch==true? acct.DUNS_HQ__c: acct.Site_Duns__c);
                // Go through the accounts and put the duns number and set the accounts
                accounts.put(acct.Site_Duns__c+(this.isBranch==true?'_'+acct.CustomerTypeId__c:''), acct);
                System.debug('Accounts to update 1- '+accounts);    
            }
            i++;
        }
            
        // Check if the accounts are to be created and that HQ is within account object
        if (accounts.size()>0 && account != null && headquarter!=null)
        {
            Account[] existingAccounts = [Select a.addr_verified_date__c, a.Website, a.Type, 
                a.Top10Account__c, a.Speed_Changes__c, a.Site_Duns__c, a.Sic, a.SIC_Code__c, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, 
                a.ShippingCountry, a.ShippingCity, a.STATUS_ACTIVE__c, a.Ryder_Specific_Loc_Type__c, a.Risk_ID__c, a.RiskStatusStable__c, 
                a.RiskStatusNoStatus__c, a.RiskStatusGrowth__c, a.RiskStatusAtRisk__c, a.RecordTypeId, a.RYDER_LOC_TYPE__c, a.Phone_2__c, 
                a.Phone, a.ParentId, a.Pager__c, a.PO_NUMBER__c, a.Other_Misc_Billing_Information__c, a.Other_Instructions__c, 
                a.NumberOfEmployees, a.NationalCustFlag__c, a.Name, a.NATL_RNTL_CUST_ID__c, a.MasterRecordId, a.LesseeNo__c, 
                a.Legal_Site_Duns__c, a.Legal_Entity_Address_Zip_Postal_Code__c, a.Legal_Entity_Address_Street__c, 
                a.Legal_Entity_Address_State_Province__c, a.Legal_Entity_Address_Country__c, a.Legal_Entity_Address_City__c, 
                a.Legacy_Last_Modified_Date__c, a.Legacy_Last_Modified_By__c, a.LastActivityDate, a.LOC_ID__c, a.Industry, a.Id, 
                a.Guarantor_Address_Zip_Postal_Code__c, a.Guarantor_Address_Street__c, a.Guarantor_Address_State_Province__c, 
                a.Guarantor_Address_Country__c, a.Guarantor_Address_City__c, a.Growth_Status_Percent__c, a.Global_Ultimate_DUNS__c, 
                a.GROWTH_ACC__c, a.FormerCustomer__c, a.Fax, a.Family_Company_id__c, a.Family_Company_Owner_id_del__c, 
                a.Family_Company_Name__c, a.Domestic_Ultimate_DUNS__c, a.Description, a.DUNS_HQ__c, a.DNB_Subsidiary_Type__c, 
                a.DB_Loc_Type__c, a.DBA__c, a.DBA_5__c, a.DBA_4__c, a.DBA_3__c, a.DBA_2__c, a.CustomerTypeID__c, a.CustProspectID__c, 
                a.CurrencyIsoCode, a.Components_Not_Included__c, a.CompanyTypeID__c, a.Central_Decisionmaking__c, a.Cell__c, 
                a.CUST_REPAIR_LIMIT__c, a.CR_STATUS_REASON__c, a.CO_SEGMENT__c, a.CO_RYDER_ANNSRY__c, a.CO_OWNER_ID__c, a.CO_ANNSRY__c, 
                a.Billing_Phone__c, a.Billing_Fax__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, 
                a.BillingCity, a.BUSINESS_STATUS__c, a.BAD_ADDR_REASON__c, a.BAD_ADDR_DATE__c, a.BAD_ADDR_CD__c, a.BAD_ADDRESS_BIT__c, 
                a.At_Risk__c, a.AnnualRevenue, a.Alias_Name__c, a.Additional_Comments__c, a.Account_Classification__c, a.ADDR_ID__c, a.OwnerId
                From Account a WHERE a.Site_Duns__c IN: dunsNumbers
                and a.CustomerTypeID__c =: account.CustomerTypeID__c]; //added logic to match on companyTypeId along with duns numbers
            
            // Go through the accounts and put the duns number and set the accounts
            for(Account existingAcct : existingAccounts)
            {
                String strToCompare = existingAcct.Site_Duns__c+(existingAcct.ParentId!=null?'_'+existingAcct.CustomerTypeId__c:'');
                System.debug('strToCompare - '+strToCompare);
                System.debug('accounts.containsKey - '+accounts.containsKey(strToCompare));
                //System.debug('existingAcct.Site_Duns__c -'+existingAcct.Site_Duns__c);
                //System.debug('existingAcct.ParentId-'+existingAcct.ParentId);
                //System.debug('existingAcct.CustomerTypeId-'+existingAcct.CustomerTypeId__c);
                            
                // Check if the accounts contains the site duns
                if (accounts.containsKey(strToCompare))
                {
                    accounts.put(strToCompare, existingAcct);
                    System.debug('Accounts to update 2 - '+accounts);
                    if (headquarter.Site_Duns__c == existingAcct.Site_Duns__c) {
                        headquarter = existingAcct;
                        existingHeadQuarter = true;
                        System.debug('Found existing HQ- '+ headquarter); 
                    } else {
                        if (existingAcct.OwnerId != recordOwner.OwnerId) { 
                            accountForTeamRole = existingAcct.Id;
                        }
                    }
                }
            }
        
            //System.debug('Accounts - '+accounts);
            // Call the common function to create the account on ryder for the primary HQ for the branch
            CommonFunctions commonFunction = new CommonFunctions();
            boolean usePhysicalAddr = false;
            if (headquarter.id != null) {
                usePhysicalAddr = true;
            }
            
            Integer companyId = -1;
            // added logic to not call create company if headquarter is found
            if (existingHeadQuarter) {
                companyId = Integer.valueOf(headquarter.CustProspectID__c);
            } else {
                companyId = commonFunction.createAccountsOnRyder(headquarter, usePhysicalAddr, false);
            }
            
            //mph update newly created account w/ custprospectid returned from call
            //system.debug('headquarter: ' + headquarter);
            //headquarter.CustProspectID__c = String.valueOf(companyId);
            //upsert headquarter;
            
            System.debug('companyId - ' + companyId);

            // Check if the record was created on Ryder
            if (companyId != -1)
            {
                System.debug('Accounts to update 3 - '+accounts);
                RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
                // Accounts to be upserted
                System.debug(LoggingLevel.INFO, '+++++++++++++++ accounts that are about to be upserted:' + accounts);
                //upsert accounts.values();
                //modified upsert to just insert
                List<Account> insertNewAcct = new List<Account>();
                for(Account newAcct : accounts.values())
                {
                    if (newAcct.Id == null) {
                        insertNewAcct.add(newAcct);
                    }
                }
                System.debug(LoggingLevel.INFO, '+++++++++++++++ accounts that are about to be inserted:' + insertNewAcct);
                if (insertNewAcct.size() > 0) {
                    insert insertNewAcct;
                }
            
                // Set the parent id for the child and ryder id for the parent
                List<Account> acctsToUpdate = new List<Account>();
                for(Account newAcct : accounts.values())
                {
                    System.debug('newAcct - '+newAcct);
                    
                    // Check if the site duns and hq duns is the same and presume it is headquarters
                    if (newAcct.DUNS_HQ__c==null || newAcct.Site_Duns__c == newAcct.DUNS_HQ__c)
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
                                // since we found existing parent we need to copy account status to be same as parent.
                                newAcct.Account_Classification__c =accounts.get(mapParentDuns.get(newAcct.DUNS_HQ__c)).Account_Classification__c;
                                // newAcct.Type = accounts.get(mapParentDuns.get(newAcct.DUNS_HQ__c)).Type;
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
                isRyderCompany = true;
            }
        }   
        System.debug('*********** End createDnBAccount **************');
        return isRyderCompany;
    }
    
    
    /**
     * createDnBAccount - Create a DnB account for rental and insert account hierarchy in Salesforce
     * 
     * @param       void            
     * @return      Account
     * @createdby   Raja Sampath
     * @createddate 10/07/2011
     * @desc        Added this method to create DNB accounts for national rental lead conversion            
     */
    private Boolean createDnBAccountForRental()
    {
        System.debug('*********** Start createDnBRentalAccount **************');
        // Initialize the variables
        Map<String, Account> accounts = new Map<String, Account>(); 
        Map<String, String> mapParentDuns = new Map<String, String>(); 

        Boolean isRyderCompany = false;
        System.debug('About to add Duns to Ryder - ' + accountSelected);
        Boolean gotHQ = false;
        Integer i = 0;
        Account acct;
        Account parentAcct;
        Account hqAcct;
        boolean isBranchAccount = false;
        boolean createParentAcct = false;
        boolean updateParentAcct = false;
        boolean createHQAcct = false;
        boolean updateHQAcct = false;
        Set<String> dunsNumbers = new Set<String>();        
        
        //this.isBranch = false;
        
        System.debug('*********** createDnBRentalAccount - getting account using corporate linkage **************');
        acct = getCorporateLinkage(accountSelected);
        isBranchAccount = this.isBranch;
        //Changed by: Raja Sampath
        //Change Date: 10/10/11
        //Change for National Rental
        System.debug('*********** createDnBRentalAccount - setting pure rental record type **************');
        acct.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Rental_Account.name());
        //End Change for National Rental
        
        System.debug(LoggingLevel.INFO, '+++++++++++ acct from getCorporateLinkage: ' + acct);
        // VISHAL 12/13/2010 - THIS NEED TO BE RE_VISITED because current implementation only allows  
        // FMS child to have FMS parent and RIL to only have RIL parent
        acct.CustomerTypeID__c = account.CustomerTypeID__c;
        acct.CompanyTypeID__c = account.CompanyTypeID__c;
        acct.CO_SEGMENT__c = account.CO_SEGMENT__c;
        // Lead Field: National_Account_Flag  should map to Account Field: Account_Classification.   The lead field is a Boolean and the Account Classification is picklist, with value National.
        if (this.fromLead == true)
        {
            System.debug('*********** createDnBRentalAccount - setting Account owner from lead **************');
            acct.ownerId = this.lead.ownerId;
            if(lead.National_Account_Flag__c == true) 
            {   
                System.debug('*********** createDnBRentalAccount - setting Account as National **************');
                acct.Account_Classification__c  = RyderGlobalVariables.AccountClassification.National.name();
            }
        }
        else
        {
            //Manual account creation - Assign current logged in user as account owner
            acct.OwnerId = Userinfo.getUserId();
        }
        // Assign the account to the main account selected 
        account = acct;
        this.accountState = RyderGlobalVariables.LeadConversionAccountState.MatchFromDnB.name();
        
        System.debug(LoggingLevel.INFO, '+++++++++++ account set to information coming from DnB : ' + account);
            
        if(account.Site_Duns__c!=null && account.Domestic_Ultimate_DUNS__c!=null 
            && account.Site_Duns__c==account.Domestic_Ultimate_DUNS__c)
        {
            //account selected is domestic ultimate.. so create the account as it is.. no further check is required
            System.debug('*********** createDnBRentalAccount - convert account is domestic ultimate **************');
            parentAcct = null;
        }
        else
        {
            String parentSiteDuns = null;
            //Check if parent already exists (domestic ult)
            if(account.Site_Duns__c!=null && account.Domestic_Ultimate_DUNS__c!=null && 
            account.Site_Duns__c!=account.Domestic_Ultimate_DUNS__c)
            {
                System.debug('*********** createDnBRentalAccount - Check if DOMULT already exists ');
                parentAcct = getExistingAccount(account.Domestic_Ultimate_DUNS__c, account.CustomerTypeID__c);
                if(parentAcct==null) //no records found & set domestic ult duns as parent duns and create DOM ULT Account
                {
                    parentSiteDuns = account.Domestic_Ultimate_DUNS__c;
                    System.debug('*********** createDnBRentalAccount - After Setting Parent Site DUNS from DOM ULT ' + parentSiteDuns);
                    if(parentSiteDuns!=null && parentSiteDuns!='')
                    {
                        System.debug('*********** createDnBRentalAccount - getting DNB data fir DOM ULT ' + parentSiteDuns);
                        parentAcct = getCorporateLinkage(parentSiteDuns);
                        if(parentAcct!=null)
                        {
                            System.debug('*********** createDnBRentalAccount - after getting parent from DNB - Create Account ************** ');
            
                            System.debug('*********** createDnBRentalAccount - setting parent record type to pure rental and other values ************** '); 
                            parentAcct.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Rental_Account.name());
                            parentAcct.OwnerId = account.ownerId;
                            parentAcct.CustomerTypeID__c = account.CustomerTypeID__c;
                            parentAcct.CompanyTypeID__c = account.CompanyTypeID__c;
                            parentAcct.CO_SEGMENT__c = account.CO_SEGMENT__c;
                            parentAcct.Account_Classification__c  = account.Account_Classification__c; 
                            System.debug('*********** createDnBRentalAccount - before inserting parent account');
                            createParentAcct = true;
                            //RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
                            //insert parentAcct;
                            System.debug('*********** createDnBRentalAccount - after inserting domestic ultimate parent account ************** ');
                        }
                        else
                        {
                            System.debug('*********** createDnBRentalAccount - DOMESTIC ULTIMATE not found in DNB');
                        }
                        
                    }
                }
                else
                {
                    if(parentAcct.Missing_DNB__c)
                    //|| (parentAcct.Global_Ultimate_DUNS__c==null && parentAcct.DUNS_HQ__c ==null
                        //&& parentAcct.Domestic_Ultimate_DUNS__c==null && parentAcct.DB_Loc_Type__c ==  null))
                    {
                        //Mannually or thro ETL account was loaded
                        //try updating dnb information
                        System.debug('*********** createDnBRentalAccount - Refreshing DNB info for DOM ULT account');
                        parentAcct = RefreshDNBInformation(parentAcct);
                        updateParentAcct = true;
                    
                    }
                     
                    System.debug('*********** createDnBRentalAccount - DOMESTIC ULTIMATE ALREADY EXISTS in SFDC');
                }
            }
            
            //Check if the acct is a branch and create HQ if needed, 
            //legacy data or transitional data may exists with this condition  
            System.debug('*********** createDnBRentalAccount - Checking to see if HQ validation is required *****');
            System.debug('isBranchAccount  = ' + isBranchAccount );
            System.debug('account.Site_Duns__c  = ' + account.Site_Duns__c );
            System.debug('account.DUNS_HQ__c  = ' + account.DUNS_HQ__c );
            System.debug('account.Domestic_Ultimate_DUNS__c  = ' + account.Domestic_Ultimate_DUNS__c );
            System.debug('Evaluate DOM ULT = HQ Check  = ' + (account.Domestic_Ultimate_DUNS__c==null || account.DUNS_HQ__c!=account.Domestic_Ultimate_DUNS__c));
            if( isBranchAccount 
                && account.Site_Duns__c!=null && account.DUNS_HQ__c!=null
                && (account.Domestic_Ultimate_DUNS__c==null || account.DUNS_HQ__c!=account.Domestic_Ultimate_DUNS__c)
                && account.Site_Duns__c!=account.DUNS_HQ__c)
            {
            }
            if( isBranchAccount 
                && account.Site_Duns__c!=null && account.DUNS_HQ__c!=null
                && (account.Domestic_Ultimate_DUNS__c==null || account.DUNS_HQ__c!=account.Domestic_Ultimate_DUNS__c)
                && account.Site_Duns__c!=account.DUNS_HQ__c)
            {
                System.debug('*********** createDnBRentalAccount - Check if HQ already exists *****');
                hqAcct = getExistingAccount(account.DUNS_HQ__c, account.CustomerTypeID__c);
                System.debug('*********** createDnBRentalAccount - Check if HQ already exists ************** ');
                
                if(hqAcct==null) //no records found & no domestic ultmiate exists
                {
                    parentSiteDuns = account.DUNS_HQ__c;
                    System.debug('*********** createDnBRentalAccount - After Setting Parent Site DUNS from HQ Duns ' + parentSiteDuns);
                    if(parentSiteDuns!=null && parentSiteDuns!='')
                    {
                        System.debug('*********** createDnBRentalAccount - getting DNB data fir HQ Account ' + parentSiteDuns);
                        hqAcct = getCorporateLinkage(parentSiteDuns);
                        if(hqAcct!=null)
                        {
                            System.debug('*********** createDnBRentalAccount - after getting parent from DNB - Create Account ************** ');
            
                            System.debug('*********** createDnBRentalAccount - setting parent record type to pure rental and other values ************** '); 
                            hqAcct.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Rental_Account.name());
                            hqAcct.OwnerId = account.ownerId;
                            hqAcct.CustomerTypeID__c = account.CustomerTypeID__c;
                            hqAcct.CompanyTypeID__c = account.CompanyTypeID__c;
                            hqAcct.CO_SEGMENT__c = account.CO_SEGMENT__c;
                            hqAcct.Account_Classification__c  = account.Account_Classification__c; 
                            System.debug('*********** createDnBRentalAccount - before inserting parent account');
                            createHQAcct=true;
                            //RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
                            //insert hqAcct;
                            //addChildOwnerToParent(hqAcct);
                            System.debug('*********** createDnBRentalAccount - after inserting parent account ************** ');
                        }
                        else
                        {
                            System.debug('*********** createDnBRentalAccount - HQ account not found in DNB');
                        }
                    }                   
                }
                else
                {
                        System.debug('*********** createDnBRentalAccount - HQ Account ALREADY EXISTS in SFDC');
                        System.debug('*********** createDnBRentalAccount - Checking if existing HQs parent is domestic ultimate ************* ');
                        
                        if(hqAcct.Missing_DNB__c)
                        //|| (hqAcct.Global_Ultimate_DUNS__c==null && hqAcct.DUNS_HQ__c ==null
                            //&& hqAcct.Domestic_Ultimate_DUNS__c==null && hqAcct.DB_Loc_Type__c ==  null))
                        {
                            //Mannually or thro ETL account was loaded
                            //try updating dnb information
                            System.debug('*********** createDnBRentalAccount - Refreshing DNB info for HQ account');
                            hqAcct = RefreshDNBInformation(hqAcct);
                            updatehqAcct = true;
                            
                        }
                    
                        
                        if(parentAcct!=null && hqAcct.Domestic_Ultimate_DUNS__c!=null 
                        && hqAcct.Domestic_Ultimate_DUNS__c == parentAcct.Site_Duns__c 
                        && (hqAcct.ParentId==null || hqAcct.ParentId!=parentAcct.Id ))
                        {
                            System.debug('*********** createDnBRentalAccount - domestic ultimate is different ************* ');
                            hqAcct.ParentId = parentAcct.Id;
                            updateHQAcct=true;
                            //RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false; 
                            //update hqAcct;
                            //addChildOwnerToParent(hqAcct);
                        }
                }           
            }
        }
        //because of webservice callouts, data commit needs to happen after all the callouts. Else SFDC will give following error
        //"You have uncommitted work pending. Please commit or rollback before calling out.."  
        if(createParentAcct || updateParentAcct)
        {
            RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
            if (createParentAcct)   insert parentAcct;
            else if(updateParentAcct)  update parentAcct;
        }
        
        if(createHQAcct || updateHQAcct)
        {
            if(parentAcct!=null)
            {
                hqAcct.ParentId = parentAcct.Id;
            }
            RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
            
            if(createHQAcct) insert hqAcct;
            else if(updateHQAcct) update hqAcct;
            
            addAccountOwnerToParent(hqAcct,parentAcct);
        }     
                    
        if (hqAcct!=null)
        {
            System.debug('*********** createDnBRentalAccount - setting new accounts parent id, here parent is HQ account ************** ');
            account.ParentId = hqAcct.Id;
        }
        else if (parentAcct!=null)//HQ is null, so the accounts parent may be DOM ult 
        {
            System.debug('*********** createDnBRentalAccount - setting new accounts parent id, here parent is DOMULT ************** ');
            account.ParentId = parentAcct.Id;
        }
        
        System.debug('*********** createDnBRentalAccount - inserting converted lead account ************** ');
        RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
        insert account;
        
        
        List<Account> accountsToFixFinal = new List<Account>();
        List<Account> accountsToFix;
                
        if (hqAcct!=null)
        {
            System.debug('*********** Add child owner to parent ************** ');
            addAccountOwnerToParent(account, hqAcct);
            System.debug('*********** createDnBRentalAccount - parent account found - trying to clean up old data relationship ************** ');
            accountsToFix = getAccountsToFixAccountParent('HQ', hqAcct.Site_Duns__c, hqAcct.CustomerTypeID__c, hqAcct.Id);
            accountsToFixFinal = transferAccountCollection(accountsToFix, accountsToFixFinal);
            if (parentAcct!=null)
            {
                System.debug('*********** Add child owner to grand parent************** ');
                addAccountOwnerToParent(account, parentAcct);
                System.debug('*********** createDnBRentalAccount - domestic ultimate found - trying to clean up old data relationship ************** ');
                accountsToFix = getAccountsToFixAccountParent('HQ', parentAcct.Site_Duns__c, parentAcct.CustomerTypeID__c, parentAcct.Id);
                accountsToFixFinal = transferAccountCollection(accountsToFix, accountsToFixFinal);
                accountsToFix = getAccountsToFixAccountParent('DOMULT', parentAcct.Site_Duns__c, parentAcct.CustomerTypeID__c, parentAcct.Id);
                accountsToFixFinal = transferAccountCollection(accountsToFix, accountsToFixFinal);
            }
        }
        else if (parentAcct!=null)//HQ is null, so the accounts parent may be DOM ult 
        {
            System.debug('*********** Add child owner to parent - here parent is domultimate ************** ');
            addAccountOwnerToParent(account, parentAcct);
            System.debug('*********** createDnBRentalAccount - domestic ultimate account found - trying to clean up old data relationship ************** ');
            accountsToFix = getAccountsToFixAccountParent('HQ', parentAcct.Site_Duns__c, parentAcct.CustomerTypeID__c, parentAcct.Id);
            accountsToFixFinal = transferAccountCollection(accountsToFix, accountsToFixFinal);
            accountsToFix = getAccountsToFixAccountParent('DOMULT', parentAcct.Site_Duns__c, parentAcct.CustomerTypeID__c, parentAcct.Id);
            accountsToFixFinal = transferAccountCollection(accountsToFix, accountsToFixFinal);
            
        } 
        else
        {
            if(account!=null)
            {
                System.debug('*********** createDnBRentalAccount - converted account is a domestic ultimate or parent account - trying to clean up old data relationship ************** ');
                accountsToFix = getAccountsToFixAccountParent('HQ', account.Site_Duns__c, account.CustomerTypeID__c, account.Id);
                accountsToFixFinal = transferAccountCollection(accountsToFix, accountsToFixFinal);
                accountsToFix = getAccountsToFixAccountParent('DOMULT', account.Site_Duns__c, account.CustomerTypeID__c, account.Id);
                accountsToFixFinal = transferAccountCollection(accountsToFix, accountsToFixFinal);
            }
        }
        
        if(accountsToFixFinal!=null && accountsToFixFinal.size()>0)
        {
            System.debug('*********** fixAccountParent - updating parent id in cleanup accounts ************** ');
            RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
            update accountsToFixFinal;
        
            for(Account existingAcct : accountsToFixFinal)
            {
                System.debug('*********** Calling procedure to add child owner to parent account ************** ');
                addChildOwnerToParent(existingAcct);
            }
        } 
        
        isRyderCompany = true;
        System.debug('*********** End createDnBRentalAccount **************');
        return isRyderCompany;
    }

    private List<Account> transferAccountCollection(List<Account> fromAccounts, List<Account> toAccounts)
    {
        if(toAccounts==null) toAccounts = new List<Account>();
        for(Account existingAcct : fromAccounts)
        {
            toAccounts.Add(existingAcct);
        }
        
        return toAccounts;
    }
    private Account RefreshDNBInformation(Account existingAccount)
    {
        if(existingAccount!=null)
        {
            Account tempAccount = getCorporateLinkage(existingAccount.Site_Duns__c);
            if(tempAccount!=null)
            {
                existingAccount.Legal_Site_Duns__c  = tempAccount.Legal_Site_Duns__c ;
                existingAccount.DB_Loc_Type__c  = tempAccount.DB_Loc_Type__c ;
                existingAccount.DUNS_HQ__c  = tempAccount.DUNS_HQ__c ;
                existingAccount.Domestic_Ultimate_DUNS__c  = tempAccount.Domestic_Ultimate_DUNS__c ;
                existingAccount.Global_Ultimate_DUNS__c  = tempAccount.Global_Ultimate_DUNS__c ;
                existingAccount.DUNS_HQ__c  = tempAccount.DUNS_HQ__c ;
                existingAccount.Domestic_Ultimate_DUNS__c  = tempAccount.Domestic_Ultimate_DUNS__c ;
                existingAccount.Global_Ultimate_DUNS__c  = tempAccount.Global_Ultimate_DUNS__c ;
                existingAccount.Legal_Entity_Address_Street__c  = tempAccount.Legal_Entity_Address_Street__c ;
                existingAccount.Legal_Entity_Address_Zip_Postal_Code__c  = tempAccount.Legal_Entity_Address_Zip_Postal_Code__c ;
                existingAccount.Legal_Entity_Address_City__c  = tempAccount.Legal_Entity_Address_City__c ;
                existingAccount.Legal_Entity_Address_State_Province__c  = tempAccount.Legal_Entity_Address_State_Province__c ;
                existingAccount.Legal_Entity_Address_Country__c  = tempAccount.Legal_Entity_Address_Country__c ;
                existingAccount.BillingStreet  = tempAccount.BillingStreet ;
                existingAccount.BillingPostalCode  = tempAccount.BillingPostalCode ;
                existingAccount.BillingCity  = tempAccount.BillingCity ;
                existingAccount.BillingState  = tempAccount.BillingState ;
                existingAccount.BillingCountry  = tempAccount.BillingCountry ;
                existingAccount.ShippingStreet  = tempAccount.ShippingStreet ;
                existingAccount.ShippingPostalCode  = tempAccount.ShippingPostalCode ;
                existingAccount.ShippingCity  = tempAccount.ShippingCity ;
                existingAccount.ShippingState  = tempAccount.ShippingState ;
                existingAccount.ShippingCountry  = tempAccount.ShippingCountry ;
                existingAccount.SIC  = tempAccount.SIC ;
                existingAccount.SIC_Code__c  = tempAccount.SIC_Code__c ;
                existingAccount.Missing_DNB__c = false;
            }       
        }
        return existingAccount;
    }
    private Account getExistingAccount(String dunsNumber, String customerTypeId)
    {
            System.debug('*********** inside getExistingAccount() ************** DUNS ' + dunsNumber + ' customer type ' + customerTypeId);
            Account rtnAccount = null;
            List<Account> existingAccounts = [Select a.addr_verified_date__c, a.Website, a.Type, 
                a.Top10Account__c, a.Speed_Changes__c, a.Site_Duns__c, a.Sic, a.SIC_Code__c, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, 
                a.ShippingCountry, a.ShippingCity, a.STATUS_ACTIVE__c, a.Ryder_Specific_Loc_Type__c, a.Risk_ID__c, a.RiskStatusStable__c, 
                a.RiskStatusNoStatus__c, a.RiskStatusGrowth__c, a.RiskStatusAtRisk__c, a.RecordTypeId, a.RYDER_LOC_TYPE__c, a.Phone_2__c, 
                a.Phone, a.ParentId, a.Pager__c, a.PO_NUMBER__c, a.Other_Misc_Billing_Information__c, a.Other_Instructions__c, 
                a.NumberOfEmployees, a.NationalCustFlag__c, a.Name, a.NATL_RNTL_CUST_ID__c, a.MasterRecordId, a.LesseeNo__c, 
                a.Legal_Site_Duns__c, a.Legal_Entity_Address_Zip_Postal_Code__c, a.Legal_Entity_Address_Street__c, 
                a.Legal_Entity_Address_State_Province__c, a.Legal_Entity_Address_Country__c, a.Legal_Entity_Address_City__c, 
                a.Legacy_Last_Modified_Date__c, a.Legacy_Last_Modified_By__c, a.LastActivityDate, a.LOC_ID__c, a.Industry, a.Id, 
                a.Guarantor_Address_Zip_Postal_Code__c, a.Guarantor_Address_Street__c, a.Guarantor_Address_State_Province__c, 
                a.Guarantor_Address_Country__c, a.Guarantor_Address_City__c, a.Growth_Status_Percent__c, a.Global_Ultimate_DUNS__c, 
                a.GROWTH_ACC__c, a.FormerCustomer__c, a.Fax, a.Family_Company_id__c, a.Family_Company_Owner_id_del__c, 
                a.Family_Company_Name__c, a.Domestic_Ultimate_DUNS__c, a.Description, a.DUNS_HQ__c, a.DNB_Subsidiary_Type__c, 
                a.DB_Loc_Type__c, a.DBA__c, a.DBA_5__c, a.DBA_4__c, a.DBA_3__c, a.DBA_2__c, a.CustomerTypeID__c, a.CustProspectID__c, 
                a.CurrencyIsoCode, a.Components_Not_Included__c, a.CompanyTypeID__c, a.Central_Decisionmaking__c, a.Cell__c, 
                a.CUST_REPAIR_LIMIT__c, a.CR_STATUS_REASON__c, a.CO_SEGMENT__c, a.CO_RYDER_ANNSRY__c, a.CO_OWNER_ID__c, a.CO_ANNSRY__c, 
                a.Billing_Phone__c, a.Billing_Fax__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, 
                a.BillingCity, a.BUSINESS_STATUS__c, a.BAD_ADDR_REASON__c, a.BAD_ADDR_DATE__c, a.BAD_ADDR_CD__c, a.BAD_ADDRESS_BIT__c, 
                a.At_Risk__c, a.AnnualRevenue, a.Alias_Name__c, a.Additional_Comments__c, a.Account_Classification__c, a.ADDR_ID__c, a.OwnerId,
                a.Missing_DNB__c
                From Account a WHERE a.Site_Duns__c =: dunsNumber
                and a.CustomerTypeID__c =: customerTypeId order by a.CustProspectID__c]; //added logic to match on companyTypeId along with duns numbers
            
            
            // Go through the accounts and put the duns number and set the accounts
            for(Account existingAcct : existingAccounts)
            {
                //due to legacy data, we may have matching customer and prospect for given duns number. In such cases, return the customer as account
                rtnAccount = existingAcct;
                if (existingAcct.Type=='Customer')
                {
                    
                    //Found existing customer, return it to the caller
                    break;
                }
                System.debug('*********** inside getExistingAccount() - founnd matching account ************** ' + rtnAccount.Id);
            }
            return rtnAccount;      
    }
    
    private Account[] getAccountsToFixAccountParent(String dunsNumberType, String dunsNumberToSearch, String customerTypeId, String parentId)
    {
            Account[] existingAccounts = null;
            System.debug('*********** fixAccountParent - trying to clean up old data relationship ************** ');
            if(dunsNumberType!=null && dunsNumberType=='HQ')
            {
                existingAccounts = [Select a.Id, a.name, a.OwnerId, a.ParentId, a.Site_Duns__c, a.Domestic_Ultimate_DUNS__c, a.DUNS_HQ__c, a.Global_Ultimate_DUNS__c
                From Account a WHERE a.DUNS_HQ__c =: dunsNumberToSearch
                and a.CustomerTypeID__c =: customerTypeId and a.Id !=: parentId 
                and a.ParentId !=: parentId
                //and a.ParentId = null
                ]; 
            }
            else if (dunsNumberType!=null && dunsNumberType=='DOMULT')
            {
                existingAccounts = [Select a.Id, a.name, a.OwnerId, a.ParentId, a.Site_Duns__c, a.Domestic_Ultimate_DUNS__c, a.DUNS_HQ__c, a.Global_Ultimate_DUNS__c
                From Account a WHERE a.Domestic_Ultimate_DUNS__c =: dunsNumberToSearch
                and a.CustomerTypeID__c =: customerTypeId  and a.Id !=: parentId 
                //and a.ParentId !=: parentId
                and a.ParentId = null
                ]; 
                
            }
            
            // Go through the accounts and put the duns number and set the accounts
            for(Account existingAcct : existingAccounts)
            {
                System.debug('*********** fixAccountParent - found accounts for cleanup ************** ' + existingAcct.Id + ',' + existingAcct.Name);
                existingAcct.ParentId = parentId;
            }

                
            return existingAccounts;        
    }
    
    private void addChildOwnerToParent(Account account) {
       System.debug('*********** addChildOwnerToParent - trying to add child owner to parent account ************** ');
       if (account.ParentId != null) 
       {
         // if parent account exists and parent account owner is different then lead owner
         // add lead owner to parent account's team also.
         System.debug('*********** parent Id - ' + account.parentId);
         System.debug('*********** account owner Id - ' + account.OwnerId);
         Account parentAccount = [select id, ownerId from Account where id =: account.parentId];
         addAccountOwnerToParent(account, parentAccount);
       }
    }
    
    private void addAccountOwnerToParent(Account account,  Account parentAccount) {
       System.debug('*********** addChildOwnerToParent - trying to add child owner to parent account ************** ');
       if (account.ParentId != null) 
       {
         // if parent account exists and parent account owner is different then lead owner
         // add lead owner to parent account's team also.
         System.debug('*********** parent Id - ' + account.parentId);
         System.debug('*********** account owner Id - ' + account.OwnerId);
         //Account parentAccount = [select id, ownerId from Account where id in (select id from Account where id =: account.parentId)];
         if (parentAccount!=null && parentAccount.OwnerId != account.OwnerId) 
         {
            System.debug('*********** parent account owner Id - ' + parentAccount.OwnerId); 
            AccountTeamMember temp = new AccountTeamMember();
            temp.UserId = account.OwnerId;
            temp.TeamMemberRole = translateAccountTeamRole(account.OwnerId); 
            temp.AccountId = parentAccount.Id;
            insert temp;
            System.debug(LoggingLevel.INFO, '&&&&&&&&&&&&&&&& Account team member added:' + temp);
            System.debug(LoggingLevel.INFO, '&&&&&&&&&&&&&&&& Account team member parentAccountId:' + parentAccount.Id);
            System.debug(LoggingLevel.INFO, '&&&&&&&&&&&&&&&& Account team member recordOwner.OwnerId:' + account.OwnerId);
            // now retrieve the account share and update Oppty and Case level access.
            List<AccountShare> shareTemp = [Select a.UserOrGroupId, 
              a.RowCause, a.OpportunityAccessLevel, a.ContactAccessLevel, a.CaseAccessLevel, a.AccountId, 
              a.AccountAccessLevel 
              From AccountShare a where a.userOrGroupId =:recordOwner.OwnerId and a.RowCause = 'Team' and a.AccountId =: parentAccount.Id LIMIT 1];
              if (shareTemp != null && shareTemp.size() > 0) {
                   shareTemp[0].AccountAccessLevel=RyderGlobalVariables.WRITE_ACCESS;
                   shareTemp[0].OpportunityAccessLevel = RyderGlobalVariables.WRITE_ACCESS;
                   shareTemp[0].CaseAccessLevel = RyderGlobalVariables.READ_ACCESS;
                   update shareTemp[0];
              } else {
                // Do nothing as account might be already shared by either OWD or some other sharing rules.
              }                
         }   
       }
    }
    /*
    *   Add lead owner to parent account so owner has visibility to the account.
    */
    private void addToAccountTeam(String parentAccountId, Account acct) {
        if (parentAccountId != null) {
            
        }
    }
    
    /**
     * getCorporateLinkage - Get the acccount based on DnB Corporate Linkage information
     * 
     * @param       void            
     * @return      Account
     */
    private Account getCorporateLinkage(String dunsNumber)
    {
        System.debug('*********** Start getCorporateLinkage **************');
        Account acct = new Account();
        // if (this.strRecordTypeId != null)
        //    acct.RecordTypeId = this.strRecordTypeId;
            
        this.isBranch = false;
        DnB_WebServiceUtilities dnbWebServiceUtilities = new DnB_WebServiceUtilities(); 
        // Check the country
//        if (account.ShippingCountry == RyderGlobalVariables.COUNTRIES_USA)
//        {
//            CorporateLinkage corporateLinkage = dnbWebServiceUtilities.GetCorporateLinkage(dunsNumber);
//            System.debug('corporateLinkage - ' + corporateLinkage); 
//    
//            // Check if we got the corporate linkage from DNB
//            if (corporateLinkage.hasCorporateLinkage)
//            {
//                
//                // Checks if the company is a branch
//                this.isBranch = (corporateLinkage.branchIndicator == RyderGlobalVariables.BRANCH_INDICATOR_Y);
//                System.debug('Within getCorporate Linkage isBranch - '+isBranch);
//                acct.Site_Duns__c = corporateLinkage.dunsNumber;
//                acct.Legal_Site_Duns__c = corporateLinkage.dunsNumber;
//                acct.Legal_Entity_Address_Country__c = corporateLinkage.countryCode;
//                acct.DB_Loc_Type__c = CommonFunctions.translateDnBLocationInfo(corporateLinkage.locationStatus);
//               if (corporateLinkage.branchIndicator == RyderGlobalVariables.BRANCH_INDICATOR_N)
//                {
//                    // if not branch hqDuns comes across as null from DnB
//                    // hqDns == siteDuns logic is used to create parent/child relationship in SFDC
//                    //acct.DUNS_HQ__c = corporateLinkage.dunsNumber;
//                    //neelima-04/20 -- update to write corporate linkage hq duns to new account hq duns.
//                    acct.DUNS_HQ__c = corporateLinkage.hqDUNS==null?'':corporateLinkage.hqDUNS;
//                    acct.Domestic_Ultimate_DUNS__c = corporateLinkage.domesticUltimateDUNS;
//                    acct.Global_Ultimate_DUNS__c = corporateLinkage.globalUltimateDUNS;
//                    
//                    //Changed by: Raja Sampath
//                    //Change Date: 10/10/11
//                    //Change for National Rental
//                    //Moved record type assignment to caller
//                    
//                    //acct.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Parent_Account.name());
//                    //End National Rental Change
//                }
//                else
//                {
//                    acct.DUNS_HQ__c = corporateLinkage.hqDUNS;
//                    acct.Domestic_Ultimate_DUNS__c = corporateLinkage.domesticUltimateDUNS;
//                    acct.Global_Ultimate_DUNS__c = corporateLinkage.globalUltimateDUNS;
//                    //Changed by: Raja Sampath
//                   //Change Date: 10/10/11
//                    //Change for National Rental
//                    //Moved record type assignment to caller
//                    
//                    //acct.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_FMS_Branch_Account.name());
//                    
//                    //End National Rental Change
//                }   
//                
//                
//                // Get the business verification
//                BusinessVerification businessVerification = dnbWebServiceUtilities.GetBusinessVerification(dunsNumber);
//                System.debug('businessVerification - '+businessVerification);
//                
//                // Check if the business Verification exist
//                if (businessVerification.hasBusinessVerication)
//                {
//                    acct.Name = businessVerification.primaryName;
//                    acct.Legal_Entity_Address_Street__c = businessVerification.addressLine;
//                    acct.Legal_Entity_Address_Zip_Postal_Code__c = businessVerification.postalCode;
//                    acct.Legal_Entity_Address_City__c = businessVerification.postalTown;
//                    acct.Legal_Entity_Address_State_Province__c = businessVerification.stateProvince;
//                    acct.Legal_Entity_Address_Country__c = businessVerification.countryCode;
//    
//                    acct.BillingStreet = businessVerification.addressLine;
//                    acct.BillingPostalCode = CommonFunctions.formatZipCode(businessVerification.postalCode);
//                    acct.BillingCity = businessVerification.postalTown;
//                    acct.BillingState = businessVerification.stateProvince.toUpperCase();
//                    if (businessVerification.countryCode.trim().toUpperCase()==RyderGlobalVariables.COUNTRIES_CANADA_TEXT) {
//                       acct.BillingCountry = RyderGlobalVariables.COUNTRIES_CANADA; 
//                    } else {
//                       acct.BillingCountry = businessVerification.countryCode.toUpperCase();
//                    }
//                    acct.ShippingStreet = businessVerification.addressLine;
//                    acct.ShippingPostalCode = CommonFunctions.formatZipCode(businessVerification.postalCode);
//                    acct.ShippingCity = businessVerification.postalTown;
//                    acct.ShippingState = businessVerification.stateProvince.toUpperCase();
//                   if (businessVerification.countryCode.trim().toUpperCase()==RyderGlobalVariables.COUNTRIES_CANADA_TEXT) {
//                       acct.ShippingCountry = RyderGlobalVariables.COUNTRIES_CANADA; 
//                    } else {
//                       acct.ShippingCountry = businessVerification.countryCode.toUpperCase();
//                    }
//                   acct.SIC = businessVerification.sicCode;
//                    acct.SIC_Code__c = getSICLookupId(businessVerification.sicCode);
//                }   
//            }
//        }
//        else
//        {
            DnB_WorldBase.DATARS worldBase = dnbWebServiceUtilities.GetWorldBase(dunsNumber);
            System.debug('worldBase - '+worldBase);
            // logic added per Jose to identify branchc from worldbase call response
            /* from DnB Documentation
             BUSINESS STRUCTURE CODE 
            <MKT_BUS_STRUC_CD>
            Indicates whether the subject business is a parent or a subsidiary location.
            Possible values are: 0=single location; 1=headquarters; 2=branch.
            */
            
            string country = null;
            string zip = null;
            if (worldBase.MKT_PHYS_CTRY_TEXT.trim().toUpperCase()==RyderGlobalVariables.COUNTRIES_CANADA_TEXT) {
               country = RyderGlobalVariables.COUNTRIES_CANADA;
               zip =  worldBase.MKT_PHYS_POST_TOWN_CD;
            } else if (worldBase.MKT_PHYS_CTRY_TEXT.trim().toUpperCase()=='USA') {
			   country = RyderGlobalVariables.COUNTRIES_USA;
			   zip = worldBase.MKT_PHYS_POST_TOWN_CD.substring(0,5);
			   System.debug('country. worldBase - '+country);            	
            }            
            else {
               country = worldBase.MKT_PHYS_CTRY_TEXT;
               zip = worldBase.MKT_PHYS_POST_TOWN_CD;
            }                       
            System.debug('a1. worldBase - '+worldBase.MKT_BUS_STRUC_CD);            
            
            if (worldBase.MKT_BUS_STRUC_CD != null && worldBase.MKT_BUS_STRUC_CD == '2')
            {
                this.isBranch = true;
                acct.DUNS_HQ__c = worldBase.MKT_HDQ_PNT_DUNS;
                acct.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_FMS_Branch_Account.name());
                acct.DB_Loc_Type__c = 'Branch';
                System.debug('a2. worldBase - '+acct.DB_Loc_Type__c);
            } else {
                acct.DUNS_HQ__c = worldBase.MKT_DUNS_NBR;
                acct.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Parent_Account.name());
                if (worldBase.MKT_BUS_STRUC_CD != null && worldBase.MKT_BUS_STRUC_CD == '1') {
                	acct.DB_Loc_Type__c = 'Headquarters';                	
                	System.debug('a3. worldBase - '+acct.DB_Loc_Type__c);
                }
                else if (worldBase.MKT_BUS_STRUC_CD != null && worldBase.MKT_BUS_STRUC_CD == '0') {
                	
                	System.debug('a4. worldBase - '+acct.DB_Loc_Type__c);
                	acct.DB_Loc_Type__c = 'Single Location';
                }                               
            }
            acct.Name = worldBase.MKT_PRIM_NME;
            acct.Legal_Site_Duns__c=dunsNumber;
            acct.Site_Duns__c = dunsNumber;
            acct.Domestic_Ultimate_DUNS__c = worldBase.MKT_DOM_ULT_PNT_DUNS;
            acct.Global_Ultimate_DUNS__c = worldBase.MKT_GLBL_ULT_PNT_DUNS;
            //03/29 Neelima-- added legal duns
/*            acct.Legal_Site_Duns__c=dunsNumber;
            acct.DUNS_HQ__c = worldBase.MKT_HDQ_PNT_DUNS;
            acct.Domestic_Ultimate_DUNS__c = worldBase.MKT_DOM_ULT_PNT_DUNS;
            acct.Global_Ultimate_DUNS__c = worldBase.MKT_GLBL_ULT_PNT_DUNS;
*/            
            acct.Legal_Entity_Address_Street__c = worldBase.MKT_PHYS_ADR_LINE;
            acct.Legal_Entity_Address_Zip_Postal_Code__c = zip;
            acct.Legal_Entity_Address_City__c = worldBase.MKT_PHYS_POST_TOWN_TEXT;
            acct.Legal_Entity_Address_State_Province__c = worldBase.MKT_PHYS_GEO_AREA_CD;
            acct.ShippingCountry = country;
            acct.Legal_Entity_Address_Country__c = country;
                
            acct.BillingStreet = worldBase.MKT_PHYS_ADR_LINE;
            acct.BillingPostalCode = zip;
            acct.BillingCity = worldBase.MKT_PHYS_POST_TOWN_TEXT;
            acct.BillingState = worldBase.MKT_PHYS_GEO_AREA_CD;            
            acct.BillingCountry = country;            
            acct.ShippingStreet = worldBase.MKT_PHYS_ADR_LINE;
            acct.ShippingPostalCode = zip;
            acct.ShippingCity = worldBase.MKT_PHYS_POST_TOWN_TEXT;
            acct.ShippingState = worldBase.MKT_PHYS_GEO_AREA_CD;
            acct.ShippingCountry = country;
            acct.SIC = worldBase.MKT_SIC8;
            acct.SIC_Code__c = getSICLookupId(worldBase.MKT_SIC8);
            // account.RecordTypeId=this.isBranch ? accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_FMS_Branch_Account.name()):accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Parent_Account.name());
//        }
        System.debug('*********** End getCorporateLinkage **************' + acct);
        return acct;
    }


    /**
     * addSFDCNewContact adds an initial contact that the user can use to create
     * 
     * @param       void            
     * @return      SFDCContact
     */
    public SFDCContact addSFDCNewContact()
    {
        System.debug('*********** Start addSFDCNewContact **************');
        SFDCContact sfdcContact = new SFDCContact();
        sfdcContact.selected = false;
        sfdcContact.createOrAttach = RyderGlobalVariables.CREATE_NEW_CONTACT_LABEL;
        sfdcContact.contact = this.contact;

        System.debug('this.contact - '+this.contact);
        System.debug('*********** End addSFDCNewContact **************');
        return sfdcContact;
    }

    /**
     * addNewAccountItem adds an initial account that the user can use to create
     * 
     * @param       void            
     * @return      void
     */
    private void addNewAccountItem()
    {
        System.debug('*********** Start addNewAccountItem **************');
        if (sfdcAccountSearchResults != null)
            sfdcAccountSearchResults.clear();
        else
            sfdcAccountSearchResults = new List<SFDCAccount>();
            
        SFDCAccount sfdcAccount = new SFDCAccount();
        sfdcAccount.selected = false;
        sfdcAccount.canBeSelected = true;
        sfdcAccount.createOrAttach = RyderGlobalVariables.CREATE_NEW_LABEL;
        Account newAccount = new Account();
        newAccount.Name = account.Name;
        sfdcAccount.account = newAccount;
        sfdcAccountSearchResults.add(sfdcAccount);
        System.debug('*********** End addNewAccountItem **************');
    }
      
    /**
     * retrieveContacts retrieves contact for the account ids that exist for a particular combination used for find
     * 
     * @param       void            
     * @return      Boolean
     */
    private void retrieveContacts()
    {
        System.debug('*********** Start retrieveContacts **************');
        if (accountExistInfoMap.size()>0)
        {
            Contact[] existingContacts = [SELECT c.VOICE_MAIL__c, c.Title, c.Salutation, c.STATUS_ACTIVE__c, c.SPOUSE_NAME__c, c.ReportsToId, c.Phone, c.PAGER__c, 
                                c.OwnerId, c.OtherStreet, c.OtherState, c.OtherPostalCode, c.OtherPhone, c.OtherCountry, c.OtherCity, c.Name, c.MobilePhone, 
                                c.MasterRecordId, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity, c.LeadSource, c.LastName, 
                                c.LastCUUpdateDate, c.LastCURequestDate, c.LastActivityDate, c.LOC_ID__c, c.Email_does_not_exist__c, c.Id, c.HomePhone, c.HOME_ADD_ID__c, 
                                c.HOBBIES__c, c.FirstName, c.Fax, c.EmailBouncedReason, c.EmailBouncedDate, c.Email, c.Description, c.Department, c.DUP_UPD_DATE__c, 
                                c.DUP_PROCESSED_DATE__c, c.DUP_PROCESSED_BY__c, c.DUP_GROUP_NO__c, c.DUP_FLAG__c, c.DOB_CARD__c, c.CurrencyIsoCode, 
                                c.CT_NICK_NAME__c, c.CO_ID__c, c.COLLEGE__c, c.COA_CARD__c, c.CHILDREN_DESC__c, c.CELL__c, c.Birthdate, c.BUSS_PHONE2_EXTN__c, 
                                c.BUSS_PHONE1_EXTN__c, c.AssistantPhone, c.AssistantName, c.AccountId, c.ASST_PHONE_EXTN__c, c.ANVR_DATE__c 
                                FROM Contact c WHERE AccountId =: accountExistInfoMap.keySet()];
            
            System.debug('Contact - '+existingContacts);
            
            // Check the contact exist 
            if (existingContacts != null && existingContacts.size() > 0)
            {
                contactExistInfoMap = new Map<String, List<SFDCContact>>();
                
                // Need to insert all the records in a map so that we can display it for the user to select
                for (String accountId : accountExistInfoMap.keySet())
                {
                    List<SFDCContact> sfdcContacts = new List<SFDCContact>();
                    sfdcContacts.add(addSFDCNewContact());
                    for(Contact existingContact : existingContacts)
                    {
                        if (accountId == existingContact.AccountId)
                        {
                            SFDCContact sfdcContact = new SFDCContact();
                            sfdcContact.selected = false;
                            sfdcContact.contact = existingContact;
                            sfdcContacts.add(sfdcContact);
                            contactMap.put(existingContact.Id, existingContact);
                        }
                    }
                    // Check if the contact had values for account id
                    if (sfdcContacts.size()>0)
                        contactExistInfoMap.put(accountId, sfdcContacts);
                }
            }
        }       
        System.debug('*********** End retrieveContacts **************');
    }
    
    /**
     * displayContactInfo checks if the contact information is displayed based on existing account and contact being present
     * 
     * @param       void            
     * @return      PageReference
     */
    public void displayContactInfo()
    {
        System.debug('*********** Start displayContactInfo **************');
        foundContactRecords = false;
        System.debug('oldAccountSelected - '+oldAccountSelected);
        sfdcContactSearchResults = new List<SFDCContact>();
        // Only allow search for contacts, if user is converting leads
        if (fromLead == true) {
            if (contactExistInfoMap.containsKey(oldAccountSelected))
            {
                sfdcContactSearchResults = contactExistInfoMap.get(oldAccountSelected);
                for(SFDCContact sfdcContactExisting : sfdcContactSearchResults)
                {
                    if (sfdcContactExisting.createOrAttach != RyderGlobalVariables.CREATE_NEW_CONTACT_LABEL)
                        sfdcContactExisting.createOrAttach = RyderGlobalVariables.ATTACH_EXISTING_LABEL;
                    sfdcContactExisting.selected = false;
                }
                foundContactRecords = true;
            }
        }

        System.debug('contactExistInfoMap - '+contactExistInfoMap);
        System.debug('sfdcContactSearchResults - '+sfdcContactSearchResults);
        System.debug('foundContactRecords - '+foundContactRecords);

        System.debug('*********** End displayContactInfo **************');
    }
    
    /*
    *   Lookup for SIC Code based on external id
    */           
    private Id getSICLookupId(String externalSICCode) {
        Id result = null;
        List<SIC_Code__c> sicCode = [select id, ext_SICCodeID__c from SIC_Code__c where ext_SICCodeID__c =: externalSICCode];
        if (sicCode != null && sicCode.size() > 0) {
            result = sicCode[0].Id;
        }
        return result;
    }   
    
    /*
    *   Lookup for SIC Code based on sf id
    */ 
    private String getSICLookupBySFId(String sicCodeSFId) {
        Id result = null;
        List<SIC_Code__c> sicCode = [select id, ext_SICCodeID__c from SIC_Code__c where id =: sicCodeSFId];
        if (sicCode != null && sicCode.size() > 0) {
            result = sicCode[0].ext_SICCodeID__c;
        }
        return result;
    }
    
    /*
    *   Rollback Account and Contact
    */
    private void rollbackAccountConversion() {
        System.debug(LoggingLevel.INFO, '**************** inside rollbackAccountConversion:');
        System.debug(LoggingLevel.INFO, '**************** this.accountState:' + this.accountState);
        System.debug(LoggingLevel.INFO, '**************** this.contactState:' + this.contactState);
        try {
            if (this.contactState == RyderGlobalVariables.LeadConversionContactState.CreatedContact.name() && contact.id != null)  {
                System.debug(LoggingLevel.INFO, '**************** contact to be deleted: ' + contact);
                delete contact;
            }
            if (this.accountState != RyderGlobalVariables.LeadConversionAccountState.ExistingSFDCAcct.name() && account.id != null)  {
                System.debug(LoggingLevel.INFO, '**************** account to be deleted: ' + account);
                String custProspectId = account.CustProspectID__c;
                delete account;
                CommonFunctions.deleteAccountsOnRyder(custProspectId);
            }
            this.account = this.orgAccount.clone(false,true);
            System.debug(LoggingLevel.INFO, '**************** this.contact with before initialization:' + this.contact);
            this.contact = this.orgContact.clone(false,true);
            System.debug(LoggingLevel.INFO, '**************** this.contact with setting it back to org:' + this.contact);
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, '******************* Error rolling back lead conversion: ' + ex);  
        }
    }
}