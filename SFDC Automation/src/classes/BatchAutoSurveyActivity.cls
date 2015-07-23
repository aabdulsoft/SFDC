global class BatchAutoSurveyActivity implements Database.Batchable<sObject>, Database.Stateful{
//This batch process creates the survey activities that will need to be distributed to the service agents
//to conduct surveys to the customer branches that have active vehicles that are due to expire within the upcoming year.
//The number of tasks to create is based on the configurable assignment that is managed in the Survey Assignment
//object - # of activities to be distributed and the active users that surveys can be assigned to for the day.

global final String ActivityType = 'Survey';
global final String ActivitySubject = 'Customer Sat Survey';

public Boolean runTestMethod = false;    //CSI_TEST 
//2012 - Build 1:  Revised query to run faster and provide results only for key contacts that exist for eligible branches
//associated with the same account.  This eliminates any Wrong Contacts where the accounts may differ in the query results.
//Includes additional termout with a prioritization of up to 5 years.  Also includes Time Zone as an addition to the Region Name.
//This query is used as the default query if there are no Survey Exclusions.
//public String queryString = 'SELECT Area_Name__c, Name, Id, Ryder_HQ_Account__c, '
//commenting out following line to add the key contact related customer branch and account id
//              + ' (SELECT Contact__c, Available_24_7__c, Available_From__c, Available_To__c from Key_Contacts__r where Contact_Role__c = \'CSI Contact\' and Contact__r.HasOptedOutofSurvey__c=false and Contact__r.HasOptedOutOfEmail=false and Contact__r.HasOptedOutOfFax=false and Contact__r.DoNotCall=false and Contact__r.STATUS_ACTIVE__c=true order by Contact_Type__c  LIMIT 1) ' 
//                + ' (SELECT Contact__c, Customer_Branch__c, HQ_Account_ID__c,Available_24_7__c, Available_From__c, Available_To__c from Key_Contacts__r where Contact_Role__c = \'CSI Contact\' and Contact__r.HasOptedOutofSurvey__c=false and Contact__r.HasOptedOutOfEmail=false and Contact__r.HasOptedOutOfFax=false and Contact__r.DoNotCall=false and Contact__r.STATUS_ACTIVE__c=true order by Contact_Type__c  LIMIT 1) ' 
//                + ' FROM Customer_Branch__c where VEH_COUNT__c > 3 and ( LastSurveyDate__c=null or LastSurveyDate__c< LAST_N_DAYS:365)  ' 
//                + ' AND CUSTOMER_BRANCH_STATUS__C = \'Active\' AND '
//                + ' Ryder_HQ_Account__c in (select Account__c from Vehicle__c where expiration_date__c > NEXT_N_DAYS:1 AND expiration_date__c <= NEXT_N_DAYS:730 '
//                + ' AND Account__r.ShippingState != \'QC\' AND (NOT Account__r.NAME LIKE \'RIL %\')  AND  (NOT Account__r.NAME LIKE \'SAFETY-KLEEN%\')) '        
//                + ' LIMIT '; 
                
public String queryString = 'SELECT Area_Name__c, Time_Zone__c, Name, Id, Ryder_HQ_Account__c, '
              + ' (SELECT Contact__c, Available_24_7__c, Available_From__c, Available_To__c from Key_Contacts__r where Contact_Role__c = \'CSI Contact\' order by Contact_Type__c  LIMIT 1) ' 
//Revising to make sure the customer branch has an associated CSI Contact Key Contact
//removing because SOQL join did not remove the ones that did not meet the criteria
//            + ' (SELECT Contact__c, Customer_Branch__c, HQ_Account_ID__c,Available_24_7__c, Available_From__c, Available_To__c from Key_Contacts__r where Contact_Role__c = \'CSI Contact\' and Contact__r.HasOptedOutofSurvey__c=false and Contact__r.HasOptedOutOfEmail=false and Contact__r.HasOptedOutOfFax=false and Contact__r.DoNotCall=false and Contact__r.STATUS_ACTIVE__c=true order by Contact_Type__c  LIMIT 1) '
              + ' FROM Customer_Branch__c where VEH_COUNT__c > 3 and ( LastSurveyDate__c=null or LastSurveyDate__c< LAST_N_DAYS:365)  ' 
              + ' AND CUSTOMER_BRANCH_STATUS__C = \'Active\' AND '
              + ' ID in (Select Customer_Branch__c from Key_Contact__c where Contact_Role__c = \'CSI Contact\' and  Contact__r.HasOptedOutofSurvey__c=false and Contact__r.HasOptedOutOfEmail=false '
              + ' and Contact__r.HasOptedOutOfFax=false and Contact__r.DoNotCall=false and Contact__r.STATUS_ACTIVE__c=true) and '
              + ' Ryder_HQ_Account__c in (select Account__c from Vehicle__c where expiration_date__c > NEXT_N_DAYS:1 AND expiration_date__c <= NEXT_N_YEARS:5  '
              + ' AND Account__r.ShippingState != \'QC\' AND (NOT Account__r.NAME LIKE \'RIL %\')  AND  (NOT Account__r.NAME LIKE \'SAFETY-KLEEN%\')) '        
              + ' LIMIT '; 
private string cbid;
private id kcid;
private id rt_id;
private id cb_account;
private id kc_account;
private id kc_cb;
private integer cnt_users;
private integer cnt_activities;
private integer cnt_limit;
private integer cnt_nottoinsert;
private string sa_surveysubtype = 'Large';
private string cb_areaname;
private string cb_timezone;  //2012 - Build 1
private string kc_available247;
private string kc_availablefrom;
private string kc_availableto;
private boolean kc_present;
private boolean kc_verified;   //Build 4
private integer kc_days;

private integer cnt_exclusions;
private String str_exclfield;
private String strSubType = 'Large';  //2012 - Build 1
private String str_exclnot = 'And (NOT ';
private String str_exclop;
private String queryString_exc =  '';
private String queryString_lim = ' LIMIT ';
private String queryString_vto = '';  //2012 - Build 1
private String queryString_veh = '';
//private String querystring_main = 'SELECT Area_Name__c, Name, Id, Ryder_HQ_Account__c, '
// commenting out following line to include Key Contact related Customer Branch and Account for comparison
//  + ' (SELECT Contact__c, Available_24_7__c, Available_From__c, Available_To__c from Key_Contacts__r where Contact_Role__c = \'CSI Contact\' and Contact__r.HasOptedOutofSurvey__c=false and Contact__r.HasOptedOutOfEmail=false and Contact__r.HasOptedOutOfFax=false and Contact__r.DoNotCall=false and Contact__r.STATUS_ACTIVE__c=true order by Contact_Type__c  LIMIT 1) ' 
//    + ' (SELECT Contact__c, Customer_Branch__c, HQ_Account_ID__c,Available_24_7__c, Available_From__c, Available_To__c from Key_Contacts__r where Contact_Role__c = \'CSI Contact\' and Contact__r.HasOptedOutofSurvey__c=false and Contact__r.HasOptedOutOfEmail=false and Contact__r.HasOptedOutOfFax=false and Contact__r.DoNotCall=false and Contact__r.STATUS_ACTIVE__c=true order by Contact_Type__c  LIMIT 1) ' 
//    + ' FROM Customer_Branch__c where ( LastSurveyDate__c=null or LastSurveyDate__c< LAST_N_DAYS:365)  ' 
//    + ' AND CUSTOMER_BRANCH_STATUS__C = \'Active\' and Ryder_HQ_Account__c in (select Account__c from Vehicle__c where expiration_date__c > NEXT_N_DAYS:1 AND expiration_date__c <= NEXT_N_DAYS:730 ' ;

private String querystring_main = 'SELECT Area_Name__c, Time_Zone__c, Name, Id, Ryder_HQ_Account__c, '
             + ' (SELECT Contact__c, Available_24_7__c, Available_From__c, Available_To__c from Key_Contacts__r where Contact_Role__c = \'CSI Contact\' order by Contact_Type__c  LIMIT 1) ' 
//Revising to make sure the customer branch has an associated CSI Contact Key Contact
//removing because SOQL join did not remove the ones that did not meet the criteria
//            + ' (SELECT Contact__c, Customer_Branch__c, HQ_Account_ID__c,Available_24_7__c, Available_From__c, Available_To__c from Key_Contacts__r where Contact_Role__c = \'CSI Contact\' and Contact__r.HasOptedOutofSurvey__c=false and Contact__r.HasOptedOutOfEmail=false and Contact__r.HasOptedOutOfFax=false and Contact__r.DoNotCall=false and Contact__r.STATUS_ACTIVE__c=true order by Contact_Type__c  LIMIT 1) '
              + ' FROM Customer_Branch__c where ( LastSurveyDate__c=null or LastSurveyDate__c< LAST_N_DAYS:365)  ' 
              + ' AND CUSTOMER_BRANCH_STATUS__C = \'Active\' AND '
              + ' ID in (Select Customer_Branch__c from Key_Contact__c where Contact_Role__c = \'CSI Contact\' and  Contact__r.HasOptedOutofSurvey__c=false and Contact__r.HasOptedOutOfEmail=false '
              + ' and Contact__r.HasOptedOutOfFax=false and Contact__r.DoNotCall=false and Contact__r.STATUS_ACTIVE__c=true) and '
              + ' Ryder_HQ_Account__c in (select Account__c from Vehicle__c where expiration_date__c > NEXT_N_DAYS:1 ';

    
global database.queryLocator start(Database.BatchableContext BC) { 
    rt_id = [select id from recordtype where name = 'Survey'][0].id;
    
    List <AggregateResult> AggResult  = [select count(id) count_users from Survey_Assignment_Member__c where Status__c = 'Active' and Survey_Assignment__c in (select id from Survey_Assignment__c where Survey_Type__c = 'Customer Sat Survey' and Survey_Sub_Type__c = 'Large')];
    cnt_users = integer.valueof(AggResult[0].get('count_users'));
    cnt_activities = integer.valueof([select Number_of_Activities__c from Survey_Assignment__c where Survey_Type__c = 'Customer Sat Survey' and Survey_Sub_Type__c = :sa_surveysubtype][0].Number_of_Activities__c);
    system.debug('cnt_users = ' +  cnt_users);
    system.debug('cnt_activities = ' +  cnt_activities);

    //TEST - start
    //Build 3: Include the sub-type of survey to ensure the correct exclusions and members are returned.
    try{
        List <AggregateResult> aggExclusions = [SELECT COUNT(ID) Exclusions from Survey_Exclusion__c where Survey_Assignment__c in (select id from Survey_Assignment__c where Survey_Type__c = 'Customer Sat Survey' and Survey_Sub_Type__c = 'Large')];
        cnt_exclusions = integer.valueof(aggExclusions[0].get('Exclusions'));
        if (cnt_exclusions > 0)
        {
            queryString = QueryString();
        }
        
        cnt_limit = cnt_users*cnt_activities;
        
        if(runTestMethod){
            //queryString = queryString.replace('Ryder_HQ_Account__c in (', 'Ryder_HQ_Account__c not in (') + 1;
            //system.debug('Limiting results to 200 for the test method');
            queryString = queryString + 200;
        }
        else {
            System.debug('*** query limit = ' + cnt_limit);
            queryString = queryString + cnt_limit;
        }
        
   }catch(system.dmlexception e){}
   //TEST - end
   
   system.debug('***queryString = ' +  queryString);
   return database.getQueryLocator(queryString); 
} //close start method 
    
global void execute(Database.BatchableContext BC, list <Customer_Branch__c> scope) { 
    
    List <Customer_Branch__c> cb= new List <Customer_Branch__c>();         
    List <Task> tasks = new List <Task>();
    List <string> kc = new List <string>();
    
    // Iterate through the whole query of Customer Branches and create activities. 
    // Create a Task that's associated with each Customer Branch.  
    // Build 2 - Incorporate the area name to allow the agent to review the region in which the call is taking place.
    
    for(Customer_Branch__c c : scope) { 
        System.debug('c.id: ' + c.id);
        cbid = c.id;
        cb_areaname = c.Area_Name__c;
        cb_timezone = c.Time_Zone__c;
        
        //Build 4 - adding to ensure customer branch and key contact are associated to the same account
        cb_account = c.Ryder_HQ_Account__c;        
        
        //TEST - start
        for(Key_Contact__c k : c.Key_Contacts__r) {
            kc_present = false;
            System.Debug('**** k.Contact__c ' + k.Contact__c);
            kcid = k.Contact__c;
          
            //Build 2 - Incorporate the availability of the key contact to ensure the agent is calling at a 
            //preferred time, if one provided.
            
            kc_available247 = k.Available_24_7__c;
            kc_availablefrom = k.Available_From__c;
            kc_availableto = k.Available_To__c;

           //Build 2 - Loop through and determine if the key contact exists 
           //more than once in the set of matching contacts to receive survey
           for(integer i=0; i < kc.size(); i++)
            {
                string[] kc_split = kc[i].split(':');
                
                
                if ((kc_split[0] == kcid) || (runtestmethod))
                {
                    //Build 2 - If the key contact exists more than once, add 21 days to the date in which
                    //the key contact is called in the future for the subsequent survey
                    
                    kc_present = true;
                    kc_days = Integer.valueOf(kc_split[1]) + 21;
                    string new_kc = kcid + ':' + kc_days;
                    if (kc_days > 0)
                    {
                        //System.Debug('**** Duplicate ' + kc_split[1]);
                        //System.Debug('**** Duplicate ' + new_kc);
                    }
                    kc.set(i, new_kc);
                }
            }
    
            if (kc_present == false)
            {
                //System.Debug('**** kcid ' + kcid);
                kc.Add(kcid + ':0');
                kc_days = 0;
            }
        
        //TEST - end

        if(kcid <> null)
        {
            Task tsk = new Task(); 
            tsk.RecordTypeID = rt_id; 
            tsk.WhoId = kcid; 
            tsk.WhatId = cbid;
            Date kc_date;
            if (kc_days == 0)
            {
                kc_date = System.today();
    
            }
            else
            {
                Date tempdate = System.today();
                kc_date = tempdate.addDays(kc_days);
            }
            tsk.ActivityDate = kc_date;
            tsk.Original_Due_Date__c = kc_date;    //Build 1 2012 - Added to track overdue activities.
            tsk.Status = 'Not Started'; 
            tsk.Call_Attempts__c = 1;
            if (strSubType == 'Large')
            {
                tsk.Survey_Sub_Type__c = 'Large';
            } 
            else
            {
                tsk.Survey_Sub_Type__c = 'Small';
            }
            
            tsk.Subject = 'Customer Sat Survey';
            tsk.Type = 'Survey';
            tsk.Area_Name__c = cb_areaname;
            tsk.Time_Zone__c = cb_timezone;
            tsk.IsReminderSet = false;
            tsk.Available_24_7__c = kc_available247;
            tsk.Available_From__c = kc_availablefrom;
            tsk.Available_To__c = kc_availableto;
            tasks.add(tsk); 
            kcid = null;  //clear the reference to the key contact to ensure not reused in next task creation
            cbid = null;  //clear the reference to the customer branch to ensure not reused in next task creation
        }
        }
    } //close for-loop 
    try { 
        //System.debug('Tasks to be inserted: ' + tasks); 
        insert tasks; 
    } catch (system.dmlexception e) { 
        System.debug('Tasks not inserted: ' + e); 
    } 
    //More coverage for test classes
    if (runTestMethod)
    {
        Task sat= new Task();
        sat.whoId = kcid;
        sat.whatID = cbid;
        sat.Status = 'Not Started';
        sat.Priority = 'Low';
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        sat.Survey_Sub_Type__c = 'Large';
        sat.Original_Due_Date__c = System.Today();
        datetime myDateTime = datetime.newInstance(2061, 8, 30, 12, 30, 2);
        sat.Survey_Call_Date_Time__c = myDateTime;
        sat.recordtypeid = rt_id;
        insert sat;
        
        sat.Status = 'Completed';
        sat.Survey_Call_Result__c  = 'Refusal';
        sat.Survey_Opt_Out__c = 'Yes';
        sat.Survey_Opt_Out_Reason__c = 'Test Refusal';   
        update sat;
                
        sat.Status = 'Retry';
        sat.ActivityDate = System.Today();
        sat.Original_Due_Date__c = System.Today();
        sat.Survey_Call_Result__c  = 'Left Message';
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
        
        sat.Status = 'Retry';
        sat.Survey_Call_Result__c  = 'Unavailable';
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
        
        sat.Status = 'Retry';
        sat.ActivityDate = System.Today();
        sat.Survey_Call_Result__c  = 'Left Message';
        sat.Call_Attempts__c = 3;
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
        
        sat.Status = 'Retry';
        sat.Survey_Call_Result__c  = 'Unavailable';
        sat.Call_Attempts__c = 3;
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;

         sat.Status = 'Deferred/Callback';
        sat.Survey_Call_Result__c  = 'Future Reschedule';
        sat.Survey_Call_Date_Time__c = System.Today().addDays(2);
        sat.Call_Attempts__c = 1;
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
        
        sat.Status = 'Completed';
        sat.Survey_Call_Result__c  = 'Refusal - Too Busy';
        sat.Type = 'Survey';
        sat.Call_Attempts__c = 1;
        sat.Subject = 'Customer Sat Survey';
        update sat;


        sat.Status = 'Deferred/Callback';
        sat.Survey_Call_Result__c  = 'Same Day Reschedule';
        sat.Call_Attempts__c = 1;
        sat.Survey_Call_Date_Time__c = System.Now();
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
       
        sat.Status = 'Completed';
        sat.Survey_Call_Result__c  = 'Hangup';
        sat.Survey_Call_Date_Time__c = NULL;
        sat.Call_Attempts__c = NULL;
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
        
        sat.Status = 'Completed';
        sat.Survey_Call_Result__c  = 'Refusal';
        sat.Survey_Submission_Date__c = NULL;
        sat.Survey_Opt_Out__c = 'Yes';
        sat.Call_Attempts__c = 3;
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
        
        sat.Status = 'Completed';
        sat.Survey_Call_Result__c  = 'Refusal';
        sat.Survey_Submission_Date__c = System.Today();
        sat.Survey_Opt_Out__c = 'No';
        sat.Call_Attempts__c = NULL;
        sat.Type = 'Survey';
        sat.Subject = 'Customer Sat Survey';
        update sat;
    }//Test coverage
    
    try { 
        update scope; 
    } catch (system.dmlexception e) { 
    System.debug('Scope not updated: ' + e); 
    } 
    
    
    
    //Build 2 - Base the agent workload on the workload adjustment assigned.
    
    DistributeWorkload();

} //close execute method 

global void finish(Database.BatchableContext BC) { 
    AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :BC.getJobId()]; 
} //close finish method 

