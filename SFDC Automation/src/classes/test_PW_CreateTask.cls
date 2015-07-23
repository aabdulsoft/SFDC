@isTest
private class test_PW_CreateTask{

    static testmethod void unitTest(){
    
        PW_CreateTask rvb = new PW_CreateTask();

		Account account = new Account();
        account.Name = 'blah';
        account.NCA__c = '00560000001NgUNAA0';
        account.Account_Classification__c = 'National';
        insert account;
        
        Opportunity oppty = new Opportunity();
        oppty.Name = 'Test';
        oppty.AccountId = account.Id;
        oppty.Original_Decision_Maker__c = '0036000001gvtuZAAQ';
        oppty.CloseDate = Date.Today();
        oppty.StageName = 'Solution Hypothesis';
        insert oppty; 
        
        List<PartialWinRateSheet__c> pwList = new List<PartialWinRateSheet__c>();
        PartialWinRateSheet__c pw = new PartialWinRateSheet__c();
        pw.Opportunity__c = oppty.Id;
        pw.Rate_Sheet__c = '123456';
        pwList.add(pw);
        insert pwList;
        
        Test.startTest();
       	Database.executeBatch(rvb, 50);        
        Test.stopTest();
    }
    
}