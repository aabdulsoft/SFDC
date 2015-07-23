/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_FailedSurveyTrigger {

    static testMethod void AddSurvey()
    {
    	 Profile p = [select id from profile where name like 'System Administrator' LIMIT 1];
        User u = new User(alias = 'testee', email='testee@testee.com',lastname = 'Testing', username = 'testing123@testing123.com',profileid = p.id, emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles', Sales_Territory__c='Bluegrass');
        
        insert u;
        
        User testuser = [Select id, Name from User where alias = 'testee'];
           
        Account acct = new Account(name = 'Ryder PDF', CustProspectID__c = '9999',LesseeNo__c = '0009999');
        insert acct;
        system.debug ('Account created' + acct);
        
        Ryder_Branch__c rb = new Ryder_Branch__c(Name = 'Test PDF Ryder Branch',Area_Name__c = 'Test PDF Area', CBU_Code__c = '1234', CBU_Name__c = 'Test PDF', Account_Manager_Email__c = NULL, Director_of_Asset_Management_Email__c = NULL, Director_of_Ops_Email__c = '123@123.com',Director_of_Rental_Email__c = '456@456.com', Director_of_Sales_Email__c = '567@567.com', Lease_Administrator_2_Email__c = '678@678.com', Lease_Administrator_Email__c = '789@789.com', Maintenance_Manager_Email__c = '012@012.com',Rental_Manager_Email__c = '234@234.com', Senior_VP_Email__c = '349@349.com', Senior_VP_of_Ops_Email__c = '469@469.com', Service_Manager_Email__c = '287@287.com',Quality_Manager_Email__c = '285@285.com', Quality_VP_Email__c = '286@286.com', Quality_Director_Email__c = '964@964.com', Finance_Manager_Email__c = '109@109.com', Finance_Director_Email__c = '110@110.com', Finance_VP_Email__c = '121@121.com');
        insert rb;
        
        Customer_Branch__c cb = new Customer_Branch__c(name = '9999 - Test Ryder PDF Branch',Ryder_Branch__c = rb.id, Customer_Branch_Owner__c = u.id, Ryder_HQ_Account__c = acct.id);
        insert cb;
        
        String cb_id = cb.id;
        
        Contact c = new Contact(AccountID = acct.id, Email = 'abc@abc.com',LastName = 'Ryder', FirstName = 'PDF Contact', Title = 'Chief PDF Reader', Fax = '123-456-9089');
        insert c;
        
        Task t = new Task(Type = 'Survey', Subject = 'Customer Sat Survey', ActivityDate = System.Today(), Priority = 'Medium', Survey_Sub_Type__c = 'Large', Status = 'Completed', whoid = c.id, whatid = cb.id, Call_Attempts__c = 2, Survey_Submission_Date__c = System.Now(),  Survey_ID__c = 'http://www.123surveypdftest');
        insert t;
        
        String task_id = t.id;
        
        Case cs = new Case(Origin = 'CSI Closed Loop', Contact__c = c.id, Customer_Branch__c = cb.id, Description = 'PDF Case', Priority = 'Low', Status = 'Open', Type = 'External', Major_Category__c = 'Billing', Subcategory__c = 'Upset Customer', Ryder_Branch__c = rb.id, Activity_ID__c = t.id);
        insert cs;
        
        Ryder_Surveys__c rs = new Ryder_Surveys__c(Survey_Submission_Date__c = t.Survey_Submission_Date__c, Activity_ID__c = t.id, Customer_Sat_Likelihood_to_Renew__c = '2', Customer_Sat_Overall_Satisfaction_FSL__c = '4',Customer_Sat_Willingness_to_Refer__c = '4', Customer_Sat_Maintenance_Satisfaction__c = '3', Customer_Sat_Shop_Communications__c = '6',Customer_Sat_Acct_Mgr_Satisfaction__c = '4', Customer_Satisfaction_Survey__c = t.Survey_ID__c, Survey_Details_Loaded__c = True);
        insert rs;
        
        String rs_id = rs.id;
        
        List <Ryder_Survey_Response__c> rsrs = new List <Ryder_Survey_Response__c>();
        Ryder_Survey_Response__c rsr = new Ryder_Survey_Response__c();
    

    // Question 22
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
        rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 22;
        rsr.Question_Response__c = 'Decision Maker';
        rsrs.add(rsr);
        
        // Question 23
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
        rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 23;
        rsr.Question_Response__c = 'N/A';
        rsrs.add(rsr);
        
        // Question 24
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
        rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 24;
        rsr.Question_Response__c = 'I use RPM.';
        rsrs.add(rsr);
        
        // Question 25
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
        rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 25;
        rsr.Question_Response__c = 'N/A';
        rsrs.add(rsr);
        
        // Question 26
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
        rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 26;
        rsr.Question_Response__c = 'I outsource maintenance of all my vehicles to Ryder.';
        rsrs.add(rsr);
        
        // Question 27
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;   
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 27;
        rsr.Question_Response__c = 'Cost Savings';
        rsrs.add(rsr);
        
        // Question 28
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;   
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 28;
        rsr.Question_Response__c = 'Provider 1 = HOGAN';
        rsrs.add(rsr);
        
        // Question 29
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 29;
        rsr.Question_Response__c = 'Customer is very happy with Ryder services.';
        rsrs.add(rsr);
        
        // Question 30
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 30;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 31
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 31;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 31.10
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 31.10;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 32
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 32;
        rsr.Question_Response__c = '3';
        rsrs.add(rsr);
        
        // Question 32.10
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 32.10;
        rsr.Question_Response__c = '4';
        rsrs.add(rsr);
        
        // Question 33
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 33;
        rsr.Question_Response__c = 'No need to review';
        rsrs.add(rsr);
        
        // Question 34
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 34;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 35
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 35;
        rsr.Question_Response__c = 'N/A';
        rsrs.add(rsr);
        
        // Question 36
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 36;
        rsr.Question_Response__c = '4';
        rsrs.add(rsr);
        
        // Question 36.10
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 36.10;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 36.20
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 36.20;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 36.30
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 36.30;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 36.40
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 36.40;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 36.50
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 36.50;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 36.60
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 36.60;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 36.70
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 36.70;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 37
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 37;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 38
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 38;
        rsr.Question_Response__c = '3';
        rsrs.add(rsr);
        
        // Question 39
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 39;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 40
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 40;
        rsr.Question_Response__c = '4';
        rsrs.add(rsr);
        
        // Question 40.10
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 40.10;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 40.20
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 40.20;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 40.30
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 40.30;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 40.40
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 40.40;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 40.50
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 40.50;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 40.60
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 40.60;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 40.70
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 40.70;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 41
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 41;
        rsr.Question_Response__c = 'Never receive the repaired truck on time nor when promised.  Usually 2 to 3 days late.';
        rsrs.add(rsr);
        
        // Question 42
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 42;
        rsr.Question_Response__c = 'Not enough stalls to wash all of our trucks.';
        rsrs.add(rsr);
        
        // Question 43
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 43;
        rsr.Question_Response__c = '3';
        rsrs.add(rsr);
        
        // Question 44
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 44;
        rsr.Question_Response__c = 'N/A';
        rsrs.add(rsr);
        
        // Question 45
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 45;
        rsr.Question_Response__c = '4';
        rsrs.add(rsr);
        
        // Question 46
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 46;
        rsr.Question_Response__c = 'Invoices are slow to receive at times.';
        rsrs.add(rsr);
        
        // Question 47
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 47;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 48
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 48;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 49
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 49;
        rsr.Question_Response__c = 'N/A';
        rsrs.add(rsr);
        
        // Question 50
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 50;
        rsr.Question_Response__c = 'N/A';
        rsrs.add(rsr);
        
        // Question 51
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 51;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 52
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 52;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 52.10
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 52.10;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 52.20
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 52.20;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 52.40
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 52.40;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 53
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 53;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 54
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 54;
        rsr.Question_Response__c = '3';
        rsrs.add(rsr);
        
        // Question 55
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 55;
        rsr.Question_Response__c = '4';
        rsrs.add(rsr);
        
        // Question 56
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 56;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 57
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 57;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 58
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 58;
        rsr.Question_Response__c = '3';
        rsrs.add(rsr);
        
        // Question 59
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 59;
        rsr.Question_Response__c = 'N/A';
        rsrs.add(rsr);
        
        // Question 60
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 60;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 60.10
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 60.10;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 60.20
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 60.20;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 60.30
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 60.30;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 60.40
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 60.40;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 60.50
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 60.50;
        rsr.Question_Response__c = '1';
        rsrs.add(rsr);
        
        // Question 60.60
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 60.60;
        rsr.Question_Response__c = '2';
        rsrs.add(rsr);
        
        // Question 61
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 61;
        rsr.Question_Response__c = 'N/A';
        rsrs.add(rsr);
        
        // Question 62
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 62;
        rsr.Question_Response__c = 'Yes';
        rsrs.add(rsr);
        
        // Question 63
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;   
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 63;
        rsr.Question_Response__c = 'Prefer an email link to complete survey online';
        rsrs.add(rsr);
        
        // Question 64
        rsr = new Ryder_Survey_Response__c();
        rsr.Activity_ID__c = task_id;
        rsr.Customer_Branch__c = cb_id;
        rsr.CT_Survey_ID__c = t.Survey_ID__c;  
    rsr.SurveyID__c = rs_id;
        rsr.Question_Number__c = 64;
        rsr.Question_Response__c = 'N/A';
        rsrs.add(rsr);

    try{
        insert rsrs;
        System.debug('Successfully inserted all survey responses.');
    }
    catch (System.DMLException e){
        System.debug('Could not insert all the survey resposnes.');
    }

        Test.StartTest();
        // Test survey list email
        //SendRyderSurveyEmail.sendActivityMailPDF('a0bR00000053NogIAE');
       // SendRyderSurveyEmail.sendActivityMailPDF(task_id);
        SendRyderSurveyEmail.sendActivityMail(task_id, UserInfo.getSessionId());
        // Test survey content retrievel from both internal and external 
        // Internal
        //RyderSurveyPDFContent.GetSurveyContentByActivityId('00TR000000CUYHM');
        // RyderSurveyPDFContent.GetSurveyContentByActivityId(task_id);
          Test.stopTest();
      

    }

}