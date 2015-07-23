/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 
 
 @isTest(SeeAllData=true)
private class test_FirstCallResolutionTrigger {

    static testMethod void sendEmailForDuplicateCase() 
    {
        Case newCase = new Case();
        Account acct = TestUtil.createAccount('Ryder FMS Parent Account', 'Customer');
        insert acct;
        Contact cont = TestUtil.createContact(acct.Id);
        insert cont;
        newCase.AccountId =acct.Id;
        newCase.ContactId =cont.Id;
        newCase.RecordTypeId=[Select Id from RecordType where name=: 'Case for Known Account' and SobjectType =: 'Case'].Id;
      //  newCase.AccountId = '0016000000YgUyv';
       // newCase.ContactId ='00360000017VQnK';
        //newCase.CreatedById = '005W0000000dpfnIAA';
        //newCase.LastModifiedById = '005W0000000dpfnIAA';
        //newCase.OwnerId='005W0000000dpfnIAA';
       // newCase.RecordTypeId ='01260000000UDIRAA4';
        //newCase.Account.Name = 'WENNER BREAD PRODUCTS, INC.';
        newCase.Major_Category__c = 'A/P 1099';
        newCase.Subcategory__c = '1099 Correction';
        insert(newCase);
    }
}
*/
@isTest(SeeAllData=true)
private class test_FirstCallResolutionTrigger {

    static testMethod void sendEmailForDuplicateCase() 
    {
        Account acnt = createAccount();
        Case newCase = new Case();
        Contact cont= createContact(acnt.Id);
        newCase.RecordTypeId=[Select Id from RecordType where name=: 'Case for Known Account' and SobjectType =: 'Case'].Id;
        newCase.AccountId = acnt.Id;
        newCase.ContactId = cont.Id;
        newCase.OwnerId = Userinfo.getUserId();
        newCase.Major_Category__c = 'A/P 1099';
        newCase.Subcategory__c = '1099 Correction';
        insert(newCase);
        for(integer i=0;i< 3; i++)
        {
            CreateDuplicateCases(acnt.Id,cont.Id);
        }
    }
    private static void CreateDuplicateCases(Id acctId, Id contId)
    {
        Case newCase2 = new Case();
        newCase2.AccountId = acctId;
        newCase2.ContactId = contId;
        newCase2.OwnerId = Userinfo.getUserId();
        newCase2.Major_Category__c = 'A/P 1099';
        newCase2.Subcategory__c = '1099 Correction';
        insert(newCase2); 
    }
    private static Account createAccount()
    {
        Account pAccount = new Account();
        pAccount.Name = 'Company for Duplicate case Testing.';
        pAccount.ShippingStreet = 'Address Line 1';
        pAccount.ShippingCity = 'Test City 1';
        pAccount.ShippingState = 'FL';
        pAccount.ShippingPostalCode = '12345';
        pAccount.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;
        pAccount.CustomerTypeID__c = RyderGlobalVariables.CustomerType.FMS.name();
        pAccount.billingstate = 'IL';
        insert pAccount;
        
        return pAccount;
    }
    private static Contact createContact(Id acctId)
    {
        Contact contact1 = new Contact();
        contact1.FirstName = 'Contact One First Name';
        contact1.LastName = 'Contact One Last Name';
        contact1.Phone = null;
        contact1.Email = 'DupCase@xyz.com';
        contact1.AccountId = acctId;
        insert contact1;
        
        return contact1;
    }
}