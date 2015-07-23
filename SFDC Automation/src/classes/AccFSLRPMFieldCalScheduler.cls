global class AccFSLRPMFieldCalScheduler implements Schedulable
{
	global void execute(SchedulableContext sc)
	{
		AccountFSLRPMFieldCalculationBatch AccFSLRPMFieldCalObj = new AccountFSLRPMFieldCalculationBatch(); 
        database.executebatch(AccFSLRPMFieldCalObj,1);
	}
}