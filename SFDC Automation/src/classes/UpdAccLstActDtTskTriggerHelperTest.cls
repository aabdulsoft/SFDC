@isTest
public class UpdAccLstActDtTskTriggerHelperTest {

    static List<string> lSalesProfiles = new List<string>(LABEL.Ryder_Sales_Profiles.split(','));
    static User actUser = createUser(true);
    static date myDate = Date.Today();
    static datetime myDateTime = System.Today();
    
    static testmethod void UnitTest() {
    
        system.debug('Saad1.0 actUser = ' + actUser);
        system.runAs(actUser) { 
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
            
            Task T1 = New Task();
            T1.OwnerId = actUser.Id;
            T1.Type = 'Other';
            T1.Subject = 'Other';
            T1.Status = 'Not Started';
            T1.ActivityDate = myDate.addDays(-10);
            T1.WhatId = Acc1.id;
            T1.RecordTypeId = taskRecordTypeId ;
            T1.Description = 'Task with type Other';
            insert T1;

            Event E1 = New Event();
            E1.OwnerId = actUser.Id;
            E1.Type = 'Cold Call Face to Face';
            E1.Subject = 'Cold Call Face to Face';
            E1.ActivityDate = myDate.addDays(-9);
            E1.StartDateTime = myDateTime.addDays(-9);
            E1.EndDateTime = myDateTime.addDays(-9);
            E1.WhatId = Acc1.id;
            E1.RecordTypeId = eventRecordTypeId;
            E1.Description = 'Test Ryder Event1';
            insert E1;
                        
            Task T2 = New Task();
            T2.OwnerId = actUser.id;
            T2.Type = 'Cold Call Face to Face';
            T2.Subject = 'Cold Call Face to Face';
            T2.Status = 'Not Started';
            T2.ActivityDate = myDate.addDays(-8);
            T2.WhatId = Opp.id;
            T2.RecordTypeId = taskRecordTypeId;
            T2.Description = 'Task with Type Cold Call Face to Face';
            insert T2;
            
            Event E2 = New Event();
            E2.OwnerId = actUser.Id;
            E2.Type = 'Other';
            E2.Subject = 'Other';
            E2.ActivityDate = myDate.addDays(-7);
            E2.StartDateTime = myDateTime.addDays(-7);
            E2.EndDateTime = myDateTime.addDays(-7);
            E2.WhatId = Opp.id;
            E2.RecordTypeId = eventRecordTypeId;
            E2.Description = 'Test Ryder Event2';
            insert E2;
            
            Task T3 = New Task();
            T3.OwnerId = actUser.Id;
            T3.Type = 'Other';
            T3.Subject = 'Other';
            T3.Status = 'Not Started';
            T3.ActivityDate = myDate.addDays(-6);
            T3.WhatId = Acc1.id;
            T3.RecordTypeId = taskRecordTypeId ;
            T3.Description = 'Task with type Other';
            insert T3;

            Task T4 = New Task();
            T4.OwnerId = actUser.Id;
            T4.Type = 'Other';
            T4.Subject = 'Other';
            T4.Status = 'Not Started';
            T4.ActivityDate = myDate.addDays(-4);
            T4.WhatId = Opp.id;
            T4.RecordTypeId = taskRecordTypeId ;
            T4.Description = 'Other';
            insert T4;

            Task T5 = New Task();
            T5.OwnerId = actUser.Id;
            T5.Type = 'Other';
            T5.Subject = 'Other';
            T5.Status = 'Not Started';
            T5.ActivityDate = myDate.addDays(-2);
            T5.WhatId = Acc2.id;
            T5.RecordTypeId = taskRecordTypeId ;
            T5.Description = 'Task with type Other';
            insert T5;
            
            Task T6 = New Task();
            T6.OwnerId = actUser.Id;
            T6.Type = 'Other';
            T6.Subject = 'Other';
            T6.Status = 'Not Started';
            T6.ActivityDate = myDate.addDays(-1);
            T6.WhatId = Acc2.id;
            T6.RecordTypeId = taskRecordTypeId ;
            T6.Description = 'Task with type Other';
            insert T6;
            
            Test.startTest();
                                       
            T1.Status = 'Completed';
            update T1;
                        
            T2.Status = 'Completed';
            update T2;
                        
            T3.Status = 'Completed';
            update T3;
            
            T4.Status = 'Completed';
            update T4;

            T6.Status = 'Completed';
            update T6;                                                       

            T6.Status = 'In Progress';  
            T6.ActivityDate = myDate.addDays(2);
            update T6;    
            
            T4.Status = 'In Progress';  
            T4.ActivityDate = myDate.addDays(2);
            update T4;    
                                       
            T3.Status = 'In Progress';  
            T3.ActivityDate = myDate.addDays(3);
            update T3;
            
            T2.Status = 'In Progress';  
            T2.ActivityDate = myDate.addDays(5);
            update T2;

            T1.Status = 'In Progress';  
            T1.ActivityDate = myDate.addDays(7);
            update T1;

            Test.stopTest();
        }
    } 
    //create uvs user
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