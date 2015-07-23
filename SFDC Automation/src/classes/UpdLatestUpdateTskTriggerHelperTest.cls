@isTest (SeeAllData=true)
public class UpdLatestUpdateTskTriggerHelperTest{

    static List<string> lProfiles = new List<string>(LABEL.LatestUpdateProfiles.split(','));
    static User actAccOwner = createUser(true, 'BDM', 'test1@rydertest.com', 'test1');
    static User actOppOwner = createUser(true, 'CDM', 'test2@rydertest.com', 'test2');    
    static User actNCAUser = createUser(true, 'NCA', 'test3@rydertest.com', 'test3'); 
    static User actSACUser = createUser(true, 'SAC', 'test4@rydertest.com', 'test4');   
    static date myDate = Date.Today();
    static datetime myDateTime = System.Today();
    
    static testmethod void UnitTest() {

        RSMCreateTestData.GetCustomSettingsRecord();       
         
        Account acc = new Account();            
        acc.name = 'Test Account';                
        acc.ShippingState = RyderGlobalVariables.TEST_STATE;                    
        acc.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;
        acc.OwnerId = actAccOwner.id;   
        insert acc;
                    
        Contact c = New Contact (); 
        c.FirstName = 'TestFirst'; 
        c.LastName = 'TestLast'; 
        c.email = 'TestContact@test.com';
        c.accountId = acc.Id;
        c.Contact_Source__c = 'Lead Conversion';
        insert c;
        
        Opportunity Opp = New Opportunity();
        Opp.Name = 'Test Opp';
        Opp.AccountId = Acc.id;
        Opp.Original_Decision_Maker__c = c.Id;
        Opp.StageName = 'Overcome Concerns';
        Opp.CloseDate = Date.Today();
        Opp.OwnerId = actOppOwner.id;        
        insert Opp;

        Test.startTest();
        
        Task T1 = New Task();
        T1.OwnerId = actAccOwner.Id;
        T1.Type = 'Account/Opportunity Update';
        T1.Subject = 'Account/Opportunity Update';
        T1.Status = 'Completed';
        T1.ActivityDate = myDate.addDays(-3);
        T1.WhatId = Acc.id;
        T1.Description = 'Test Account/Opportunity Update Type 1';
        insert T1;

        Task T2 = New Task();
        T2.OwnerId = actOppOwner.id;
        T2.Type = 'Account/Opportunity Update';
        T2.Subject = 'Account/Opportunity Update';
        T2.Status = 'Completed';
        T2.ActivityDate = myDate.addDays(-2);
        T2.WhatId = Opp.id;
        T2.Description = 'Test Account/Opportunity Update Type 2';
        insert T2;
        
        Task T3 = New Task();
        T3.OwnerId = actNCAUser.id;
        T3.Type = 'Account/Opportunity Update';
        T3.Subject = 'Account/Opportunity Update';
        T3.Status = 'Completed';
        T3.ActivityDate = myDate.addDays(-1);
        T3.WhatId = Acc.id;
        T3.Description = 'Test Account/Opportunity Update Type 3';
        insert T3;        
        
        Task T4 = New Task();
        T4.OwnerId = actSACUser.id;
        T4.Type = 'Account/Opportunity Update';
        T4.Subject = 'Account/Opportunity Update';
        T4.Status = 'Completed';
        T4.ActivityDate = myDate;
        T4.WhatId = Opp.id;
        T4.Description = 'Test Account/Opportunity Update Type 4';
        insert T4;          
        
        Test.stopTest();
    }
    
    //create user
    private static User createUser(Boolean isInsert, string strProfileName, string strUserName, string strAlias) {
        Profile p = [select p.id from Profile p where p.Name =: strProfileName LIMIT 1];

        //Creating the user
        User u = new User(Username = strUserName, Alias = strAlias, FirstName = 'Ryder', LastName = 'Tester', 
                        Email = strUserName, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                        LocalesIdKey = 'en_US', ProfileId = p.Id, TimeZonesIdKey = 'America/Los_Angeles',
                        isActive = true);
        if(isInsert){
            insert u;
        }
        return u;
    }
}