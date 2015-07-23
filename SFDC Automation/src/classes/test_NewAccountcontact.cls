/**
 * This class contains unit tests for validating the behavior of Apex classes and validating the lead conversion and contact management.
 *
 */
@isTest
private class test_NewAccountcontact
{
    // Create lead to convert
    public static User sysAdmin = TestUtilUvs.createUser(True);
    private static Lead createLead(String country)
    {
        Lead lead = new Lead();
        lead.FirstName = RyderGlobalVariables.TEST_FIRST_NAME;
        lead.LastName = RyderGlobalVariables.TEST_LAST_NAME;
        lead.Company = RyderGlobalVariables.TEST_PRIMARY_NAME;
        lead.Status = RyderGlobalVariables.TEST_STATUS;
        lead.LeadSource = RyderGlobalVariables.TEST_SOURCE;
        lead.LeadSource = 'Employee Referral' ;
        lead.Street = RyderGlobalVariables.TEST_ADDRESS_LINE;
        lead.City = RyderGlobalVariables.TEST_CITY;
        lead.SapID__c = 'test';
        lead.Employee_Zipcode__c = '302019';
        lead.Employee_Phone__c = '(999) 999-9999';
        lead.Employee_Name__c = 'test';
        lead.Employee_Email__c = 'abc@gmail.com';
        lead.Entity_Type__c = 'Individual Consumer';
        lead.phone = '(999) 999-9999';

        lead.LeadSource = 'Inbound';
        lead.Lead_Source_Detail__c = 'Walk-in';
        
        if (country == RyderGlobalVariables.COUNTRIES_USA) {
            lead.State = RyderGlobalVariables.TEST_STATE;
            lead.PostalCode = RyderGlobalVariables.TEST_POST_CODE;
        } else {
            lead.State = RyderGlobalVariables.TEST_STATE_CANADA;
            lead.PostalCode = RyderGlobalVariables.TEST_CANADA_POST_CODE;
        }
        lead.National_Account_Flag__c = true;
        lead.Country = country;
        
        lead.Customer_Type__c = RyderGlobalVariables.CustomerType.FMS.name();
        // lead.Country = 'US';
        insert lead;
        
        return lead;
    }
    
    // Create Account to attach to existing lead convert
    private static Account createAccount(String country)
    {
        
        Account account1 = new Account();
        account1.RyderProbabilityMatch__c = 100.00;
        account1.Name = RyderGlobalVariables.TEST_PRIMARY_NAME;
        account1.phone = '(999) 999-9999';
        account1.ShippingStreet = RyderGlobalVariables.TEST_ADDRESS_LINE;
        account1.ShippingCity = RyderGlobalVariables.TEST_CITY;
        
            account1.ShippingState = RyderGlobalVariables.TEST_STATE;
            account1.ShippingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
            account1.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;
 
        account1.CustomerTypeID__c = RyderGlobalVariables.CustomerType.FMS.name();
        account1.billingstate = 'IL';
        insert account1;        
        
        
        Account account = new Account();
        account.parentId = account1.id;
        account.RyderProbabilityMatch__c = 100.00;
        account.Name = RyderGlobalVariables.TEST_PRIMARY_NAME;
        account.phone = '(999) 999-9999';
        account.ShippingStreet = RyderGlobalVariables.TEST_ADDRESS_LINE;
        account.ShippingCity = RyderGlobalVariables.TEST_CITY;
        if (country == RyderGlobalVariables.COUNTRIES_USA) {
            account.ShippingState = RyderGlobalVariables.TEST_STATE;
            account.ShippingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
            account.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;
        } else {
            account.ShippingState = RyderGlobalVariables.TEST_STATE_CANADA;
            account.ShippingPostalCode = RyderGlobalVariables.TEST_CANADA_POST_CODE;
            account.ShippingCountry = RyderGlobalVariables.COUNTRIES_CANADA;
        }

        account.CustomerTypeID__c = RyderGlobalVariables.CustomerType.FMS.name();
        account.billingstate = 'IL';
        insert account;
        
        return account;
    }

