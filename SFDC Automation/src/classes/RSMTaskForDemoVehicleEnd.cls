//FR022-Batch Class to Trigger a task to CCM at the end of the demo period informing demo period expired
global class RSMTaskForDemoVehicleEnd implements Database.Batchable<SObject>
{
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		Date sFromDate = System.Today();
		String sQuery = 'Select v.RSM_To__c, v.RSM_Demo__c, v.Account__r.RSM_CCMs__c, '
						+ 'v.Account__c, v.Account__r.RSM_CCMs__r.Id From Vehicle__c v '
						+ 'where RSM_To__c = : sFromDate and RSM_Demo__c = true '
						+ 'and Account__c != null and Account__r.RSM_CCMs__c != null';
        return Database.getQueryLocator(sQuery);
    }
    global void execute(Database.BatchableContext BC, List<Vehicle__c> scope)
    {
    	ID TaskRecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r 
								where SobjectType = 'Task' and Name = 'RydeSmart Task'].Id;
		List<Task> lTask = new List<Task>();
		for(Vehicle__c VehicleObj : scope)
		{
            Task TaskObj = new Task();
			TaskObj.OwnerId = VehicleObj.Account__r.RSM_CCMs__r.Id;
			TaskObj.Subject = 'Other';
			TaskObj.WhatId = VehicleObj.Id;
			TaskObj.ActivityDate = System.today().addDays(1);
			TaskObj.Description = 'There is a Demo Vehicle where End Date expired Yesterday!';
			TaskObj.Status = 'In Progress';
			TaskObj.Priority = 'High';
			TaskObj.RecordTypeId = TaskRecordTypeId;
			lTask.add(TaskObj);
        }
        if(lTask.size() > 0)
			insert lTask;
	}
	global void finish(Database.BatchableContext BC)
    {}
}