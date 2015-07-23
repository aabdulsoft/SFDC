@isTest
public class UpdAccLstActDtEvtTriggerHelperTest {

    static List<string> lSalesProfiles = new List<string>(LABEL.Ryder_Sales_Profiles.split(','));
    static User actUser  = createUser(true);
    static date myDate = Date.Today();
    static datetime myDateTime = System.Today();
    
    static testmethod void UnitTest() {

        RSMCreateTestData.GetCustomSettingsRecord();       
         
        Account acc1 = new Account();            
        acc1.name = 'Test Account1';                
        acc1.ShippingState = RyderGlobalVariables.TEST_STATE;                    
        acc1.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;                    
        insert acc1;
                    
        Account acc2 = new Account();            
        acc2.name = 'Test Account2';                
        acc2.ShippingState = RyderGlobalVariables.TEST_STATE;                    
        acc2.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;                    
        insert acc2;       
        
        Contact c = New Contact (); 
        c.FirstName = 'TestFirst'; 
        c.LastName = 'TestLast'; 
        c.email = 'TestContact@test.com';
        c.accountId = acc1.Id;
        c.Contact_Source__c = 'Lead Conversion';
        insert c;
        
        Opportunity Opp = New Opportunity();
        Opp.Name = 'Test Opp';
        Opp.AccountId = Acc1.id;
        Opp.Original_Decision_Maker__c = c.Id;
        Opp.StageName = 'Overcome Concerns';
        Opp.CloseDate = Date.Today();
        insert Opp;
        
        Id eventRecordTypeId = LABEL.Ryder_Event_Record_ID;
        Id taskRecordTypeId = LABEL.Ryder_Task_Record_ID;
                
        List<string> lActivityType = new List<string>(LABEL.Activity_Type.split(','));
            
        Event E1 = New Event();
        E1.OwnerId = actUser.Id;
        E1.Type = 'Cold Call Face to Face';            
        E1.Subject = 'Cold Call Face to Face';
        E1.ActivityDate = myDate.addDays(-10);
        E1.StartDateTime = myDateTime.addDays(-10);
        E1.EndDateTime = myDateTime.addDays(-10);
        E1.WhatId = Acc1.id;
        E1.RecordTypeId = eventRecordTypeId;
        E1.Description = 'Test Ryder Event1';
        insert E1;

        Task T1 = New Task();
        T1.OwnerId = actUser.Id;
        T1.Type = 'Other';
        T1.Subject = 'Other';
        T1.Status = 'Not Started';
        T1.ActivityDate = myDate.addDays(-9);
        T1.WhatId = Acc1.id;
        T1.RecordTypeId = taskRecordTypeId ;
        T1.Description = 'Task with type Face To Face';
        insert T1;

        Event E2 = New Event();
        E2.OwnerId = actUser.Id;
        E2.Type = 'Other';
        E2.Subject = 'Other';
        E2.ActivityDate = myDate.addDays(-8);
        E2.StartDateTime = myDateTime.addDays(-8);
        E2.EndDateTime = myDateTime.addDays(-8);
        E2.WhatId = Opp.id;
        E2.RecordTypeId = eventRecordTypeId;
        E2.Description = 'Test Ryder Event2';
        insert E2;
                                
        Task T2 = New Task();
        T2.OwnerId = actUser.id;
        //T2.Orignal_Task_Date__c = System.Today();
        T2.Type = 'Cold Call Face to Face';
        T2.Subject = 'Cold Call Face to Face';
        T2.Status = 'Not Started';
        T2.ActivityDate = myDate.addDays(-7);
        T2.WhatId = Opp.id;
        T2.RecordTypeId = taskRecordTypeId;
        T2.Description = 'Task with Type Cold Call Face to Face';
        insert T2;
        
        Event E3 = New Event();
        E3.OwnerId = actUser.Id;
        E3.Type = 'Face to Face';
        E3.Subject = 'Face to Face';
        E3.ActivityDate = myDate.addDays(-6);
        E3.StartDateTime = myDateTime.addDays(-6);
        E3.EndDateTime = myDateTime.addDays(-6);
        E3.WhatId = Acc1.id;
        E3.RecordTypeId = eventRecordTypeId;
        E3.Description = 'Test Ryder Event3';
        insert E3;
        
        Event E4 = New Event();
        E4.OwnerId = actUser.Id;
        E4.Type = 'Other';
        E4.Subject = 'Other';
        E4.ActivityDate = myDate.addDays(-5);
        E4.StartDateTime = myDateTime.addDays(-5);
        E4.EndDateTime = myDateTime.addDays(-5);
        E4.WhatId = Opp.id;
        E4.RecordTypeId = eventRecordTypeId;
        E4.Description = 'Test Ryder Event4';
        insert E4;
        
        Event E5 = New Event();
        E5.OwnerId = actUser.Id;
        E5.Type = 'Face to Face';
        E5.Subject = 'Face to Face';
        E5.ActivityDate = myDate.addDays(-4);
        E5.StartDateTime = myDateTime.addDays(-4);
        E5.EndDateTime = myDateTime.addDays(-4);
        E5.WhatId = Acc2.id;
        E5.RecordTypeId = eventRecordTypeId;
        E5.Description = 'Test Ryder Event5';
        insert E5;
        
        Event E6 = New Event();
        E6.OwnerId = actUser.Id;
        E6.Type = 'Other';
        E6.Subject = 'Other';
        E6.ActivityDate = myDate.addDays(-2);
        E6.StartDateTime = myDateTime.addDays(-2);
        E6.EndDateTime = myDateTime.addDays(-2);
        E6.WhatId = Opp.id;
        E6.RecordTypeId = eventRecordTypeId;
        E6.Description = 'Test Ryder Event6';
        insert E6;
                      
        Test.startTest();
                                   
        T1.Status = 'Completed';
        update T1;
                    
        T2.Status = 'Completed';
        update T2;
                    
        E6.ActivityDate = myDate.addDays(2);        
        E6.StartDateTime = myDateTime.addDays(2);
        E6.EndDateTime = myDateTime.addDays(2);
        update E6;
        

        E4.ActivityDate = myDate.addDays(2);        
        E4.StartDateTime = myDateTime.addDays(2);
        E4.EndDateTime = myDateTime.addDays(2);
        update E4;
        
        E3.ActivityDate = myDate.addDays(3);        
        E3.StartDateTime = myDateTime.addDays(3);
        E3.EndDateTime = myDateTime.addDays(3);
        update E3;           
        
        E2.ActivityDate = myDate.addDays(4);        
        E2.StartDateTime = myDateTime.addDays(4);
        E2.EndDateTime = myDateTime.addDays(4);
        update E2;           

        E1.ActivityDate = myDate.addDays(5);        
        E1.StartDateTime = myDateTime.addDays(5);
        E1.EndDateTime = myDateTime.addDays(5);
        update E1;           
        
        Test.stopTest();
    }
    
    //create user
    private static User createUser(Boolean isInsert) {
        Profile p = [select p.id from Profile p where p.Name in : lSalesProfiles LIMIT 1];

        //Creating the user
        User u = new User( Username = 'test@rydertest.com',
                                    Alias = 'test', FirstName = 'Ryder', LastName = 'Tester', Email = 'test@rydertest.com',
                                    EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                                    LocalesIdKey = 'en_US', ProfileId = p.Id, TimeZonesIdKey = 'America/Los_Angeles',
                                    isActive = true);
        if(isInsert){
            insert u;
        }
        return u;
    }
}