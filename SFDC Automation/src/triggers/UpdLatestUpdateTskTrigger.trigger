/*
* 
*   Trigger that updates the values of Latest Update field on the Account/Opportunity when a new Task of Type = 
*   'Account/Opportunity Update' is created  on Account/Opportunity by the Account/Opportunity owner respectively or NCA or SAC.
*
*   Author                     |Date               |Comment
*   --------------------------|-------------------|--------------------------------------------------
*   Saad Wali Jaan      |06.18.2015     |First draft
*
*/

trigger UpdLatestUpdateTskTrigger on Task (after insert) {
    
    if(trigger.isAfter)
    {
        List<Task> lstTask = new List<Task>();
                
        system.debug('UALUT0.0');
        for(Task newTask : trigger.new)
        {
            system.debug('UALUT0.1');
            if((newTask.WhatId != null) && (newTask.Type != null) && (newTask.Type == LABEL.LatestUpdateType) && (newTask.Description != null) && (newTask.Description.length() >= 3) && (newTask.Status == 'Completed'))
            {
                system.debug('UALUT0.2');
                lstTask.add(newTask);
            }
        } 
        system.debug('UALUT0.3');
        if(lstTask != null && lstTask.size()>0)
        {
            UpdLatestUpdateTskTriggerHelper.UpdateAccOpp(lstTask);
            system.debug('UALUT0.4');            
        }
    }
}