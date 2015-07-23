trigger ScheduleARequestManagement on UVS_SheduleA_Request__c(before insert, after Update)
{
	if(trigger.isInsert)
		ScheduleARequestManagement_Helper.ManageRequestTypeInsert(trigger.new);
	else if(trigger.isUpdate)
		ScheduleARequestManagement_Helper.ManageRequestTypeUpdate(trigger.New, trigger.oldMap);
}