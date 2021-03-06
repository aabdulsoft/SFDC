@isTest
private class ApproveLargeOppPageControllerTest {
  
    static List<string> lSalesProfiles = new List<string>(LABEL.Ryder_Sales_Profiles.split(','));
    static User accOwnerManager  = createUser(true, true); 
    static User accOwner  = createUser(true, false);   
    static date myDate = Date.Today();

    static testmethod void test_updateOpportunity()
    {
        system.debug('ALOPCT2');
        
        RSMCreateTestData.GetCustomSettingsRecord();       
        
        system.debug('ALOPCT3');
        
        Account acc1 = new Account();            
        acc1.name = 'Test Account1';                
        acc1.ShippingState = RyderGlobalVariables.TEST_STATE;                    
        acc1.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;    
        acc1.Ownerid = accOwner.id;                
        insert acc1;
        
        system.debug('ALOPCT4');            
        
        Contact c = New Contact (); 
        c.FirstName = 'TestFirst'; 
        c.LastName = 'TestLast'; 
        c.email = 'TestContact@test.com';
        c.accountId = acc1.Id;
        c.Contact_Source__c = 'Lead Conversion';
        c.Ownerid = accOwner.id;
        insert c;
        
        system.debug('ALOPCT5');
        
        Opportunity Opp = New Opportunity();
        Opp.Name = 'Test Opp';
        Opp.AccountId = Acc1.id;
        Opp.Original_Decision_Maker__c = c.Id;
        Opp.StageName = 'Overcome Concerns';
        Opp.CloseDate = myDate.addDays(-45);
        Opp.Num_of_vehicles__c = 15;
        Opp.Ownerid = accOwner.id;
        insert Opp;
        
        system.debug('ALOPCT6');        
         
        ApexPages.StandardController stdController = new ApexPages.StandardController(Opp);
    
        system.debug('ALOPCT7');    
        
        ApproveLargeOppPageController ALOPCT = new ApproveLargeOppPageController(stdController);
        ALOPCT.updateOpportunity();

        system.debug('ALOPCT8');        
    }
    
    //create user
    private static User createUser(Boolean isInsert, Boolean isManager) {
        system.debug('ALOPCT1');
        Profile p = [select p.id from Profile p where p.Name in : lSalesProfiles LIMIT 1];
        User u = new User();
        if(isManager)
        {
            //Creating the user
            u = new User( Username = 'testManager@rydertest.com',
                                    Alias = 'test1', FirstName = 'Ryder', LastName = 'Manager', Email = 'testManager@rydertest.com',
                                    EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocalesIdKey = 'en_US', 
                                    ProfileId = p.Id, TimeZonesIdKey = 'America/Los_Angeles', isActive = true);
        }
        else
        {
            //Creating the user
            u = new User( Username = 'testUser@rydertest.com',
                                    Alias = 'test3', FirstName = 'Ryder', LastName = 'User', Email = 'testUser@rydertest.com',
                                    EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocalesIdKey = 'en_US', ManagerId = accOwnerManager.id,
                                    ProfileId = p.Id, TimeZonesIdKey = 'America/Los_Angeles', isActive = true);            
        }
        if(isInsert){
            insert u;
        }
        return u;
    }
}