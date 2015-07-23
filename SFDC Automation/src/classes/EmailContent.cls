public with sharing class EmailContent {

	
    Public static void sendMail(string[] idList, Ryder_Surveys__c rs, string objType)
    {
    	string fromId = '';
        //Variable to hold the content of the email
        string htmlBody = '';
        //Variable to hold the subject of the email
        string emailSubject = '';
        //Variable to hold the value of rs.Customer_Sat_Maintenance_Satisfaction__c
        string strCustSatMntSat;
        //Variable to hold the value of rs.Customer_Sat_Likelihood_to_Renew__c
        string strCustSatLkhRen;
        //Variable to hold the value of rs.Customer_Sat_Acct_Mgr_Satisfaction__c
        string strCustSatActSat;
        //Variable to hold the value of rs.Customer_Sat_Shop_Communications__c
        string strCustSatShpCom;
        //Variable to hold the value of rs.Contact__c;        
        string strContactId = rs.Contact__c;        
        //Variable to hold the Name of rs.Contact__c;        
        list <Contact> surveyContact = [select Name from Contact where id = :strContactId];
        //Variable to hold the value of Don't Know
        string DONT_KNOW = 'Don\'t Know';
        string caller = '';
        //Variable to hold the Email message.
        string emailMessage ='';
        //Variable to hold the Email messages.
        List<string> mailList = new List<String>();
        //Variable to hold Mail type like HTML, Text etc.
        string mailType ='';
        if (rs.Customer_Sat_Maintenance_Satisfaction__c != null)
        {
            strCustSatMntSat = rs.Customer_Sat_Maintenance_Satisfaction__c;
        }
        else
        {
            strCustSatMntSat = '&nbsp;';
        }
        
        if (rs.Customer_Sat_Likelihood_to_Renew__c != null)
        {
            strCustSatLkhRen = rs.Customer_Sat_Likelihood_to_Renew__c;
        }
        else
        {
            strCustSatLkhRen = '&nbsp;';
        }
        
        if (rs.Customer_Sat_Acct_Mgr_Satisfaction__c != null)
        {
            strCustSatActSat = rs.Customer_Sat_Acct_Mgr_Satisfaction__c;
        }
        else
        {
            strCustSatActSat = '&nbsp;';
        }
        
        if (rs.Customer_Sat_Shop_Communications__c != null)
        {
            strCustSatShpCom = rs.Customer_Sat_Shop_Communications__c;
        }
        else
        {
            strCustSatShpCom = '&nbsp;';
        }
        if (objType == 'Survey')
        {
            //Setting the email content in case the class is called when the survey is failed
            htmlBody = '<html><head><title>Test</title></head><body><table><tr><td><table id="1"><tr><td colspan="3">';
            htmlBody = htmlBody + 'A Customer Satisfaction Survey was completed yesterday by one of your Customers. ';
            htmlBody = htmlBody + 'One or more of the key satisfaction scores indicated by the Customer are within the ';
            htmlBody = htmlBody + 'Customer Stated Dissatisfaction Program parameters: </td></tr>';
            htmlBody = htmlBody + '<tr><td colspan="3">&nbsp;</td></tr><tr><td colspan="3">&nbsp;</td></tr>';
            htmlBody = htmlBody + '<tr><td colspan="3">CSI Score equal to or less than 70 </br></td></tr>';
            htmlBody = htmlBody + '<tr><td colspan="3">Maintenance Satisfaction Survey Response equal to or less than 5 </br></td></tr>';
            htmlBody = htmlBody + '<tr><td colspan="3">Likelihood to Renew Survey Response equal to or less than 5 </br></td></tr>';
            htmlBody = htmlBody + '<tr><td colspan="3">Account Manager Satisfaction Survey Response equal to or less than 5 </br></td></tr>';
            htmlBody = htmlBody + '<tr><td colspan="3">Shop Communication Satisfaction equal to or less than 5 </br></td></tr>';
            htmlBody = htmlBody + '<tr><td colspan="3">&nbsp;</td></tr><tr><td colspan="3">&nbsp;</td></tr>';
            htmlBody = htmlBody + '<tr><td colspan="3">All Account Management Team members assigned to this Customer have received this email. ';
            htmlBody = htmlBody + 'You, along with the other Account Management Team members, will receive a separate e-mail ';
            htmlBody = htmlBody + 'with a PDF of the complete survey content. Please follow the established Customer Stated ';
            htmlBody = htmlBody + 'Dissatisfaction Protocol to resolve this issue with the Customer.</br></td></tr>';
            htmlBody = htmlBody + '<tr><td colspan="3">&nbsp;</td></tr><tr><td colspan="3">&nbsp;</td></tr>';
            htmlBody = htmlBody + '<tr><td colspan="3"><b>Customer Name: </b> ' + rs.Ryder_Customer__c + '</td></tr>';
            htmlBody = htmlBody + '<tr><td colspan="3"><b>Branch Name or Number: </b> ' + rs.Customer_Branch__r.Name + '</td></tr>';
            htmlBody = htmlBody + '<tr><td colspan="3"><b>Name of person who Completed Survey: </b> ' + surveyContact[0].Name + '</td></tr>';
            htmlBody = htmlBody + '<tr><td colspan="3"><b>Survey Completion Date: </b> ' + rs.Survey_Submission_Date__c + '</td></tr>';
            htmlBody = htmlBody + '<tr><td colspan="3">&nbsp;</td></tr><tr><td colspan="3">&nbsp;</td></tr>';
            htmlBody = htmlBody + '<tr><td colspan="3"><table border="1"><tr><td align="center">&nbsp;</td>';
            htmlBody = htmlBody + '<td align="center"><b>Score </br>Provided by </br>Customer </b></td>'; 
            htmlBody = htmlBody + '<td align="center"><b>Customer Stated </br>Dissatisfaction </br>Program Minimum </b></td></tr>';
            htmlBody = htmlBody + '<tr><td align="center"><b>CSI Score</b></td>'; 
            htmlBody = htmlBody + '<td align="center"><b>' + rs.CS_Score__c.intValue() + '</b></td>';  
            htmlBody = htmlBody + '<td align="center"><b>70</b></td></tr><tr><td align="center"><b>Maintenance Satisfaction</b></td>';
            htmlBody = htmlBody + '<td align="center"><b>' + strCustSatMntSat + '</b></td>';
            htmlBody = htmlBody + '<td align="center"><b>6</b></td></tr><tr><td align="center"><b>Likelihood to renew</b></td>';
            htmlBody = htmlBody + '<td align="center"><b>' + strCustSatLkhRen + '</b></td>';
            htmlBody = htmlBody + '<td align="center"><b>6</b></td></tr><tr><td align="center"><b>Account Manager Satisfaction</b></td>';
            htmlBody = htmlBody + '<td align="center"><b>' + strCustSatActSat + '</b></td>'; 
            htmlBody = htmlBody + '<td align="center"><b>6</b></td></tr><tr><td align="center"><b>Shop Communication Satisfaction</b></td>'; 
            htmlBody = htmlBody + '<td align="center"><b>' + strCustSatShpCom + '</b></td>'; 
            htmlBody = htmlBody + '<td align="center"><b>6</b></td></tr></table></td></tr><tr><td colspan="3"></br></br>If you should have ';
            htmlBody = htmlBody + 'questions, please contact your CDM. </td></tr></table></td></tr></table></body></html>';
            
            //Setting the subject of the email in case the class is called when the survey is failed
            emailSubject = 'Customer Stated Dissatisfaction';
            caller = 'SURVEY';
        }
        else
        {
            //Setting the email content in case the class is called when the follow up task is closed as unresolved
            htmlBody = '<html><head><title></title></head><body><table><tr><td><table id="1"><tr><td colspan="3">';
            htmlBody = htmlBody + ' As you know, <b>' + rs.Ryder_Customer__c + '</b> completed a Customer Satisfaction survey 60 days';
            htmlBody = htmlBody + ' ago and provided responses that triggered the Customer Stated Dissatisfaction process.</td></tr>';
            htmlBody = htmlBody + ' <tr><td colspan="3">&nbsp;</td></tr><tr><td colspan="3">The Customer was recently re-contacted by'; 
            htmlBody = htmlBody + ' Ryder to determine if the situation has been resolved. The Customer indicated that he/she is not';
            htmlBody = htmlBody + ' satisfied with the problem resolution. </td></tr><tr><td colspan="3">&nbsp;</td></tr>';
            htmlBody = htmlBody + ' <tr><td colspan="3">This notification has been delivered to the entire Account Management';
            htmlBody = htmlBody + ' Team to ensure that all team members are aware of the problem. However, it is specifically';
            htmlBody = htmlBody + ' the CDM’s responsibility to coordinate a meeting with the Account Management Team and/or';
            htmlBody = htmlBody + ' the Customer within the next 48 hours to determine the plan for corrective action.</td></tr>';
            htmlBody = htmlBody + ' <tr><td colspan="3">&nbsp;</td></tr><tr><td colspan="3">In 60 days Ryder will again reach out';
            htmlBody = htmlBody + ' to this Customer with a brief survey.  It is expected that at that time the Customer will be';
            htmlBody = htmlBody + ' satisfied with Ryder’s effort to resolve the issue. If not, another email notification will be'; 
            htmlBody = htmlBody + ' sent to the entire Account Management Team.</td></tr></table></td></tr></table></body></html>';
            
            //Setting the subject of the email case the class is called when the follow up task is closed as unresolved
            emailSubject = 'Unresolved Customer Issue';
            caller ='Other';
        }
         for(OrgWideEmailAddress owa : [select Address from OrgWideEmailAddress]) 
        {
            system.debug('Saad owa.Address = ' + owa.Address);
            if(owa.Address.contains('rydercsi'))
            {
            	 fromId = owa.Address; 
            	 break;
            }
        } 
        mailType = 'HTML';
        //Add the email properties in below Order only.
	    //FromID ### Email Ids ### Email Subject ### Message ### Attachment ### Type (HTML,text etc) ### Caller.
        emailMessage = fromId + '###' +
        					   EMailUtil.PrepareMailIds(idList) + '###' +
        					   emailSubject  + '###' +
        					   htmlBody + '###' +
        					   '' + '###' +
        					   mailType + '###' +
        					   caller;
  		mailList.add(emailMessage);
  		EMailUtil.sendRyderEmail(mailList,false);
    }        
}