//FR033-Generate Email to RSS once unit cancels their contract to request de-activation
global class RSMEmailRSSToDeactivateConCtrl {

    global List<RSM_ContractDetail__c> rsmCdList { get{
        return [select Name,Contract_Number__c,Contract_Number__r.Name,Unit_Number__c,Unit_Number__r.Name from RSM_ContractDetail__c where  Action_Name__c='Cancel' and Is_Current__c=true and Email_sent_to_De_Activate_contract__c=false Limit 200];          
       
    } set; }
   
}