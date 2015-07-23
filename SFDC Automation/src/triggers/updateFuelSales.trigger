//trigger <name> on Fuel_Sales__c (<events>) {
trigger updateFuelSales on Fuel_Sales__c(after update)
{
    Set<Id> fuelSalesId = new Set<Id>();
    double q1 = 0;
    
    System.debug('aaaaaaaaa In Trigger!!');
    
    for(Fuel_Sales__c fsId : Trigger.new)
    {
        fuelSalesId.add(fsId.Id);
        q1 = fsId.Total_Q1__c;
    }
    
    System.debug('aaaaaaaaa q1: ' + q1);
    
    //Logic here: find out if the Fuel Sale record has a value of 100
    if (q1 == 100)
    {
        System.debug('aaaaaaaaa q1 = 100');
        
        //Query Task object by status <> closed and equals to this Fuel Sale record (WhatId in Task)
        List<Task> tsk = [Select Id From Task where Status != 'Completed' and WhatId =: fuelSalesId];
        System.debug('aaaaaaaaa tsk : ' + tsk );
        if(tsk != null)
        {
          List<Task> updTsk = new List<Task>();
          for(Task tskUpd: tsk)
            {
                Task T = new Task();
                T.Id = tskUpd.Id;
                T.Status = 'Completed';
                updTsk.add(T);
            }
            
          update updTsk;    
          System.debug('aaaaaaaaa updTsk: ' + updTsk);    
        }
    }    
    
}