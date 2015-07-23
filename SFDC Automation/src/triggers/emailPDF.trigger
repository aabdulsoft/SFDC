trigger emailPDF on Ryder_Surveys__c (before insert,before update) {
    
    string userId = '';
    string activityId = '';
    boolean surveyDetailsLoaded = true;
    boolean surveyDetailsLoadedOld;
    Set<String> lActivityIds = new Set<String>();
    for (Ryder_Surveys__c rs : Trigger.new)
    {
    	lActivityIds.add(rs.Activity_ID__c);
    } 
	List<Task> surveyActivities = [SELECT Id, Type, Survey_Sub_Type__c FROM Task WHERE Id =: lActivityIds and Type = 'Survey' and Survey_Sub_Type__c in ('Large', 'Small')];
    system.debug('*****total large survey activities = ' + surveyActivities.size());
    for (Ryder_Surveys__c rs : Trigger.new)
    {
    	boolean bSendEmail = false;
        if(Trigger.isInsert)surveyDetailsLoadedOld=false;
        else if(Trigger.isUpdate) surveyDetailsLoadedOld = trigger.oldMap.get(rs.Id).Survey_Details_Loaded__c;

        activityId = rs.Activity_ID__c;
        surveyDetailsLoaded = boolean.valueOf(rs.Survey_Details_Loaded__c);
        //List<Task> surveyActivities = [SELECT Id, Type, Survey_Sub_Type__c FROM Task WHERE Id =: rs.Activity_ID__c and Type = 'Survey' and Survey_Sub_Type__c = 'Large'];
        
        system.debug('*****rs.Activity_ID__c = ' + rs.Activity_ID__c);
        system.debug('*****rs.Survey_Details_Loaded__c = ' + rs.Survey_Details_Loaded__c);
        //userId = rs.Customer_Branch__r.Customer_Branch_Owner__c;
        // neelima-02/15/2011- moved the following logic inside the for loop, aslo send auto email only if pdf emailed flag is false.
        //raja - only send PDFs for survey subtype large
        for(Task t:surveyActivities)
        {
        	if(t.Id==rs.Activity_ID__c)
        	{
        		system.debug('***** Large survey activity found, set sendEmail to true');
        		bSendEmail = true;
        		break;
        	}
        }
        if(bSendEmail)
        {
        	system.debug('***** cleared to sendEmail. checking other conditions');
            if(!surveyDetailsLoadedOld && surveyDetailsLoaded && rs.PDF_Emailed__c==false )
            {
            	system.debug('***** All cleared. Sending Email Survey PDF');
                SendRyderSurveyEmail.sendActivityMail(activityId, UserInfo.getSessionId());
                rs.PDF_Emailed__c=true;
                rs.Times_PDF_Emailed__c=(rs.Times_PDF_Emailed__c==null?1:rs.Times_PDF_Emailed__c+1);
                rs.Last_PDF_Emailed_Date__c= System.now();
                rs.Last_PDF_Emailed_BY_User__c= Userinfo.getUserId();
                
            }
        }
    }
}