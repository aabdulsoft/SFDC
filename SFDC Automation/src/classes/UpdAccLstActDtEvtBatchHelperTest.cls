@isTest
public class UpdAccLstActDtEvtBatchHelperTest {

    static List<string> lSalesProfiles = new List<string>(LABEL.Ryder_Sales_Profiles.split(','));
    static User eventUser = createUser(true);    
    static date myDate = Date.Today();    
    static datetime myDateTime = System.Today();    

    static testmethod void UnitTest() {
    
        system.runAs(eventUser) {        
        
            Test.startTest();        

            RSMCreateTestData.GetCustomSettingsRecord();       
            Account acc = new Account();
            acc.name = 'Test Account';    
            acc.ShippingState = RyderGlobalVariables.TEST_STATE;        
            acc.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;
            acc.ShippingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
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
            insert Opp;
            
            Id eventRecordTypeId = LABEL.Ryder_Event_Record_ID;
                    
            Event E1 = New Event();
            E1.OwnerId = eventUser.Id;
            E1.Subject = 'Other';
            E1.ActivityDate = Date.Today();
            E1.StartDateTime = Date.Today();
            E1.EndDateTime = Date.Today();
            E1.WhatId = Acc.id;
            E1.Type = 'Other';
            E1.RecordTypeId = eventRecordTypeId;
            E1.Description = 'Test Ryder Event1';
            insert E1;
                    
            Event E2 = New Event();
            E2.OwnerId = eventUser.Id;
            E2.Subject = 'Cold Call Face to Face';
            E2.ActivityDate = Date.Today();
            E2.StartDateTime = Date.Today();
            E2.EndDateTime = Date.Today();
            E2.WhatId = Opp.id;
            E2.Type = 'Cold Call Face to Face';
            E2.RecordTypeId = eventRecordTypeId;
            E2.Description = 'Test Ryder Event2';
            insert E2;
    
            Event E3 = New Event();
            E3.OwnerId = eventUser.Id;
            E3.Subject = 'Face to Face';
            E3.ActivityDate = Date.Today();
            E3.StartDateTime = Date.Today();
            E3.EndDateTime = Date.Today();
            E3.WhatId = Acc.id;
            E3.Type = 'Cold Call Face to Face';
            E3.RecordTypeId = eventRecordTypeId;
            E3.Description = 'Test Ryder Event3';
            insert E3;
    
            /*
            E2.ActivityDate = Date.Today();        
            update E2;
            
            E3.ActivityDate = myDate;        
            E3.StartDateTime = myDateTime;
            E3.EndDateTime = myDateTime;
            update E3;
            */    

            UpdAccLstActDtEvtBatchHelper batchEvent = new UpdAccLstActDtEvtBatchHelper(); 
            batchEvent.query='select Id, WhatId, WhoId, ActivityDate, StartDateTime, EndDateTime, Type from Event where ActivityDate = TODAY';        
            database.executebatch(batchEvent);
            
            Test.stopTest();            
        }
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