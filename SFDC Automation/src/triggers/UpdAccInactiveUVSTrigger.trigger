/**
* 
*   Trigger assigns SalesAdmin as the owner of the Account, deletes the 
*   AccountTeamMember when a UVS user marks the Account as Inactive
*
*   Author           |Author-Email                      |Date       |Comment
*   -----------------|----------------------------------|-----------|--------------------------------------------------
*   Saad Wali Jaan   |                                  |01.13.2015 |First draft
*
*/

trigger UpdAccInactiveUVSTrigger on Account (after update) {
    
    if(trigger.isAfter)
    {
        //RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
        UpdAccInactiveUVSTriggerHelper.UpdateAccount(trigger.new, trigger.oldMap);
    }
}