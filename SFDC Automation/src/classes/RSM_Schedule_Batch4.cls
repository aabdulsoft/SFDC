global class RSM_Schedule_Batch4 implements Schedulable {
      global void execute(SchedulableContext sc) {
        
        //************Emails************
    //FR010-Batchable to send initial welcome letter to non-key accounts
       RSMInitialWelEmailToNonKeyAc rsiwe= new RSMInitialWelEmailToNonKeyAc (); 
        rsiwe.query='select Id,RSM_AC_Classification__c,RSM_Onboarding__c from Account where RSM_AC_Classification__c=\'Non-Key Account\' and RSM_Onboarding__c=\'Initiation\''; 
        database.executebatch(rsiwe,200);
        
        //FR011-Batch Class to Send Email to Non-Key Ac once installation Process is complete for all the contracted vehicles
        RSMEmailToNonKeyAcAfterInstCompleted rseaic= new RSMEmailToNonKeyAcAfterInstCompleted(); 
        rseaic.query='select Id,RSM_AC_Classification__c from Account where RSM_AC_Classification__c=\'Non-Key Account\' and RSM_Account_Status__c = \'Customer\''; 
        database.executebatch(rseaic,200);
        
        //FR134-Batch Class to Send Email to Non-Key Accounts for cancelation contracts
        RSMCancelEmailtoNonKeyAc rsce= new RSMCancelEmailtoNonKeyAc(); 
        rsce.query='select Id,LesseeNo__c,RSM_AC_Classification__c from Account where RSM_AC_Classification__c=\'Non-Key Account\''; 
        database.executebatch(rsce,200);
        
       //FR033-Generate Email to RSS once unit cancels their contract to request de-activation
        RSMEmailRSSToDeactivateCon rerd= new RSMEmailRSSToDeactivateCon(); 
        rerd.query='select Id,Action_Name__c,Is_Current__c,Email_sent_to_De_Activate_contract__c from RSM_ContractDetail__c where Action_Name__c=\'Cancel\' and Is_Current__c=true and Email_sent_to_De_Activate_contract__c=false'; 
        database.executebatch(rerd,200);
        
        //FR034-Generate an email to RSS to reactivate billing  when FSL is billing, approved contract for RydeSmart exists and RydeSmart is not billing
        RSMEmailRSSToReactivatebilling rerb= new RSMEmailRSSToReactivatebilling(); 
       rerb.query='select Id,Unit_Number__c,Unit_Number__r.Name,Validation_Rule_Id__c from RSM_VehicleValidationDetails__c where Validation_Rule_Id__c=\'11\' OR Validation_Rule_Id__c=\'22\'';
          database.executebatch(rerb,500);
        
      }
}