    // Create Contact to attach to existing lead convert
    private static Contact createContact(Id acctId)
    {
        Contact contact = new Contact();
        contact.FirstName = RyderGlobalVariables.TEST_FIRST_NAME;
        contact.LastName = RyderGlobalVariables.TEST_LAST_NAME;
        contact.Phone = null;
        contact.Email_does_not_exist__c = true;
        contact.Email_Does_Not_Exist_Reason__c = 'I will update it later';
        contact.AccountId = acctId;
        insert contact;
        
        return contact;
    }
    
    // Basic test checks if the lead is converted with creation of USA account and contact 
    static testMethod void test_NewAccountPageFromLeadUSA() 
    {
       // User sysAdmin = TestUtilUvs.createUser(True);

        System.runAs ( sysAdmin ) {
            
            
        Lead lead = createLead(RyderGlobalVariables.COUNTRIES_USA);
        Account account = createAccount(RyderGlobalVariables.COUNTRIES_USA);
        Contact cntct = createContact(account.Id);
        // Start the test
        Test.startTest();
        account.Company_Lead_Type__c = 'Individual';
        update account;
        RyderGlobalVariables.IS_TEST = true;
        RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
        // Set the Page Reference
        PageReference newAccountPage = Page.NewAccount;
        Test.setCurrentPage(newAccountPage);
                    
        // Set the model action
        ApexPages.currentPage().getParameters().put('leadId', lead.Id);
        ApexPages.currentPage().getParameters().put('fromLead', 'true');

        // Create a standard controller 
        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(account); 
        
        //create instance of pages controller
        newAccountContactController newAccountContactController = new newAccountContactController(controller);
        
        newAccountContactController.isUVSLead = true;
        newAccountContactController.isIndividualLead = true;
        newAccountContactController.convertIndividualLead();
        // Lookup values
        List<SelectOption> selectCountries = newAccountContactController.getItemsCountries();
        List<DBAccount> dbAccounts = newAccountContactController.getDBAccountToDisplay();
        Account accountRecordOwner = newAccountContactController.getRecordOwner();
        
        newAccountContactController.account = account;
        newAccountContactController.isIndividualLead = false;
        PageReference pageRefSearch = newAccountContactController.doSearch();

        System.debug('Account - '+accountRecordOwner);
        
        // Call the cancel function 
        PageReference pageRefCancel = newAccountContactController.Cancel();
        
        newAccountContactController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.assignAccount();
        newAccountContactController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.assignAccount();

        newAccountContactController.oldAccountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.accountSelected = '098765';
        newAccountContactController.assignAccount();

        newAccountContactController.oldAccountSelected = '';
        newAccountContactController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.assignAccount();
        
        newAccountContactController.assignContact();
        SFDCContact afdcContact = newAccountContactController.addSFDCNewContact();

        // Call the convert function and then check the assert
        PageReference pageRef = newAccountContactController.createNewAccount();
        
        Lead leadToCheck = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id =: lead.Id];
        System.debug('leadToCheck - ' + leadToCheck);
        //System.assert(leadToCheck.ConvertedAccountId == null);
        //System.assert(leadToCheck.ConvertedContactId == null);
        // Stop the test
        Test.stopTest();
      } 
    }

    // Basic test checks if the lead is converted with creation of Canada account and contact 
    static testMethod void test_NewAccountPageFromLeadCanada() 
    {
        //User sysAdmin = TestUtilUvs.createUser(True);

        System.runAs ( sysAdmin ) {
            
        
        
        Lead lead = createLead(RyderGlobalVariables.COUNTRIES_CANADA);
        Account account = createAccount(RyderGlobalVariables.COUNTRIES_CANADA);
        Contact cntct = createContact(account.Id);
        // Start the test
        Test.startTest();
                    
        RyderGlobalVariables.IS_TEST = true;
        RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
        // Set the Page Reference
        PageReference newAccountPage = Page.NewAccount;
        Test.setCurrentPage(newAccountPage);
                    
        // Set the model action
        ApexPages.currentPage().getParameters().put('leadId', lead.Id);
        ApexPages.currentPage().getParameters().put('fromLead', 'true');

        // Create a standard controller
        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(account); 

        //create instance of pages controller
        newAccountContactController newAccountContactController = new newAccountContactController(controller);
        newAccountContactController.isUVSLead = true;
        // Lookup values
        List<SelectOption> selectCountries = newAccountContactController.getItemsCountries();
        List<DBAccount> dbAccounts = newAccountContactController.getDBAccountToDisplay();
        Account accountRecordOwner = newAccountContactController.getRecordOwner();

        PageReference pageRefSearch = newAccountContactController.doSearch();

        System.debug('Account - '+accountRecordOwner);
        
        // Call the cancel function 
        PageReference pageRefCancel = newAccountContactController.Cancel();
        
        newAccountContactController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.assignAccount();
        newAccountContactController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.assignAccount();

        newAccountContactController.oldAccountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.accountSelected = '098765';
        newAccountContactController.assignAccount();
        
        newAccountContactController.oldAccountSelected = '';
        newAccountContactController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.assignAccount();
        
        newAccountContactController.assignContact();
        SFDCContact afdcContact = newAccountContactController.addSFDCNewContact();

        // Call the convert function and then check the assert
        PageReference pageRef = newAccountContactController.createNewAccount();
        
        Lead leadToCheck = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id =: lead.Id];
        System.debug('leadToCheck - ' + leadToCheck);
        //System.assert(leadToCheck.ConvertedAccountId == null);
        //System.assert(leadToCheck.ConvertedContactId == null);
        // Stop the test
        Test.stopTest();
        }
    }

    // Basic test checks if the lead is converted with creation of Canada account and contact 
    static testMethod void test_NewAccountPageFromNewAccountCanada() 
    {
       
        //User sysAdmin = TestUtilUvs.createUser(True);

        System.runAs ( sysAdmin ) {
            
       
        // Start the test
        Test.startTest();
        Account account = createAccount(RyderGlobalVariables.COUNTRIES_CANADA);
        Contact cntct = createContact(account.Id);
                    
        RyderGlobalVariables.IS_TEST = true;
        RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
        // Set the Page Reference
        PageReference newAccountPage = Page.NewAccount;
        Test.setCurrentPage(newAccountPage);
                    
        // Create a standard controller
        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(account); 

        //create instance of pages controller
        newAccountContactController newAccountContactController = new newAccountContactController(controller);
        newAccountContactController.isUVSLead = true;
        newAccountContactController.account = account;
        newAccountContactController.contact = cntct;

        // Lookup values
        List<SelectOption> selectCountries = newAccountContactController.getItemsCountries();
        List<DBAccount> dbAccounts = newAccountContactController.getDBAccountToDisplay();
        Account accountRecordOwner = newAccountContactController.getRecordOwner();

        PageReference pageRefSearch = newAccountContactController.doSearch();

        System.debug('Account - '+accountRecordOwner);
        
        // Call the cancel function 
        PageReference pageRefCancel = newAccountContactController.Cancel();
        
        newAccountContactController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.assignAccount();
        newAccountContactController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.assignAccount();
        newAccountContactController.oldAccountSelected = '';
        newAccountContactController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.assignAccount();
        
        newAccountContactController.assignContact();
        SFDCContact afdcContact = newAccountContactController.addSFDCNewContact();

        // Call the convert function and then check the assert
        PageReference pageRef = newAccountContactController.createNewAccount();
        System.assert(pageRef == null);
        // Stop the test
        Test.stopTest();
        }
    }

    // Basic test checks if the lead is converted with creation of Canada account and contact 
    static testMethod void test_NewAccountPageFromNewAccountUSA() 
    {
       // User sysAdmin = TestUtilUvs.createUser(True);

        System.runAs ( sysAdmin ) {
            
        
        // Start the test
        Test.startTest();
        Account account = createAccount(RyderGlobalVariables.COUNTRIES_USA);
        Contact cntct = createContact(account.Id);
                    
        RyderGlobalVariables.IS_TEST = true;
        RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
        // Set the Page Reference
        PageReference newAccountPage = Page.NewAccount;
        Test.setCurrentPage(newAccountPage);
                    
        // Create a standard controller
        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(account); 

        //create instance of pages controller
        newAccountContactController newAccountContactController = new newAccountContactController(controller);
        newAccountContactController.isUVSLead = true;
        newAccountContactController.account = account;
        newAccountContactController.contact = cntct;

        // Lookup values
        List<SelectOption> selectCountries = newAccountContactController.getItemsCountries();
        List<DBAccount> dbAccounts = newAccountContactController.getDBAccountToDisplay();
        Account accountRecordOwner = newAccountContactController.getRecordOwner();

        PageReference pageRefSearch = newAccountContactController.doSearch();

        System.debug('Account - '+accountRecordOwner);
        
        // Call the cancel function 
        PageReference pageRefCancel = newAccountContactController.Cancel();
        
        newAccountContactController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.assignAccount();
        newAccountContactController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.assignAccount();
        newAccountContactController.oldAccountSelected = '';
        newAccountContactController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.assignAccount();
        
        newAccountContactController.assignContact();
        SFDCContact afdcContact = newAccountContactController.addSFDCNewContact();

        // Call the convert function and then check the assert
        PageReference pageRef = newAccountContactController.createNewAccount();
        System.assert(pageRef == null);
        // Stop the test
        Test.stopTest();
        }
    }
    
 //AAK //////////////////////
 
     // Create Account to attach to existing lead convert
    private static Account createRentalAccount(String country)
    {
        Account account = new Account();
        account.RyderProbabilityMatch__c = 100.00;
        account.Name = RyderGlobalVariables.TEST_PRIMARY_NAME;
        account.ShippingStreet = RyderGlobalVariables.TEST_ADDRESS_LINE;
        account.ShippingCity = RyderGlobalVariables.TEST_CITY;
        if (country == RyderGlobalVariables.COUNTRIES_USA) {
            account.ShippingState = RyderGlobalVariables.TEST_STATE;
            account.ShippingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
            account.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;
        } else {
            account.ShippingState = RyderGlobalVariables.TEST_STATE_CANADA;
            account.ShippingPostalCode = RyderGlobalVariables.TEST_CANADA_POST_CODE;
            account.ShippingCountry = RyderGlobalVariables.COUNTRIES_CANADA;
        }

        account.CustomerTypeID__c = 'FMS Rental';
        account.billingstate = 'IL';
        insert account;
        
        return account;
    }

        // Create Contact to attach to existing lead convert
    private static Contact createContactwithEmail(Id acctId)
    {
        Contact contact = new Contact();
        contact.FirstName = RyderGlobalVariables.TEST_FIRST_NAME;
        contact.LastName = RyderGlobalVariables.TEST_LAST_NAME;
        contact.Phone = null;
        contact.Email = 'abc@test.com';
        contact.Email_does_not_exist__c = false;
        contact.Email_Does_Not_Exist_Reason__c = null;
        contact.AccountId = acctId;
        insert contact;
        
        return contact;
    }
 
     //to work with Rental account without lead
     // Basic test checks if the lead is converted with creation of Canada account and contact 
    static testMethod void test_NewAccountPageFromNewAccountCanadaRental() 
    {
       //User sysAdmin = TestUtilUvs.createUser(True);

        System.runAs ( sysAdmin ) {
            
        
        // Start the test
        Test.startTest();
        Account account = createRentalAccount(RyderGlobalVariables.COUNTRIES_CANADA);
        Contact cntct = createContactwithEmail(account.Id);
                    
        RyderGlobalVariables.IS_TEST = true;
        RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
        // Set the Page Reference
        PageReference newAccountPage = Page.NewAccount;
        Test.setCurrentPage(newAccountPage);
                    
        // Create a standard controller
        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(account); 

        //create instance of pages controller
        newAccountContactController newAccountContactController = new newAccountContactController(controller);
        newAccountContactController.isUVSLead = true;
        newAccountContactController.account = account;
        newAccountContactController.contact = cntct;

        // Lookup values
        List<SelectOption> selectCountries = newAccountContactController.getItemsCountries();
        List<DBAccount> dbAccounts = newAccountContactController.getDBAccountToDisplay();
        Account accountRecordOwner = newAccountContactController.getRecordOwner();

        PageReference pageRefSearch = newAccountContactController.doSearch();

        System.debug('Account - '+accountRecordOwner);
        
        // Call the cancel function 
        PageReference pageRefCancel = newAccountContactController.Cancel();
        
        newAccountContactController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.assignAccount();
        newAccountContactController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.assignAccount();
        newAccountContactController.oldAccountSelected = '';
        newAccountContactController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountContactController.assignAccount();
        
        newAccountContactController.assignContact();
        SFDCContact afdcContact = newAccountContactController.addSFDCNewContact();

        // Call the convert function and then check the assert
        PageReference pageRef = newAccountContactController.createNewAccount();
        System.assert(pageRef == null);
        // Stop the test
        Test.stopTest();
        }
    }  

    static testMethod void test_NewAccountPageForAccountShareCustom() 
    {
       // User sysAdmin = TestUtilUvs.createUser(True);
        Profile p = [select p.id from Profile p where p.Name in ('VSM_VSR') LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name LIKE '%VSM%' LIMIT 1];
        //Creating the user
        User u = new User( Username = 'uvs2@rydertest.com',
                                    Alias = 'autclon', FirstName = 'Ryder2', LastName = 'Tester2', Email = 'uvs2@rydertest.com',
                                    EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                                    LocalesIdKey = 'en_US', ProfileId = p.Id, TimeZonesIdKey = 'America/New_York',
                                    isActive = true, userRoleId = r.Id);
        
        User u3 = new User( Username = 'uvs3@rydertest.com',
                                    Alias = 'autclon', FirstName = 'Ryder3', LastName = 'Tester3', Email = 'uvs3@rydertest.com',
                                    EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                                    LocalesIdKey = 'en_US', ProfileId = p.Id, TimeZonesIdKey = 'America/New_York',
                                    isActive = true, userRoleId = r.Id);

        
        System.runAs (u) {
            
            
        Lead lead = createLead(RyderGlobalVariables.COUNTRIES_USA);
        Account account = new Account();

        // Start the test
        Test.startTest();

        // Set the Page Reference
        PageReference newAccountPage = Page.NewAccount;
        Test.setCurrentPage(newAccountPage);
                    
        // Set the model action
        ApexPages.currentPage().getParameters().put('leadId', lead.Id);
        ApexPages.currentPage().getParameters().put('fromLead', 'true');

        // Create a standard controller 
        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(account); 
        
        //create instance of pages controller
        newAccountContactController newAccountContactController = new newAccountContactController(controller);
        
        // Call the convert function and then check the assert
        PageReference pageRef = newAccountContactController.createNewAccount();
        Account acct = newAccountContactController.account;
        
        acct.Phone = '111-111-1111';
        update acct;
            
        List<AccountShareCustom__c> accsharecust = [SELECT AccountId__c, GroupId__c FROM AccountShareCustom__c where accountId__c =: acct.Id];
        system.debug('Account Share Custom : ' + accsharecust);
        List<AccountShare> accshare = [SELECT AccountId, UserOrGroupId, RowCause FROM AccountShare where AccountId =: acct.Id];            
        system.debug('Account Share : ' + accshare);            

        delete acct;            
            
        // Stop the test
        Test.stopTest();
      } 
    } 

}