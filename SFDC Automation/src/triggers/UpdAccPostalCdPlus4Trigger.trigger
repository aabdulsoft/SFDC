/**
* 
*   Trigger updates the values of PostalCode_No_Plus_4__c field when a new account
*   is created or the Physical Zip Code (ShippingPostalCode) is updated
*
*   Author           |Author-Email                      |Date       |Comment
*   -----------------|----------------------------------|-----------|--------------------------------------------------
*   Saad Wali Jaan   |                                  |12.10.2014 |First draft
*
*/

trigger UpdAccPostalCdPlus4Trigger on Account (after update) {
    
    if (RyderGlobalVariables.firstRun == true)
    {
        if(trigger.isAfter)
        {
            RyderGlobalVariables.firstRun = false;
            UpdAccPostalCdPlus4TriggerHelper.UpdateAccount(trigger.new, trigger.oldMap);
        }
    }
}