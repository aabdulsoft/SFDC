@isTest
private class test_CreateTaskPartialWin {

    static testMethod void test_getOppToCreateTasks() {
        
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
        
        PartialWinRateSheet__c pw = new PartialWinRateSheet__c();
        pw.Opportunity__c = oppty.Id;
        pw.Rate_Sheet__c = '123456';
        pw.IsTaskCreated__c = false;
        insert pw;
        
        Test.startTest();
        CreateTaskPartialWin.getOppToCreateTasks();
        Test.stopTest();
    }
    
    static testMethod void test_PartialWinTask(){
        
        Account account = new Account();
        account.Name = 'blah';
        account.NCA__c = '00560000001NgUNAA0'; 
        account.Account_Classification__c = 'National';
        insert account;
        
        Opportunity oppty = new Opportunity();
        oppty.Name = 'Test';
        //oppty.AccountId = account.Id;
        oppty.Original_Decision_Maker__c = '0036000001gvtuZAAQ';
        oppty.CloseDate = Date.Today();
        oppty.StageName = 'Solution Hypothesis';
        insert oppty;
        
        List<ID> lOppIds = new List<ID>();
        lOppIds.add(String.valueOf(oppty.Id));
        
        PartialWinRateSheet__c pw = new PartialWinRateSheet__c();
        pw.Opportunity__c = oppty.Id;
        pw.Rate_Sheet__c = '123456';
        insert pw;
        
        Test.startTest();
        CreateTaskPartialWin.PartialWinTask(lOppIds);
        Test.stopTest();
    }
    

    static testMethod void test_ClosePartialWinTask() {
        
        Opportunity oppty = new Opportunity();
        oppty.Name = 'Test';
        oppty.Original_Decision_Maker__c = '0036000001gvtuZAAQ';
        oppty.CloseDate = Date.Today();
        oppty.StageName = 'Solution Hypothesis';
        insert oppty;
        
        Task T = new Task();
        T.WhatId = oppty.Id;
        T.Type = 'Partial Win';
        insert T;
        
        Test.startTest();
        CreateTaskPartialWin.ClosePartialWinTask(String.valueOf(oppty.Id));
        Test.stopTest();
        
    }
    
}