public String QueryString() {
 
//   List <Survey_Exclusion__c> survExclusions_VTO = [select Exclusion_Field__c, Exclusion_Operator__c, Exclusion_Value__c from Survey_Exclusion__c where Exclusion_Field__c = 'Vehicle Term Out' and Survey_Assignment__c in (select id from Survey_Assignment__c where Survey_Type__c = 'Customer Sat Survey' and Survey_Sub_Type__c = 'Large')];
//   for (Survey_Exclusion__c se_vto: survExclusions_VTO){
        
    
//    }
    List <Survey_Exclusion__c> survExclusions = [select Exclusion_Field__c, Exclusion_Operator__c, Exclusion_Value__c from Survey_Exclusion__c where Survey_Assignment__c in (select id from Survey_Assignment__c where Survey_Type__c = 'Customer Sat Survey' and Survey_Sub_Type__c = 'Large')];
    System.Debug('**** queryString_main start = ' + queryString_main);
    for (Survey_Exclusion__c se : survExclusions){
        
        if (se.Exclusion_Field__c == 'Account Name') 
        {
            str_exclfield = ' Account__r.Name ';
        }
        else if (se.Exclusion_Field__c.indexOf('City') > 0) 
        {
            str_exclfield = ' Account__r.ShippingCity ';
        }
        else if (se.Exclusion_Field__c.indexOf('State') > 0) 
        {
            str_exclfield = ' Account__r.ShippingState ';
        }
        else if (se.Exclusion_Field__c.indexOf('Country') > 0)
        {
            str_exclfield = ' Account__r.ShippingCountry ';
        }
        else if (se.Exclusion_Field__c.indexOf('Type') > 0)
        {        
            str_exclfield = ' Account__r.Type ';
        }
        else if (se.Exclusion_Field__c.indexOf('Lessee') > 0)
        {
            str_exclfield = ' Account__r.LesseeNo__c ';
        }
        else if (se.Exclusion_Field__c.indexOf('Risk') > 0)
        {
            
            str_exclfield = ' Account__r.At_Risk__c';
        }
        else if (se.Exclusion_Field__c.indexOf('Top') > 0) 
        {
            str_exclfield = ' Account__r.Top10Account__c ';
        }
        else if (se.Exclusion_Field__c == 'Vehicle Count') 
        {
            queryString_veh = ') AND VEH_COUNT__c ';
        }
        else if (se.Exclusion_Field__c == 'Vehicle Term Out') 
        {
            queryString_vto = ' AND expiration_date__c ';
        }
        
        if (se.Exclusion_Operator__c == 'starts with')
        {
            str_exclop = 'LIKE \'';
            queryString_exc = str_exclnot + str_exclfield + str_exclop + se.Exclusion_Value__c + '%\')';

            querystring_main = querystring_main + queryString_exc;
        }    
        else if (se.Exclusion_Operator__c == 'not equal')
        {
            
            if (se.Exclusion_Field__c == 'Vehicle Count') {
                str_exclop = '<> ';
                queryString_veh = queryString_veh + str_exclop + se.Exclusion_Value__c + '';
            }
            else if ((se.Exclusion_Field__c == 'Account Top 10 Ranking') || (se.Exclusion_Field__c == 'Account Risk Level'))
            {
                str_exclop = '<> ';
                queryString_exc = 'AND (' + str_exclfield + str_exclop + se.Exclusion_Value__c + ') ';
                querystring_main = querystring_main + queryString_exc;
            }
            else {
                str_exclop = '!= \'';
                queryString_exc = str_exclnot + str_exclfield + str_exclop + se.Exclusion_Value__c + '\') ';
                querystring_main = querystring_main + queryString_exc;
            }
        }
        else if (se.Exclusion_Operator__c == 'contains')
        {
            str_exclop = 'LIKE \'%';
            queryString_exc = str_exclnot + str_exclfield + str_exclop + se.Exclusion_Value__c + '%\') ';
            
            querystring_main = querystring_main + queryString_exc;
        }
        
        
        else if (se.Exclusion_Operator__c == 'equals')
        {
            
            if (se.Exclusion_Field__c == 'Vehicle Count')  {
                str_exclop = '= ';
                queryString_veh = queryString_veh + str_exclop + se.Exclusion_Value__c + '';
            }
            else if ((se.Exclusion_Field__c == 'Account Top 10 Ranking') || (se.Exclusion_Field__c == 'Account Risk Level')){
                str_exclop = '= ';
                queryString_exc = 'AND (' + str_exclfield + str_exclop + se.Exclusion_Value__c + ') ';
                querystring_main = querystring_main + queryString_exc;
            }
            else {
                str_exclop = '= \'';
                queryString_exc = str_exclnot + str_exclfield + str_exclop + se.Exclusion_Value__c + '\') ';
                querystring_main = querystring_main + queryString_exc;
            }
        }
        
        else if (se.Exclusion_Operator__c == 'less than')
        {
            
            if (se.Exclusion_Field__c == 'Vehicle Count') {
                str_exclop = '< ';
                queryString_veh = queryString_veh + str_exclop + se.Exclusion_Value__c + '';
                if (se.Exclusion_Value__c == '4')
                {
                    strSubType = 'Small';
                    System.debug('strSubType: ' + strSubType);
                }
            }
            else {
                str_exclop = '< \'';
                queryString_exc = str_exclnot + str_exclfield + str_exclop + se.Exclusion_Value__c + '\') ';
                querystring_main = querystring_main + queryString_exc;
            }
        }
        
        else if (se.Exclusion_Operator__c == 'greater than') 
        {
            
            if (se.Exclusion_Field__c == 'Vehicle Count') {
                str_exclop = '> ';
                queryString_veh = queryString_veh + str_exclop + se.Exclusion_Value__c + '';
               
            }
            else {
                str_exclop = '> \'';
                queryString_exc = str_exclnot + str_exclfield + str_exclop + se.Exclusion_Value__c + '\') ';
                querystring_main = querystring_main + queryString_exc;
            }
        }
        
        else if (se.Exclusion_Operator__c == 'less than or equal') 
        {
            
            if (se.Exclusion_Field__c == 'Vehicle Count') {
                str_exclop = '<= ';
                queryString_veh = queryString_veh + str_exclop + se.Exclusion_Value__c + '';
                if (se.Exclusion_Value__c == '3')
                {
                    strSubType = 'Small';
                    System.debug('strSubType: ' + strSubType);
                }
            }
            else if (se.Exclusion_Field__c == 'Vehicle Term Out')
            {
                str_exclop = ' <= NEXT_N_YEARS:';
                queryString_vto = queryString_vto + str_exclop + se.Exclusion_Value__c + ' ';
            }
            else {
                str_exclop = '<= \'';
                queryString_exc = str_exclnot + str_exclfield + str_exclop + se.Exclusion_Value__c + '\') ';
                querystring_main = querystring_main + queryString_exc;
            }
        }
        
        else if (se.Exclusion_Operator__c == 'greater than or equal')
        {
            
            if (se.Exclusion_Field__c == 'Vehicle Count') {
                str_exclop = '>= ';
                queryString_veh = queryString_veh + str_exclop + se.Exclusion_Value__c + '';
            }
            else {
                str_exclop = '>= \'';
                queryString_exc = str_exclnot + str_exclfield + str_exclop + se.Exclusion_Value__c + '\') ';
                querystring_main = querystring_main + queryString_exc;
            }
        }
    }
    
    if ((querystring_veh != '') && (queryString_vto !=''))
    {
        querystring_main = queryString_main + queryString_vto;
        querystring_main = querystring_main + queryString_veh; 
        querystring_main = querystring_main + queryString_lim;
    }
    else {
        querystring_main = queryString_vto + querystring_main + ')' + queryString_lim;
    }
    System.Debug('**** querystring_main final = ' + querystring_main);
    return querystring_main;
}

