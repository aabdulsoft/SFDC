@isTest
private class test_PWRateSheet {
    
    static testMethod void Test_searchPartialWinData()
    {
    	RSMCreateTestData.GetCustomSettingsRecord();
    	/*
    	User u = createUser();
        Account a = createAccount();
        Contact c = createContact(a, u);
        Opportunity o = createOpportunity(a, c);
        Rate_Sheet__c rs = createRateSheet(o);
        */
        //public Boolean isSubmit = false;
        //public Boolean dontSave = false;
    	
        Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '0123123';
        insert Acc1;
    	
    
		Contact Cont1 = new Contact();
		Cont1.AccountId = Acc1.Id;
		Cont1.FirstName = 'Test Contact';
		Cont1.LastName = 'Sample';
		Cont1.Email = 'test8979123@rydertest.com';
		Cont1.Maintenance_Contact_Type__c = 'Primary';
		Cont1.Phone = '(123) 456-8789';
		Cont1.Contact_Source__c = 'Lead Conversion';
		insert Cont1;
    	
    
        Opportunity Opp = new Opportunity();
        Opp.AccountId = Acc1.id;
        Opp.Original_Decision_Maker__c = Cont1.id;
        Opp.CloseDate = date.today()+2;
        Opp.StageName = 'Qualifying';
        Opp.name = 'test opportunity';
        Opp.Estimated_Proposal_Date__c = System.today() + 1;
        opp.PartialWinLostReason__c = 'Lost';
        insert Opp;
        
        Deal_Summary__c ds = new Deal_Summary__c();
        ds.Opportunity__c = Opp.id;
        ds.ext_dealsummary_id__c = 98765;
        insert ds;
        
        Rate_Sheet__c rs1 = new Rate_Sheet__c();
        rs1.Opportunity__c = Opp.id;
        rs1.ext_ratesheet_id__c = 12345;
        rs1.Name = '12345';
        rs1.Deal_Summary__c = ds.id;
        insert rs1;
        
        Rate_Sheet__c rs2 = new Rate_Sheet__c();
        rs2.Opportunity__c = Opp.id;
        rs2.ext_ratesheet_id__c = 23456;
        rs2.Name = '23456';
        insert rs2;
        
        PartialWinRateSheet__c pw1 = new PartialWinRateSheet__c();
        pw1.Opportunity__c = Opp.id;
        pw1.Rate_Sheet__c = rs1.id;
        pw1.Rate_Sheet_Name__c = '12345';
        pw1.Status__c = NULL;
        pw1.Deal_Summary__c = ds.id;
        insert pw1;
                
        PartialWinRateSheet__c pw2 = new PartialWinRateSheet__c();
        pw2.Opportunity__c = Opp.id;
        pw2.Rate_Sheet__c = rs2.id;
        pw2.Rate_Sheet_Name__c = '23456';
        pw2.Status__c = 'Lost';
        pw1.Deal_Summary__c = '';
        insert pw2;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(Opp);
        
        PWRateSheet pwRS = new PWRateSheet(stdController);
        pwRS.searchPartialWinData();
        pwRS.doSave();
        pwrs.isSubmit = true;
        pwRS.doSave();
        pwRS.doSubmit();
        
    	//pwRS.RelocateRateSheets(pwrs.partialWinRateSheet);
    	//pwRS.ExtractAndRefreshNewOpportunityIds(pwrs.partialWinRateSheet);
    	//pwRS.UpdateMovedRSDS(pwrs.partialWinRateSheet);
    	//pwRS.ClosePartialWinTask(Opp.id);
     
    }
    
}