/*
This class is used to call the Web service to send Mass Email.
Created By : Baskar Venugopal on 07/25/2012.
*/
public  with sharing class EMailUtil 
{   
    /*
    This method is used to call the web service to send Mass Email.
    The email message properties are concatenated using the delimiter '###'.
    ***ALWAYS *** add the email properties in below Order only.
    FromID ### Email Ids ### Email Subject ### Message ### Attachment ### Type (HTML,text etc) ### Caller.
    */
    public static void  SendRyderEmail(List<String> emailMessages, boolean useFutureCall)
    {
        if(!useFutureCall)
        {
            SendMail(emailMessages);
        }
        else
        {
            SendMailUsingFutureCall(emailMessages);
        }
    }
    
    private static void SendMail(List<String> emailMessages)
    {
        RyderEmailService.CRMCredential credential = new RyderEmailService.CRMCredential();
        RyderEmailService.RyderEmailServiceSoap emailSvc = new RyderEmailService.RyderEmailServiceSoap();
        RyderEmailService.RyderEmailRequestData emailData = new RyderEmailService.RyderEmailRequestData();
        RyderEmailService.DCRyderEmailResponseData resp= null;
        emailSvc.endpoint_x = RyderGlobalVariables.RYDER_WS_ENDPOINT + RyderGlobalVariables.SEND_RYDER_EMAIL;
        credential.UserName = '';
        credential.Password = '';
        credential.SecurityToken = '';
        emailData.Emails = prepareEmailRequest(emailMessages);
        resp= emailSvc.SendEmail(credential, emailData);
        system.debug('Service Call Result ' + resp.IsEmailsSent);
    }
    @future (Callout=true)
    private static void SendMailUsingFutureCall(List<String> emailMessages)
    {
        SendMail(emailMessages);
    }
    //This method is used to transform the RyderEmail objects into RyderEmailService.ArrayOfEmail.
    private  static RyderEmailService.ArrayOfEmail prepareEmailRequest(List<String> emailMessages) 
    {
        List<RyderEmailService.Email> emailList = new List<RyderEmailService.Email>();
        RyderEmailService.Email emailReq = null;
        system.debug('Email message size Util class' + emailMessages.size());
        for(String mailMsg : emailMessages)
        {
            List<string> email = mailMsg.split('###');
            system.debug('Email string' + email);
            emailReq  =new  RyderEmailService.Email();
            emailReq.FromId = email.get(0);
            system.debug('Email From Id ' + email.get(0));
            emailReq.EmailIds = email.get(1);
            system.debug('Email Ids ' + email.get(1));
            emailReq.Subject = email.get(2);
            system.debug('Email Subject' + email.get(2));
            emailReq.Message = email.get(3);
            system.debug('Email Message ' + email.get(3));
            emailReq.MessageBody = email.get(4);
            system.debug('Email Attachment' + email.get(4));
            emailReq.Type_x = email.get(5);
            system.debug('Email Type ' + email.get(5));
            emailReq.Caller = email.get(6);
            system.debug('Email Caller ' + email.get(6));
            emailList.add(emailReq);
            system.debug('Email' + emailReq);
        }
        RyderEmailService.ArrayOfEmail emailArray = new RyderEmailService.ArrayOfEmail();
        system.debug('Email List' + emailList);
        emailArray.Email = emailList;
        return emailArray;
    }
    
    // This Method will read the email ids from a String Array and concatenates each id with semicoln.
    //The email ids will be concatenated like abc@xy.com;cde@ijk.com etc  
    //Because the Email service requires theTO address in this format. 
    public  static string PrepareMailIds(string[] idList)
    {
        integer maxCount=1;
        string emailIds ='';
        if(idList == null || idList.size()==0)
        {
            return emailIds;
        }
        for(integer i=0;i< idList.size(); i++)
        {
            if(maxCount != idList.size())
            {
                emailIds = emailIds + idList[i] + ';';
            }
            else
            {
                emailIds = emailIds + idList[i];
            }
            maxCount++;
        } 
        return emailIds;
    }

//Email to Users:
//string[] email, string mailBody
//Public static void sendTaskMail(string strFrom, Task taskCreated){
//  
//  //Task task = new Task(Id=taskId); 
//  string[] toMail;    
//  toMail.add(taskCreated.Owner);
//  system.debug('emailemail Task Id' + taskCreated );
//  system.debug('emailemail owner' + toMail );
        
//      string mailType = 'HTML';
//      string strSubject; 
//      string strBody;
    
//  if (strFrom == 'FromInsert'){   
//      system.debug('emailemail FromINsert');  
//      strSubject = 'Task for Credit: Creation'; 
//      strBody = 'New task was created for you';
//  }
                
//      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
 //     String[] toAddresses = new String[] {'franklin_suazo@ryder.com'};
 //     //String[] toAddresses = new String[] {toMail};
    
 //     mail.setToAddresses(toAddresses);
 //     mail.setPlainTextBody(strBody);
 //     mail.setSubject(strSubject);    
 //     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
 // }

//Email to Users:
//string[] email, string mailBody
Public static void sendMailtoUsers(string action, Map<Id,Task> taskMap){
        
    string[] sendTo = new string[]{};
    List<Id> mailTo = new List<Id>();
    string taskSubject = '';
    string taskType = '';
    date taskRequestedDate;
    date taskDueDate;
    date taskEstComplDate;
    string taskComments = '';
    string taskStatus = '';
    string uniquetaskId;
    Account[] taskCompanyName;
    String currUser = '';
    
    Set<Id> taskIds = taskMap.keySet();
    for (Id taskId: taskIds) {
        Task task = taskMap.get(taskId);
        mailTo.add(task.OwnerId);
        taskSubject = task.Subject;
        taskType = task.Type;
        taskComments = task.Description;
        taskRequestedDate = task.Requested_Date__c;
        taskDueDate = task.ActivityDate;
        taskEstComplDate = task.Estimated_Completion__c;
        taskStatus = task.Status;
        uniquetaskId = task.Id;
        currUser = task.CreatedById;
        
        taskCompanyName = [Select a.Name from Account a where a.Id =: task.AccountId limit 1];
        system.debug('taskCompanyName = ' + taskCompanyName[0].Name);
    }        
    system.debug('emailemail owner' + mailTo ); 
    
    //Get current User
    //currUser = UserInfo.getUserId();
    mailTo.add(currUser);
    system.debug('emailemail currUser' + mailTo );
    
    //Get Emails
    User[] users = [Select u.Email from User u where u.Id in: mailTo];
    System.debug(' !!!! Account here' + users);
    for (User usr : users){ 
        sendTo.add(usr.Email);
    }   
    system.debug('emailemail sendTo' + sendTo );
    
    string strSubject; 
    string strBody;
    
    if (action == 'FromInsert'){    
        system.debug('emailemail FromINsert');
        strBody = 'Created';
    }
    else if (action == 'FromUpdate' ) {
        strBody = 'Created / Updated'; 
    }
    else if (action == 'FromClose') {
        strBody = 'Closed'; 
    }   
    
    //Subject
    strSubject = 'Task has been ' + strBody + '.';
    system.debug('emailemail inside Email');
    string caller ='CREDIT';
    string mailType = 'HTML';
        
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //' + LABEL.HostURL +'
    //mail.setHtmlBody('Task:<b> ' + taskSubject +' </b>has been ' + strBody + '.<p> For more detailed information <a href=https://na4.salesforce.com/'+uniquetaskId+'>click here.</a>');
    //mail.setHtmlBody('Task has been ' + strBody + '.<p> CompanyName:<b> ' + taskCompanyName[0].Name + ' </b> <p> Subject:<b> ' + taskSubject + ' </b> <p> Type:<b> ' + taskType + ' </b>  <p> Due Date:<b> ' + taskDueDate + ' </b> <p> Status:<b> ' + taskStatus + ' </b>  <p> Comments:<b> ' + taskComments + ' </b> <p> For more detailed information <a href=https://cs20.salesforce.com/'+uniquetaskId+'>click here.</a>');
    //mail.setHtmlBody('Task has been ' + strBody + '.<p> CompanyName:<b> ' + taskCompanyName[0].Name + ' </b> <p> Subject:<b> ' + taskSubject + ' </b> <p> Type:<b> ' + taskType + ' </b> <p> Requested Date:<b> ' + taskRequestedDate + ' </b> <p> Estimated Completion Date:<b> ' + taskEstComplDate + ' </b> <p> Due Date:<b> ' + taskDueDate + ' </b> <p> Status:<b> ' + taskStatus + ' </b>  <p> Comments:<b> ' + taskComments + ' </b> <p> For more detailed information <a href=https://na4.salesforce.com/'+uniquetaskId+'>click here.</a>');
      mail.setHtmlBody('Task has been ' + strBody + '.<p> CompanyName:<b> ' + taskCompanyName[0].Name + ' </b> <p> Subject:<b> ' + taskSubject + ' </b> <p> Type:<b> ' + taskType + ' </b> <p> Requested Date:<b> ' + taskRequestedDate + ' </b> <p> Estimated Completion Date:<b> ' + taskEstComplDate + ' </b> <p> Due Date:<b> ' + taskDueDate + ' </b> <p> Status:<b> ' + taskStatus + ' </b>  <p> Comments:<b> ' + taskComments + ' </b> <p> For more detailed information <a href=' + LABEL.HostURL +'//'+uniquetaskId+'>click here.</a>');
    //String[] toAddresses = new String[] {'franklin_suazo@ryder.com'};
    String[] toAddresses = new String[]{};
    toAddresses = sendTo;       
    
    mail.setToAddresses(toAddresses);
   
    mail.setSubject(strSubject);    
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }
}