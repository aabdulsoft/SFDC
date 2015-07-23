@isTest
private class RSMInstallationFlowBatch_Test{

    static testmethod void unitTest(){
    Test.startTest();
  	RSMCreateTestData.GetCustomSettingsRecord();
    
    RSMInstallationFlowBatch rif= new RSMInstallationFlowBatch ();
    rif.query='select Id,RSM_Device_Status__c,RSM_Request_for_Billing__c,RSM_Health_Status__c,RSM_Billing_Status__c from vehicle__c where RSM_Device_Status__c=\'Installed\' and RSM_Health_Status__c=\'No issues reported\' and RSM_Billing_Status__c=false LIMIT 10'; 
    database.executebatch(rif);
    
    Test.stopTest();

}
}