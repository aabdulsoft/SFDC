global class SendRyderSurveyEmail{
    
    webservice static void sendActivityMailPDF(string surveyID)
    {
    /*	
        List<Ryder_Surveys__c> rs = [SELECT r.Activity_ID__c, r.Customer_Branch__r.Customer_Branch_Owner__c, r.Customer_Branch__r.Ryder_HQ_Account__c, r.Customer_Branch__r.Ryder_Branch__c,r.PDF_Emailed__c,r.Times_PDF_Emailed__c,r.Last_PDF_Emailed_Date__c,r.Last_PDF_Emailed_BY_User__c FROM Ryder_Surveys__c r  WHERE r.Id = :surveyId];
        
        for(Ryder_Surveys__c r : rs)
        {
            system.debug('***** r.ID = ' + surveyID);
            system.debug('***** r.Activity_Id__c = ' + r.Activity_Id__c);
            system.debug('***** r.Customer_Branch__r.Customer_Branch_Owner__c = ' + r.Customer_Branch__r.Customer_Branch_Owner__c);
            system.debug('***** r.Customer_Branch__r.Ryder_HQ_Account__c = ' + r.Customer_Branch__r.Ryder_HQ_Account__c);
            system.debug('***** r.Customer_Branch__r.Ryder_Branch__c = ' + r.Customer_Branch__r.Ryder_Branch__c );
            
            // Call get page content
            PageReference pdf = Page.RyderSurveyPDF;
            
            //pass in activityId to the PDF page
            pdf.getParameters().put('id',r.Activity_Id__c);
            pdf.getParameters().put('render','pdf');            
            
            Blob body;
        
            try {
        
                // returns the output of the page as a PDF
                body = pdf.getContent();
                system.debug ('***PDF - body blobbed'); 
                system.debug ('***PDF - body = ' + body); 
            } catch (VisualforceException e) {
                body = Blob.valueOf('PDF - Page not generated');
                system.debug ('***PDF - body not blobbed');
            }
                   
            // Send emails
            sendEmailList(r.Activity_Id__c, r.Customer_Branch__r.Customer_Branch_Owner__c, r.Customer_Branch__r.Ryder_Branch__c, null, body, true); 
            //neelima-02/15/2012 log info when an email is sent out
            r.PDF_Emailed__c=true; 
            r.Times_PDF_Emailed__c=(r.Times_PDF_Emailed__c==null?1:r.Times_PDF_Emailed__c+1);
            r.Last_PDF_Emailed_Date__c= System.now();
            r.Last_PDF_Emailed_BY_User__c= Userinfo.getUserId();
        }
        
        update rs;
        
        */    
    }
    
    @future (Callout=true)
    Public static void sendActivityMail(string activityId, string sessionId)
    {
     /*   List<Ryder_Surveys__c> rs = [SELECT r.Activity_ID__c, r.Customer_Branch__r.Customer_Branch_Owner__c, r.Customer_Branch__r.Ryder_HQ_Account__c, r.Customer_Branch__r.Ryder_Branch__c FROM Ryder_Surveys__c r  WHERE r.Activity_ID__c = :activityId];
        
        for(Ryder_Surveys__c r : rs)
        {
            // Call web service and get survey content
            soapSforceComSchemasClassRydersurve.RyderSurveyPDFContent ryderSurvey = new soapSforceComSchemasClassRydersurve.RyderSurveyPDFContent ();
            ryderSurvey.SessionHeader = new soapSforceComSchemasClassRydersurve.SessionHeader_element();
            ryderSurvey.SessionHeader.sessionId = sessionId;
            
            system.debug('***** sessionId = ' + sessionId);
            
            string surveyContent = ryderSurvey.GetSurveyContentByActivityId(r.Activity_Id__c);
        
            // Send emails
            sendEmailList(r.Activity_Id__c, r.Customer_Branch__r.Customer_Branch_Owner__c, r.Customer_Branch__r.Ryder_Branch__c, surveyContent, null, false); 
        }      
      */ 
      
         
    }
    
    Public static void sendEmailList(string activityId, string customerBranchOwner, string ryderBranch, string mailBody, Blob mailBodyPdf, boolean isPDF)
    {
    	/*
    	
        // Email list
        String[] emailList = new List<String>();
        
        // Neelima-02/03/2012- read the emails from custom settings and send a copy of all automated pdfs to that email list;
        string staticEmailList = RyderGlobalVariables.Ryder_Survey_PDF_Recipients;
        if(staticEmailList!=null) emailList = staticEmailList.split(',');
        
        // Store branch owner email address
        String emailBranchOwnerEmail = '';
		
		//Neelima- 20Mar2012- check if the cust branch owner exist before getting the email.  
       	List<User> userBranchOwner ;
        if(customerBranchOwner!=null) userBranchOwner = [Select u.Email from User u where u.Id = :customerBranchOwner];
     
     	//List to store whether the Send_To_All is checked or not and store the email addresses 
		List<Ryder_Branch__c> emails = [SELECT rb.Send_To_All__c, rb.Account_Manager_Email__c, rb.Director_of_Asset_Management_Email__c, rb.Director_of_Ops_Email__c, rb.Director_of_Rental_Email__c, rb.Director_of_Sales_Email__c, rb.Lease_Administrator_2_Email__c, rb.Lease_Administrator_Email__c, rb.Maintenance_Manager_Email__c, rb.Rental_Manager_Email__c, rb.Senior_VP_Email__c, rb.Senior_VP_of_Ops_Email__c, rb.Service_Manager_Email__c,rb.Quality_Manager_Email__c, rb.Quality_VP_Email__c, rb.Quality_Director_Email__c, rb.Finance_Manager_Email__c, rb.Finance_Director_Email__c, rb.Finance_VP_Email__c, rb.SAC_Email__c, rb.SAC2_Email__c, rb.Inside_Sales_Email__c, rb.MOS_Email__c, rb.MOS_Name__c, rb.MOS_Phone__c, rb.MOS_UserId__c FROM Ryder_Branch__c rb WHERE rb.Id = :ryderBranch];
		 
	 	//Retreive the email address when Send_To_All is checked
	 	if (emails[0].Send_To_All__c)
	 	{
	      	if(userBranchOwner != null && userBranchOwner.size()>0)
	        {
	            emailBranchOwnerEmail  = userBranchOwner[0].Email;
	            
	            emailList.add(emailBranchOwnerEmail);
	        }
	        
	        if(emails <> null)
	        {
	            if(emails[0].Account_Manager_Email__c != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Account_Manager_Email__c = ' + emails[0].Account_Manager_Email__c);
	            
	                if((emails[0].Account_Manager_Email__c != null) &&
	                (emails[0].Account_Manager_Email__c != ''))
	                {
	                    emailList.add(emails[0].Account_Manager_Email__c);
	                }
	            }
	            
	            if(emails[0].Director_of_Asset_Management_Email__c != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Director_of_Asset_Management_Email__c = ' + emails[0].Director_of_Asset_Management_Email__c);
	            
	                if((emails[0].Director_of_Asset_Management_Email__c != null) &&
	                (emails[0].Director_of_Asset_Management_Email__c != ''))
	                {
	                    emailList.add(emails[0].Director_of_Asset_Management_Email__c);
	                }
	            }
	
	            if(emails[0].Director_of_Ops_Email__c != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Director_of_Ops_Email__c = ' + emails[0].Director_of_Ops_Email__c);
	            
	                if((emails[0].Director_of_Ops_Email__c != null) &&
	                (emails[0].Director_of_Ops_Email__c != ''))
	                {
	                    emailList.add(emails[0].Director_of_Ops_Email__c);
	                }
	            }
	
	            if(emails[0].Director_of_Rental_Email__c != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Director_of_Rental_Email__c = ' + emails[0].Director_of_Rental_Email__c);
	
	                if((emails[0].Director_of_Rental_Email__c != null) &&
	                (emails[0].Director_of_Rental_Email__c != ''))
	                {
	                    emailList.add(emails[0].Director_of_Rental_Email__c);
	                }
	            }
	
	            if(emails[0].Director_of_Sales_Email__c != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Director_of_Sales_Email__c = ' + emails[0].Director_of_Sales_Email__c);
	            
	                if((emails[0].Director_of_Sales_Email__c != null) &&
	                (emails[0].Director_of_Sales_Email__c != ''))
	                {
	                    emailList.add(emails[0].Director_of_Sales_Email__c);
	                }
	            }
	      
	            if(emails[0].Maintenance_Manager_Email__c != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Maintenance_Manager_Email__c = ' + emails[0].Maintenance_Manager_Email__c);
	            
	                if((emails[0].Maintenance_Manager_Email__c != null) &&
	                (emails[0].Maintenance_Manager_Email__c != ''))
	                {
	                    emailList.add(emails[0].Maintenance_Manager_Email__c);
	                }
	            }
	
	            if(emails[0].Rental_Manager_Email__c != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Rental_Manager_Email__c = ' + emails[0].Rental_Manager_Email__c);
	            
	                if((emails[0].Rental_Manager_Email__c != null) &&
	                (emails[0].Rental_Manager_Email__c != ''))
	                {
	                    emailList.add(emails[0].Rental_Manager_Email__c);
	                }
	            }
	
	            if(emails[0].Senior_VP_Email__c  != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Senior_VP_Email__c = ' + emails[0].Senior_VP_Email__c);
	            
	                if((emails[0].Senior_VP_Email__c != null) &&
	                (emails[0].Senior_VP_Email__c != ''))
	                {
	                    emailList.add(emails[0].Senior_VP_Email__c);
	                }
	            }
	
	            if(emails[0].Senior_VP_of_Ops_Email__c != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Senior_VP_of_Ops_Email__c = ' + emails[0].Senior_VP_of_Ops_Email__c);
	            
	                if((emails[0].Senior_VP_of_Ops_Email__c != null) &&
	                (emails[0].Senior_VP_of_Ops_Email__c != ''))
	                {
	                    emailList.add(emails[0].Senior_VP_of_Ops_Email__c);
	                }
	            }
	
	            if(emails[0].Service_Manager_Email__c != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Service_Manager_Email__c = ' + emails[0].Service_Manager_Email__c);
	            
	                if((emails[0].Service_Manager_Email__c != null) &&
	                (emails[0].Service_Manager_Email__c != ''))
	                {
	                    emailList.add(emails[0].Service_Manager_Email__c);
	                }
	            }
	            
	            if(emails[0].Quality_Manager_Email__c != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Quality_Manager_Email__c = ' + emails[0].Quality_Manager_Email__c);
	            
	                if((emails[0].Quality_Manager_Email__c != null) &&
	                (emails[0].Quality_Manager_Email__c != ''))
	                {
	                    emailList.add(emails[0].Quality_Manager_Email__c);
	                }
	            }
	            
	            if(emails[0].Quality_VP_Email__c != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Quality_VP_Email__c = ' + emails[0].Quality_VP_Email__c);
	            
	                if((emails[0].Quality_VP_Email__c != null) &&
	                (emails[0].Quality_VP_Email__c != ''))
	                {
	                    emailList.add(emails[0].Quality_VP_Email__c);
	                }
	            }
	            
	            if(emails[0].Quality_Director_Email__c != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Quality_Director_Email__c = ' + emails[0].Quality_Director_Email__c);
	            
	                if((emails[0].Quality_Director_Email__c != null) &&
	                (emails[0].Quality_Director_Email__c != ''))
	                {
	                    emailList.add(emails[0].Quality_Director_Email__c);
	                }
	            }
	            
	            if(emails[0].Finance_Manager_Email__c != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Finance_Manager_Email__c = ' + emails[0].Finance_Manager_Email__c);
	            
	                if((emails[0].Finance_Manager_Email__c != null) &&
	                (emails[0].Finance_Manager_Email__c != ''))
	                {
	                    emailList.add(emails[0].Finance_Manager_Email__c);
	                }
	            }
	            
	            if(emails[0].Finance_Director_Email__c != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Finance_Director_Email__c = ' + emails[0].Finance_Director_Email__c);
	            
	                if((emails[0].Finance_Director_Email__c != null) &&
	                (emails[0].Finance_Director_Email__c != ''))
	                {
	                    emailList.add(emails[0].Finance_Director_Email__c);
	                }
	            }
	            
	            if(emails[0].Finance_VP_Email__c != emailBranchOwnerEmail)
	            {
	                system.debug('***** emails[0].Finance_VP_Email__c = ' + emails[0].Finance_VP_Email__c);
	            
	                if((emails[0].Finance_VP_Email__c != null) &&
	                (emails[0].Finance_VP_Email__c != ''))
	                {
	                    emailList.add(emails[0].Finance_VP_Email__c);
	                }
	            }           
	            
	            // Saad - 14May2012- Added the email for SAC, SAC2 & Inside Sales.
	            if(emails[0].SAC_Email__c != customerBranchOwner)
	            {
	                system.debug('***** emails[0].SAC_Email__c = ' + emails[0].SAC_Email__c);
	            
	                if((emails[0].SAC_Email__c != null) && 
	                (emails[0].SAC_Email__c != ''))
	                {
	                    emailList.add(emails[0].SAC_Email__c);
	                }
	            }
	            
	            if(emails[0].SAC2_Email__c != customerBranchOwner)
	            {
	                system.debug('***** emails[0].SAC2_Email__c = ' + emails[0].SAC2_Email__c);
	            
	                if((emails[0].SAC2_Email__c != null) && 
	                (emails[0].SAC2_Email__c != ''))
	                {
	                    emailList.add(emails[0].SAC2_Email__c);
	                }
	            }
	            
	            if(emails[0].Inside_Sales_Email__c != customerBranchOwner)
	            {
	                system.debug('***** emails[0].Inside_Sales_Email__c = ' + emails[0].Inside_Sales_Email__c);
	            
	                if((emails[0].Inside_Sales_Email__c != null) && 
	                (emails[0].Inside_Sales_Email__c != ''))
	                {
	                    emailList.add(emails[0].Inside_Sales_Email__c);
	                }
	            }   
	            
	            // MOS added by Baskar on 06/01/2012.
	            if(emails[0].MOS_Email__c != customerBranchOwner)
	            {
	                system.debug('***** emails[0].MOS_Email__c = ' + emails[0].MOS_Email__c);
	            
	                if((emails[0].MOS_Email__c != null) && 
	                (emails[0].MOS_Email__c != ''))
	                {
	                    emailList.add(emails[0].MOS_Email__c);
	                }
	            }
	        } 
	 	}
        system.debug('***** emailList = ' + emailList);
        if (emailList.size() > 0)
        {
        	sendMail(activityId, emailList, mailBody, mailBodyPdf, isPDF);
        }
        system.debug('*****Email Invocations Encountered**** = ' + Limits.getEmailInvocations());
        system.debug('*****Limit of Email Invocations**** = ' + Limits.getLimitEmailInvocations());
        system.debug('*****Limit of DML Rows**** = ' + Limits.getLimitDMLRows());
        system.debug('*****DML Rows Encountered**** = ' + Limits.getDmlRows());
        
        */
    }
	
	//@future 
    Public static void sendMail(string activityId, string[] email, string mailBody, Blob mailBodyPdf, boolean isPDF){
        
        /*
        String CCO = '';
        
        List<Ryder_Surveys__c > customers = [SELECT rs.Contact__r.Account.Name, 
                       rs.Customer_Branch__r.Name,
                       rs.Customer_Branch__r.Id, 
                       rs.Contact__r.Account.Account_Classification__c,
                       rs.Contact__r.Account.CustProspectID__c,
                       rs.Survey_Submission_Date__c 
                       FROM Ryder_Surveys__c rs WHERE rs.Activity_ID__c = :activityId LIMIT 1];
        
        try{               
        List<Case> cases = [SELECT c.Origin FROM Case c WHERE c.Customer_Branch__r.Id = :customers[0].Customer_Branch__r.Id AND c.Activity_ID__c = :activityID LIMIT 1];

        if((cases[0].Origin.contains('CSI Closed Loop')) || (cases[0].Origin.contains('Customer Sat Survey')) || (cases[0].Origin.contains('Phone')))
        {
            CCO = 'CCO';
        }
        else
        {
            CCO = 'NON-CCO';
        }
        }catch (Exception e){
            CCO = 'NON-CCO';
        }
        system.debug('*****email = ' + email);
           
        if(email.size() <= 0)
        {
            return;
        }   
            
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        
        if(isPDF)
        {
            attach.setContentType('application/pdf');
            attach.setFileName('RyderSurvey.pdf');
            attach.Body = mailBodyPdf;            
            
      		attach.setInline(false);
 
      		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      		mail.setUseSignature(false);
      		mail.setToAddresses(email);
		    
		    //**** Format needs to be: [AccountClassification]Local|National CSI Report-No CCO: [CustomerName]B W P DISTRIBUTORS INC., [CustomerNumber]0000070231, Loc [CustomerBranchName]467 ***
		  	mail.setSubject(customers[0].Contact__r.Account.Account_Classification__c + ' CSI Report-' + CCO + ': ' + customers[0].Contact__r.Account.Name + ', ' + customers[0].Contact__r.Account.CustProspectID__c + ', ' + customers[0].Customer_Branch__r.Name); 
		
		  	//mail.setHtmlBody(mailBody);
		  	mail.setPlainTextBody('Attached is an individual customer report for your CBU on a recent Customer Survey Interview. Please share this information with all appropriate team members. If you have any questions regarding this survey, please e-mail inquiries to rydercsi@ryder.com. Thank you for your continued support.');
		  	mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
		  	for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress]) 
		  	{
		    	if(owa.Address.contains('rydercsi')) 
		    	{
		      		mail.setOrgWideEmailAddressId(owa.id); 
		      		break;
		    	}
		  	} 
          	// Send the email
          	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        else
        {
           	string emailIds = EMailUtil.PrepareMailIds(email);
           	List<string> mailList = new List<String>();
           	string mail = '';
           	string fromId='';
           	system.debug('email id' + emailIds);
           	string caller ='SURVEY';
           	string message = 'Attached is an individual customer report for your CBU on a recent Customer Survey Interview. Please share this information with all appropriate team members. If you have any questions regarding this survey, please e-mail inquiries to rydercsi@ryder.com. Thank you for your continued support.';
           	string mailType = 'HTML';
           	string subject = customers[0].Contact__r.Account.Account_Classification__c + ' CSI Report-' + CCO + ': ' + customers[0].Contact__r.Account.Name + ', ' + customers[0].Contact__r.Account.CustProspectID__c + ', ' + customers[0].Customer_Branch__r.Name ;
          	//Set Email sender Id.
           	for(OrgWideEmailAddress owa : [select Address from OrgWideEmailAddress]) 
           	{
           		system.debug('Org Email Address' + owa.Address);
            	if(owa.Address.contains('rydercsi')) 
            	{
              		fromId= owa.Address;
              		break;
            	}
           	} 
           	//Add the email properties in below Order only.
         	//FromID ### Email Ids ### Email Subject ### Message ### Attachment ### Type (HTML,text etc) ### Caller.
           	mail = fromId + '###' + emailIds + '###' + subject + '###' + message + '###' + mailBody  + '###' + mailType + '###' + caller;
           	mailList.add(mail);
           	EmailUtil.sendRyderEmail(mailList,false);
        }
        
      */
	}

	
}