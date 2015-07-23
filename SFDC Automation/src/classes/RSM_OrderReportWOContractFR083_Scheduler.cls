global class RSM_OrderReportWOContractFR083_Scheduler implements Schedulable
{
	 global void execute(SchedulableContext sc)
	 {
	 	RSM_OrderReportWOContractFR083_Batch ClassObj = new RSM_OrderReportWOContractFR083_Batch();
	 	database.executebatch(ClassObj,200);
	 }
}