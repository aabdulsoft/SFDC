trigger CaseManagement on Case (before insert, after insert, After update)
{
    // Call the Class method to process newly inserted Cases
    if(trigger.isAfter && trigger.isInsert)
    {
        CaseManagement_Helper.RunAssignmentRuleForMobileLegalRecord(trigger.new);
        CaseManagement_Helper.CreateChatterFeedonInsert(trigger.new);
    }
    // Call the Class method to process updated Cases
    if(trigger.isAfter && trigger.isUpdate)
        CaseManagement_Helper.CreateChatterFeedonUpdate(trigger.new, trigger.oldMap);   
}