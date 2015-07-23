global class scheduledBatchAutoOpptyRenewal implements Schedulable {

   global void execute(SchedulableContext sc) {
      BatchAutoOpptyRenewal batch = new BatchAutoOpptyRenewal(); 
      database.executebatch(batch);
   }

}