global class RSM_OrdRepWOContractGT30FR085_Scheduler implements Schedulable
{
	global void execute(SchedulableContext sc)
	{
		RSM_OrderReportWOContractGT30FR085_Batch ClassObj = new RSM_OrderReportWOContractGT30FR085_Batch(); 
        database.executebatch(ClassObj,200);
	}
}