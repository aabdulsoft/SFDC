trigger FailedSurvey on Ryder_Surveys__c (before insert, before update) {
//Trigger is fired when Failed CSI Survey workflow is fired
//It is used to send emails to the Account Management Team and create a Task when a Survey is Failed
//Saad Wali Jaan: Created on 04/03/2012.

    string objType = '';
    string surveyId = '';
    string surveyRecordTypeId = '';
    datetime dtIncludeIn360Date;
    datetime dtSurveySubmittionDate;
    boolean bFailedSurvey = false;
    boolean bIncludeInC360 = false;
    boolean bFailedSurveyMailSent = false;
    
    objType = 'Survey';
    
    List<Task> TaskToInsert = new List<Task>();      
    Map<Id,Id> mapSurveyRyderBranch= new Map<Id,Id>();
    Map<Id,boolean> mapRyderBranchInclude = new Map<Id,boolean>();
    Map<Id,datetime> mapRyderBranchIncludeDate = new Map<Id,datetime>();
    
    Map<String, Id> surveyRecordTypes = CommonFunctions.getRecordTypeMap('Ryder_Surveys__c');
    surveyRecordTypeId = surveyRecordTypes.get('CSI_Survey');
    //Get the ryder branches for the ryder surveys
    //to do add record type filter
    for(Ryder_Surveys__c rs: [select Id, Customer_branch__r.Ryder_Branch__c from Ryder_surveys__c where id in :trigger.new])// and RecordTypeId = surveyRecordTypeId])
    {
        if(!mapSurveyRyderBranch.containskey(rs.id)) mapSurveyRyderBranch.put(rs.Id, rs.Customer_branch__r.Ryder_Branch__c);
    }
    //Get the include in 360 flag from ryder branches 
    //to do add record type filter
    for (Ryder_Branch__c rb:[SELECT rb.id, rb.Include_In_360__c, rb.Include_In_360_Date__c FROM Ryder_Branch__c rb WHERE rb.Id in :mapSurveyRyderBranch.values()])
    {
        if(!mapRyderBranchInclude.containskey(rb.id)) mapRyderBranchInclude.put(rb.id, rb.Include_In_360__c);
        if(!mapRyderBranchIncludeDate.containskey(rb.id)) mapRyderBranchIncludeDate.put(rb.id, rb.Include_In_360_Date__c);
    }
    system.debug('Saad - Inside FailedSurvey trigger ');
    for (Ryder_Surveys__c rs: Trigger.new)
    {
        if(rs.RecordTypeId != surveyRecordTypeId) return;
        //Get the ryder branch for the ryder survey from the map
        Id rbId = mapSurveyRyderBranch.get(rs.Id);
        //Get the corresponding include in boolean flag
        bIncludeInC360 = mapRyderBranchInclude.get(rbId)==null?false:mapRyderBranchInclude.get(rbId);
        //Get the corresponding Failed Survey flag
        bFailedSurvey = rs.Failed_Survey__c;
        //Get the date on which the Survey was marked as Failed Survey
        dtIncludeIn360Date = mapRyderBranchIncludeDate.get(rbId)==null?null:mapRyderBranchIncludeDate.get(rbId);
        //Get the Failed Survey Mail Sent Flag
        bFailedSurveyMailSent = rs.Failed_Survey_Email_Sent__c;
        //Get the id of the Survey
        surveyId = rs.Id;
        //Get the submission date of the Survey
        dtSurveySubmittionDate = rs.Survey_Submission_Date__c;
        
        system.debug(' ******* trigger.oldMap = ' + trigger.oldMap);
        system.debug('Trigger.isInsert ' + Trigger.isInsert);
        system.debug('Trigger.isUpdate ' + Trigger.isUpdate);
        
        system.debug('Saad 1 - bIncludeinC360 ' + bIncludeinC360);
		system.debug('Saad 1 - bFailedSurvey = ' + bFailedSurvey);
		system.debug('Saad 1 - dtIncludeIn360Date = ' + dtIncludeIn360Date);
        system.debug('Saad 1 - bFailedSurveyMailSent = ' + bFailedSurveyMailSent);
        system.debug('Saad 1 - dtSurveySubmittionDate = ' + dtSurveySubmittionDate);
        system.debug('Saad 1 - Failed_Survey_Email_Date__c = ' + rs.Failed_Survey_Email_Date__c); 
        		
        if( trigger.oldMap!=null)
        {
            system.debug(' ******* trigger.oldMap rs exists = ' + trigger.oldMap.get(rs.Id));
            system.debug(' ******* trigger.oldMap is Failed Survey = ' + trigger.oldMap.get(rs.Id).Failed_Survey__c);
        }
            
        if(bFailedSurvey && bIncludeinC360 && (dtIncludeIn360Date < dtSurveySubmittionDate) && !bFailedSurveyMailSent && (Trigger.isInsert || (Trigger.isUpdate && (trigger.oldMap==null || (trigger.oldMap!=null && trigger.oldMap.get(rs.Id)!=null && !trigger.oldMap.get(rs.Id).Failed_Survey__c)))))
        {
            system.debug(' ******* Inside Failed Survey Check');
            system.debug('Saad 2 - bIncludeinC360 ' + bIncludeinC360);
			system.debug('Saad 2 - bFailedSurvey = ' + bFailedSurvey);
			system.debug('Saad 2 - dtIncludeIn360Date = ' + dtIncludeIn360Date);
	        system.debug('Saad 2 - bFailedSurveyMailSent = ' + bFailedSurveyMailSent);
	        system.debug('Saad 2 - dtSurveySubmittionDate = ' + dtSurveySubmittionDate);
	        system.debug('Saad 2 - Failed_Survey_Email_Date__c = ' + rs.Failed_Survey_Email_Date__c);
             
            //Getting the email id of the account management team
            GetAcctMngID.GetDetails(rs.id, objType);
            
            //Updating the Failed_Survey_Email_Sent__c flag to true & Failed_Survey_Email_Date__c
	        rs.Failed_Survey_Email_Sent__c = true;
            rs.Failed_Survey_Email_Date__c = system.now();
            
            system.debug('Saad 3 - rs.Failed_Survey_Email_Sent__c = ' + rs.Failed_Survey_Email_Sent__c);
			system.debug('Saad 3 - rs.Failed_Survey_Email_Date__c = ' + rs.Failed_Survey_Email_Date__c);
			
            //Creating a task
            TaskToInsert.add(CreateTask.Care360Task(surveyId));
        }
    }
    //Insert the new tasks if there are any
    if(TaskToInsert != null && TaskToInsert.size()>0) insert TaskToInsert;
}