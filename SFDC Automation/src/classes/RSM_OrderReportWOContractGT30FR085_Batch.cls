global with sharing class RSM_OrderReportWOContractGT30FR085_Batch implements Database.Batchable<SObject>
{
	/* 
		Query the RSM_VehicleValidationDetails__c object where the Validation Id is: 
		As this Id is always there which is matching the FR087 condition
	*/ 
	public String query = 'Select r.Validation_Rule_Id__c, r.Unit_Number__c, r.Status_Date__c, '
							+'r.Rule_Description__c, r.Name, r.Id, r.Unit_Number__r.Account__c, r.Unit_Number__r.Account__r.OwnerId '
							+'From RSM_VehicleValidationDetails__c r where Validation_Rule_Id__c = \'38\'';
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		/* 
			Return the Query Data
		*/		
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<RSM_VehicleValidationDetails__c> lVehicleValidate)
	{
		/* 
			Get the Task RydeSmart Record Type Id from Custom Settings
		*/
		String sTaskRecordTypeId = '';
		Global_Settings__c TaskRydeSmartRecordType = Global_Settings__c.getValues('6');
		// if the custom settings is not null then get the value from settings and out in a local variable
		if(TaskRydeSmartRecordType != null && TaskRydeSmartRecordType.IsActive__c)
			sTaskRecordTypeId = TaskRydeSmartRecordType.Value__c;
		Set<String> sVehicleIds = new Set<String>();
		Set<String> sAccIds = new Set<String>();
		Set<String> sVehicleExistIds = new Set<String>();
		/* 
			Iterate the Data and collect the Vehicle Ids
		*/ 
		for(RSM_VehicleValidationDetails__c VehicleValidate : lVehicleValidate)
		{   
			sVehicleIds.add(VehicleValidate.Unit_Number__c);
		}
		/* 
			Query the Existing Task
		*/		
		if(sVehicleIds.size() > 0)
		{
			List<Task> lTaskExist = [Select t.WhatId, t.Subject, t.RecordTypeId 
									From Task t where RecordTypeId =: sTaskRecordTypeId and 
									Subject like '%is Reporting with no Contract for more than 30 Days' and 
									Subject like 'Unit No.%' and WhatId in : sVehicleIds];// Add logic for Account here with: sAccIds
			for(Task TaskO : lTaskExist)
			{
				sVehicleExistIds.add(TaskO.WhatId);
			}
		}
		/* 
			Remove the Vehicle Id where the Task has already been created
		*/		
		sVehicleIds.removeall(sVehicleExistIds);
		if(sVehicleIds.size() > 0)
		{
			List<Vehicle__c> lVehicle = [Select v.Unit__c, v.Id, 
											v.Account__r.RSM_CCMs__c, v.Account__c 
											From Vehicle__c v where 
											Id in : sVehicleIds and 
											Account__r.RSM_CCMs__c != null];
			List<Task> lTask = new List<Task>();
			/* 
				Iterate the Vehicle List and Create the Task
			*/
			for(Vehicle__c Vehicle : lVehicle)
			{    
		    	Task TaskObj = new Task(RecordTypeId = sTaskRecordTypeId, Type = 'Action from RydeSmart');
		    	TaskObj.Subject = 'Unit No. ' + Vehicle.Unit__c + ' is Reporting with no Contract for more than 30 Days';
		    	TaskObj.Description = 'Create Contract for Account';
		    	TaskObj.ActivityDate = System.today().addDays(15);
		    	TaskObj.Type = 'Action from RydeSmart';
		    	TaskObj.WhatId = Vehicle.Id;
		    	TaskObj.OwnerId = Vehicle.Account__r.RSM_CCMs__c;		    	
		    	lTask.add(TaskObj);
		    }
		    if(lTask.size() > 0)
		    	insert lTask;
		}
	}
	global void finish(Database.BatchableContext BC){
	}
}