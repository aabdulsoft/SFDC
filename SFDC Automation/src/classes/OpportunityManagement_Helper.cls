public with sharing class OpportunityManagement_Helper
{
    public static void SetOpportunityDefaultPriceBook(List<Opportunity> lOpp)
    {
        Id uvsRTId = UVS_Util.UVSRecordType_Opp;
        Map<String,String> mPriceBook = new Map<String,String>();
        Map<String,String> mPriceBookOthers = new Map<String,String>();
        Map<String,String> mAccIds = new Map<String,String>();
        Map<String,Opportunity> mOppIds = new Map<String,Opportunity>();
        ID RentalOppRecordTypeId = [Select r.Id From RecordType r where Name = 'National Rental Opportunity' and SobjectType = 'Opportunity'].Id;
        ID RentalPriceBookRecordTypeId = [Select r.Id From RecordType r where Name = 'National Rental PriceBook' and SobjectType = 'PriceBook2'].Id;
        List<Pricebook2> lPricebook = [Select p.RecordTypeId, p.Name, p.Id From Pricebook2 p];
        if(lPricebook != null && lPricebook.size() > 0)
        {
            for(Pricebook2 Obj : lPricebook)
            {
                if(Obj.RecordTypeId == RentalPriceBookRecordTypeId)
                    mPriceBook.put(Obj.Name, Obj.Id);
                else
                    mPriceBookOthers.put(Obj.Name, Obj.Id);
            }
        }
        for(Opportunity OppObj : lOpp)
        {
            if(OppObj.RecordTypeId != null && OppObj.RecordTypeId == RentalOppRecordTypeId && OppObj.AccountId != null)
            {
                mOppIds.put(OppObj.Name, OppObj);
                mAccIds.put(OppObj.Name, OppObj.AccountId);
            }
            else if(OppObj.RecordTypeId != null)
            {
              // Sunil : 9/13/2014: As per the discussion we are bypassing the below method in the case of UVS Opporutnity.
			        // Manisha Gupta : 10/16/2014 : Check for opp type and assign price book accordingly.
			        // For UVS Opportunity, price book must be UVS for rest(Lease) it must be Standard.
			        if(OppObj.RecordTypeId == uvsRTId && mPriceBookOthers.get('UVS') != null) {
			        	oppObj.Pricebook2Id = mPriceBookOthers.get('UVS');
			        }else if(mPriceBookOthers.get('Standard Price Book') != null){
			        	OppObj.Pricebook2Id = mPriceBookOthers.get('Standard Price Book');
			        }
            }
        }
        if(mAccIds.size() > 0)
        {
            Map<Id,Account> mAcc = new Map<Id,Account>([select Id, Rental_Price_Tier__c
                                                        from Account where Id in : mAccIds.values()
                                                        and Rental_Price_Tier__c != null]);
            if(mAcc != null && mAcc.size() > 0)
            {
                for(Opportunity OppObj : mOppIds.values())
                {
                    Account Acc = mAcc.get(OppObj.AccountId);
                    if(Acc != null && Acc.Rental_Price_Tier__c != null && mPriceBook.get(Acc.Rental_Price_Tier__c) != null)
                    {
                        OppObj.Pricebook2Id = mPriceBook.get(Acc.Rental_Price_Tier__c);
                    }
                }
            }
        }
    }
    public static void ManageOwnership(List<Opportunity> lOpp, Map<Id, Opportunity> mOldOpp)
    {
        String sStageName = 'Booked, Signed';
        Set<ID> sOppOwnerIds = new Set<ID>();
        Set<ID> sAccIds = new Set<ID>();
        List<Opportunity> lOppProcess = new List<Opportunity>();

        for(Opportunity Opp : lOpp)
        {
            String sNew = '';
            String sOld = '';
            if(Opp.get('StageName') != null)
                sNew = Opp.StageName + '';
            if(mOldOpp != null && mOldOpp.get(Opp.Id).get('StageName') != null)
                sOld = mOldOpp.get(Opp.Id).StageName + '';
            if(sStageName.contains(sNew) && sNew != sOld && Opp.Customer_100_Ownership__c == 'Yes' && sOld != 'Signed' && sOld != 'Booked')
            {
                lOppProcess.add(Opp);
                sOppOwnerIds.add(Opp.OwnerId);
                sAccIds.add(Opp.AccountId);
                system.debug('******entered***');
            }
        }
        // Not National Account
        if(lOppProcess.size() > 0 && sOppOwnerIds.size() > 0)
        {
            Map<Id, Account> mAccount = new Map<Id, Account>([select Id, Name from Account
                                                                where Id in : sAccIds]);
          //  List<User> lUser = new List<User>{[Select u.Manager.Email, u.ManagerId, u.Id,u.Manager.Name From User u
           //                                     where Id in : sOppOwnerIds and ManagerId != null]};
            Map<String, User> mUseretails = new Map<String, User>();

         //   if(lUser.size()>0)
         //   {
            for(User userObj : [Select u.Manager.Email, u.ManagerId, u.Id,u.Manager.Name From User u
                                             where Id in : sOppOwnerIds and ManagerId != null])
            {
                mUseretails.put(userObj.Id, userObj);
            }
             system.debug('******entered1***');
        //     }
            List<Task> lTask = new List<Task>();
            List<Messaging.SingleEmailMessage> lSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
            EmailTemplate EmailTemplateObj = [Select e.Subject, e.Id, e.HtmlValue, e.Body From EmailTemplate e where DeveloperName = 'Ownership100'];

            if(EmailTemplateObj != null && mUseretails.size() > 0 && mAccount.size() > 0)
            {

              system.debug('******entered2***');
                for(Opportunity Opp : lOppProcess)
                {
                  system.debug('******entered3***');
                    if(mAccount.get(Opp.AccountId) != null)
                    {
                        String sHtmlValue = EmailTemplateObj.HtmlValue;
                        sHtmlValue = sHtmlValue.replaceAll('#OpportunityName', Opp.Name+'');
                        sHtmlValue = sHtmlValue.replaceAll('#OpportunityStageName', Opp.StageName+'');

                        sHtmlValue = sHtmlValue.replaceAll('#UserName', mUseretails.get(Opp.OwnerId).Manager.Name+'');
                        sHtmlValue = sHtmlValue.replaceAll('#OppID', Opp.Id+'');
                        //sHtmlValue = sHtmlValue.replaceAll('#AccName', mAccount.get(Opp.AccountId).Name+'');
                        if(mAccount.get(Opp.AccountId) != null)
                        {
                            String sAccN = Matcher.quoteReplacement(mAccount.get(Opp.AccountId).Name+'');
                            System.debug('Nitin---sAccN>'+sAccN);
                            sHtmlValue = sHtmlValue.replaceAll('#AccName', sAccN);
                        }
                        Messaging.SingleEmailMessage MailObj = new Messaging.SingleEmailMessage();
                        MailObj.setHtmlBody(sHtmlValue);
                        MailObj.setSaveAsActivity(false);
                        MailObj.setSubject(EmailTemplateObj.Subject);
                        MailObj.setToAddresses(new List<String>{mUseretails.get(Opp.OwnerId).Manager.Email});
                        lSingleEmailMessage.add(MailObj);

                        String sBody = EmailTemplateObj.Body;
                        sBody = sBody.replaceAll('#OpportunityName', Opp.Name+'');
                        sBody = sBody.replaceAll('#OpportunityStageName', Opp.StageName+'');

                        sBody = sBody.replaceAll('#UserName', mUseretails.get(Opp.OwnerId).Manager.Name+'');
                        if(mAccount.get(Opp.AccountId) != null)
                        {
                            String sAccN = Matcher.quoteReplacement(mAccount.get(Opp.AccountId).Name+'');
                            sBody = sBody.replaceAll('#AccName', sAccN);
                        }
                        Task TaskObj = new Task();
                        TaskObj.ActivityDate = System.today();
                        TaskObj.OwnerId = mUseretails.get(Opp.OwnerId).ManagerId;
                        TaskObj.Subject = 'Ownership Validation';
                        TaskObj.WhatId = Opp.Id;
                        TaskObj.Type = 'Other';
                        TaskObj.Status = 'Not Started';
                        TaskObj.Priority = 'Normal';
                        TaskObj.Description = sBody;
                        lTask.add(TaskObj);
                    }
                }
                System.debug('---lSingleEmailMessage-->'+lSingleEmailMessage);
                System.debug('---lTask-->'+lTask);
                if(lSingleEmailMessage.size() > 0)
                    Messaging.sendEmail(lSingleEmailMessage);
                if(lTask.size() > 0)
                    insert lTask;
            }
        }
    }
    
    /*
    *  Commented by Virendra as Not in use from anywhere and Trigger Code is commented out
    *    Effecting Code Coverag 
    *  2/218/2015
    
    public static void SendEmailToSafetyDirectors(List<Opportunity> lOpp, Map<Id, Opportunity> mOldOpp)
    {
    	List<Messaging.SingleEmailMessage> lSendEmail = new List<Messaging.SingleEmailMessage>();
    	Set<String> sSafetyDirectors = new Set<String>{'Northeast','Southeast','Central','West'};
    	Map<String, User> mSafetyDirectors = new Map<String, User>();
    	Set<Id> sOwnerIds = new Set<Id>();
    	Set<Id> sOppIds = new Set<Id>();
    	Map<Id, User> mUsers = null;
    	ID UVSRecordTypeId = [Select r.SobjectType, r.Name, r.IsActive, r.Id
    							From RecordType r where SobjectType = 'Opportunity'
    							and Name = 'UVS Opportunity' limit 1].Id;
    	for(Opportunity Opp : lOpp)
    	{
    		String sNew = '';
    		String sOld = '';
    		if(Opp.Specialized_Operating_Criteria__c != null)
    			sNew = Opp.Specialized_Operating_Criteria__c;
    		if(mOldOpp != null && mOldOpp.get(Opp.Id).Specialized_Operating_Criteria__c != null)
    			sOld = mOldOpp.get(Opp.Id).Specialized_Operating_Criteria__c;
    		if(sNew != sOld && Opp.RecordTypeId != UVSRecordTypeId)
    		{
    			sOwnerIds.add(Opp.OwnerId);
    			sOppIds.add(Opp.Id);
    		}
    	}
    	if(sOppIds.size() > 0)
    	{
    		mUsers = new Map<Id, User>([Select u.Short_Title__c, u.Region__c,
										u.Id From User u where Id in: sOwnerIds and Region__c != null]);

    		List<User> lUser = [Select u.Email, u.Short_Title__c, u.Region__c,
								u.Id From User u where
								Region__c in : sSafetyDirectors and
								Short_Title__c = 'Safety'];
    		for(User UserObj : lUser)
    		{
    			mSafetyDirectors.put(UserObj.Region__c, UserObj);
    		}
    	}
    	if(mSafetyDirectors.size() > 0)
    	{
    		List<Opportunity> lOppty = [Select o.Specialized_Operating_Criteria__c, o.Owner.Region__c,
    									o.Owner.Name, o.OwnerId, o.Name, o.Id, o.CreatedDate, o.CloseDate,
    									o.Account.OwnerId, o.Account.Owner.Name, o.Account.Name,
    									o.Account.Id, o.AccountId From Opportunity o where
    									Id in : sOppIds];
    		String sEmailContent = 'An opportunity has been flagged with "Specialized Operating Criteria"';

    		for(Opportunity Opp : lOppty)
    		{
    			Boolean bAlreadyExist = false;
    			User OwnerU = mUsers.get(Opp.OwnerId);
    			String sRegion = OwnerU.Region__c;
    			User SafetyDirector = mSafetyDirectors.get(sRegion);
				sEmailContent += '\n\n\n';
    			sEmailContent += 'Account Name: ' + Opp.Account.Name + '\n';
    			sEmailContent += 'Account Owner: ' + Opp.Account.Owner.Name + '\n';
    			sEmailContent += 'Opportunity Owner: ' + Opp.Owner.Name + '\n';
    			sEmailContent += 'Opportunity Name: ' + Opp.Name + '\n';
    			sEmailContent += 'Created Date: ' + String.valueOf(Opp.CreatedDate) + '\n';
    			sEmailContent += 'Close Date: ' + String.valueOf(Opp.CloseDate) + '\n';
    			sEmailContent += 'Owner Region: ' + Opp.Owner.Region__c + '\n';
    			sEmailContent += 'Specialized Operating Criteria: ' + Opp.Specialized_Operating_Criteria__c + '\n';

    			List<String> sPicklistValues = String.valueOf(Opp.Specialized_Operating_Criteria__c).split(';');
    			for(String sValue : sPicklistValues)
    			{
    				List<String> lEmailAddress = new List<String>();
    				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		            mail.setPlainTextBody(sEmailContent);
		            System.debug('-----EmailAddress->'+LABEL.SafetyDirectors.split(';')[0].split('#')[1]);
		            System.debug('-----EmailAddress->'+LABEL.SafetyDirectors.split(';')[1].split('#')[1]);
		            if(sValue == 'Parking Lot')
		            	lEmailAddress.add(LABEL.SafetyDirectors.split(';')[0].split('#')[1]);
		            else if(sValue == 'Natural Gas')
		            	lEmailAddress.add(LABEL.SafetyDirectors.split(';')[1].split('#')[1]);
		            else if(!bAlreadyExist)
		            {
		            	for(String sMRegion : mSafetyDirectors.keySet())
		    			{
		    				bAlreadyExist = true;
		    				if(sMRegion.contains(sRegion))
		    					lEmailAddress.add(mSafetyDirectors.get(sMRegion).Email);
		    			}
		            }

		            System.debug('-----lEmailAddress->'+lEmailAddress);
		            if(lEmailAddress.size() > 0)
		            {
			            mail.setToAddresses(lEmailAddress);
			            mail.setSubject('An opportunity has been flagged with "Specialized Operating Criteria"');
			            lSendEmail.add(mail);
		            }
    			}
    		}
    	}
    	System.debug('-----lSendEmail->'+lSendEmail);
    	if(lSendEmail.size() > 0)
	    {
	        Messaging.sendEmail(lSendEmail);
	    }
    }*/
	
	public static void SynchronizeMissingCustProspect(List<Opportunity> lOpp)
    {
    	CommonFunctions commonFunction = new CommonFunctions();
    	Map<String,RecordType> ValidRecTypes = commonFunction.getValidFMSOpportunityRecordTypes();
    	for(Opportunity Opp : lOpp)
    	{
    		if(ValidRecTypes.get(Opp.RecordTypeId) != null)
    		{
    			CommonFunctions.UpdateCustProspectFuture(Opp.AccountId);
    		}
    		
    	}
    	    	
    }
}