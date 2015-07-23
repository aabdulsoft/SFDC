@isTest
private class RSMEmailRSSToDeactivateCon_Test{

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
        Acc1.LesseeNo__c = '123123';
        insert Acc1;
    		
    	RSM_Contract__c Contrt1 = new RSM_Contract__c();
	    Contrt1.Lessee__c = Acc1.LesseeNo__c;
	    Contrt1.Contract_Number__c = 2434;
	    Contrt1.Status_Name__c = 'Approved';
	    //Contrt1.Cancelled_Contract_details__c = 10;
	    //Contrt1.Total_Contract_Detail__c = 10;
	    insert Contrt1;
	    
	    RSM_ContractDetail__c Contrt1Detail = new RSM_ContractDetail__c();
	    Contrt1Detail.Contract_Number__c = Contrt1.id;
	    Contrt1Detail.Action_Name__c = 'Cancel';
	    Contrt1Detail.Is_Current__c = True;
	    Contrt1Detail.Email_sent_to_De_Activate_contract__c = false;
	    insert Contrt1Detail;
	    
	    
		RSMEmailRSSToDeactivateCon red= new RSMEmailRSSToDeactivateCon(); 
	    red.query='select Id,Action_Name__c,Is_Current__c,Email_sent_to_De_Activate_contract__c'
	    		+' from RSM_ContractDetail__c where Action_Name__c=\'Cancel\' and Is_Current__c=true '
	    		+'and Email_sent_to_De_Activate_contract__c=false limit 1'; 
	    Id BatchprocessId4 = Database.executeBatch(red);	    
		
	    Test.stopTest();	
	}
}