@isTest
private class test_RelocateOpportunities {

    //public static List<PartialWinRateSheet__c> CreateOpportunityFromPartialWin(String oldOppId)
    
    private static User createUser()
    {
        Profile pro = [select id from profile where name= 'CDM'][0];
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
    
    private static Account createAccount()
    {
        Account a1 = new Account(Id = '0016000000Ygtlk');
        
//        0016000000Ygtlk
//        a.BillingState = 'FL';
//        a.BillingCountry = 'US';
//        a.BillingCity = 'Pembroke Pines';
//        a.BillingPostalCode = '33025';
//        //a.BillingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
//        a.name = 'test account';
//        a.Account_Classification__c = 'Local';
//        a.Owner = [select id from user limit 1] ;
//       insert a;        

        return a1;
    }
   
    
     private static Contact createContact(Account a)
     {
        Contact c = New Contact (Id='0036000001VyyDA'); 
//        c.FirstName = 'TestFirst'; 
//        c.LastName = 'TestLast'; 
//        c.email = 'TestContact@test.com';
//        c.accountId = a.Id;
//        insert c;

        return c;
    }
    
    private static Opportunity createOpportunity(Account a, Contact c)
    {
        Opportunity o = new Opportunity(Id='0066000000dwwPR');
//        o.AccountId = a.id;
//        o.Original_Decision_Maker__c = c.id;
//        o.CloseDate = date.today()+2;
//        o.StageName = 'Booked';
//        o.name = 'test opportunity';
//        o.Estimated_Proposal_Date__c = System.today() + 1;
//        insert o;
        return o;
    }
    
    private static Rate_Sheet__c createRateSheet1(Opportunity o)
    {
        Rate_Sheet__c r1 = new Rate_Sheet__c();
        r1.Opportunity__c = o.id;
        r1.ext_ratesheet_id__c = 123;
        r1.Rate_Sheet_Name__c = 'Test RS 1';
        r1.Gross_Revenue__c = 500.00;
        insert r1;
        return r1;
    }
    
    private static Rate_Sheet__c createRateSheet2(Opportunity o)
    {
        Rate_Sheet__c r2 = new Rate_Sheet__c();
        r2.Opportunity__c = o.id;
        r2.ext_ratesheet_id__c = 456;
        r2.Rate_Sheet_Name__c = 'Test RS 2';
        r2.Gross_Revenue__c = 1000.00;
        insert r2;
        return r2;
    }
    
    private static PartialWinRateSheet__c createPartialWin1(Contact c, Opportunity o, Rate_Sheet__c r1)
    {
        PartialWinRateSheet__c pw1 = new PartialWinRateSheet__c();
        pw1.Name = 'PW RS 1';
        pw1.Opportunity__c = o.id;
        pw1.Rate_Sheet__c = String.valueOf(r1.ext_ratesheet_id__c);
        pw1.Rate_Sheet_Name__c = r1.Rate_Sheet_Name__c;
        pw1.Original_Decision_Maker__c = c.id;
        /*
        o.CloseDate = date.today()+2;
        o.StageName = 'Booked';
        o.name = 'test opportunity';
        o.Estimated_Proposal_Date__c = System.today() + 1;
        */
        insert pw1;
        return pw1;
    }
    
    private static PartialWinRateSheet__c createPartialWin2(Contact c, Opportunity o, Rate_Sheet__c r2)
    {
        PartialWinRateSheet__c pw2 = new PartialWinRateSheet__c();
        pw2.Name = 'PW RS 2';
        pw2.Opportunity__c = o.id;
        pw2.Rate_Sheet__c = String.valueOf(r2.ext_ratesheet_id__c);
        pw2.Rate_Sheet_Name__c = r2.Rate_Sheet_Name__c;
        pw2.Original_Decision_Maker__c = c.id;
        /*
        o.CloseDate = date.today()+2;
        o.StageName = 'Booked';
        o.name = 'test opportunity';
        o.Estimated_Proposal_Date__c = System.today() + 1;
        */
        insert pw2;
        return pw2;
    }

    static testMethod void test_CreateOpportunityFromPartialWin()
    {   
     
    
//        User u = createUser();
//        Account a = createAccount();
 //       Contact c = createContact(a);
  //      Opportunity o = createOpportunity(a, c);
  //      Rate_Sheet__c r1 = createRateSheet1(o);
  //      Rate_Sheet__c r2 = createRateSheet2(o);
  //      PartialWinRateSheet__c pw1 = createPartialWin1(c, o, r1);
  //      PartialWinRateSheet__c pw2 = createPartialWin1(c, o, r2);
 //  
  //      PartialWinRateSheet__c partialWinValue = new PartialWinRateSheet__c();
  //      List<PartialWinRateSheet__c> partialWinResultFinal = new List<PartialWinRateSheet__c>();
  //      List<PartialWinRateSheet__c> partialWinResult_Lost = new List<PartialWinRateSheet__c>();
  //      List<PartialWinRateSheet__c> partialWinResult_OpenBusiness = new List<PartialWinRateSheet__c>();
  //      List<PartialWinRateSheet__c> partialWinResult_WonBusinessNext = new List<PartialWinRateSheet__c>();
  //      List<PartialWinRateSheet__c> partialWinResult_WonBusinessThis = new List<PartialWinRateSheet__c>();
   //     Opportunity newOpptyLost = new Opportunity();
   //     Opportunity newOpptyOpenB = new Opportunity();
   //     Opportunity newOpptyWonBusNext = new Opportunity();
   //     Opportunity newOpptyWonBusThis = new Opportunity();
    }
    
}