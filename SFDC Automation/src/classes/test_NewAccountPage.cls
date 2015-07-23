/**
 * This class contains unit tests for validating the behavior of Apex classes and validating the lead convert page.
 *
 */
@isTest
private class test_NewAccountPage 
{
    // Create lead to convert
    private static Lead createLead(String country)
    {
        Lead lead = new Lead();
        lead.FirstName = RyderGlobalVariables.TEST_FIRST_NAME;
        lead.LastName = RyderGlobalVariables.TEST_LAST_NAME;
        lead.Company = RyderGlobalVariables.TEST_PRIMARY_NAME;
        lead.Status = RyderGlobalVariables.TEST_STATUS;
        lead.LeadSource = RyderGlobalVariables.TEST_SOURCE;
        lead.Street = RyderGlobalVariables.TEST_ADDRESS_LINE;
        lead.City = RyderGlobalVariables.TEST_CITY;
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
        Account account = new Account();
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

        account.CustomerTypeID__c = RyderGlobalVariables.CustomerType.FMS.name();
        account.billingstate = 'IL';
        account.RyderProbabilityMatch__c = RyderGlobalVariables.CUT_OFF_ACCURACY_PROBABILITY +1;
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
        contact.Email = 'abc@abc.abc';
        contact.AccountId = acctId;
        insert contact;
        
        return contact;
    }

    // Basic test checks if the lead is converted with creation of USA account and contact 
    static testMethod void test_NewAccountPageFromLeadUSA() 
    {
        Lead lead = createLead(RyderGlobalVariables.COUNTRIES_USA);
        Account account = createAccount(RyderGlobalVariables.COUNTRIES_USA);
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
        NewAccountController newAccountController = new NewAccountController(controller);

        // Lookup values
        List<SelectOption> selectCountries = newAccountController.getItemsCountries();
        List<DBAccount> dbAccounts = newAccountController.getDBAccountToDisplay();
        Account accountRecordOwner = newAccountController.getRecordOwner();

        PageReference pageRefSearch = newAccountController.doSearch();

        System.debug('Account - '+accountRecordOwner);
        
        // Call the cancel function 
        PageReference pageRefCancel = newAccountController.Cancel();
        
        newAccountController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.assignAccount();
        newAccountController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.assignAccount();

        newAccountController.oldAccountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.accountSelected = '098765';
        newAccountController.assignAccount();

        newAccountController.oldAccountSelected = '';
        newAccountController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.assignAccount();
        
        newAccountController.assignContact();
        SFDCContact afdcContact = newAccountController.addSFDCNewContact();

        // Call the convert function and then check the assert
        
        PageReference pageRef = newAccountController.createNewAccount();
        
        Lead leadToCheck = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id =: lead.Id];
        System.debug('leadToCheck - ' + leadToCheck);
        System.assert(leadToCheck.ConvertedAccountId != null);
        System.assert(leadToCheck.ConvertedContactId != null);
        
