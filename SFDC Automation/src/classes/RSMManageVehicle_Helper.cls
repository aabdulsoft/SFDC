public with sharing class RSMManageVehicle_Helper
{
    /*
        // FR022 Implementation
        // If the contract is approved and the vehicle is in demo, 
        // trigger a task to FIS people with Demo info to verify 
        // that it is still a demo contract.
    */  
    public static void CearteTaskIfApprovedAndInDemo(List<Vehicle__c> lVehicle, Map<Id,Vehicle__c> mVehicle)
    {
        List<Task> lTask = new List<Task>();
        List<Vehicle__c> lVehicleProcess = new List<Vehicle__c>();
        for(Vehicle__c ObjVehicle : lVehicle)
        {
            if(ObjVehicle.RSM_Demo__c && ObjVehicle.RSM__c == 'Approved' && 
                (mVehicle.get(ObjVehicle.Id).RSM__c == null || mVehicle.get(ObjVehicle.Id).RSM__c != 'Approved'))
            {
                lVehicleProcess.add(ObjVehicle);
            }
        }
        if(lVehicleProcess.size() > 0)
        {
            ID TaskRecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r 
                                        where SobjectType = 'Task' 
                                        and Name = 'RydeSmart Task'].Id;
            List<GroupMember> lGroup = [Select g.UserOrGroupId, g.Id, g.Group.Name, g.Group.Id, g.GroupId 
                                        From GroupMember g where Group.Name = 'FIS'];
            if(lGroup != null && lGroup.size() > 0)
            {
                for(Vehicle__c ObjVehicle : lVehicleProcess)
                {
                    for(GroupMember GroupMemberObj : lGroup)
                    {
                        Task TaskObj = new Task();
                        TaskObj.OwnerId = GroupMemberObj.UserOrGroupId;
                        TaskObj.Subject = 'Other';
                        TaskObj.WhatId = ObjVehicle.Id;
                        TaskObj.ActivityDate = System.today().addDays(1);
                        TaskObj.Description = 'There is a Demo Vehicle which has got approved, please take a necessary action!';
                        TaskObj.Status = 'In Progress';
                        TaskObj.Priority = 'High';
                        TaskObj.RecordTypeId = TaskRecordTypeId;
                        lTask.add(TaskObj);
                    }
                }
                if(lTask.size() > 0)
                    insert lTask;
            }
        }
    }
    /*
        // Implementation for Managing the FSL and RPM fields update
    */
    public static void UpdateAccount(List<Vehicle__c> lVehicle, Map<Id,Vehicle__c> mVehicle)
    {
        Set<Id> sAccountIds = new Set<Id>();    
        Set<String> sFields = new Set<String>{'Account__c','PRODUCT_LINE__c','Last_12_Months_Fixed_Cost__c',
                                                'Last_12_Months_Rated_Cost__c','Last_12_Months_Revenue__c',
                                                'Life_to_Date_Fixed_Cost__c','Life_to_Date_Rated_Cost__c',
                                                'Life_to_Date_Revenue__c'};
        for(Vehicle__c Vehicle : lVehicle)
        {
            if(Vehicle.RecordTypeId == null || !String.valueOf(LABEL.Exclude_RecordTypes_On_HQ_Visit).contains(Vehicle.RecordTypeId + ''))
            {
                for(String sField : sFields)
                {
                    String sNew = '';
                    String sOld = '';
                    if(Vehicle.get(sField) != null)
                        sNew = String.valueOf(Vehicle.get(sField));
                    if(mVehicle != null && mVehicle.get(Vehicle.Id).get(sField) != null)
                        sOld = String.valueOf(mVehicle.get(Vehicle.Id).get(sField));
                    if(sNew != sOld)
                    {
                        sAccountIds.add(Vehicle.Account__c);
                        if(sNew == 'Account__c')
                            sAccountIds.add(mVehicle.get(Vehicle.Id).Account__c);
                    }               
                }
            }
        }
        if(sAccountIds.size() > 0)
        {
            List<Account> lAcc = new List<Account>();
            for(ID AccId : sAccountIds)
            {
                Account Acc = new Account(Id = AccId, UpdatedFSLRPMFields__c = true);
                lAcc.add(Acc);
            }
            if(lAcc.size() > 0)
            {
                update lAcc;
            }
        }
    }
    public static void UpdateAccountOnExpirationDateChange(List<Vehicle__c> lVehicle, Map<Id,Vehicle__c> mVehicle)
    {
        Set<Id> sAccountIds = new Set<Id>();    
        Set<String> sFields = new Set<String>{'Account__c','EXPIRATION_DATE__c'};
        for(Vehicle__c Vehicle : lVehicle)
        {
            if(Vehicle.RecordTypeId == null || !String.valueOf(LABEL.Exclude_RecordTypes_On_HQ_Visit).contains(Vehicle.RecordTypeId + ''))
            {
                for(String sField : sFields)
                {
                    String sNew = '';
                    String sOld = '';
                    if(Vehicle.get(sField) != null)
                        sNew = String.valueOf(Vehicle.get(sField));
                    if(mVehicle != null && mVehicle.get(Vehicle.Id).get(sField) != null)
                        sOld = String.valueOf(mVehicle.get(Vehicle.Id).get(sField));
                    if(sNew != sOld)
                    {
                        sAccountIds.add(Vehicle.Account__c);
                        if(sNew == 'Account__c')
                            sAccountIds.add(mVehicle.get(Vehicle.Id).Account__c);
                    }               
                }
            }
        }
        if(sAccountIds.size() > 0)
        {
            List<Account> lAcc = new List<Account>();
            for(ID AccId : sAccountIds)
            {
                Account Acc = new Account(Id = AccId, Update_Revenue__c = true);
                lAcc.add(Acc);
            }
            if(lAcc.size() > 0)
            {
                update lAcc;
            }
        }
    }
    /*
    	While NRV vehicle is created update the Unit Number with the same value as Name (Unit#)
    */
    public static void PopulateUnitNumber(List<Vehicle__c> lVehicle)
    {
    	// Set the Vehicle Record Type Ids
    	String sVehicleRecordTypeId = '';
		Global_Settings__c VehicleRydeSmartNRVRecordType = Global_Settings__c.getValues('7');
		// if the custom settings is not null then get the value from settings and out in a local variable
		if(VehicleRydeSmartNRVRecordType != null && VehicleRydeSmartNRVRecordType.IsActive__c)
			sVehicleRecordTypeId = VehicleRydeSmartNRVRecordType.Value__c;
		if(sVehicleRecordTypeId != '')
    	{
    		for(Vehicle__c Vehicle : lVehicle)
    		{
    			if(Vehicle.RecordTypeId != null && Vehicle.RecordTypeId == sVehicleRecordTypeId)
    			{
    				if(Vehicle.Name.length() > 10)
    					Vehicle.Unit__c = Vehicle.Name.subString(0, 10);
    				else
    					Vehicle.Unit__c = Vehicle.Name;    				
    				Vehicle.Product_Line__c = 'NRV';
    			}
    		}
    	}
    }
}