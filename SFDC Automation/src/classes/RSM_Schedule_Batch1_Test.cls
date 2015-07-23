@isTest
private Class RSM_Schedule_Batch1_Test{
    static testmethod void unitTest()
    {
	    Test.startTest();
	    
	    RSMUpdateVehicleBatch ruvb = new RSMUpdateVehicleBatch ();
	    ruvb.query='select Contract_Number__r.Account__c, Unit_Number__r.id, Unit_Number__r.Account__c, Action_Name__c, Id,Unit_Number__c,Service_Name__c,Contract_Number__r.Status_Name__c from RSM_ContractDetail__c limit 1';  
	    Id BatchprocessId = Database.executeBatch(ruvb);
	    
	    Test.StopTest();
    }
    static testmethod void unitTest1()
    {
	    Test.startTest();
	    
	    RSMUpdateOrderStatusBatch  ros= new RSMUpdateOrderStatusBatch ();
	    ros.query='select Id,Unit_Number__c,DateReceived__c,DateShipped__c,DateOrdered__c from RSM_PO__c where LastModifiedDate=LAST_N_DAYS:0 limit 1'; 
	    Id BatchprocessId4 = Database.executeBatch(ros);
	    
	    Test.StopTest();
    }
    static testmethod void unitTest2()
    {
	    Test.startTest();
	    RSMCreatePreLaunchCheckList rpl= new RSMCreatePreLaunchCheckList(); 
	    rpl.query='select Id,LesseeNo__c,RSM_PLC_Flag__c from Account where RSM_PLC_Flag__c = false and RSM_AC_Classification__c=\'Key Account\' limit 10';
	    Id BatchprocessId2 = Database.executeBatch(rpl);
	    Test.StopTest();
    }
    static testmethod void unitTest3()
    {
	    Test.startTest();
	    
	    RSMInstallationFlowBatch rif= new RSMInstallationFlowBatch ();
	    rif.query='select Id,RSM_Device_Status__c,RSM_Request_for_Billing__c,RSM_Health_Status__c,RSM_Billing_Status__c from vehicle__c where RSM_Device_Status__c=\'Installed\' and RSM_Health_Status__c=\'No issues reported\' and RSM_Billing_Status__c=false limit 1'; 
	    Id BatchprocessId5 = Database.executeBatch(rif);
	    
	    Test.StopTest();
    }
    static testmethod void unitTest4()
    {
	    Test.startTest();
	    
	    RSMCreateSalesQuestionaairTask rsq= new RSMCreateSalesQuestionaairTask(); 
	    rsq.query='select Id from Account where RSM_Onboarding__c=\'\' limit 1'; 
	    Id BatchprocessId3 = Database.executeBatch(rsq);
	    
	    Test.StopTest();
    }
}