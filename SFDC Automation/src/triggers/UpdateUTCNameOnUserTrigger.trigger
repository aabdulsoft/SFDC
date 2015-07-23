/* 
*   Trigger that updates the UTC_Name__c field when the UTC__c field is updated on the User.
*
*   Author                     |Date               |Comment
*   -------------------------|------------------|--------------------------------------------------
*   Saad Wali Jaan    |06.07.2015   |First draft
*
*/
trigger UpdateUTCNameOnUserTrigger on User (after insert, after update) {

    system.debug('UTC0.1');
    List<User> lstUser = new List<User>();
    
    for (User u : trigger.new)
    {
        system.debug('UTC0.2');
        if(((trigger.oldMap != null) && (trigger.oldMap.get(u.id) != trigger.newMap.get(u.id))) || (trigger.oldMap == null)) {
            lstUser.add(U);
            system.debug('UTC0.3 - lstUser = ' + lstUser);
        }
    }
    
    if(lstUser != null && lstUser.size() > 0)
    {
        system.debug('UTC0.4 - lstUser = ' + lstUser);        
        UpdateUTCNameOnUserTriggerHelper.UpdateUser(lstUser, trigger.oldMap, trigger.NewMap);
    }
}