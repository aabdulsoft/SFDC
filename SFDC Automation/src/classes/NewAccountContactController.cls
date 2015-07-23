/**
*
*   NewAccountContactController is a class that allows the user to convert account and associate it with D&B accounts.
*
*   Author           |Author-Email                      |Date       |Comment
*   -----------------|----------------------------------|-----------|--------------------------------------------------
*   Vishal Patel     |vishal@comitydesigns.com          |11.22.2010 |First draft
*   Sunil(Appirio) UVS changes 09.04.2014
*   AAK (Ryder) 12/04/2014 changes for QC 630 Change lead conversion process to use DUNSRIGHT API for matching and restore restricted functionality to create account without match
*/
public without sharing class NewAccountContactController  
{
    private String leadId {get; set;}
    private List<SelectOption> optionsCountries = new List<SelectOption>();
    //AAK 01/08/2015 Start - variable to hold Lead Source / Detail to Account Source Mapping for the SAM
    private Map<String, String> MapLeadtoAccountSource = new Map<String, String>();
    private String sleadSSD {get; set;} 
    //AAK 01/08/2015 End 
    private Account recordOwner = new Account();
    private List<Account> accountExistInfo = new List<Account>();
    private List<Contact> contactExistInfo = new List<Contact>();
    private Map<String, Account> accountExistInfoMap = new Map<String, Account>();
    private Map<String, List<SFDCContact>> contactExistInfoMap = new Map<String, List<SFDCContact>>();
    private Map<String, Contact> contactMap = new Map<String, Contact>();
    private Boolean isBranch {get; set;}
    public Boolean doNotAllowAccountCreation {get;set;}
    
    // Normal get/set of objects    
    public Account account {get; set;}
    public Contact contact {get; set;}
    public String pageTitle {get; set;}
    
    //Test for Parent Contact Creation
    //public Account parentAccount {get;set;}
    
    private Account orgAccount {get; set;}
    private Contact orgcontact {get; set;}

    public Account[] dbAccountSearchResults {get; set;}
    //AAK 12/04/2014 Start - QC630 Change lead conversion process to use DUNSRIGHT API for matching and restore restricted functionality to create account without match
    public Account[] dbAccountSearchResultsDUNSRight {get; set;}
    public List<DBAccount> dbAccountMatch = new List<DBAccount>();
    //AAK 12/04/2014 End
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
    
    // Sunil: below variable is used for UVS Changes
    public Boolean isIndividualLead{get;set;}
    public Boolean isIncorporatedLead{get;set;}
    
    public Boolean isUVSLead{get;set;}
    private Solutions_Interest__c currentSolutionInterest;
    
    
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
    + 'a.ADDR_ID__c, a.OwnerId, a.UVS_Type__c From Account a ';

    /**
     * NewAccountContactController acts as a constructor for the controller class.
     * Fetches the record details being referred in the context
     * 
     * @param        controller        
     * @return       void              
     */
    public NewAccountContactController(ApexPages.StandardController controller) 
    {
    doNotAllowAccountCreation = false;
        isIndividualLead = false;
          isIncorporatedLead = false;
        System.debug('*********** Start NewAccountController **************');
        this.fromLead = false;
        
        this.disableCreateAccount = true;
              
        this.labelAccountCreation =  RyderGlobalVariables.CREATE_ACCOUNT;
        
          
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
            //AAK 12/04/2014 Start
            //Changes for QC 536 Modify Lead Conversion process - For phone numbers - added Billing Phone and Fax
            //Changes for QC 642  Modify Lead Conversion Process to include data on lead object - DOT # added DOT_Number__c
            /*this.lead = [SELECT l.Website, l.Employee_Name__c, l.Employee_Email__c, l.Lead_Source_Detail__c, l.Entity_Type__c, l.Original_Decision_Maker__c, l.VEHICLE_CNT__c,l.Type__c, l.Truck_Usages__c, l.Tractor_Estimate__c, l.Title, l.Suspect_Id__c, l.Street, l.Status_Active__c, 
                            l.Status, l.State, l.Site_Duns__c, l.Sic_Code_Desc__c, l.Segment__c, l.Salutation, l.SUSPECT_LOC_ID__c, l.SIC_CODE__c, l.Rating, 
                            l.RECEIVED_MAIL_FOR_LEAD_BIT__c, l.PostalCode, l.Phone, l.PHONE_EXTN__c, l.PRODUCT_LINE__c,l.OwnerId,l.IsOpportunityNeeded__c, l.NumberOfEmployees, l.Nearest_Branch__c, l.Name, l.MasterRecordId, 
                            l.MGR_Email__c, l.MGR_TITLE__c, l.MGR_NAME__c, l.LeadSource, l.LastName, 
                            l.LOC_ID__c, l.IsUnreadByOwner, l.IsConverted, l.Industry, l.Id, l.Global_Ultimate_DUNS__c, l.FirstName, l.Final_Approval__c, l.EmailBouncedReason, 
                            l.EmailBouncedDate, l.Email, l.EXTRACT_NAME__c, l.ESTEQUIPTYPE__c, l.Duns_HQ__c, l.Domestic_Ultimate_DUNS__c, l.Distanct_to_Ryder_miles__c, 
                            l.Description, l.DM_Title__c, l.DM_Phone__c, l.DM_Name__c, l.DISPOSITION_CODE__c, l.DBD__c, l.DBD_NAME__c, l.CurrencyIsoCode, l.LastActivityDate,
                            l.Country, l.ConvertedOpportunityId, l.ConvertedDate, l.ConvertedContactId, l.ConvertedAccountId, l.Company, l.City, 
                            l.COMPTOROUTSOURCED__c, l.CFO_TITLE__c, l.CFO_NAME__c, l.CFO_Email__c, l.CALL_DATE__c, l.BDM__c, l.BDM_NAME__c, l.BDM_CODE__c, 
                            l.AnnualRevenue, SapID__c, Employee_Zipcode__c, Employee_Phone__c, l.APPROXSIZE__c, l.ADDR_ID__c, l.Customer_Type__c, l.Email_does_not_exist__c, l.National_Account_Flag__c, l.Data_Source__c
                        FROM Lead l WHERE Id =:this.leadId];*/

            this.lead = [SELECT l.Website, l.Employee_Name__c, l.Employee_Email__c, l.Lead_Source_Detail__c, l.Entity_Type__c, l.Original_Decision_Maker__c, l.VEHICLE_CNT__c,l.Type__c, l.Truck_Usages__c, l.Tractor_Estimate__c, l.Title, l.Suspect_Id__c, l.Street, l.Status_Active__c, 
                            l.Status, l.State, l.Site_Duns__c, l.Sic_Code_Desc__c, l.Segment__c, l.Salutation, l.SUSPECT_LOC_ID__c, l.SIC_CODE__c, l.Rating, 
                            l.RECEIVED_MAIL_FOR_LEAD_BIT__c, l.PostalCode, l.Phone, l.PHONE_EXTN__c, l.PRODUCT_LINE__c,l.OwnerId,l.IsOpportunityNeeded__c, l.NumberOfEmployees, l.Nearest_Branch__c, l.Name, l.MasterRecordId, 
                            l.MGR_Email__c, l.MGR_TITLE__c, l.MGR_NAME__c, l.LeadSource, l.LastName, 
                            l.LOC_ID__c, l.IsUnreadByOwner, l.IsConverted, l.Industry, l.Id, l.Global_Ultimate_DUNS__c, l.FirstName, l.Final_Approval__c, l.EmailBouncedReason, 
                            l.EmailBouncedDate, l.Email, l.EXTRACT_NAME__c, l.ESTEQUIPTYPE__c, l.Duns_HQ__c, l.Domestic_Ultimate_DUNS__c, l.Distanct_to_Ryder_miles__c, 
                            l.Description, l.DM_Title__c, l.DM_Phone__c, l.DM_Name__c, l.DISPOSITION_CODE__c, l.DBD__c, l.DBD_NAME__c, l.CurrencyIsoCode, l.LastActivityDate,
                            l.Country, l.ConvertedOpportunityId, l.ConvertedDate, l.ConvertedContactId, l.ConvertedAccountId, l.Company, l.City, 
                            l.COMPTOROUTSOURCED__c, l.CFO_TITLE__c, l.CFO_NAME__c, l.CFO_Email__c, l.CALL_DATE__c, l.BDM__c, l.BDM_NAME__c, l.BDM_CODE__c, 
                            l.AnnualRevenue, SapID__c, Employee_Zipcode__c, Employee_Phone__c, l.APPROXSIZE__c, l.ADDR_ID__c, l.Customer_Type__c, l.Email_does_not_exist__c, l.National_Account_Flag__c, l.Data_Source__c,
                            l.Billing_Phone__c, l.Billing_Fax__c, l.DOT_Number__c                            
                        FROM Lead l WHERE Id =:this.leadId];
    
            
            //AAK 12/04/2014 End
            recordOwner.OwnerId = this.lead.OwnerId;
            
            
            // Sunil: 9/9/2014 Check if Lead is a From UVS.
            isUVSLead = UVS_Util.isUVSProfile;
            System.debug('$$$: isUVSLead = ' + isUVSLead);
            
            if(isUVSLead == true){
              fillSolutionInterest();
              //AAK 01/08/2015 Start
             system.debug('lead source and detail: ' + sleadSSD);          
            }
            
            // Sunil: 9/9/2014 if Lead type is individual set below property.
            if(this.lead.Entity_Type__c == 'Individual Consumer'){
              isIndividualLead = true;
            }
            
            // Sunil: 9/19/2014 if Lead type is individual set below property.
            if(this.lead.Entity_Type__c == 'Incorporated'){
              isIncorporatedLead = true;
            }
            
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
            
            //AAK 12/04/2014 Start - Changes for QC 642 Modify Lead Conversion Process to include data on lead object - DOT #
            this.account.DOT_Number__c = lead.DOT_Number__c;
            //AAK 12/04/2014 End  
            //AAK 12/04/2014 Start - Changes for QC 536 Modify Lead Conversion process - For phone numbers            
            if (this.fromLead == true)
            {
                account.Billing_Phone__c = (lead.Billing_Phone__c!=null?lead.Billing_Phone__c:null);
                account.Billing_Fax__c = (lead.Billing_Fax__c!=null?lead.Billing_Fax__c:null);
                system.debug('billing phone : ' + lead.Billing_Phone__c);
                system.debug('billing fax : ' + lead.Billing_Fax__c);
            }                                
            //AAK 12/04/2014 End                      
            
            
            // neelima- april 12 2012- added the new contact source field to differentiate contacts created by lead conversion and new contact button.
            this.contact.Contact_Source__c=(RyderGlobalVariables.ContactSource.Lead_Conversion.name()).replace('_',' ');
            this.contact.FirstName = lead.FirstName;
            this.contact.LastName = lead.LastName;
            this.contact.Phone = lead.Phone;
            //AAK 12/04/2014 Start - Changes for QC 536 Modify Lead Conversion process - For phone numbers
            system.debug('lead Phone : ' + lead.Phone);
            this.contact.BUSS_PHONE1_EXTN__c = lead.PHONE_EXTN__c;
            //AAK 12/04/2014 End            
            this.contact.ownerId = lead.ownerId;
            if (lead.Email != null) {
                this.contact.Email = lead.Email;
            } else  {
                this.contact.Email_does_not_exist__c = true; 
                this.contact.Email_Does_Not_Exist_Reason__c = RyderGlobalVariables.I_WILL_UPDATE_LATER;
            }
            
            
            if(isUVSLead == true){
              // sunil; 09-16-2014; set default values for below fields.
              this.account.CO_SEGMENT__c = '0 - Three trucks or less';
              this.account.CompanyTypeID__c = '1 Corporation';
              this.account.CustomerTypeID__c = 'FMS';
              
              //sunil: set UVS Type
              this.account.UVS_Type__c = 'Prospect';
              
              // sunil: Set Employee Details
              if(this.lead.LeadSource == 'Employee Referral' ){
                this.account.SapID__c = this.lead.SapID__c;
                this.account.Employee_Zipcode__c = this.lead.Employee_Zipcode__c;
                this.account.Employee_Phone__c = this.lead.Employee_Phone__c;
                this.account.Employee_Name__c = this.lead.Employee_Name__c;
                this.account.Employee_Email__c = this.lead.Employee_Email__c;
              }
            }
            
            labelAccountCreation = RyderGlobalVariables.CONVERT_LEAD;
            
            System.debug(LoggingLevel.INFO, '+++++++++++ account set to : ' + account);
            
            System.debug('*********** End From Lead **************');
        }        
        else {
        
            // Sunil: 10/28/2014 If current user is UVS don't allow to create new Account. I-135961
            if(isUVSLead == true){
              doNotAllowAccountCreation = true;
            }
          
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
        System.debug('*********** End NewAccountContactController **************');
        
        
    }
    
    
    // Sunil: 9/9/2014 if Lead type is individual a page action will be called.
    public PageReference convertIndividualLead(){
      System.debug('@@@convert individual');
      if(this.isIndividualLead == true){
        return createNewAccount();
      }
      return null;
      
    }
    
    
    
    /**
     * Fetch Current Solution Interest for respective Lead.
     */
    private void fillSolutionInterest(){
      String productLine = Profile_Default_Products__c.getAll().get('VSM_VSR').Default_Product__c;
      
      if(String.isNOTBlank(ProductLine)){
        List<Solutions_Interest__c> lstSI = [SELECT Id, Lead_Id__c,Stage__c, Product_Line__c, Contact_Id__c
                            FROM Solutions_Interest__c WHERE Lead_Id__c = :this.lead.Id
                            AND Product_Line__c = :productLine];
        if(lstSI.size() > 0){
          currentSolutionInterest = lstSI.get(0);
        }   
      }
      system.debug('@@@currentSolutionInterest' + currentSolutionInterest);
    }
    
    
    
    /**
     * doSearch checks if the account exist in the account object before
     * checking D&B web services
     * @param        void        
     * @return       PageReference              
     */
    public PageReference doSearch(){
        try {
        System.debug('@@@ Start DoSearch **************');
        displayNewAccount = false;
        disableCreateAccount = true;
        this.canSelectAccountWithoutDnB = true;
        //AAK 01/08/2015 Start added to default the account source
        this.buildLeadToAccSourceMapping();

		//AAK 03/10/2015 Start - QC845 Modify Lead conversion for UVS users 
		//fixing when account created directly from the menu
		if(lead != null)
		{
			if(lead.LeadSource != null)
			{
			//AAK 03/10/2015 End
		        if (lead.Lead_Source_Detail__c != null)
		            sleadSSD = lead.LeadSource + lead.Lead_Source_Detail__c;
		        else            
		            sleadSSD = lead.LeadSource;
		    //AAK 03/10/2015 Start - QC845 Modify Lead conversion for UVS user 
		    //fixing when account created directly from the menu
			}
		}
        //AAK 03/10/2015 End
        
        system.debug('Testing lead source and detail: ' + sleadSSD);            
         //AAK 01/08/2015 End
        
        // Check if the DnB account exist, if so we need to clear it for new values
        if (dbAccountSearchResults != null){
          dbAccountSearchResults.Clear();
        }
            
        // Clear all the Salesforce results and repopulate with new values
        if(sfdcAccountSearchResults != null){
          sfdcAccountSearchResults.Clear();
        }
        
        this.orgAccount.CustomerTypeID__c = this.account.CustomerTypeID__c;
        this.orgAccount.CompanyTypeID__c = this.account.CompanyTypeID__c;
        //Swetha-----US Zipcode ---Ignoring special characters----
             
        //  String zipCode = String.escapeSingleQuotes(account.ShippingPostalCode);
        String zipCode;
        if(account.ShippingPostalCode !=null){
          zipCode = (account.ShippingPostalCode);
          System.debug('@@@ Before zipCode:'+zipCode);
          zipCode = zipCode.replaceAll('-', '');
          System.debug('@@@ After zipCode:'+zipCode);
        }
        
        // Build the SOQL
        String accountSOQL = strAccountSOQL;
        String tmpName = account.name;
        tmpName = tmpName.replaceall(' ', '%');
        //String whereClause = 'WHERE a.Name Like \'%' + String.escapeSingleQuotes(account.Name) + '%\'';
        String whereClause = 'WHERE a.Name Like \'%' + String.escapeSingleQuotes(tmpName) + '%\'';
        
        if(account.CustomerTypeID__c != null){
          whereClause += ' AND a.CustomerTypeID__c = \'' + String.escapeSingleQuotes(account.CustomerTypeID__c) + '\'';
        }
        
        if (account.ShippingStreet != null)
            whereClause += ' AND a.ShippingStreet Like \'%' + String.escapeSingleQuotes(account.ShippingStreet) + '%\''; 
        if (account.ShippingCity != null)
            whereClause += ' AND a.ShippingCity Like \'%' + String.escapeSingleQuotes(account.ShippingCity) + '%\'';
        if (account.ShippingState != null)
            whereClause += ' AND a.ShippingState Like \'%' + String.escapeSingleQuotes(account.ShippingState) + '%\'';
        if (account.ShippingPostalCode != null)
            whereClause += ' AND a.ShippingPostalCode Like \'%' + zipCode + '%\'';
            //whereClause += ' AND a.ShippingPostalCode Like \'%' + String.escapeSingleQuotes(account.ShippingPostalCode) + '%\'';
        if (account.ShippingCountry != null)
            whereClause += ' AND a.ShippingCountry Like \'%' + String.escapeSingleQuotes(account.ShippingCountry) + '%\'';
        
        // Sunil; 09-16-2014; search only individual accounts in the case of individual lead.
        if(this.isIndividualLead == true){
            whereClause += ' AND a.Company_Lead_Type__c = \'Individual\' ';
        }
        
        
        accountSOQL += whereClause;
        accountSOQL += ' LIMIT ' + RyderGlobalVariables.NUMBER_OF_RECORDS_PER_SEARCH;
        System.debug('@@@accountSOQL - ' + accountSOQL);   
        Account[] sfdcAccountResults = Database.query(accountSOQL);
        system.debug('@@@ sfdcAccountResults:' + sfdcAccountResults);
        
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
        if (sfdcAccountResults != null && sfdcAccountResults.size() > 0)
        {
            system.debug('@@@---293---'+sfdcAccountResults);
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
        
        
         // Sunil; 09-16-2014; In case of individual we won't need to search Data.com DUNS number and all.
        if(this.isIndividualLead == true){
          return null;
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
                
            //AAK 12/04/2014 Start - QC630 Change lead conversion process to use DUNSRIGHT API for matching and restore restricted functionality to create account without match
            if (dbAccountMatch != null)
                dbAccountMatch.clear();
            else
                dbAccountMatch = new List<DBAccount>();
            //AAK 12/04/2014 End
                
            
            CommonFunctions commonFunction = new CommonFunctions();
            
               //AAK 12/04/2014 Start - QC630 Change lead conversion process to use DUNSRIGHT API for matching and restore restricted functionality to create account without match

                dbAccountSearchResultsDUNSRight = commonFunction.getSFDCAccountsFromDatacomMatch(account.Name, account.ShippingState, account.ShippingCountry,
                                                                                 account.ShippingStreet, account.ShippingCity, account.ShippingPostalCode,
                                                                                 contact.Phone);
                                                                                 
                system.debug(LoggingLevel.INFO, '+++++++++++++++++ dbAccountSearchResultsDUNSRight: ' + dbAccountSearchResultsDUNSRight);
                if (dbAccountSearchResultsDUNSRight != null && dbAccountSearchResultsDUNSRight.size()>0)
                {
                    System.debug('Duns set - '+dunsExistSet);
                    foundDBRecords = true;
                    for (Account acct : dbAccountSearchResultsDUNSRight)
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
                            //acctToDisplay.ryderProbability = acct.ryderProbabilityMatch__c;
                            //if (acct.RyderProbabilityMatch__c > RyderGlobalVariables.CUT_OFF_ACCURACY_PROBABILITY) {
                            //    this.canSelectAccountWithoutDnB = false;
                            //}
                            acctToDisplay.locationType = acct.LOC_ID__c;
                            acctToDisplay.AnnualRevenue = acct.AnnualRevenue;
                            acctToDisplay.matchGrade = acct.Match_Grade__c;
                            acctToDisplay.matchConfidence = acct.Match_Confidence__c;
                            if(acctToDisplay.matchConfidence >= 8)
                                this.canSelectAccountWithoutDnB = false;
                                
                            acctToDisplay.tradeStyle = acct.Tradestyle;
                            dbAccountMatch.add(acctToDisplay);
                        }
                    }
                }
                system.debug(' this.canSelectAccountWithoutDnB : ' + this.canSelectAccountWithoutDnB);
                // check if we have found DnB Account with matching accuracy probability > X then do not allow
                // user to create new account
                if (this.canSelectAccountWithoutDnB == false) {
                    for ( SFDCAccount tempAccount: sfdcAccountSearchResults){
                      if (tempAccount.createOrAttach == RyderGlobalVariables.CREATE_NEW_LABEL) {
                        tempAccount.canBeSelected = false;
                      }     
                    }
                }
                                                                                 
               
               
               //AAK 12/04/2014 End            
            
            
            // Create criteria to send request to Ryder WSDL
            //AAK 06/20/2014 - Start - Changes for  ReqID 343 Replace DnB with Data.com
            system.debug('Using Data.com Search API');
            //dbAccountSearchResults = commonFunction.getSFDCAccountsFromDandB(account.Name, account.ShippingState, account.ShippingCountry,
            //                                                                 account.ShippingStreet, account.ShippingCity, account.ShippingPostalCode,
            //                                                                 contact.Phone);
            dbAccountSearchResults = commonFunction.getSFDCAccountsFromDatacom(account.Name, account.ShippingState, account.ShippingCountry,
                                                                             account.ShippingStreet, account.ShippingCity, account.ShippingPostalCode,
                                                                             contact.Phone);
            //AAK 06/20/2014 - End
                                                                                                                                                              
            system.debug(LoggingLevel.INFO, '@@@+++++++++++++++++ dbAccountSearchResults: ' + dbAccountSearchResults);
            if (dbAccountSearchResults != null && dbAccountSearchResults.size()>0)
            {
                System.debug('Duns set - ' + dunsExistSet);
                foundDBRecords = true;
                for (Account acct : dbAccountSearchResults)
                {
                    System.debug('Check - ' + acct.Site_Duns__c + '_' + customerTypeId);
                    // Check if the duns and customer type id exist and eliminate those values
                    if (!dunsExistSet.contains(acct.Site_Duns__c + '_' + customerTypeId))
                    {
                        //AAK 12/02/2014 Start - QC630 Change lead conversion process to use DUNSRIGHT API for matching and restore restricted functionality to create account without match
                        //added to avoid duplicate result from the Match Search Reslut above                            
                        if(!dbAccountSearchResultsMap.containsKey(acct.Site_Duns__c))
                        {
                        //AAK 12/02/2014 End                                
                        
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
                            //if (acct.RyderProbabilityMatch__c > RyderGlobalVariables.CUT_OFF_ACCURACY_PROBABILITY) {
                            //    this.canSelectAccountWithoutDnB = false;
                            //}
                            //AAK 07/17/2014 Start - REQ343 Replace DnB with Data.com
                            //Change request from business to add Location Type and Annual Revenue
                            acctToDisplay.locationType = acct.LOC_ID__c;
                            acctToDisplay.AnnualRevenue = acct.AnnualRevenue;
                            //AAK 07/17/2014 End
                            //AAK 07/17/2014 Start - QC630
                            acctToDisplay.tradeStyle = acct.Tradestyle; 
                            //AAK 07/17/2014 End                           
                            dbAccount.add(acctToDisplay);
                        }
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
            
        system.debug('sfdcAccountSearchResults = ' + sfdcAccountSearchResults);
        system.debug('dbAccountSearchResults = ' + dbAccountSearchResults);
        system.debug('foundRecords = ' + foundRecords);
        system.debug('foundDBRecords = ' + foundDBRecords);
        system.debug('Contact = ' + contact);
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
     * @return       PageReference      
     */
    public PageReference createNewAccount(){
        try {
            System.debug('@@@ Start createNewAccount');
            Boolean createNewAccountSuccessful = false;
              
        accountForTeamRole = null;
        if (this.fromLead && accountCreateOrAttached != RyderGlobalVariables.CREATE_NEW_LABEL){
            System.debug('@@@ Account selected - '+ accountSelected);
          System.debug('@@@ Contact selected - '+ contactSelected);
            
          // Sunil 9/10/2014 set selected account automatically (as UI will not be shown to Users)
          if(isIndividualLead == true){
            doSearch();
            
            System.debug('@@@###' + sfdcAccountSearchResults);
            System.debug('@@@###' + sfdcAccountSearchResults.get(0).Account.Id);
            
            if(sfdcAccountSearchResults.size() < 2){
              accountSelected = 'CreateNew';
            }
            else{
              accountSelected = sfdcAccountSearchResults.get(1).Account.Id;
            }
          }
          System.debug('@@@###' + accountSelected);
          // AAK 01/07/2015 Start - to default the SIC Code for the individual
          account.SIC = '4789';
          account.SIC_Code__c = getSICLookupId(account.SIC);
          string asize =  String.valueOf(MapLeadtoAccountSource.size());
          //account.Additional_Comments__c = 'test' + sleadSSD + ' :: ' + MapLeadtoAccountSource.get(sleadSSD) + '::' + asize;
          updateAccountSource(account);
          // AAK 01/07/2015 End
          
          createNewAccountSuccessful = Convert();
          System.debug('@@@###' + createNewAccountSuccessful);
        }
        else{
            createNewAccountSuccessful = false;
          Boolean isRyderAccount = createCompany();
          if (account.id != null){
            createNewAccountSuccessful = true;
          }
        }       
        
        if (createNewAccountSuccessful){
            if (this.fromLead) {
                PageReference pageRef =  Page.LeadConversionResult;
            pageRef.getParameters().put('accountStatus', this.accountState);
            pageRef.getParameters().put('contactStatus', this.contactState);
            pageRef.getParameters().put('id', this.lead.id);
            pageRef.setRedirect(true);
            System.debug('@@@ End Convert **************');
            return pageRef;
          }
          else {
            PageReference pageRef =  new ApexPages.StandardController(account).view();
            pageRef.setRedirect(true);
            System.debug('@@@ End Convert **************');
            return pageRef;
          }
        }
        System.debug(LoggingLevel.INFO, '@@@ account: ' + this.account);
        System.debug('@@@ End createNewAccount **************');
      }
      catch(RyderException ex) {
        addErrors(ex.dbResponse);
        ApexPages.Message msgError = new ApexPages.Message(ApexPages.Severity.Error, ex.errorMessage);  
        ApexPages.addMessage(msgError); 
      }
      catch(Exception ex) {
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
                
    //AAK 12/04/2014 Start - QC630 Change lead conversion process to use DUNSRIGHT API for matching and restore restricted functionality to create account without match
    /**
     * getDBAccount retrieves accounts that are to be displayed on the screen for Match
     * 
     * @param       void            
     * @return      List<DBAccount>
     */
    public List<DBAccount> getDBAccountToDisplayMatch()
    {
        System.debug(' -----------------> fromLead IS Match ' + fromLead + this.fromLead);
        return dbAccountMatch;
    }
    //AAK 12/13/2014 End
    
                
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
    public Boolean Convert(){
        System.debug('@@@ Start Convert **************');
        System.debug('sleadssd : ' + this.sleadSSD);
      Boolean convertSuccessful = false; 
      contactFound = false;
        
      // sunil 9/9/2014
      Boolean doNotCreateOppty = true;
      if(this.lead.IsOpportunityNeeded__c == true){
        doNotCreateOppty = false;
      }
      
      Boolean emailToOwner = false;
      Boolean replaceLeadSource = false;
      CommonFunctions commonFunction = new CommonFunctions();
      System.debug(LoggingLevel.INFO, '@@@ Account before convert: ' + account);
      
      try{
        
        // Create company based on lead convert selected
        
        Boolean isRyderCompany;
        isRyderCompany = createCompany();
        
        
        System.debug(LoggingLevel.INFO, '@@@ Account after convert: ' + account);
        
        
        
        
        System.debug('@@@###' + isUVSLead);
        System.debug('@@@###' + accountSelected);
        System.debug('@@@###' + RyderGlobalVariables.CREATE_NEW);
        
        // Sunil: 11/18/2014 in case of existing account set UVS Type and update this.
        if(isUVSLead == true  ) {
          //Virendra: 02/16/2015 Below USV_Type__c populated Un Commented as per requirement  on I-136628
          account.UVS_Type__c = 'Prospect';
          if(this.lead.LeadSource == 'Employee Referral' ){
           System.debug('@@@###SWATHY' + RyderGlobalVariables.CREATE_NEW);
            account.SapID__c = this.lead.SapID__c;
            account.Employee_Zipcode__c = this.lead.Employee_Zipcode__c;
            account.Employee_Phone__c = this.lead.Employee_Phone__c;
            account.Employee_Name__c = this.lead.Employee_Name__c;
            account.Employee_Email__c = this.lead.Employee_Email__c;
            updateAccountSource(account);
          }
          update account;
        }
        System.debug('@@@### - UVS Type = ' + account.UVS_Type__c);
        
        //  if account exists and is owned by a UVS user and a LEASE Lead is converted, 
        // then override ownership with owner of Lead, add UVS User --previous Owner --to Account Team.
        // I-138915
        if(isUVSLead == false && accountSelected != RyderGlobalVariables.CREATE_NEW){
            if(UVS_Util.isUVSProfile(account.OwnerId)){
                Id oldOwnerId = account.OwnerId; 
                account.OwnerId = this.lead.OwnerId;
                System.debug('@@@###$$$$%%' + account);
                update account;
                
                //addToAccountTeam(account.Id, oldOwnerId);
            }
        }
        
        
        // Check if the account id was retrieved
        if (account.id != null){
            Contact existingsameAccount;
          Contact existingPrimary;
          
           if(isUVSLead == true){
              
        List<contact>     existingContacts=[select id,Email,Is_Duplicate__c,HQ_Account_Id_18__c, AccountId,Contact_Trigger_Toggle__c,
                Pre_Sales_Contact_Role__c,FirstName, LastName,Account.ParentId,Account.Parent.CustomerTypeID__c, 
                Account.CustomerTypeID__c,
                RecordType.Name from Contact where Phone = :contact.phone and (Account.Id= :account.Id or Account.Id=:account.ParentId)
                Order by  RecordType.Name desc];
                  if(existingContacts.size()>0)
                   existingsameAccount = existingContacts[0];
                }
          
          // neelima- april 11 2012 - existing contact check for contact to conform to unique email address requirement by Eloqua
          if (contact.Email!=null){
             if(isUVSLead == false){
            existingsameAccount = DedupUtil.getContactFromSameAccountHierarchy(contact.Email,account.Id, account.ParentId); }
            existingPrimary = DedupUtil.getFMSDuplicateContacts(contact.Email);
            
            system.debug('@@@existingsameAccount' + existingsameAccount );
            system.debug('@@@existingPrimary' +  existingPrimary);
            }
            // Neelima- 02/27/2012--if the existing contact is from the same account do not create the contact. Instead 
            // use the existing contact for the lead conversion
            
            if (existingsameAccount!=null){
                system.debug('@@@contact:' + contact);
                system.debug('@@@existingsameAccount:' + existingsameAccount);
                
                //Name check done with the existing contact.
              if(RyderGlobalVariables.PERFORM_NAME_CHECK && (contact.FirstName != existingsameAccount.FirstName || contact.LastName != existingsameAccount.LastName )){
                contactFound= false;
              }
              else {
                contact = existingsameAccount;
                contactFound = True;
                // do not carry over lead source to contact as the contact already exists
                replaceLeadSource = false;
                this.contactState = RyderGlobalVariables.LeadConversionContactState.ExistingSFDCContact.name();
                //Create a note and attach to the contact indicating a new lead is converted for the same contact. 
                Note ne = new Note();
                ne.title = 'Contact Updated';
                System.debug('------Contact.Id:'+Contact.Id);
                ne.ParentId = contact.Id;
                ne.body = 'Lead got Converted.\n First Name:'+lead.FirstName+'\n Last Name:'+lead.lastName+'\n Title:'+lead.Title+'\n Phone:'+lead.Phone+'\n Lead Source:'+lead.Leadsource+'\n Product Line:'+lead.PRODUCT_LINE__c;
                insert ne;
                
                //Added to avoid duplicate contact role.
                List<AccountContactRole> availableAccountContactRoles = new List<AccountContactRole>();
                availableAccountContactRoles = [SELECT Id, ContactId, AccountId  FROM AccountContactRole WHERE ContactId =:contact.Id AND AccountId =:Account.Id];
                
                if(availableAccountContactRoles.isEmpty()){
                    //Create Account Contact Role
                  AccountContactRole accConRole=new  AccountContactRole ();
                  accConRole.AccountId=Account.Id;
                  System.debug('------Account.Id:'+Account.Id);
                  accConRole.ContactId = contact.Id;
                  Insert accConRole;
                }
              }
            }
             if (existingPrimary!=null){
                contact.Is_Duplicate__c = true;
              contact.Primary_Contact_Id__c = existingPrimary.Id;
            }
         
          
          // Add the contact
          if (contactFound == false){
            // contact = new contact(firstname=contact.FirstName, lastname=contact.LastName,accountid=account.id, ownerId = lead.ownerId);
            contact.accountid = account.id;
            // contact.accountid=account.ParentId==null?account.Id:account.ParentId;
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
            AccountContactRole acr= new AccountContactRole();
            acr.AccountId = Account.Id;
            acr.contactId = Contact.Id;
            insert acr;
            this.contactState = RyderGlobalVariables.LeadConversionContactState.CreatedContact.name();
            System.debug('@@@ Added new contact');
          }
          
          addAccountTeams(account);
          
          //AAK 12/04/2014 Start - QC 536 Modify Lead Conversion process - For phone numbers
          //to update the phone at the lead with the Data.com, carry over by out of box lead conversion functionality
          if (account.Phone != null){
                lead.Phone = account.Phone.replace('+1',' ');
                update lead;
                system.debug('lead : ' + lead);                
           }
          //AAK 12/04/2014 End
          
          Database.LeadConvert converter = new Database.LeadConvert();
          converter.setLeadId(lead.id);
          //---Swetha - 08/01/12-------
          converter.setAccountId(account.id);
          converter.setAccountId(account.ParentId==null?account.Id:account.ParentId);
          system.debug('@@@###$$$' + account.id);
          system.debug('@@@###$$$' + account.ParentId);
                         
          if(isUVSLead == true && account.ParentId!=null ) {
           Account pAccount =   [select id,SapID__c,Employee_Zipcode__c,Employee_Phone__c,Employee_Name__c,Employee_Email__c from
                   Account where ID = : account.ParentId];
           if(this.lead.LeadSource == 'Employee Referral' ){
          // System.debug('@@@###SWATHY' + RyderGlobalVariables.CREATE_NEW);
            pAccount.SapID__c = this.lead.SapID__c;
            pAccount.Employee_Zipcode__c = this.lead.Employee_Zipcode__c;
            pAccount.Employee_Phone__c = this.lead.Employee_Phone__c;
            pAccount.Employee_Name__c = this.lead.Employee_Name__c;
            pAccount.Employee_Email__c = this.lead.Employee_Email__c;
            updateAccountSource(pAccount);
              }
             update pAccount;
           }
          // neelima - April 12, 2012
          // Set the contact id  only if it is a new contact
          // sunil 9/8/2014
          system.debug('@@@###' + contact.Id);
          if(contact.Id != null){
            // set Original Decision Maker into Lead and Update the lead record, so that 
            // Lead mapping can update the respective Opprotunity field while conversion.
            this.lead.Original_Decision_Maker__c = contact.Id;
            update this.lead;
                  
            // Sunil : 9/8/2014 Update Solution Interest record with new Contact Id.
            if(isUVSLead == true && currentSolutionInterest != null){
              currentSolutionInterest.Contact_Id__c = contact.Id;
              //currentSolutionInterest.Stage__c = 'Qualified';
              
              update currentSolutionInterest;
            }
          }
          
          system.debug('@@@###' + this.lead.Original_Decision_Maker__c); 
          converter.setContactId(contact.id);
          converter.setOverwriteLeadSource(replaceLeadSource);
          
          //Swetha ---08/01/2012----
          //---Oppor creation---
          // converter.setDoNotCreateOpportunity(false);
          //Swetha----08/28/2012----Opp creation not needed now-----
          converter.setDoNotCreateOpportunity(doNotCreateOppty);
          String ownerId = recordOwner.OwnerId;
          system.debug('@@@###$$$' + ownerId);
          converter.setOwnerId(ownerId); 
          system.debug('contact' + contact);          

          // 04/25/12 Raja Changed to get lead converted status based on lead status. Record type could be used as well                
          // converter.setConvertedStatus(RyderGlobalVariables.CONVERTED_STATUS);
          
          converter.setConvertedStatus(RyderGlobalVariables.getConvertedLeadStatus(lead.Status));
          converter.setSendNotificationEmail(emailToOwner);
          system.debug(LoggingLevel.INFO, '@@@ Lead Convertor: Lead:' + lead);
          system.debug(LoggingLevel.INFO, '@@@ Lead Convertor: Account:' + account);
          system.debug(LoggingLevel.INFO, '@@@ Lead Convertor: Contact:' + contact);
          system.debug(LoggingLevel.INFO, '@@@ converter - '+converter);
          Database.Leadconvertresult convertResult = Database.convertLead(converter);
          
          if(!convertResult.isSuccess()){
            system.debug('Conversion Failed');
            // Get the first save result error
            Database.Error err = convertResult.getErrors()[0];
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, RyderGlobalVariables.ERROR_CONVERTING_LEADS + err.getMessage() + '\n');
            ApexPages.addmessage(errorMsg);
          }
          else{
            system.debug('@@@ Conversion successful');
            convertSuccessful = true;
            system.debug('@@@###' + convertResult.getAccountId());
            system.debug('@@@###' + convertResult.getContactId());
            UpdateCompetitorVehicles.updateCompetitorVehiclesOnLeads(convertResult); 
          }
        }
      }
      //catch(RyderException ex) {
      //  addErrors(ex.dbResponse);
      //  system.debug('@@@ ----678---Exception: '+ex.getMessage());
      //  ApexPages.Message msgError = new ApexPages.Message(ApexPages.Severity.Error, ex.errorMessage);  
      //  ApexPages.addMessage(msgError);
      //  convertSuccessful = false;
      //  rollbackAccountConversion(); 
      //}
      catch(Exception ex){
        // Vishal 12/13/2010 - To do when the web method on web service gets implemented
        //if (isRyderCompany && account.id != null)
        //commonFunctions.createAccountsFailed(account.Id);
        system.debug('@@@ ----747---Exception: '+ex.getMessage());
        addErrors(ex.getMessage());
        ApexPages.addMessages(ex);
        convertSuccessful = false;
        rollbackAccountConversion();
      }     
      System.debug('*********** End Convert **************');
      return convertSuccessful;
    }
        //Swetha ----Oppor on child account----08/01/2012----
      //  Private void updateOpportunity(Id oppId)  {
       // Opportunity opp =[select Id,AccountId from Opportunity where Id =: oppId];
      // opp.AccountId=account.Id;
       // Update Opp;
       // }
        
        //Swetha  -----OppContactRole is included----
       // Private void createContactRole (Id oppId,Id contId)  {
         //   OpportunityContactRole oppConRole=new OpportunityContactRole();
         // oppConRole.OpportunityId=oppId;
          // oppConRole.ContactId = contId;
            //Insert oppConRole;
          // }
        
      
        
    /*
    * If lead owner and account owners are different add lead owner to be part of account team for child and parent
    * Also, if lead converter is not a salesperson (owner will be SP) but TSA, add TSA's to the account team
    */
   
    private void addAccountTeams(Account account) {
    
	 //to avoid getting UVS part of the Account Team    
     if (!this.isUVSLead)
     {
        system.debug('@@@addAccountTeams');
      //Get current logged in user profile and check if it is TSA
      Id profId = UserInfo.getProfileId();
       
      Profile pro =[Select Id, Name from Profile where Id =: profId LIMIT 1];
      system.debug('-------pro:' +pro);
      if(pro.Name.contains('TSA')) {
        addToAccountTeam(account.Id, UserInfo.getUserId());
      }
      
      //Id profId = UserInfo.getProfileId();
        
      //Profile pro =[Select Id, Name from Profile where Id =: profId and Name like '%TSA%' LIMIT 1];
       
      system.debug('@@@' + account.OwnerId);
      system.debug('@@@' + recordOwner.OwnerId);
         
      if(account.OwnerId != recordOwner.OwnerId) { 
      	system.debug('recordOwner.OwnerId :' + recordOwner.OwnerId + ' account.OwnerId: ' + account.OwnerId);
      	if (!UVS_Util.isUVSProfile(account.OwnerId)){
        	addToAccountTeam(account.Id, recordOwner.OwnerId);
      	}
      }
        
      /*
      if (pro!=null && account.OwnerId != UserInfo.getUserId() && recordOwner.OwnerId != UserInfo.getUserId()){
        addToAccountTeam(account.Id, UserInfo.getUserId());
      }
      */
      system.debug('@@@' + account.ParentId); 
      if (account.ParentId != null) {
        // if parent account exists and parent account owner isdifferent then lead owner
        // add lead owner to parent account's team also.
        Account parentAccount = [select id, ownerId from Account where id =: account.parentId];
        //Swetha----Always add parent account owner as child account team---even if the owner is the same--
        if (parentAccount.OwnerId != recordOwner.OwnerId) { 
          addToAccountTeam(parentAccount.Id, recordOwner.OwnerId);
        }
        
        //  if (pro!=null && parentAccount.OwnerId != UserInfo.getUserId() && recordOwner.OwnerId != UserInfo.getUserId()){
        //       addToAccountTeam(parentAccount.Id, UserInfo.getUserId());
        // }
      }
      
      
     }else{
     	system.debug('enter uvs account share addition:');
      //AAK 03/10/2015 Start - QC845 Modify Lead conversion for UVS users 
      //if(this.isUVSLead){
     	/*List<AccountTeamMember> lstcurrentTeamMembers = [select UserId from AccountTeamMember where AccountId =: account.Id];
     	List<User> sleadOwner = [select Id, UTC__c, ProfileId from User where Id =: lead.OwnerId];
     	String sPro = '%VSM%';
     	pro = [SELECT Id,Name FROM Profile WHERE Name LIKE :sPro];
     	system.debug('lead owner utc : ' + sleadOwner[0].UTC__c);
     	if(sleadOwner[0].UTC__c != null && sleadOwner[0].UTC__c != '')
     	{
	     	List<User> lstuserUTC = [select Id, UTC__c from User where UTC__c =: sleadOwner[0].UTC__c AND ProfileId =: pro.Id];
			Boolean bnew;
			system.debug('account team member : ' + lstcurrentTeamMembers);
			system.debug('lead owner utc : ' + sleadOwner);
			system.debug('vsm vsr UTC : ' + lstuserUTC);
	
			
			for(User users : lstuserUTC)
			{
				bnew = true;
				for(AccountTeamMember atm : lstcurrentTeamMembers)
				{
					if(atm.UserId == users.Id){
						bnew = false;
						break;
					}
				}
				if(bnew){
					system.debug('new : ' + users.Id);
					addToAccountTeam(account.Id, users.Id);
				}
					
			}    		
     	}
      }*/
     
      //Approach 2
      User leadOwner = [select Id, UTC__c, UserRoleId, UserRole.DeveloperName from User where Id =: lead.OwnerId LIMIT 1];
	  system.debug('lead owner utc : ' + leadOwner + ' Developer Name :' + leadOwner.UserRole.DeveloperName);
      Group ownerGroupId = [SELECT Id FROM Group WHERE DeveloperName =: leadOwner.UserRole.DeveloperName LIMIT 1];
	  system.debug('ownerGroupId : ' + ownerGroupId.Id);
	  //addToAccountTeam(account.Id, ownerGroupId.Id);
/*      List<AccountShare> accShareTemp = [Select a.UserOrGroupId, 
          a.RowCause, a.OpportunityAccessLevel, a.ContactAccessLevel, a.CaseAccessLevel, a.AccountId, 
          a.AccountAccessLevel 
          From AccountShare a where a.userOrGroupId =:ownerGroupId.Id and a.AccountId =: account.Id LIMIT 1];*/
      List<AccountShareCustom__c> accShareTemp = [Select a.AccountId__c, a.GroupId__c 
          From AccountShareCustom__c a where a.GroupId__c =:ownerGroupId.Id and a.AccountId__c =: account.Id LIMIT 1];
          
	  system.debug('accShareTemp : ' + accShareTemp);      
      if(accShareTemp.size() == 0)
	  {
	  		system.debug('enter uvs account share : ');
	  		AccountShareCustom__c accShare = new AccountShareCustom__c();
	  		accShare.AccountId__c = account.Id;
	  		//accShareTemp[0].RowCause = 'Team';
            //accShare.AccountAccessLevel=RyderGlobalVariables.WRITE_ACCESS;
      		//accShare.OpportunityAccessLevel = 'None'; // RyderGlobalVariables.PRIVATE_ACCESS;
            //accShare.CaseAccessLevel = RyderGlobalVariables.READ_ACCESS;
            accShare.GroupId__c = ownerGroupId.Id;
            insert accShare;	  
	  }  	
     
    //AAK 03/10/2015 End      
    }
    }
  
   //  Add lead owner to parent account so owner has visibility to the account.
    
    private void addToAccountTeam(String parentAccountId, String aUserId) {
        system.debug('@@@');
        if (parentAccountId != null) {
        	//AAK 03/10/2015 Start  - QC845 Modify Lead conversion for UVS users
        	//to avoid getting UVS part of the Account Team
        	if (!isUVSLead)
        	{
	            AccountTeamMember temp = new AccountTeamMember();
	            temp.UserId = aUserId;
	            temp.TeamMemberRole = translateAccountTeamRole(aUserId); 
	            temp.AccountId = parentAccountId;
	            insert temp;
	            system.debug(LoggingLevel.INFO, '&&&&&&&&&&&&&&&& Account team member added:' + temp);
	            system.debug(LoggingLevel.INFO, '&&&&&&&&&&&&&&&& Account team member parentAccountId:' + parentAccountId);
	            system.debug(LoggingLevel.INFO, '&&&&&&&&&&&&&&&& Account team member recordOwner.OwnerId:' + aUserId);
	            // now retrieve the account share and update Oppty and Case level access.
        	} 
        	//AAK 03/10/2015 Start     
            List<AccountShare> shareTemp = [Select a.UserOrGroupId, 
              a.RowCause, a.OpportunityAccessLevel, a.ContactAccessLevel, a.CaseAccessLevel, a.AccountId, 
              a.AccountAccessLevel 
              From AccountShare a where a.userOrGroupId =:aUserId and a.RowCause = 'Team' and a.AccountId =: parentAccountId LIMIT 1];
              if (shareTemp != null && shareTemp.size() > 0) {
                   shareTemp[0].AccountAccessLevel=RyderGlobalVariables.WRITE_ACCESS;
                   //AAK 03/10/2015 Start -  - QC845 Modify Lead conversion for UVS users  
                   //Making opportunity private for uvs users avoiding access to lease opportunities
                   if (isUVSLead)
                   		shareTemp[0].OpportunityAccessLevel = 'None'; // RyderGlobalVariables.PRIVATE_ACCESS;
                   else
                   //AAK 03/10/2015 End Making opportunity private for uvs users avoiding access to lease opportunities
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
            If the profile of the owner is Rental, the Team Role needs to be National Rental Manager (which doesn?t exist yet, please create).
    */
    private String translateAccountTeamRole(String userId) {
        String result = '';
       system.debug('*********** Start translateAccountTeamRole UserId**************' + userId );
        String userProfileName = [select id, name from profile where id in (Select u.profileId From User u where u.id =:userId)].name;
        system.debug('*********** userProfileName**************' + userProfileName );
        Ryder_Account_Team_Role_Map__c accountRole = Ryder_Account_Team_Role_Map__c.getValues(userProfileName);
        system.debug('*********** accountRole1**************' + accountRole);
        if (accountRole == null) {
            accountRole = Ryder_Account_Team_Role_Map__c.getValues(RyderGlobalVariables.DEFAULT_ACCOUNT_ROLE_MAP);
             system.debug('*********** accountRole2**************' + accountRole);
        }
        result = accountRole.Account_Team_Role__c;
         system.debug('*********** accountRole.Account_Team_Role__c**************' + accountRole.Account_Team_Role__c);
        return result;
    }
    
    // Create account creation process that either creates account on the Ryder
    //TODO: Remove the boolean flag from being returned
    private Boolean createCompany(){
        System.debug('*********** Start createCompany **************');
      System.debug(' -----------------> fromLead IS ' + fromLead + this.fromLead);
      Boolean isRyderCompany = false;
      
      system.debug('@@@###' + accountExistInfoMap);
      system.debug('@@@###' + accountSelected);
      // Choosing an existing account
      if (accountExistInfoMap.containsKey(accountSelected)){
        system.debug('@@@');
        // Existing account and contact info
        account = accountExistInfoMap.get(accountSelected);
        // if lead's owner is not the owner or the account 
        this.accountState = RyderGlobalVariables.LeadConversionAccountState.ExistingSFDCAcct.name();
        /*
        if (account.OwnerId != recordOwner.OwnerId) { 
            accountForTeamRole = account.Id;
        }
        */
        System.debug(LoggingLevel.INFO, '@@@+++++++++++ account set to : ' + account);
        
        if (contactMap.containsKey(contactSelected)){
          contact = contactMap.get(contactSelected); 
          contactFound = true;
          this.contactState = RyderGlobalVariables.LeadConversionContactState.ExistingSFDCContact.name();
          system.debug('@@@Attached existing contact');
        }
        system.debug('@@@Attached existing account');
      }
      else {
        system.debug('@@@');
        //check if DUNS number already exists as account in the system
        // Tied to bug #21 in QC.];
        List<Account> existingDUNSAccounts = null;
        //AAK 06/04/2014 - Start - to include data.com companyid
        /*if (accountSelected != null && accountSelected.length() > 0 && accountSelected != RyderGlobalVariables.CREATE_NEW) {
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
        }*/
        
        
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
            a.At_Risk__c, a.UVS_Type__c, a.AnnualRevenue, a.Alias_Name__c, a.Additional_Comments__c, a.Account_Classification__c, a.ADDR_ID__c , a.OwnerId, a.DCCompanyId__c,
            a.SAM_Account_Source__c
            From Account a where (a.Site_Duns__c =: accountSelected or  (a.DUNS_HQ__c =: accountSelected and a.ParentId != null)) and a.CustomerTypeID__c =:account.CustomerTypeID__c LIMIT 1]; //added logic to match on companyTypeId along with duns numbers
         }
         
         //AAK 06/04/2014 - End - to include data.com companyid
         
         // Neelima-04/20- added a.ParentId != null in the above where condition.
       if (existingDUNSAccounts != null && existingDUNSAccounts.size() > 0) {
         System.debug(LoggingLevel.INFO, '@@@Found matching account: ' + account);
         account = existingDUNSAccounts[0];
         /*
         if (account.OwnerId != recordOwner.OwnerId) { 
         accountForTeamRole = account.Id;
         }
         */
         this.accountState = RyderGlobalVariables.LeadConversionAccountState.ExistingSFDCAcct.name();
       }
       else  {
         system.debug('@@@');
         // Check if it is a Duns number we are trying to add 
         if (accountSelected != RyderGlobalVariables.CREATE_NEW){
        //Changed by: Raja Sampath
        //Change Date: 10/10/11
        //Change for National Rental
        //Conditionally calling new method if customer type is FMS Rental
        //isRyderCompany = createDnBAccount();
        if (account.CustomerTypeID__c=='FMS Rental'){
            isRyderCompany = createDnBAccountForRental();
        }
        else{
          isRyderCompany = createDnBAccount();
        } 
      }
      
      else{
        
        
        //AAK 12/04/2014 Start - 
        //QC 536 Modify Lead Conversion process - For phone numbers
        //QC 642 Modify Lead Conversion Process to include data on lead object - DOT #
        if (this.fromLead == true)
        {
            account.Billing_Phone__c = (lead.Billing_Phone__c!=null?lead.Billing_Phone__c:null);
            account.Billing_Fax__c = (lead.Billing_Fax__c!=null?lead.Billing_Fax__c:null);
            account.DOT_Number__c = (lead.DOT_Number__c!=null?lead.DOT_Number__c:null);
        }                                
        //AAK 12/04/2014 End
        
        //Changed by: Raja Sampath
        //Change Date: 10/10/11
        //Change for National Rental, added check for FMS Rental and skip calling radar for rental accounts
        //Condtional Code added
        System.debug('@@@');
        if (account.CustomerTypeID__c=='FMS Rental'){
            system.debug('@@@');
            account.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Rental_Account.name());
          // since account is missing DnB information
          account.Missing_DNB__c = true;
          System.debug('insert new account: ' + account);
          insert account;
          System.debug('insert new account: ' + account);
        }
        
        // 11/02/2014 (Hari Krishnan): As per the req, the web service call out to RADAR should not happen for UVS.
        else if (isUVSLead) {
            account.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Parent_Account.name());
            account.Missing_DNB__c = true;
            //AAK 01/07/2015 Start - to update the Account Source from the Lead
            updateAccountSource(account);
            //AAK 01/07/2015 End
            insert account;           
            system.debug('@@@#### added new account' + account);
          }
        else{
            //End Change for National rental
          // Create a record on Ryder for Duns number = null, i.e. non DnB account
          CommonFunctions commonFunction = new CommonFunctions();
          Integer companyId = commonFunction.createAccountsOnRyder(account, false, true);
          System.debug('companyId - ' + companyId);
          System.debug('----------906------------------');
          // Check if the record was created on Ryder and now insert the account on SFDC
          
          if (companyId != -1){
            system.debug('Account to insert without DUNS - '+account);
            Account matchingCustProspectAccount = getAccountByCustProspectId(companyId);
            if (matchingCustProspectAccount == null) {
                account.CustProspectID__c = String.valueOf(companyId);
              account.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Parent_Account.name());
              // since account is missing DnB information
              account.Missing_DNB__c = true;
              system.debug('@@@#### added new account' + account);
              insert account;
              system.debug('@@@#### added new account' + account);
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
            }
            else {
                String errMsg = RyderGlobalVariables.DUPLICATE_CUST_PROSPECT_ACCOUNT;
              errMsg +=  matchingCustProspectAccount.Name;
              ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, errMsg);
              ApexPages.addmessage(errorMsg);
              System.debug(LoggingLevel.INFO, errMsg);
            }
          }
        }
        //Changed by: Raja Sampath
          //Change Date: 10/10/11
          //Change for National Rental, added check for FMS Rental and skip calling radar for rental accounts
          //Condtional Code added - end condition
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
                //AAK 12/04/2014 Start - 
                //QC 536 Modify Lead Conversion process - For phone numbers
                //QC 642 Modify Lead Conversion Process to include data on lead object - DOT #
                if (this.fromLead == true)
                {
                    acct.Billing_Phone__c = (lead.Billing_Phone__c!=null?lead.Billing_Phone__c:null);
                    acct.Billing_Fax__c = (lead.Billing_Fax__c!=null?lead.Billing_Fax__c:null);
                    acct.DOT_Number__c = (lead.DOT_Number__c!=null?lead.DOT_Number__c:null);
                    //AAK 01/07/2015 Start added to default the account source
                    this.updateAccountSource(acct);
                    //AAK 01/07/2015 End
                }                                
                //AAK 12/04/2014 End
                
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
                    //AAK 12/04/2014 Start - 
                    //QC 536 Modify Lead Conversion process - For phone numbers
                    //QC 642 Modify Lead Conversion Process to include data on lead object - DOT #
                    acct.Billing_Phone__c = (lead.Billing_Phone__c!=null?lead.Billing_Phone__c:null);
                    acct.Billing_Fax__c = (lead.Billing_Fax__c!=null?lead.Billing_Fax__c:null);
                    acct.DOT_Number__c = (lead.DOT_Number__c!=null?lead.DOT_Number__c:null);                                
                    //AAK 12/04/2014 End
                    //AAK 01/07/2015 Start added to default the account source
                    this.updateAccountSource(acct);
                    //AAK 01/07/2015 End
                    
                } else {
                    acct.CO_SEGMENT__c = account.CO_SEGMENT__c;
                }
                gotHQ = true;
            }
            
            
            system.debug('Branch Indicator - ' + this.isBranch);
            
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
                system.debug('Accounts to update 1- '+accounts);    
            }
            i++;
        }
            
        // Check if the accounts are to be created and that HQ is within account object
        if (accounts.size()>0 && account != null && headquarter!=null)
        {
            //AAK 06/04/2014 - Start - to include data.com conpanyid
            /*Account[] existingAccounts = [Select a.addr_verified_date__c, a.Website, a.Type, 
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
            */
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
                a.At_Risk__c, a.AnnualRevenue, a.Alias_Name__c, a.Additional_Comments__c, a.Account_Classification__c, a.ADDR_ID__c, a.OwnerId, a.DCCompanyId__c,
                a.SAM_Account_Source__c
                From Account a WHERE a.Site_Duns__c IN: dunsNumbers
                and a.CustomerTypeID__c =: account.CustomerTypeID__c]; //added logic to match on companyTypeId along with duns numbers
                //AAK 06/04/2014 - End - to include data.com conpanyid   
            
            // Go through the accounts and put the duns number and set the accounts
            for(Account existingAcct : existingAccounts)
            {
                String strToCompare = existingAcct.Site_Duns__c+(existingAcct.ParentId!=null?'_'+existingAcct.CustomerTypeId__c:'');
                system.debug('strToCompare - '+strToCompare);
                system.debug('accounts.containsKey - '+accounts.containsKey(strToCompare));
                //System.debug('existingAcct.Site_Duns__c -'+existingAcct.Site_Duns__c);
                //System.debug('existingAcct.ParentId-'+existingAcct.ParentId);
                //system.debug('existingAcct.CustomerTypeId-'+existingAcct.CustomerTypeId__c);
                            
                // Check if the accounts contains the site duns
                if (accounts.containsKey(strToCompare))
                {
                    accounts.put(strToCompare, existingAcct);
                    system.debug('Accounts to update 2 - '+accounts);
                    if (headquarter.Site_Duns__c == existingAcct.Site_Duns__c) {
                        headquarter = existingAcct;
                        existingHeadQuarter = true;
                        system.debug('Found existing HQ- '+ headquarter); 
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
                // HK (12/17/2014): Since we don't make the callout to RADAR, we need to check if CustProspectID__c is null before assigning it to company id.
                if(headquarter.CustProspectID__c != null)
                    companyId = Integer.valueOf(headquarter.CustProspectID__c);
            } else if(!isUVSLead) {  // HK (02/17/2015): I-144303 - skip the callout to RADAR for UVS
                companyId = commonFunction.createAccountsOnRyder(headquarter, usePhysicalAddr, false);
            }
            
            //mph update newly created account w/ custprospectid returned from call
            //  system.debug('headquarter: ' + headquarter);
            //  headquarter.CustProspectID__c = String.valueOf(companyId);
            // upsert headquarter;
            
            System.debug('companyId - ' + companyId);
            
            // Check if the record was created on Ryder
            // Hari Krishnan (12/17/2014): Added condition to execute the 'if' logic for UVS even when companyId = -1
            if (companyId != -1 || (companyId == -1 && isUVSLead))
            {
                system.debug('Accounts to update 3 - '+accounts);
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
            system.debug('----------------1211----------------');
                // Set the parent id for the child and ryder id for the parent
                List<Account> acctsToUpdate = new List<Account>();
                for(Account newAcct : accounts.values())
                {
                  if(isUVSLead == true && this.lead.LeadSource == 'Employee Referral') {
                      // newAcct.UVS_Type__c = 'Prospect';
         
                  newAcct.SapID__c = this.lead.SapID__c;
                  newAcct.Employee_Zipcode__c = this.lead.Employee_Zipcode__c;
                  newAcct.Employee_Phone__c = this.lead.Employee_Phone__c;
                  newAcct.Employee_Name__c = this.lead.Employee_Name__c;
                  newAcct.Employee_Email__c = this.lead.Employee_Email__c;
                  //AAK 01/07/2015 Start - to update the Account Source from the Lead
                  updateAccountSource(newAcct);
                  //AAK 01/07/2015 End
                  
                     }
          
                    System.debug('newAcct - '+newAcct);
                    System.debug( '----------------1217---------------');
                    
                    // Check if the site duns and hq duns is the same and presume it is headquarters
                    if (newAcct.DUNS_HQ__c==null || newAcct.DUNS_HQ__c=='' || newAcct.Site_Duns__c == newAcct.DUNS_HQ__c)
                    {
                        
                        if (newAcct.CustProspectID__c != String.valueOf(companyId))
                        {
                            //AAK HELP
                            if(companyId != -1)
                            newAcct.CustProspectID__c = String.valueOf(companyId);
                            acctsToUpdate.add(newAcct);
                        }
                         system.debug('acctsToUpdate--' +acctsToUpdate);
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
            //AAK 12/04/2014 Start - 
            //QC 536 Modify Lead Conversion process - For phone numbers
            //QC 642 Modify Lead Conversion Process to include data on lead object - DOT #
            acct.Billing_Phone__c = (lead.Billing_Phone__c!=null?lead.Billing_Phone__c:null);
            acct.Billing_Fax__c = (lead.Billing_Fax__c!=null?lead.Billing_Fax__c:null);
            acct.DOT_Number__c = (lead.DOT_Number__c!=null?lead.DOT_Number__c:null);                               
            //AAK 12/04/2014 End
            
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
            system.debug('isBranchAccount  = ' + isBranchAccount );
            system.debug('account.Site_Duns__c  = ' + account.Site_Duns__c );
            system.debug('account.DUNS_HQ__c  = ' + account.DUNS_HQ__c );
            system.debug('account.Domestic_Ultimate_DUNS__c  = ' + account.Domestic_Ultimate_DUNS__c );
            system.debug('Evaluate DOM ULT = HQ Check  = ' + (account.Domestic_Ultimate_DUNS__c==null || account.DUNS_HQ__c!=account.Domestic_Ultimate_DUNS__c));
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
            if(isUVSLead == true  && this.lead.LeadSource == 'Employee Referral') {
         // account.UVS_Type__c = 'Prospect';
         
            parentAcct.SapID__c = this.lead.SapID__c;
            parentAcct.Employee_Zipcode__c = this.lead.Employee_Zipcode__c;
            parentAcct.Employee_Phone__c = this.lead.Employee_Phone__c;
            parentAcct.Employee_Name__c = this.lead.Employee_Name__c;
            parentAcct.Employee_Email__c = this.lead.Employee_Email__c;
            //AAK 01/07/2015 Start - to update the Account Source from the Lead
            updateAccountSource(parentAcct);
            //AAK 01/07/2015 End
            
          }
         
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
                //AAK 06/04/2014 - Start - to include data.com companyid
                existingAccount.DCCompanyId__c = tempAccount.DCCompanyId__c;
                //AAK 06/04/2014 - End            
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
            //AAK 06/04/2014 - Start - to include data.com companyid
            /*List<Account> existingAccounts = [Select a.addr_verified_date__c, a.Website, a.Type, 
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
            */
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
                a.Missing_DNB__c, a.DCCompanyId__c
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
        	//AAK 03/10/2015 Start  - QC845 Modify Lead conversion for UVS users
        	if (!isUVSLead)
        	{
	            AccountTeamMember temp = new AccountTeamMember();
	            temp.UserId = account.OwnerId;
	            temp.TeamMemberRole = translateAccountTeamRole(account.OwnerId); 
	            temp.AccountId = parentAccount.Id;
	            insert temp;
	            system.debug(LoggingLevel.INFO, '&&&&&&&&&&&&&&&& Account team member added:' + temp);
	            system.debug(LoggingLevel.INFO, '&&&&&&&&&&&&&&&& Account team member parentAccountId:' + parentAccount.Id);
	            system.debug(LoggingLevel.INFO, '&&&&&&&&&&&&&&&& Account team member recordOwner.OwnerId:' + account.OwnerId);
	            // now retrieve the account share and update Oppty and Case level access.
        	}
        	//AAK 03/10/2015 End
            List<AccountShare> shareTemp = [Select a.UserOrGroupId, 
              a.RowCause, a.OpportunityAccessLevel, a.ContactAccessLevel, a.CaseAccessLevel, a.AccountId, 
              a.AccountAccessLevel 
              From AccountShare a where a.userOrGroupId =:recordOwner.OwnerId and a.RowCause = 'Team' and a.AccountId =: parentAccount.Id LIMIT 1];
              if (shareTemp != null && shareTemp.size() > 0) {
                   shareTemp[0].AccountAccessLevel=RyderGlobalVariables.WRITE_ACCESS;
                   //AAK 03/10/2015 Start -  - QC845 Modify Lead conversion for UVS users  
                   //Making opportunity private for uvs users avoiding access to lease opportunities
                   if (isUVSLead)
                   		shareTemp[0].OpportunityAccessLevel = 'None';  // RyderGlobalVariables.PRIVATE_ACCESS;
                   else
                   //AAK 03/10/2015 End 
	                   shareTemp[0].OpportunityAccessLevel = RyderGlobalVariables.WRITE_ACCESS;
                   shareTemp[0].CaseAccessLevel = RyderGlobalVariables.READ_ACCESS;
                   update shareTemp[0];
              } else {
                // Do nothing as account might be already shared by either OWD or some other sharing rules.
              }                
         }   
       }
    }
    
   //  private void addCurrentUserToAccounts(Account account) {
        
        
    // }
     
     
    /*
    *   Add lead owner to parent account so owner has visibility to the account.
    */
   // private void addToAccountTeam(String parentAccountId, Account acct) {
    //    if (parentAccountId != null) {
            
      //  }
  //  }
    
    /**
     * getCorporateLinkage - Get the acccount based on DnB Corporate Linkage information
     * 
     * @param       void            
     * @return      Account
     */
    private Account getCorporateLinkage(String dunsNumber)
    {

        System.debug('*********** Start getCorporateLinkage **************');
        System.debug('Corporated Duns Number : ' + dunsNumber);
        Account acct = new Account();
        // if (this.strRecordTypeId != null)
        //    acct.RecordTypeId = this.strRecordTypeId;
            
        this.isBranch = false;
        //AAK 06/12/2014 Start - ReqID 343 Replace DnB with Data.com
        //DnB_WebServiceUtilities dnbWebServiceUtilities = new DnB_WebServiceUtilities(); 
        //AAK 06/12/2014 End 
         
        // Check the country
        //if (account.ShippingCountry == RyderGlobalVariables.COUNTRIES_USA)
        //{
        //   CorporateLinkage corporateLinkage = dnbWebServiceUtilities.GetCorporateLinkage(dunsNumber);
        //    System.debug('corporateLinkage - ' + corporateLinkage); 
    
        //    // Check if we got the corporate linkage from DNB
        //    if (corporateLinkage.hasCorporateLinkage)
        //    {
        //        
        //        // Checks if the company is a branch
        //        this.isBranch = (corporateLinkage.branchIndicator == RyderGlobalVariables.BRANCH_INDICATOR_Y);
        //        System.debug('Within getCorporate Linkage isBranch - '+isBranch);
        //        acct.Site_Duns__c = corporateLinkage.dunsNumber;
        //        acct.Legal_Site_Duns__c = corporateLinkage.dunsNumber;
        //        acct.Legal_Entity_Address_Country__c = corporateLinkage.countryCode;
        //        acct.DB_Loc_Type__c = CommonFunctions.translateDnBLocationInfo(corporateLinkage.locationStatus);
        //        if (corporateLinkage.branchIndicator == RyderGlobalVariables.BRANCH_INDICATOR_N)
        //        {
        //            // if not branch hqDuns comes across as null from DnB
        //            // hqDns == siteDuns logic is used to create parent/child relationship in SFDC
        //            //acct.DUNS_HQ__c = corporateLinkage.dunsNumber;
        //            //neelima-04/20 -- update to write corporate linkage hq duns to new account hq duns.
        //            acct.DUNS_HQ__c = corporateLinkage.hqDUNS==null?'':corporateLinkage.hqDUNS;
        //            acct.Domestic_Ultimate_DUNS__c = corporateLinkage.domesticUltimateDUNS;
        //            acct.Global_Ultimate_DUNS__c = corporateLinkage.globalUltimateDUNS;
        //            
        //            //Changed by: Raja Sampath
        //            //Change Date: 10/10/11
        //            //Change for National Rental
        //            //Moved record type assignment to caller
        //            
        //            //acct.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Parent_Account.name());
        //            //End National Rental Change
        //        }
        //       else
        //        {
        //            acct.DUNS_HQ__c = corporateLinkage.hqDUNS;
        //            acct.Domestic_Ultimate_DUNS__c = corporateLinkage.domesticUltimateDUNS;
        //            acct.Global_Ultimate_DUNS__c = corporateLinkage.globalUltimateDUNS;
        //            //Changed by: Raja Sampath
        //            //Change Date: 10/10/11
        //            //Change for National Rental
        //            //Moved record type assignment to caller
        //            
        //            //acct.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_FMS_Branch_Account.name());
        //            
        //            //End National Rental Change
        //        }   
        //        
        //        
        //        // Get the business verification
        //        BusinessVerification businessVerification = dnbWebServiceUtilities.GetBusinessVerification(dunsNumber);
        //        System.debug('businessVerification - '+businessVerification);
        //        
        //        // Check if the business Verification exist
        //        if (businessVerification.hasBusinessVerication)
        //        {
        //            acct.Name = businessVerification.primaryName;
        //            acct.Legal_Entity_Address_Street__c = businessVerification.addressLine;
        //            acct.Legal_Entity_Address_Zip_Postal_Code__c = businessVerification.postalCode;
        //            acct.Legal_Entity_Address_City__c = businessVerification.postalTown;
        //            acct.Legal_Entity_Address_State_Province__c = businessVerification.stateProvince;
        //            acct.Legal_Entity_Address_Country__c = businessVerification.countryCode;
    
        //             acct.BillingStreet = businessVerification.addressLine;
        //            acct.BillingPostalCode = CommonFunctions.formatZipCode(businessVerification.postalCode);
        //            acct.BillingCity = businessVerification.postalTown;
        //            if(BusinessVerification.stateProvince !=null) {
        //           acct.BillingState = businessVerification.stateProvince.toUpperCase();
        //           }
        //           if(businessVerification.countryCode != null)
        //           {
        //            if (businessVerification.countryCode.trim().toUpperCase()==RyderGlobalVariables.COUNTRIES_CANADA_TEXT) {
        //               acct.BillingCountry = RyderGlobalVariables.COUNTRIES_CANADA; 
        //           } else {
        //               acct.BillingCountry = businessVerification.countryCode.toUpperCase();
        //           }
        //            }
        //            acct.ShippingStreet = businessVerification.addressLine;
        //            acct.ShippingPostalCode = CommonFunctions.formatZipCode(businessVerification.postalCode);
        //            acct.ShippingCity = businessVerification.postalTown;
        //            if(BusinessVerification.stateProvince !=null)
        //            {
        //            acct.ShippingState = businessVerification.stateProvince.toUpperCase();
        //            }
        //            if(businessVerification.countryCode != null)
        //           {
        //            if (businessVerification.countryCode.trim().toUpperCase()==RyderGlobalVariables.COUNTRIES_CANADA_TEXT) {
        //               acct.ShippingCountry = RyderGlobalVariables.COUNTRIES_CANADA; 
        //            } else {
        //               acct.ShippingCountry = businessVerification.countryCode.toUpperCase();
        //            }
        //            }
        //            acct.SIC = businessVerification.sicCode;
        //            acct.SIC_Code__c = getSICLookupId(businessVerification.sicCode);
        //        }   
        //    }
        //}
        //else
        //{
            //AAK 06/12/2014 Start - ReqID 343 Replace DnB with Data.com        
            //DnB_WorldBase.DATARS worldBase = dnbWebServiceUtilities.GetWorldBase(dunsNumber);
            //System.debug('worldBase - '+worldBase);
            //AAK 06/12/2014 End
            // logic added per Jose to identify branchc from worldbase call response
            /* from DnB Documentation
             BUSINESS STRUCTURE CODE 
            <MKT_BUS_STRUC_CD>
            Indicates whether the subject business is a parent or a subsidiary location.
            Possible values are: 0=single location; 1=headquarters; 2=branch.
            */
            //AAK 06/12/2014 Start - ReqID 343 Replace DnB with Data.com                    
            /*string country = null;
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
            acct.Global_Ultimate_DUNS__c = worldBase.MKT_GLBL_ULT_PNT_DUNS;*/
            //AAK 06/12/2014 End
                        
            //03/29 Neelima-- added legal duns
/*            acct.Legal_Site_Duns__c=dunsNumber;
            acct.DUNS_HQ__c = worldBase.MKT_HDQ_PNT_DUNS;
            acct.Domestic_Ultimate_DUNS__c = worldBase.MKT_DOM_ULT_PNT_DUNS;
            acct.Global_Ultimate_DUNS__c = worldBase.MKT_GLBL_ULT_PNT_DUNS;
*/
            //AAK 06/12/2014 Start - ReqID 343 Replace DnB with Data.com            
            /*acct.Legal_Entity_Address_Street__c = worldBase.MKT_PHYS_ADR_LINE;
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
*/
                    System.Debug('dunsNumber in getcorporatelinkage : ' + dunsNumber);
                    DatacloudDandBCompany dcc = RDatacom_SearchAPI.getDatacloudDandBCompany(dunsNumber);
                    System.Debug('DatacloudDandBCompany in getcorporatelinkage : ' + dcc);
                    string country = null;
                    string zip = null;
                    
                    acct.DCCompanyId__c = dcc.CompanyId;
                    if (dcc.Country.trim().toUpperCase() == RyderGlobalVariables.COUNTRIES_CANADA_TEXT) {
                       country = RyderGlobalVariables.COUNTRIES_CANADA;
                       zip = dcc.Zip;
                    } else if (dcc.Country.trim().toUpperCase() =='USA' || dcc.Country.trim().toUpperCase() =='UNITED STATES') {
                       country = RyderGlobalVariables.COUNTRIES_USA;
                       zip = dcc.Zip.substring(0,5);
                       system.debug('country. worldBase - '+country);               
                    }            
                    else {
                       country = dcc.Country;
                       zip = dcc.Zip;
                    }                       
                    system.debug('a1. worldBase - '+dcc.LocationStatus);            
                    //0 = Single Location ; 1 = Headquarters/Parent ; 2 = Branch
                    if (dcc.LocationStatus != null && dcc.LocationStatus == '2')
                    {
                        this.isBranch = true;
                        acct.DUNS_HQ__c = dcc.ParentOrHqDunsNumber; // worldBase.MKT_HDQ_PNT_DUNS;
                        acct.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_FMS_Branch_Account.name());
                        acct.DB_Loc_Type__c = 'Branch';
                        system.debug('a2. worldBase - '+acct.DB_Loc_Type__c);
                    } else {
                        acct.DUNS_HQ__c = dcc.DunsNumber; //  worldBase.MKT_DUNS_NBR;
                        acct.RecordTypeId = accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Parent_Account.name());
                        if (dcc.LocationStatus != null && dcc.LocationStatus == '1') {
                            acct.DB_Loc_Type__c = 'Headquarters';                   
                            system.debug('a3. worldBase - '+acct.DB_Loc_Type__c);
                        }
                        else if (dcc.LocationStatus != null && dcc.LocationStatus == '0') {
                            
                            system.debug('a4. worldBase - '+acct.DB_Loc_Type__c);
                            acct.DB_Loc_Type__c = 'Single Location';
                        }                               
                    }
                    if (acct.DUNS_HQ__c == '000000000')
                        acct.DUNS_HQ__c = null;
                    
                    acct.Name = dcc.Name; // worldBase.MKT_PRIM_NME;
                    acct.Legal_Site_Duns__c= dunsNumber;
                    acct.Site_Duns__c = dunsNumber;
                    acct.Domestic_Ultimate_DUNS__c = dcc.DomesticUltimateDunsNumber; // worldBase.MKT_DOM_ULT_PNT_DUNS;
                    if (acct.Domestic_Ultimate_DUNS__c == '000000000')
                        acct.Domestic_Ultimate_DUNS__c = null;
        
                    acct.Global_Ultimate_DUNS__c = dcc.GlobalUltimateDunsNumber; // worldBase.MKT_GLBL_ULT_PNT_DUNS;

                    acct.Legal_Entity_Address_Street__c = dcc.Street; // worldBase.MKT_PHYS_ADR_LINE;
                    acct.Legal_Entity_Address_Zip_Postal_Code__c = zip;
                    acct.Legal_Entity_Address_City__c = dcc.City; // worldBase.MKT_PHYS_POST_TOWN_TEXT;
                    acct.Legal_Entity_Address_State_Province__c = RDatacom_SearchAPI.getDatacloudstateCode(dcc.CompanyId); //pacct.ShippingState; // didn't use dcc as dataclouddnbcompany was return full state name instead of two letter code // worldBase.MKT_PHYS_GEO_AREA_CD;
                     //Populating Below >> commented by Virendra acct.ShippingCountry = country;
                    acct.Legal_Entity_Address_Country__c = country;
                        
                    acct.BillingStreet = dcc.Street; // worldBase.MKT_PHYS_ADR_LINE;
                    acct.BillingPostalCode = zip;
                    acct.BillingCity = dcc.City; // worldBase.MKT_PHYS_POST_TOWN_TEXT;
                    acct.BillingState = acct.Legal_Entity_Address_State_Province__c; //pacct.ShippingState; // worldBase.MKT_PHYS_GEO_AREA_CD;
                    system.debug('acct.BillingState : acct.Legal_Entity_Address_State_Province__c :' + acct.BillingState );
                    acct.ShippingStreet = dcc.Street; // worldBase.MKT_PHYS_ADR_LINE;
                    acct.ShippingPostalCode = zip;
                    acct.ShippingCity = dcc.City; // worldBase.MKT_PHYS_POST_TOWN_TEXT;
                    acct.ShippingState = acct.Legal_Entity_Address_State_Province__c; //pacct.ShippingState; // worldBase.MKT_PHYS_GEO_AREA_CD;
                   
                    //Added By Virendra to get two digit Country Code
                    if(country!=null){
                       if(country.length() == 2){   
                         acct.ShippingCountry = country;
                         acct.BillingCountry = country;    
                       }else {
                         acct.ShippingCountry = getCountryCode(country);
                         acct.BillingCountry = getCountryCode(country);    
                       }
                    }
                    //AAK 12/04/2014 Start
                    //QC 536 Modify Lead Conversion process - For phone numbers
                    if(dcc.Phone != null)
                        acct.Phone = dcc.Phone;
                            
                    system.debug('dcc.phone : ' + acct.Phone + ' -- ' + dcc.Phone);
                    //AAK 11/30/2014 End                                            
                    acct.SIC = dcc.PrimarySic; // worldBase.MKT_SIC8;
                    acct.SIC_Code__c = getSICLookupId(dcc.PrimarySic);
                    system.debug ('acct.SIC_Code__c : ' + acct.SIC_Code__c);
                    system.debug ('acct.PrimarySicDesc : ' + dcc.PrimarySicDesc);
                    
                    system.debug ('getcorporate acct : ' + acct);
            //AAK 06/12/2014 End

        system.debug('Corporated acc : ' + acct);
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
        System.debug('*********** Start addItem **************');
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
        system.debug(LoggingLevel.INFO, '**************** inside rollbackAccountConversion:');
        system.debug(LoggingLevel.INFO, '**************** this.accountState:' + this.accountState);
        system.debug(LoggingLevel.INFO, '**************** this.contactState:' + this.contactState);
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

    /*
    *  Get Two Digit Code while populating the Country fields recieved from D&B account 
    *  Created by Virendra on 18 Feb 2015 to fix issues on I-145858
    */
    
    private String getCountryCode(String countryName){
        List<SelectOption> countriesOptions = getItemsCountries(); 
        String countryCode = null;
        for(SelectOption sop:countriesOptions){
            if(sop.getLabel() == countryName ){
                countryCode = sop.getValue();
                break;
            }
        }
        return countryCode;
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
        if(isUVSLead == true){
          if (optionsCountries.size()==0)
          {
            optionsCountries.add(new SelectOption('US','UNITED STATES'));
            optionsCountries.add(new SelectOption('CA','CANADA'));
            optionsCountries.add(new SelectOption('MX','MEXICO'));
            optionsCountries.add(new SelectOption('GB','UNITED KINGDOM'));
            optionsCountries.add(new SelectOption('PR','PUERTO RICO'));
            optionsCountries.add(new SelectOption('AO','ANGOLA'));
            optionsCountries.add(new SelectOption('AR','ARGENTINA'));
            optionsCountries.add(new SelectOption('BS','BAHAMAS'));
            optionsCountries.add(new SelectOption('BZ','BELIZE'));
            optionsCountries.add(new SelectOption('BR','BRAZIL'));
            optionsCountries.add(new SelectOption('BG','BULGARIA'));
            optionsCountries.add(new SelectOption('KY','CAYMAN ISLANDS'));
            optionsCountries.add(new SelectOption('CL','CHILE'));
            optionsCountries.add(new SelectOption('CN','CHINA'));
            optionsCountries.add(new SelectOption('CO','COLOMBIA'));
            optionsCountries.add(new SelectOption('CR','COSTA RICA'));
            optionsCountries.add(new SelectOption('CU','CUBA'));
            optionsCountries.add(new SelectOption('DO','DOMINICAN REPUBLIC'));
            optionsCountries.add(new SelectOption('EC','ECUADOR'));
            optionsCountries.add(new SelectOption('SV','EL SALVADOR'));
            optionsCountries.add(new SelectOption('GH','GHANA'));
            optionsCountries.add(new SelectOption('GU','GUAM'));
            optionsCountries.add(new SelectOption('GT','GUATEMALA'));
            optionsCountries.add(new SelectOption('HT','HAITI'));
            optionsCountries.add(new SelectOption('HN','HONDURAS'));
            optionsCountries.add(new SelectOption('HU','HUNGARY'));
            optionsCountries.add(new SelectOption('JM','JAMAICA'));
            optionsCountries.add(new SelectOption('AN','NETHERLAND ANTILLES'));
            optionsCountries.add(new SelectOption('NI','NICARAGUA'));
            optionsCountries.add(new SelectOption('NE','NIGERIA'));
            optionsCountries.add(new SelectOption('PA','PANAMA'));
            optionsCountries.add(new SelectOption('PY','PARAGUAY'));
            optionsCountries.add(new SelectOption('PE','PERU'));
            optionsCountries.add(new SelectOption('PH','PHILIPPINES'));
            optionsCountries.add(new SelectOption('AS','AMERICAN SAMOA'));
            optionsCountries.add(new SelectOption('RO','ROMANIA'));
            optionsCountries.add(new SelectOption('RU','RUSSIA'));
            optionsCountries.add(new SelectOption('SA','SAUDI ARABIA'));
            optionsCountries.add(new SelectOption('ZA','SOUTH AFRICA'));
            optionsCountries.add(new SelectOption('SR','SURINAM'));
            optionsCountries.add(new SelectOption('UY','URUGUAY'));
            optionsCountries.add(new SelectOption('VE','VENEZUELA'));
            optionsCountries.add(new SelectOption('VI','VIRGIN ISLANDS'));
            optionsCountries.add(new SelectOption('WS','WESTERN SAMOA'));
            optionsCountries.add(new SelectOption('AU','AUSTRALIA'));
            optionsCountries.add(new SelectOption('BO','BOLIVIA'));
            optionsCountries.add(new SelectOption('CW','CURACAO'));
            optionsCountries.add(new SelectOption('KE','KENYA'));
            optionsCountries.add(new SelectOption('SG','SINGAPORE'));
            optionsCountries.add(new SelectOption('VE','VIETNAM'));
            optionsCountries.add(new SelectOption('CY','CYPRUS'));
            optionsCountries.add(new SelectOption('ZW','ZIMBABWE'));
            optionsCountries.add(new SelectOption('BM','BERMUDA'));
            optionsCountries.add(new SelectOption('BE','BELGIUM'));
            optionsCountries.add(new SelectOption('UA','UKRAINE'));
            optionsCountries.add(new SelectOption('AE','UNITED ARAB EMIRATES'));
            optionsCountries.add(new SelectOption('LR','LIBERIA'));
            optionsCountries.add(new SelectOption('AE','DUBAI'));
            optionsCountries.add(new SelectOption('ZM','ZAMBIA'));
            optionsCountries.add(new SelectOption('AI','ANGUILLA'));
            optionsCountries.add(new SelectOption('TC','TURKS AND CAICOS ISLANDS'));
            optionsCountries.add(new SelectOption('BB','BARBADOS'));
            optionsCountries.add(new SelectOption('TT','TRINIDAD AND TOBAGO'));
            optionsCountries.add(new SelectOption('GY','GUYANA'));
            optionsCountries.add(new SelectOption('YE','YEMEN'));
            optionsCountries.add(new SelectOption('AG','ANTIGUA'));
            optionsCountries.add(new SelectOption('NA','NAMIBIA'));
            optionsCountries.add(new SelectOption('CI','COTE DIVOIRE'));
            optionsCountries.add(new SelectOption('QA','QATAR'));
            optionsCountries.add(new SelectOption('TN','TUNISIA'));
            optionsCountries.add(new SelectOption('MZ','MOZAMBIQUE'));
            optionsCountries.add(new SelectOption('MA','MOROCCO'));
            optionsCountries.add(new SelectOption('GA','GABON'));
            optionsCountries.add(new SelectOption('SN','SENEGAL'));
            optionsCountries.add(new SelectOption('AW','ARUBA'));
            optionsCountries.add(new SelectOption('MP','SAIPAN'));
            optionsCountries.add(new SelectOption('NL','NETHERLANDS'));
            optionsCountries.add(new SelectOption('LC','ST LUCIA'));
            optionsCountries.add(new SelectOption('MC','MONACO'));
            optionsCountries.add(new SelectOption('GN','CONAKRY'));
            optionsCountries.add(new SelectOption('RW','RWANDA'));
            optionsCountries.add(new SelectOption('CD','DEMOCRATIC REPUBLIC OF CONGO'));
            optionsCountries.add(new SelectOption('UK','ENGLAND'));
            optionsCountries.add(new SelectOption('ET','ETHIOPIA'));
            optionsCountries.add(new SelectOption('MU','REPUBLIC OF MAURITIUS'));
            optionsCountries.add(new SelectOption('MW','MALAWI'));
            optionsCountries.add(new SelectOption('SC','SEYCHELLES'));
            optionsCountries.add(new SelectOption('TZ','TANZANIA'));
            optionsCountries.add(new SelectOption('IN','INDIA'));

          }
        }
        else{
          if (optionsCountries.size()==0)
          {
              optionsCountries.add(new SelectOption(RyderGlobalVariables.COUNTRIES_USA, RyderGlobalVariables.COUNTRIES_USA));
              optionsCountries.add(new SelectOption(RyderGlobalVariables.COUNTRIES_CANADA, RyderGlobalVariables.COUNTRIES_CANADA_TEXT));
          }
        }
        System.debug('*********** End getItemsCountries **************');
        return optionsCountries;
    }
    
     //AAK 01/08/2015 Start - variable to hold Lead Source / Detail to Account Source Mapping for the SAM
     private void buildLeadToAccSourceMapping()
     {
        this.MapLeadtoAccountSource.put('Employee ReferralRAM','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Employee ReferralRental Counter','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Employee ReferralVSM','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Employee ReferralBDM','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Employee ReferralCDM','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Employee ReferralDBD','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Employee ReferralDNA','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Employee ReferralSupply Chain Services','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Employee ReferralRyder Fleet Products','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Employee ReferralCOMBO','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Employee ReferralIndustry Specialist','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Employee ReferralNRM','Salesforce called/visited');                        
        this.MapLeadtoAccountSource.put('Employee ReferralRIDE Page','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Existing Customer','Exp. With Ryder / Prev. customer');
        this.MapLeadtoAccountSource.put('Other Customer','Exp. With Ryder / Prev. customer');
        this.MapLeadtoAccountSource.put('Digital MarketingRyder web site visitor via web search','Ryder Website');
        this.MapLeadtoAccountSource.put('Digital MarketingTruck Paper','Truck Paper');
        this.MapLeadtoAccountSource.put('Digital MarketingTruckerAds.com','Internet ? Other');
        this.MapLeadtoAccountSource.put('Digital MarketingTrucker.com','Internet ? Other');
        this.MapLeadtoAccountSource.put('Digital MarketingCommercialTruckTrader.com','Truck Trader');
        this.MapLeadtoAccountSource.put('Digital MarketingTruckAndTrailer.ca','Internet ? Other');
        this.MapLeadtoAccountSource.put('Direct Dimensional MarketingTransportation Direct Marketing','Direct Mail');
        this.MapLeadtoAccountSource.put('Direct Dimensional MarketingRed Cross','Exp. With Ryder / Prev. customer');
        this.MapLeadtoAccountSource.put('Direct Dimensional MarketingiPad Purl Promotion','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Direct Dimensional MarketingFood and Beverage','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Direct Dimensional MarketingLocal Campaign','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Other OutboundBlitz','Salesforce called/visited');     
        this.MapLeadtoAccountSource.put('Other OutboundSelf-Generated','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Other OutboundUniversal Fleet Database','Other');
        this.MapLeadtoAccountSource.put('Other OutboundSeminar / Trade Shows','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Seminar / Trade Shows','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('Local Campaigns','Salesforce called/visited');
        this.MapLeadtoAccountSource.put('InboundWalk-in','Walk in/Drive By');
        this.MapLeadtoAccountSource.put('InboundVendor','Word of mouth/Business assoc');
        this.MapLeadtoAccountSource.put('InboundWord of Mouth','Word of mouth/Business assoc');
        this.MapLeadtoAccountSource.put('InboundCustomer Referral','Word of mouth/Business assoc');
        this.MapLeadtoAccountSource.put('InboundEnd of Lease','Exp. With Ryder / Prev. customer');
        this.MapLeadtoAccountSource.put('InboundRyder 800 Number','Word of mouth/Business assoc');
        this.MapLeadtoAccountSource.put('Other','Other');
     }
     
     private void updateAccountSource(Account account)
     {
        if (account.SAM_Account_Source__c == null){
        	//AAK 03/10/2015 Start - fixing when account created directly from the menu
        	system.debug('updateAccountSource sleadSSD ' + sleadSSD);
        	if (sleadSSD != null)
        	{
        	//AAK 03/10/2015 End
	            if (MapLeadtoAccountSource.containsKey(sleadSSD)){
	                account.SAM_Account_Source__c = MapLeadtoAccountSource.get(sleadSSD);
	            }
	        //AAK 03/10/2015 Start - fixing when account created directly from the menu
        	}
        	system.debug('updateAccountSource account.SAM_Account_Source__c ' + account.SAM_Account_Source__c);
        	//AAK 03/10/2015 End
        }
            
     }
     //AAK 01/08/2015 End
     
    
    
/*    private static Lead createLead(String country)
  {
    Lead lead = new Lead();
    lead.FirstName = RyderGlobalVariables.TEST_FIRST_NAME;
    lead.LastName = RyderGlobalVariables.TEST_LAST_NAME;
    lead.Company = RyderGlobalVariables.TEST_PRIMARY_NAME;
    lead.Status = RyderGlobalVariables.TEST_STATUS;
    lead.LeadSource = RyderGlobalVariables.TEST_SOURCE;
    lead.Email='test@email.com';
    lead.Street = RyderGlobalVariables.TEST_ADDRESS_LINE;
    lead.City = RyderGlobalVariables.TEST_CITY;
    if (country == RyderGlobalVariables.COUNTRIES_USA) {
      lead.State = RyderGlobalVariables.TEST_STATE;
      lead.PostalCode = RyderGlobalVariables.TEST_POST_CODE;
    } else {
      lead.State = RyderGlobalVariables.TEST_STATE_CANADA;
      lead.PostalCode = RyderGlobalVariables.TEST_CANADA_POST_CODE;
    }
    lead.Country = country;
    
    lead.Customer_Type__c = RyderGlobalVariables.CustomerType.FMS.name();
    // lead.Country = 'US';
    insert lead;
    
    return lead;
    
    }
 */   
    //AAK 06/20/2014 Start - getting Error: Test methods must be in test classes at line 2428 column 35 so commented
    /*public static testMethod void test_contactmanag(){
        Lead lead = createLead(RyderGlobalVariables.COUNTRIES_USA);
    
        Account pAccount = new Account();
        pAccount.Name = 'Parent Company Ltd.';
        pAccount.ShippingStreet = 'Address Line 1';
        pAccount.ShippingCity = 'Test City 1';
        pAccount.ShippingState = 'FL';
        pAccount.ShippingPostalCode = '12345';
        pAccount.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;
        pAccount.CustomerTypeID__c = RyderGlobalVariables.CustomerType.FMS.name();
        pAccount.billingstate = 'IL';
        pAccount.DUNS_HQ__c='12345678';
        pAccount.Site_Duns__c='12845678';
        
        insert pAccount;
        
        Account account = new Account();
        account.Name = RyderGlobalVariables.TEST_PRIMARY_NAME;
        account.ShippingStreet = RyderGlobalVariables.TEST_ADDRESS_LINE;
        account.ShippingCity = RyderGlobalVariables.TEST_CITY;
        account.ShippingState = RyderGlobalVariables.TEST_STATE;
        account.ShippingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
        account.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;  
        account.CustomerTypeID__c = RyderGlobalVariables.CustomerType.FMS.name();
        account.billingstate = 'IL';
        account.ParentId = pAccount.Id;
        account.OwnerId = UserInfo.getUserId();
        insert account;
       SIC_Code__c siccode= new SIC_Code__c();
       siccode.Name='Test';
       siccode.CurrencyIsoCode='USD';
       insert siccode;
        ApexPages.currentPage().getParameters().put('leadId', lead.Id);
        ApexPages.currentPage().getParameters().put('fromLead', 'true');
        ApexPages.StandardController cont = new ApexPages.StandardController(account);
        NewAccountContactController nac = new NewAccountContactController(cont);
      
        nac.addErrors('errorConvertinglead');
    
        nac.addAccountTeams(account);    
        nac.addToAccountTeam(String.valueOf(pAccount.Id), String.valueOf(UserInfo.getUserId()));
        nac.translateAccountTeamRole(UserInfo.getUserId());
        try {
           nac.getAccountByCustProspectId(123);
           nac.createDnBAccountForRental();           
        } catch(Exception e) {
        }
        try{
        nac.RefreshDNBInformation(account);
        }catch(Exception e){
        }
        nac.getExistingAccount(pAccount.Site_Duns__c,pAccount.CustomerTypeID__c);
       // nac.getExistingAccount('12345','123');
       nac.getAccountsToFixAccountParent('HQ',pAccount.DUNS_HQ__c,pAccount.CustomerTypeID__c,paccount.Id);
        nac.addChildOwnerToParent(account);
        nac.addAccountOwnerToParent(account,pAccount);
   // nac.addCurrentUserToAccounts(account);
    nac.retrieveContacts();
      nac.getSICLookupBySFId(siccode.id);
    nac.rollbackAccountConversion();

}*/
//AAK 06/20/2014 End
}