global class RevenueRollupAccount_Schedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        RevenueRollupAccount RevenueRollup = new RevenueRollupAccount(); 
        database.executebatch(RevenueRollup,1);
    }
}