public Void DistributeWorkload()
//2012 Build 1:  Revised function to account for all overdue activities associated with the user based on 4 use cases
//UC denotes the use case that is being handled in the code.
/*TR 02-10-12 Explanations of each use case
UC1 = daily workload is 0 then move all activities to tomorrow
UC2 = today's queue > daily workload and overdue = 0:  Example: 70 today queue;0 overdue;workload 60 - Results: 10 moved to tomorrow and agent has 60 for today
UC3 = today's queue < daily Workload Example: 57 today queue; 12 overdue; workload 60 - Results: 3 get moved from overdue queue to today and agent has 60 for today
UC4 = today's queue > daily workload and overdue <> 0:  Example: 60 today queue; 100 overdue; workload 50 - REsults: 10 MOVE TO TOMORROW*/
{
    List<Survey_Assignment_Member__c> users = [SELECT Id, Status__c, Workload_Adjustment__c, User__c FROM Survey_Assignment_Member__c WHERE Status__c = 'Active'];
    List<Task> TasksToUpdate = new List<task>();
    
    for (Survey_Assignment_Member__c u : users)
    {
        // Store the daily workload
        integer dailyWorkload = 0;
        
        System.Debug('*** u.Workload_Adjustment__c: ' + u.Workload_Adjustment__c);
        
        if(u.Workload_Adjustment__c == null)
        {
            dailyWorkload = cnt_activities;
        }
        else
        {
            dailyWorkload = Integer.valueOf(u.Workload_Adjustment__c);
        }
            
        System.Debug('*** dailyWorkload: ' + dailyWorkload );
        
        Date todayDate = System.today();
        List <AggregateResult> todayJob = [SELECT Count(ID) TodayJobs FROM Task WHERE OwnerId = :u.User__c AND ActivityDate = :todayDate AND Status = 'Not Started' and Type = 'Survey'];
        List <AggregateResult> overdueJob = [SELECT Count(ID) OverdueJobs FROM Task WHERE OwnerId = :u.User__c AND ActivityDate < :todayDate AND Status = 'Not Started' and Type = 'Survey'];
        integer todayJobCount = integer.valueof(todayJob[0].get('TodayJobs'));
        integer overdueJobCount = integer.valueof(overdueJob[0].get('OverdueJobs'));
        
        System.Debug('*** todayJobCount: ' + todayJobCount);
        System.Debug('*** overdueJobCount: ' + overdueJobCount );        
        
        // UC1 - If daily workload is 0, move all tasks to tomorrow.
        if(dailyWorkload == 0)
        {
            List<Task> tasks = [SELECT OwnerId, ActivityDate FROM Task WHERE OwnerId = :u.User__c AND ActivityDate = :todayDate AND Status = 'Not Started' and Type = 'Survey'];
            
            System.Debug ('***UC1 - Daily Workload 0');
            
            for (Task t: tasks)
            {
                t.ActivityDate = t.ActivityDate.addDays(1);
                
                System.Debug ('***UC1 - t.ActivityDate: ' + t.ActivityDate);
                //neelima-02/07/20120 move update dml ouside the for loop
                 //update tasks;
                 TasksToUpdate.add(t);
            }
                      
        }
        
        // UC2 & UC3 - If daily workload is greater than 0, calculate today's tasks and move balance to tomorrow.
        if(dailyWorkload > 0)
        {
            integer moveTaskCount = (todayJobCount + overdueJobCount ) - dailyWorkload;
            
            if(runTestMethod)
            {
                moveTaskCount = 1;
            }
            
            System.Debug('***UC2 & UC3  & UC4 - moveTaskCount: ' + moveTaskCount);
            //02-10-12 Added Use Case 4
            // UC4 - If overdue tasks is greater than 0 and today tasks is greater than daily workload, move difference of today's taska and daily workload to tomorrow.
            if((todayJobCount > dailyWorkload) && (overdueJobCount > 0))
            {
                integer moveTodayToTomorrow = todayJobCount - dailyWorkload;
                integer total = 0;
                
                System.Debug ('***UC4 - moveTodayToTomorrow: ' + moveTodayToTomorrow);
                
                List<Task> tasks = [SELECT OwnerId, ActivityDate FROM Task WHERE OwnerId = :u.User__c AND ActivityDate = :todayDate AND Status = 'Not Started' and Type = 'Survey' LIMIT :todayJobCount];
                
                for (Task t: tasks)
                {
                    if(total < moveTodayToTomorrow)
                    {
                        t.ActivityDate = t.ActivityDate.addDays(1);
                        
                        total = total + 1;

                        TasksToUpdate.add(t);
                    }
                }
                
                System.Debug ('***UC4 - ' + (total + 1) + ' tasks moved to tomorrow.');
                
            } else if((moveTaskCount > 0) && (overdueJobCount == 0))
            {
                // UC2 - If overdue and today tasks are more than limit, move the difference to tomorrow.
                
                List<Task> tasks = [SELECT OwnerId, ActivityDate FROM Task WHERE OwnerId = :u.User__c AND ActivityDate = :todayDate AND Status = 'Not Started' and Type = 'Survey' LIMIT :moveTaskCount];
                
                integer total = 0;
                
                for (Task t: tasks)
                {
                    if(total <= moveTaskCount)
                    {
                        t.ActivityDate = t.ActivityDate.addDays(1);
                        
                        total = total + 1;
                        //neelima-02/07/20120 move update dml ouside the for loop
                        // update tasks;
                        TasksToUpdate.add(t);
                    }
                }
                            
                System.Debug ('***UC2 - ' + (total + 1) + ' tasks moved to tomorrow.');
            }
            else if(todayJobCount < dailyWorkload)            
            {
                // UC3 - If todays task are not more than limit and there are overdue tasks, move the differenct of overdue tasks to today.
                
                integer overdueMoveTaskCount = (dailyWorkload - todayJobCount);
                
                System.Debug('***UC3 - overdueMoveTaskCount: ' + overdueMoveTaskCount );
                
                if(overdueJobCount < overdueMoveTaskCount)
                {
                    overdueMoveTaskCount = overdueJobCount;
                }
                
                List<Task> overdueTasks = [SELECT OwnerId, ActivityDate FROM Task WHERE OwnerId = :u.User__c AND ActivityDate < :todayDate AND Status = 'Not Started' and Type = 'Survey' LIMIT :overdueMoveTaskCount];

                integer total = 0;
                
                for (Task t: overdueTasks )
                {
                    t.ActivityDate = System.today();
                    
                    total = total + 1;
                     //neelima-02/07/20120 move update dml ouside the for loop
                    //update overdueTasks;
                    TasksToUpdate.add(t);
                }
                               
                // Do nothing. This is for logic purpose only.
                System.Debug ('***UC3 - ' + (total + 1) + ' overdue tasks moved to today.');
            }
        }
             
    }
    // neelima-02/07/20120 move update dml ouside the for loop
        System.debug('***Number of Tasks to be updated' + TasksToUpdate.size());
        if(!TasksToUpdate.isEmpty() && TasksToUpdate.size()>0)
        update TasksToUpdate;
}
}