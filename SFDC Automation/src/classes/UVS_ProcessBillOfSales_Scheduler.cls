global class UVS_ProcessBillOfSales_Scheduler implements Schedulable
{
	global void execute(SchedulableContext sc)
	{
		// Execute the Batch apex using sacheduler
		UVS_ProcessBillOfSales UVS_ProcessBillOfSalesObj = new UVS_ProcessBillOfSales(); 
        database.executebatch(UVS_ProcessBillOfSalesObj,1);
	}
}