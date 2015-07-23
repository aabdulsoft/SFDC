//Controller for VF Component 'RSM Activate Billing Comp'
global class RSMActivateBillingCtrl {
global String accountId{get;set;}
global String accountName{get;set;}
global List<Vehicle__c> vehList{
    get{
        return [select Id,Name,RSM_Device_Status__c,RSM_Request_for_Billing__c,RSM_Health_Status__c,RSM_Billing_Status__c from vehicle__c where RSM_Request_for_Billing__c='Send to Activate Billing' and RSM_Billing_Status__c=false and Account__c =:accountId];
    }
    set;
}
}