trigger calcBusinessHours on Task (before insert, before update) {
// Ensures all tasks that are created for surveys are associated to working days (including non-holidays)
BusinessHours stdBusinessHours = [select id from businesshours where isDefault = true];

for (Task t : Trigger.new) {
if ((t.ActivityDate != NULL) && (stdBusinessHours != NULL) && (t.Status == 'Not Started') && (t.Subject == 'Customer Sat Survey') && (t.Type == 'Survey')) {

Date dToday = t.ActivityDate;
Datetime dt = datetime.newInstance(dToday.year(), dToday.month(),dToday.day());

// Agents normally work Monday - Friday except holidays according to the Company Hours.  
if (t.Survey_Call_Date_Time__c != NULL)
{
    Datetime dt_scdt = datetime.newInstance(t.Survey_Call_Date_Time__c.year(), t.Survey_Call_Date_Time__c.month(),t.Survey_Call_Date_Time__c.day(),t.Survey_Call_Date_Time__c.hour(),t.Survey_Call_Date_Time__c.minute(), t.Survey_Call_Date_Time__c.second());
    t.Survey_Call_Date_Time__c = BusinessHours.add (stdBusinessHours.id, dt_scdt, 24 * 60 * 1000L);
    t.ActivityDate = date.newinstance(BusinessHours.add (stdBusinessHours.id, dt_scdt, 24 * 60 * 1000L).year(), BusinessHours.add (stdBusinessHours.id, dt_scdt, 24 * 60 * 1000L).month(),BusinessHours.add (stdBusinessHours.id, dt_scdt, 24 * 60 * 1000L).day());
} else {
    t.ActivityDate = date.newinstance(BusinessHours.add (stdBusinessHours.id, dt, 23 * 60 * 1000L).year(), BusinessHours.add (stdBusinessHours.id, dt, 23 * 60 * 1000L).month(),BusinessHours.add (stdBusinessHours.id, dt, 23 * 60 * 1000L).day());
}
  //Build 1 2012  - Provide the original due date

if ((dt != NULL) && (t.CreatedDate != NULL)){
    if (dt == datetime.newInstance(t.CreatedDate.year(), t.CreatedDate.month(),t.CreatedDate.day()))
    {
        t.Original_Due_Date__c = date.newinstance(BusinessHours.add (stdBusinessHours.id, dt, 23 * 60 * 1000L).year(), BusinessHours.add (stdBusinessHours.id, dt, 23 * 60 * 1000L).month(),BusinessHours.add (stdBusinessHours.id, dt, 23 * 60 * 1000L).day());
    }
}
}
}
}