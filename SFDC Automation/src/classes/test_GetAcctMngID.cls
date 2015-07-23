@isTest(SeeAllData=true)
private class test_GetAcctMngID {
    static testMethod void TestGetAcctMngID(){
         /*Ryder_Surveys__c rs= new Ryder_Surveys__c();
         rs.RecordTypeId=[Select Id from RecordType where name=: 'CSI Survey' and SobjectType =: 'Ryder_Surveys__c'].Id;
         rs.Customer_Sat_Overall_Satisfaction_FSL__c= '8';
         rs.Customer_Sat_Likelihood_to_Renew__c='8';
         rs.Customer_Sat_Willingness_to_Refer__c ='8';
         rs.Customer_Sat_Shop_Communications__c='8';
         rs.Customer_Sat_Maintenance_Satisfaction__c ='8';
         rs.Customer_Sat_Acct_Mgr_Satisfaction__c='8';
         insert rs; 
         */
         Profile p = [select id from profile where name like 'System Administrator' LIMIT 1];
         User u = new User(alias = 'testee', email='testee@testee.com',lastname = 'Testing', username = 'testing123@testing123.com',profileid = p.id, emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles', Sales_Territory__c='Bluegrass');
         insert u;
         Account acct = new Account(name = 'Ryder PDF', CustProspectID__c = '9999',LesseeNo__c = '0009999');
         insert acct;
         Contact c = new Contact(AccountID = acct.id, Email = 'abc@abc.com',LastName = 'Ryder', FirstName = 'PDF Contact', Title = 'Chief PDF Reader', Fax = '123-456-9089');
         insert c;
         Ryder_Branch__c rb = new Ryder_Branch__c(Name = 'Test PDF Ryder Branch',Area_Name__c = 'Test PDF Area', CBU_Code__c = '1234', CBU_Name__c = 'Test PDF', Account_Manager_Email__c = NULL, Director_of_Asset_Management_Email__c = NULL, Director_of_Ops_Email__c = '123@123.com',Director_of_Rental_Email__c = '456@456.com', Director_of_Sales_Email__c = '567@567.com', Lease_Administrator_2_Email__c = '678@678.com', Lease_Administrator_Email__c = '789@789.com', Maintenance_Manager_Email__c = '012@012.com',Rental_Manager_Email__c = '234@234.com', Senior_VP_Email__c = '349@349.com', Senior_VP_of_Ops_Email__c = '469@469.com', Service_Manager_Email__c = '287@287.com',Quality_Manager_Email__c = '285@285.com', Quality_VP_Email__c = '286@286.com', Quality_Director_Email__c = '964@964.com', Finance_Manager_Email__c = '109@109.com', Finance_Director_Email__c = '110@110.com', Finance_VP_Email__c = '121@121.com');
         insert rb;
         Customer_Branch__c cb = new Customer_Branch__c(name = '9999 - Test Ryder PDF Branch',Ryder_Branch__c = rb.id, Customer_Branch_Owner__c = u.id, Ryder_HQ_Account__c = acct.id);
         insert cb;
         Task t = new Task(Type = 'Survey', Subject = 'Customer Sat Survey', ActivityDate = System.Today(), Priority = 'Medium', Survey_Sub_Type__c = 'Large', Status = 'Completed', whoid = c.id, whatid = cb.id, Call_Attempts__c = 2, Survey_Submission_Date__c = System.Now(),  Survey_ID__c = 'http://www.123surveypdftest');
         insert t;
         Ryder_Surveys__c rs = new Ryder_Surveys__c(CS_Score__c=4,Contact__c=c.id,Customer_Branch__c= cb.Id,Survey_Submission_Date__c = t.Survey_Submission_Date__c, Activity_ID__c = t.id, Customer_Sat_Likelihood_to_Renew__c = '2', Customer_Sat_Overall_Satisfaction_FSL__c = '4',Customer_Sat_Willingness_to_Refer__c = '4', Customer_Sat_Maintenance_Satisfaction__c = '3', Customer_Sat_Shop_Communications__c = '6',Customer_Sat_Acct_Mgr_Satisfaction__c = '4', Customer_Satisfaction_Survey__c = t.Survey_ID__c, Survey_Details_Loaded__c = True);
         insert rs;
        
         
         GetAcctMngID.GetDetails(rs.Id,'Survey');
        // GetAcctMngID.sendEmailToList(rb.Id,rs,'Survey'); 
    
    }
}