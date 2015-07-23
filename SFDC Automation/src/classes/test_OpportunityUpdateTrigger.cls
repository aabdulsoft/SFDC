@isTest
private with sharing class test_OpportunityUpdateTrigger {

    private static User createUser(){
        Profile pro = [select id from profile where name = 'standard user'][0];
        User u1 = new user();
        u1.username = 'opptest@ryder.com';
        u1.LastName = 'lastname';
        u1.Email = 'mherlihy@salesforce.com';
        u1.Alias = 'tuser';
        u1.CommunityNickname = 'tnick';
        u1.profileid = pro.id;
        u1.TimeZoneSidKey = 'America/New_York';
        u1.LocaleSidKey = 'en_US';
        u1.EmailEncodingKey = 'ISO-8859-1';
        u1.LanguageLocaleKey = 'en_US';
        insert u1;
        return u1;
    }

    private static Account createAccount(){
        Account a = new Account();
        a.BillingState = 'IL';
        a.BillingCountry = 'US';
        a.BillingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
        a.name = 'test account';
        a.Account_Classification__c = 'Local';
        insert a;
        
        return a;
    }
    
    private static Contact createContact(Account a){
        Contact c = New Contact (); 
        c.FirstName = 'TestFirst'; 
        c.LastName = 'TestLast'; 
        c.email = 'TestContact@test.com';
        c.accountId = a.Id;
        insert c;
        return c;
    }
    
    private static Opportunity createOpportunity(Account a, Contact c){
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.Original_Decision_Maker__c = c.id;
        o.CloseDate = date.today()+2;
        o.StageName = 'Qualifying';
        o.name = 'test opportunity';
        o.Estimated_Proposal_Date__c = System.today() + 1;
        insert o;
        return o;
    }

    static testMethod void test_OpportunityUpdateTrigger(){
        User u = createUser();
        Account a = createAccount();
        Contact c = createContact(a);
        Opportunity o = createOpportunity(a, c);
        //Opportunity_Split__c os = [select id, sales_team_member__c from Opportunity_Split__c where Opportunity__c = :o.id];
        o.OwnerId = u.id;
        update o;
        //Opportunity_Split__c osupdated = [select id, sales_team_member__c from Opportunity_Split__c where Opportunity__c = :o.id];
        //system.assertequals(osupdated.sales_team_member__c, u.id);
    }
    
    static testMethod void test_OpportunityUpdateTrigger_CaseCreate(){
        
        User u = createUser();
        Account a = createAccount();
        Contact c = createContact(a);
        Opportunity oppty = createOpportunity(a, c);
        //Opportunity oppty = new Opportunity();
        oppty.StageName = 'Booked';
        oppty.Customer_100_Ownership__c = 'Yes';
        oppty.OwnerId = u.id;
        update oppty;
    }

}