@isTest
private class RSMSalesQuestionnaire_Test{

    static testmethod void unitTest()
    {
	    Test.startTest();
	    
	    RSMCreateTestData.GetCustomSettingsRecord();
	    Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '0123123';
        insert Acc1;


	    RSM_Sales_Qus__c rsq = new RSM_Sales_Qus__c ();
	    rsq.Account_Number__c = Acc1.LesseeNo__c;
	    rsq.Customer_Name__c = Acc1.Id;
	    rsq.Sales_Person_Name__c = Acc1.OwnerId;
	    rsq.Date__c = System.today();
	    rsq.Phone_Number__c = Acc1.Owner.phone;
	    Insert rsq;
	    PageReference pr = Page.RSM_Sales_Questionnaire_Task_List;
    
	    Test.setCurrentPage(pr);
	    Apexpages.currentPage().getParameters().put('accId',Acc1.Id);
	    Apexpages.currentPage().getParameters().put('Id',rsq.Id);
	    Apexpages.StandardController ctrl = new Apexpages.StandardController(rsq);
	    RSMSalesQuestionnaire rq = new RSMSalesQuestionnaire(ctrl);
	    rq.save();

    	Test.stopTest();
	}
	static testmethod void unitTest1()
    {
	    Test.startTest();
	    
	    RSMCreateTestData.GetCustomSettingsRecord();
	    Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '0123123';
        insert Acc1;
		
		RSM_Sales_Qus__c rsq = new RSM_Sales_Qus__c ();
	    rsq.Account_Number__c = Acc1.LesseeNo__c;
	    rsq.Customer_Name__c = Acc1.Id;
	    rsq.Sales_Person_Name__c = Acc1.OwnerId;
	    rsq.Date__c = System.today();
	    rsq.Phone_Number__c = Acc1.Owner.phone;
	    
		PageReference pr = Page.RSM_Sales_Questionnaire_Task_List;
		Test.setCurrentPage(pr);
	    Apexpages.currentPage().getParameters().put('accId',Acc1.Id);
	    Apexpages.StandardController ctrl = new Apexpages.StandardController(rsq);
	    RSMSalesQuestionnaire rq = new RSMSalesQuestionnaire(ctrl);
	    rq.save();

    	Test.stopTest();
	}
}