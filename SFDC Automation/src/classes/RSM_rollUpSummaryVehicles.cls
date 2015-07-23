global class RSM_rollUpSummaryVehicles implements Database.Batchable<sObject>
{
    global Database.Querylocator start(Database.BatchableContext bc)
    {
        String sContractStatus = 'Approved';
        Set<String> sField = new Set<String>{'RSM__c','RSM_Service_Level__c', 'Account__c'};
        DateTime sDate = DateTime.newInstance(System.Now().year(), System.Now().Month(), System.Now().Day(), 00, 00, 00);
        String dateTimeFormat = sDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String sQuery = 'Select v.Parent.Account__c, v.ParentId From Vehicle__History v';
        sQuery += ' where Parent.RSM__c = : sContractStatus and Field in: sField and CreatedDate >' + dateTimeFormat;
        return Database.getQueryLocator(sQuery);
    }
    global void execute(Database.BatchableContext BC, List<Vehicle__History> scope)
    {
        RSM_RollUpSummaryVehicles_Helper.ProcessVehicleHistory(scope);
    }
    global void finish (Database.Batchablecontext BC){
    }
}