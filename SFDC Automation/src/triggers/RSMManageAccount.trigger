/*
    This trigger update the Account Category based on the Account Classification and Service Level fields: Plus, Plus1 Standard 
*/
trigger RSMManageAccount on Account (before insert, before update, after insert, after update)
{
    if(trigger.isAfter)
    {
        RSMManageAccount_Helper.RSMCCMUpdate(trigger.new, trigger.OldMap);          
    }
    else if(trigger.isBefore)
    {
        RSMManageAccount_Helper.ManageAccountCategory(trigger.new, trigger.oldMap);
        RSMManageAccount_Helper.ValidateAccountLesseNumber(trigger.new, trigger.oldMap);
    }
}