        //throw some exception
        //newAccountController.lead = null;
        //newAccountController.createNewAccount();
        // Stop the test
        Test.stopTest();
    }

    // Basic test checks if the lead is converted with creation of Canada account and contact 
    static testMethod void test_NewAccountPageFromLeadCanada() 
    {
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
        NewAccountController newAccountController = new NewAccountController(controller);

        // Lookup values
        List<SelectOption> selectCountries = newAccountController.getItemsCountries();
        List<DBAccount> dbAccounts = newAccountController.getDBAccountToDisplay();
        Account accountRecordOwner = newAccountController.getRecordOwner();

        PageReference pageRefSearch = newAccountController.doSearch();

        System.debug('Account - '+accountRecordOwner);
        
        // Call the cancel function 
        PageReference pageRefCancel = newAccountController.Cancel();
        
        newAccountController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.assignAccount();
        newAccountController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.assignAccount();

        newAccountController.oldAccountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.accountSelected = '098765';
        newAccountController.assignAccount();
        
        newAccountController.oldAccountSelected = '';
        newAccountController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.assignAccount();
        
        newAccountController.assignContact();
        SFDCContact afdcContact = newAccountController.addSFDCNewContact();

        // Call the convert function and then check the assert
        PageReference pageRef = newAccountController.createNewAccount();
        
        Lead leadToCheck = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id =: lead.Id];
        System.debug('leadToCheck - ' + leadToCheck);
        System.assert(leadToCheck.ConvertedAccountId != null);
        System.assert(leadToCheck.ConvertedContactId != null);
        // Stop the test
        Test.stopTest();
    }

    // Basic test checks if the lead is converted with creation of Canada account and contact 
    static testMethod void test_NewAccountPageFromNewAccountCanada() 
    {
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
        NewAccountController newAccountController = new NewAccountController(controller);

        newAccountController.account = account;
        newAccountController.contact = cntct;

        // Lookup values
        List<SelectOption> selectCountries = newAccountController.getItemsCountries();
        List<DBAccount> dbAccounts = newAccountController.getDBAccountToDisplay();
        Account accountRecordOwner = newAccountController.getRecordOwner();

        PageReference pageRefSearch = newAccountController.doSearch();

        System.debug('Account - '+accountRecordOwner);
        
        // Call the cancel function 
        PageReference pageRefCancel = newAccountController.Cancel();
        
        newAccountController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.assignAccount();
        newAccountController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.assignAccount();
        newAccountController.oldAccountSelected = '';
        newAccountController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.assignAccount();
        
        newAccountController.assignContact();
        SFDCContact afdcContact = newAccountController.addSFDCNewContact();

        // Call the convert function and then check the assert
        PageReference pageRef = newAccountController.createNewAccount();
        System.assert(pageRef != null);
        // Stop the test
        Test.stopTest();
    }

    // Basic test checks if the lead is converted with creation of Canada account and contact 
    static testMethod void test_NewAccountPageFromNewAccountUSA() 
    {
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
        NewAccountController newAccountController = new NewAccountController(controller);

        newAccountController.account = account;
        newAccountController.contact = cntct;

        // Lookup values
        List<SelectOption> selectCountries = newAccountController.getItemsCountries();
        List<DBAccount> dbAccounts = newAccountController.getDBAccountToDisplay();
        Account accountRecordOwner = newAccountController.getRecordOwner();

        PageReference pageRefSearch = newAccountController.doSearch();

        System.debug('Account - '+accountRecordOwner);
        
        // Call the cancel function 
        PageReference pageRefCancel = newAccountController.Cancel();
        
        newAccountController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.assignAccount();
        newAccountController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.assignAccount();
        newAccountController.oldAccountSelected = '';
        newAccountController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.assignAccount();
        
        newAccountController.assignContact();
        SFDCContact afdcContact = newAccountController.addSFDCNewContact();

        // Call the convert function and then check the assert
        PageReference pageRef = newAccountController.createNewAccount();
        System.assert(pageRef != null);
        // Stop the test
        Test.stopTest();
    }
    
 //AAK //////////////////////
 
     // Create Account to attach to existing lead convert
    private static Account createRentalAccount(String country)
    {
        Account account = new Account();
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
        NewAccountController newAccountController = new NewAccountController(controller);

        newAccountController.account = account;
        newAccountController.contact = cntct;

        // Lookup values
        List<SelectOption> selectCountries = newAccountController.getItemsCountries();
        List<DBAccount> dbAccounts = newAccountController.getDBAccountToDisplay();
        Account accountRecordOwner = newAccountController.getRecordOwner();

        PageReference pageRefSearch = newAccountController.doSearch();

        System.debug('Account - '+accountRecordOwner);
        
        // Call the cancel function 
        PageReference pageRefCancel = newAccountController.Cancel();
        
        newAccountController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.assignAccount();
        newAccountController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.assignAccount();
        newAccountController.oldAccountSelected = '';
        newAccountController.accountSelected = RyderGlobalVariables.TEST_DUNS_NUMBER;
        newAccountController.assignAccount();
        
        newAccountController.assignContact();
        SFDCContact afdcContact = newAccountController.addSFDCNewContact();

        // Call the convert function and then check the assert
        PageReference pageRef = newAccountController.createNewAccount();
        System.assert(pageRef != null);
        // Stop the test
        Test.stopTest();
    }    
}