trigger UpdAccLstActDtEvtTrigger on Event (after update) {

    if(trigger.isAfter)
    {
        List<Event> lstRyderEvent = new List<Event>();
        
        for(Event newRyderEvent : trigger.new)
        {
            if(newRyderEvent.RecordTypeId == LABEL.Ryder_Event_Record_ID){
                lstRyderEvent.add(newRyderEvent);
            }
        } 
        
        //UpdAccLstActDtEvtTriggerHelper.UpdateAccount(trigger.new, trigger.oldMap, trigger.newMap);
        
        if(lstRyderEvent != null && lstRyderEvent.size()>0){
            UpdAccLstActDtEvtTriggerHelper.UpdateAccount(lstRyderEvent, trigger.oldMap, trigger.newMap);         
        }
    }  
}