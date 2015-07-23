/**
 * This class contains unit tests for validating the behavior of Apex classes and validating the DedupUtil Class.
 *
 */
@isTest
private with sharing class Test_DedupUtil {

    //Creating Account One
    private static Account createParentAccount()
    {
        Account pAccount = new Account();
        pAccount.Name = 'Parent Company Ltd.';
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
    
    //Creating Child Account for Account One
    private static Account createChildAccountOne(Id acctId)
    {
        Account cAccount1 = new Account();
        cAccount1.Name = 'Child Company One Ltd.';
        cAccount1.ShippingStreet = 'Address Line 2';
        cAccount1.ShippingCity = 'Test City 2';
        cAccount1.ShippingState = 'FL';
        cAccount1.ShippingPostalCode = '54321';
        cAccount1.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;
        cAccount1.CustomerTypeID__c = RyderGlobalVariables.CustomerType.FMS.name();
        cAccount1.billingstate = 'FL';
        cAccount1.ParentId = acctId;
        
        insert cAccount1;
        
        return cAccount1;
    }
    
    //Creating Child Account for Account Two
    private static Account createChildAccountTwo(Id acctId)
    {
        Account cAccount2 = new Account();
        cAccount2.Name = 'Child Company Two Ltd.';
        cAccount2.ShippingStreet = 'Address Line 3';
        cAccount2.ShippingCity = 'Test City 3';
        cAccount2.ShippingState = 'FL';
        cAccount2.ShippingPostalCode = '32451';
        cAccount2.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;
        cAccount2.CustomerTypeID__c = RyderGlobalVariables.CustomerType.FMS.name();
        cAccount2.billingstate = 'FL';
        cAccount2.ParentId = acctId;
        
        insert cAccount2;
        
        return cAccount2;
    }
    
    //Creating a Rental Account 
    private static Account createRentalAccount()
    {
        Account rAccount = new Account();
        rAccount.Name = 'Rental Company Ltd.';
        rAccount.ShippingStreet = 'Address Line 4';
        rAccount.ShippingCity = 'Test City 4';
        rAccount.ShippingState = 'FL';
        rAccount.ShippingPostalCode = '43251';
        rAccount.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;
        rAccount.CustomerTypeID__c = 'FMS Rental'; //RyderGlobalVariables.CustomerType.FMSRENTAL.name();
        rAccount.billingstate = 'FL';
                
        insert rAccount;
        
        return rAccount;
    }
    
    //Creating Contact One for Parent Account
    private static Contact createContact(Id acctId, String email)
    {
        Contact contact1 = new Contact();
        contact1.FirstName = 'Contact One First Name';
        contact1.LastName = 'Contact One Last Name';
        contact1.Phone = null;
        contact1.Email = email;//'abc@xyz.com';
        contact1.AccountId = acctId;
        insert contact1;
        
        return contact1;
    }
    //swetha
    //creating contact two for child account
    private static Contact createContacttwo(Id acctId,String email)
    {
        Contact contact2 =new Contact();
        contact2.FirstName = 'Contact two First Name';
        contact2.LastName = 'Contact two Last Name';
        contact2.Phone = null;
        contact2.Email = email;//'abc@xyz.com';
        contact2.AccountId = acctId;
        insert contact2;
        
        return contact2;
    }
    
    
    //Create contact at HQ Level 
    static testMethod void test_NewContactsAtHQ()
    {
        Account pAccount = createParentAccount();
        Contact cnt1 = createContact(pAccount.Id, 'abc1@xyz.com');
        Contact cnt2 = createContact(pAccount.Id, 'abc2@xyz.com');
    }
    
    //new contact added at hq and the dup is at child level in same herarchy
    static testMethod void test_NewContactsAtHQDupChild()
    {
        Account pAccount = createParentAccount();
        Account cAccount = createChildAccountOne(pAccount.Id);
        Contact cnt1 = createContact(cAccount.Id,'abc3@xyz.com');
        cnt1.Pre_Sales_Contact_Role__c='Business User;Decision Maker';
        update cnt1;
        Contact cnt2 = createContact(pAccount.Id,'abc4@xyz.com');
        cnt1.Pre_Sales_Contact_Role__c='Other';
        update cnt1;
        Contact cnt3 = createContact(pAccount.Id,'abc5@xyz.com');
    }
    
    //Create contact at child level and dup is at HQ 
    static testMethod void test_NewContactsAtChildDupHQ()
    {
        Account pAccount = createParentAccount();
        Account cAccount = createChildAccountOne(pAccount.Id);
        Contact cnt1 = createContact(pAccount.Id,'abc6@xyz.com');
        cnt1.Pre_Sales_Contact_Role__c='Business User,Decision Maker';
        update cnt1;
        Contact cnt2 = createContact(cAccount.Id,'abc7@xyz.com');
    }
    //New contact is being added at child level - same child
    static testMethod void test_NewContactsInSameChild()
    {
        Account pAccount = createParentAccount();
        Account cAccount = createChildAccountOne(pAccount.Id);
        Contact cnt1 = createContact(cAccount.Id,'abc8@xyz.com');
        Contact cnt2 = createContact(cAccount.Id,'abc9@xyz.com');
    }
    //New contact is being added to a different child account in the same hierachy
    static testMethod void test_NewContactsInDiffChild()
    {
        Account pAccount = createParentAccount();
        Account cAccountOne = createChildAccountOne(pAccount.Id);
        Account cAccountTwo = createChildAccountTwo(pAccount.Id);
        Contact cnt1 = createContact(cAccountOne.Id,'abc10@xyz.com');
        Contact cnt2 = createContact(cAccountTwo.Id,'abc11@xyz.com');
    }
    //New contact is being added to a child account in the different hierachy
    static testMethod void test_NewContactsInDiffHierarchy()
    {
        Account pAccountOne = createParentAccount();
        Account pAccountTwo = createParentAccount();
        Account cAccountOne = createChildAccountOne(pAccountOne.Id);
        Account cAccountTwo = createChildAccountTwo(pAccountTwo.Id);
        Contact cnt1 = createContact(cAccountOne.Id,'abc12@xyz.com');
        Contact cnt2 = createContact(cAccountTwo.Id,'abc13@xyz.com');
    }
    //swetha
    //Duplicate contact is being added
    
    static testMethod void test_createAsDuplicate(){
        Account pAccountOne=createParentAccount();
        List<Contact> contList=new List<Contact>();
        try
        {
            Contact contact1 =new Contact();
            contact1.FirstName = 'Contact two First Name';
            contact1.LastName = 'Contact two Last Name';
            contact1.Phone = null;
            contact1.Email = 'test123@xyz.com';
            contact1.AccountId = pAccountOne.Id;
            insert contact1;
            contact1.Is_Duplicate__c = false;
            update contact1;
            
            Contact contact2 =new Contact();
            contact2.FirstName = 'Contact two First Name';
            contact2.LastName = 'Contact two Last Name';
            contact2.Phone = null;
            contact2.Email = 'test123@xyz.com';
            contact2.AccountId = pAccountOne.Id;
            insert contact2;
            contList.add(contact2);
            DedupUtil.validateForDupOnInsert(contList);
            //insert contList;
        }
        catch (Exception e )
        {
        
        }
        
    }
    
    //New contact is being added to a child account in the different hierachy
    static testMethod void test_NewContactsinCaseofFMSRental()
    {
        Account rAccount = createRentalAccount();
        Account pAccount = createParentAccount();
        Contact cnt1 = createContact(rAccount.Id,'abc14@xyz.com');
        Contact cnt2 = createContact(pAccount.Id,'abc15@xyz.com');
    }
    
    //update email address on a contact
    static testMethod void test_UpdateContactEmail()
    {       
        Account pAccount = createParentAccount();
        Contact cnt1 = createContact(pAccount.Id,'abc16@xyz.com');
        cnt1.Email='abc@ryder.test.com';
        update cnt1;
        Contact cnt2 = createContact(pAccount.Id,'abc17@xyz.com');
        try
        {
        cnt2.Email='abc@ryder.test.com';
        update cnt2;
        }
        catch (Exception e )
        {
        }
        
    }
        
    
    //update is duplicate flag on a contact
    static testMethod void test_UpdateIsDuplicate()
    {       
        Account pAccount = createParentAccount();
        Contact cnt1 = createContact(pAccount.Id,'abc18@xyz.com');
        cnt1.Is_Duplicate__c=true;
        update cnt1;
    }
    
    // misc calls
     
    static testmethod void miscCalls()
    {
        Account pAccount = createParentAccount();
        Contact cnt1 = createContact(pAccount.Id,'abc19@xyz.com');
        Deduputil.getContactFromSameAccount(cnt1.Email, cnt1.AccountId);
        Deduputil.getDuplicateContacts(cnt1.Email);
        Deduputil.getFMSDuplicateContacts(cnt1.Email);
        
    }
    
    /*
    static testMethod void test_NewContacts()
    {
        Map<string,AccountContactRole> mapcontactRoles= new Map<string,AccountContactRole>();   
        List<Id>acctInAcr= new List<Id>();
        List<Id>conInAcr= new List<Id>();
        
        Account pAccount = createParentAccount();
        Account cAccountOne = createChildAccountOne(pAccount.Id);
        Account cAccountTwo = createChildAccountTwo(pAccount.Id);
        Account rAccount = createRentalAccount();
                
        Contact cnt1 = createContact(pAccount.Id);
        Contact cnt2 = createContact(pAccount.Id);
        Contact cnt3 = createContact(cAccountOne.Id);
        Contact cnt4 = createContact(cAccountOne.Id);
        Contact cnt5 = createContact(cAccountTwo.Id);
        Contact cnt6 = createContact(rAccount.Id);
                
        // Start the test
        Test.startTest();
                    
        RyderGlobalVariables.IS_TEST = true;
        RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
        //Same Hierarchy
        if (cnt1.HQ_Account_Id_18__c == cnt2.HQ_Account_Id_18__c)
        {
            //New contact at HQ Level
            If(cnt1.AccountId == cnt2.HQ_Account_Id_18__c)
            {
                cnt2.Primary_Contact_Id__c = cnt1.Id;
                cnt2.Is_Duplicate__c = true;
                cnt2.Note__c = 'A contact with the same email address already exists in the same account.';
                if(cnt2.Contact_Source__c == RyderGlobalVariables.ContactSource.Manual.name()) cnt2.Can_Be_Removed__c=true;
                // if duplicate is at a child level move child to parent account and make account contact role entries.
                if(cnt2.AccountId!=cnt2.HQ_Account_Id_18__c)
                {   
                    AccountContactRole acr = new AccountContactRole();
                    acr.AccountId = cnt2.AccountId;
                    acr.ContactId = cnt2.Id;
                    acr.Role = cnt2.Pre_Sales_Contact_Role__c;
                      
                    ContactUtil.MoveContactToParent(cnt2);
                    cnt2.Added_As_Key_Contact__c = false;
                    
                    Database.update(cnt2);
                    acctInAcr.add(acr.accountid);
                    conInAcr.add(acr.contactid);
                        
                    if (!mapcontactRoles.containsKey(acr.accountid+'_'+acr.contactid +'_'+acr.role))mapcontactRoles.put(acr.accountid+'_'+acr.contactid+'_'+acr.role,acr);
                }
            }   
            //New contact is added at child and dup is at HQ Level
            else if (cnt1.AccountId == cnt3.HQ_Account_Id_18__c)
            {
                cnt3.Primary_Contact_Id__c = cnt1.Id;
                cnt3.Is_Duplicate__c = true;
                cnt3.Note__c = 'A contact with the same email address already exists in the same account at the HQ level. A new account contact role is created in this account';
                if(cnt3.Contact_Source__c == RyderGlobalVariables.ContactSource.Manual.name()) cnt3.Can_Be_Removed__c=true;
                
                AccountContactRole acr = new AccountContactRole();
                acr.AccountId = cnt1.AccountId;
                acr.ContactId = cnt3.Id;
              
                acr.Role = cnt3.Pre_Sales_Contact_Role__c;
                acctInAcr.add(acr.accountid);
                conInAcr.add(acr.contactid);
                if (!mapcontactRoles.containsKey(acr.accountid+'_'+acr.contactid+'_'+acr.role))mapcontactRoles.put(acr.accountid+'_'+acr.contactid+'_'+acr.role,acr);
            }
            //New contact is being added at child level- same child
            else if (cnt3.AccountId == cnt4.AccountId)
            {
                cnt4.Primary_Contact_Id__c = cnt3.Id;
                cnt4.Is_Duplicate__c = true;
                cnt4.Note__c = 'A contact with the same email address already exists in the same child account.';
                if(cnt4.Contact_Source__c == RyderGlobalVariables.ContactSource.Manual.name()) cnt4.Can_Be_Removed__c=true;
            } 
            //New contact is being added to a different child account in the same hierachy
            else if(cnt3.AccountId != cnt5.AccountId)
            {
                cnt5.Primary_Contact_Id__c = cnt3.Id;
                cnt5.Is_Duplicate__c = true;
                cnt5.Note__c = 'A contact with the same email address already exists in the same HQ at a different child account.The primary contact is moved to the HQ and corresponding Account Contact Role entries are created.';
                if(cnt5.Contact_Source__c == RyderGlobalVariables.ContactSource.Manual.name()) cnt5.Can_Be_Removed__c=true;
                
                AccountContactRole acrDup = new AccountContactRole();
                acrDup.AccountId = cnt5.AccountId;
                acrDup.ContactId = cnt5.Id;
                acrDup.Role = cnt5.Pre_Sales_Contact_Role__c;
                acctInAcr.add(acrDup.accountid);
                conInAcr.add(acrDup.contactid);
                if (!mapcontactRoles.containsKey(acrDup.accountid+'_'+acrDup.contactid +'_'+acrDup.role))mapcontactRoles.put(acrDup.accountid+'_'+acrDup.contactid+'_'+acrDup.role,acrDup);
               
                AccountContactRole acrNewCon = new AccountContactRole();
                acrNewCon.AccountId = cnt3.AccountId;
                acrNewCon.ContactId = cnt5.Id;
                acrNewCon.Role = cnt5.Pre_Sales_Contact_Role__c;
                acctInAcr.add(acrNewCon.accountid);
                conInAcr.add(acrNewCon.contactid);
                if (!mapcontactRoles.containsKey(acrNewCon.accountid+'_'+acrNewCon.contactid+ '_'+acrNewCon.role))mapcontactRoles.put(acrNewCon.accountid+'_'+acrNewCon.contactid+'_'+acrNewCon.role,acrNewCon);
                
                //ContactUtil.MoveContactToParent(dupCon);
                cnt5.Added_As_Key_Contact__c=false;
                Database.update(cnt5);
            }
        }  
        // added to a different account
        else
        {
            string customerType; 
            if(cnt3.Account.Parent.CustomerTypeID__c!=null) customerType=cnt3.Account.Parent.CustomerTypeID__c;
            else customerType=cnt3.Account.CustomerTypeID__c;
            // if the existing contact is for a FMS Rental then the new contact is primary else the existing contact
            // continues to be primary.
            if(customerType=='FMS Rental')
            {
                cnt3.Is_Duplicate__c=true;
                //Primary id will be set in update trigger as the id of the new contact is not avaiable in the before insert trigger
                Database.update(cnt3);
            }
            else
            {
                cnt6.Is_Duplicate__c=true;
                // set the id of the existing contact as primary id on the new contact
                cnt6.Primary_Contact_Id__c=cnt3.Id;
            }
        }
        
        List<AccountContactRole>existingContactRoles= [Select Id, contactId, AccountId, role from AccountContactRole where contactid in :conInAcr and accountid= :acctInAcr];
        for (AccountContactRole acr :existingContactRoles)
        {
        if (mapcontactRoles.containskey(acr.accountid+'_'+acr.contactid + '_'+acr.role))
        mapcontactRoles.remove(acr.accountid+'_'+acr.contactid+'_'+acr.role);
        }
        system.debug('accountContactRoles after ids ' + mapcontactRoles.values());
        if(mapcontactRoles.values().size()>0)Database.upsert(mapcontactRoles.values());
        
        Test.stopTest();
    }
    */
}