global class UVS_OpportunityBillOfSaleScheduler implements Schedulable
{
	global void execute(SchedulableContext sc)
	{
		// Execute the Batch apex using sacheduler
		UVS_OpportunityBillOfSaleBatch UVS_OppBillOfSaleBatchObj = new UVS_OpportunityBillOfSaleBatch(); 
        database.executebatch(UVS_OppBillOfSaleBatchObj,200);
	}
}