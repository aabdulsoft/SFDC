global class RSM_VehicleActReportGT60FR087_Scheduler implements Schedulable
{
	global void execute(SchedulableContext sc)
	{
		RSM_VehicleActiveReportGT60FR087_Batch ClassObj = new RSM_VehicleActiveReportGT60FR087_Batch(); 
        database.executebatch(ClassObj,200);
	}
}