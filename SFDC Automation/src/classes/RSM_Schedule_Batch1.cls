global class RSM_Schedule_Batch1 implements Schedulable {
        global void execute(SchedulableContext sc) {
                
        //Batchable class to update contract status and service level in vehicle 
        RSMUpdateVehicleBatch rsuvb = new RSMUpdateVehicleBatch (); 
        //rsuvb.query='select Id,Unit_Number__c,Service_Name__c,Contract_Number__r.Status_Name__c,Action_Name__c from RSM_ContractDetail__c';
        rsuvb.query='select Id,Unit_Number__c,Unit_Number__r.Account__c,Service_Name__c,Action_Name__c,Contract_Number__r.Status_Name__c,Contract_Number__r.Account__c,Is_Current__c,Valid__c from RSM_ContractDetail__c where Contract_Number__r.Account__c <> NULL order by EffectiveDate__c';
        database.executebatch(rsuvb,50);
 
        //Batchable class to create pre-launch checklist once the contract approves
        RSMCreatePreLaunchCheckList rspcl= new RSMCreatePreLaunchCheckList(); 
        rspcl.query='select Id,LesseeNo__c,RSM_PLC_Flag__c from Account where RSM_PLC_Flag__c = false and RSM_AC_Classification__c=\'Key Account\''; 
        database.executebatch(rspcl,5);
               
        //Batchable class to create RS sales questionnaire task 
        RSMCreateSalesQuestionaairTask rssqt= new RSMCreateSalesQuestionaairTask(); 
        rssqt.query='select Id from Account where RSM_Onboarding__c=\'\''; 
        database.executebatch(rssqt,20);
        
        //Batchable class to update Order Status in vehicle Object
        RSMUpdateOrderStatusBatch  rsosu= new RSMUpdateOrderStatusBatch ();
        rsosu.query='select Id,Unit_Number__c,DateReceived__c,DateShipped__c,DateOrdered__c from RSM_PO__c where LastModifiedDate=LAST_N_DAYS:0'; 
        database.executebatch(rsosu,200);      
        
        //Batchable class to Initiate Installation to update RSM Billing Status=Send to billing
        RSMInstallationFlowBatch rsif= new RSMInstallationFlowBatch ();
        rsif.query='select Id,RSM_Device_Status__c,RSM_Request_for_Billing__c,RSM_Health_Status__c,RSM_Billing_Status__c from vehicle__c where RSM__c=\'Approved\' and RSM_Device_Status__c=\'Installed\' and RSM_Health_Status__c=\'No issues reported\' and RSM_Request_for_Billing__c!=\'Sent to Activate Billing\' and RSM_Billing_Status__c=false'; 
        database.executebatch(rsif,200);
 
      }
}