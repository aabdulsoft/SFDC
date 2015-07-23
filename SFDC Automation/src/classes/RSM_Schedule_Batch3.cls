global class RSM_Schedule_Batch3 implements Schedulable {
      global void execute(SchedulableContext sc) {
         
      //Batchable class to update billing Status in Account Object
      RSMUpdateBillingStatusBatch rsubs= new RSMUpdateBillingStatusBatch ();
      rsubs.query='select Id,RSM_Billing__c from Account where RSM_Account_Status__c = \'Customer\''; 
      database.executebatch(rsubs,200);
      
      //Batchable class to update RydeSmart Revenue in Account Object
      RSMUpdateAccountRevenueBatch rsuar= new RSMUpdateAccountRevenueBatch ();
      rsuar.query='select Id from Account where RSM_Account_Status__c = \'Customer\'';
      database.executebatch(rsuar,200);
      
      //Batchable class to Initiate Installation2 to send email to activate billing and update RSM Billing Status=Sent to billing
      RSMInstallationFlowBatch2 rsif2= new RSMInstallationFlowBatch2 ();
      rsif2.query='select Id from Account where RSM_Account_Status__c = \'Customer\''; 
      database.executebatch(rsif2,200);
      
      //Batchable to initiate onboarding flow to create Task for CCMs to schedule Training
      RSMOnboardingFlowBatch rsobf= new RSMOnboardingFlowBatch (); 
      rsobf.query='select Id from Account where RSM_AC_Classification__c=\'Key Account\' and RSM_Account_Status__c=\'Customer\''; 
      database.executebatch(rsobf,200);
      
      //Batch class to calculate the vehicle is Upgraded or Downgraded based on the Service level change and Additional service level
      //This batch to be scheduled after 'RSMUpdateVehicleBatch' is completed
      RSMServiceLevelChangeStatus rssls= new RSMServiceLevelChangeStatus(); 
      //rssls.query='select Id,RSM__c,RSM_Add_Service_current_count__c,RSM_Addition_Service_prior_count__c,RSM_Service_Level__c,RSM_Service_Level_Prior_value__c from Vehicle__c where RSM__c=\'Approved\''; 
      rssls.query='select r.Unit_Number__r.RSM__c, r.Action_Name__c, r.Unit_Number__r.RSM_Add_Service_current_count__c, r.Unit_Number__r.RSM_Addition_Service_prior_count__c, r.Unit_Number__r.RSM_Service_Level__c, r.Unit_Number__r.RSM_Service_Level_Prior_value__c, r.Contract_Number__r.Account__c, r.Unit_Number__c, r.Unit_Number__r.Account__c from RSM_ContractDetail__c r where r.Is_Current__c=true and r.Unit_Number__r.RSM__c=\'Approved\'';
      database.executebatch(rssls,200);
    
      }
}