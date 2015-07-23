global class RSM_SoldVehicleReportFR077_Scheduler implements Schedulable
{
	global void execute(SchedulableContext sc)
	{
		RSM_SoldVehicleReportFR077_Batch ClassObj = new RSM_SoldVehicleReportFR077_Batch (); 
        database.executebatch(ClassObj,1000);
	}
}