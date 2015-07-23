global class RSM_Schedule_Batch2 implements Schedulable
{
  global void execute(SchedulableContext sc)
  { 
    
    RSM_rollUpSummaryVehicles runLockBatch = new RSM_rollUpSummaryVehicles();
    Database.executeBatch(runLockBatch, 200);
    
    //FR022
    RSMTaskForDemoVehicleEnd ClassObj = new RSMTaskForDemoVehicleEnd();
    database.executebatch(ClassObj,500);
  }
}