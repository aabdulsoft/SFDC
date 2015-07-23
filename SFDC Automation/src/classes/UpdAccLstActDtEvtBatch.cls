global class UpdAccLstActDtEvtBatch implements Schedulable {

        global void execute(SchedulableContext sc) {
                
        UpdAccLstActDtEvtBatchHelper batchEvent = new UpdAccLstActDtEvtBatchHelper(); 
        batchEvent.query='select Id, WhatId, WhoId, ActivityDate, StartDateTime, EndDateTime, Type from Event where ActivityDate = TODAY';
        database.executebatch(batchEvent,100);
      
      }
}