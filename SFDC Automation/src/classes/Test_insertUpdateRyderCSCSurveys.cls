@isTest
private class Test_insertUpdateRyderCSCSurveys {

    static testMethod void Test_insertUpdateRyderCSCSurvey() {
        // set test data
        // create parent account
        RecordType rCase = [Select r.SobjectType, r.Name, r.DeveloperName, r.IsActive, r.Id From RecordType r where r.SobjectType='Case' and  r.Name='Sales Pilot'];
        RecordType rSurvey = [Select r.SobjectType, r.Name, r.DeveloperName, r.IsActive, r.Id From RecordType r where r.SobjectType='Ryder_CSC_Surveys__c' and  r.Name='Pilot Survey'];
        
		Account parentAcct = TestUtil.createAccount('Ryder FMS Parent Account', 'Customer');
        insert parentAcct;
        
        Contact con = TestUtil.createContact(parentAcct.Id);
         insert con;
         // neelima-03/13/2012-case insert test is not there. so including case insert in the test for coverage of insert case trigger too.
          Test.startTest();
         
         Case c= new Case();
        // c.RecordTypeId=rCase.Id;
         c.Contact__c=con.Id;
         c.Caller_Type__c='External';
         c.Status='New';
         c.Origin='Sales Pilot';
         c.Address_Verified__c='Yes';
         c.Email_Address_Verified__c='Yes';
         c.Description='Test survey pilot case';
         c.AccountId=parentAcct.Id;
         
         Insert c;
        
       
        Ryder_CSC_Surveys__C rs= new Ryder_CSC_Surveys__C();
        rs.Contact__c=con.Id;
        rs.Case__c=c.Id;
        rs.Feedback_about_the_agent__c='Test Agent Feedback';
        rs.How_satisfied_are_you_with_the_agent__c='Satisfied';
        rs.Was_your_call_resolved__c='Yes';
        rs.Was_your_issue_addressed__c='Yes';
        rs.Likelihood_of_calling_again__c='Likely';
        rs.RecordTypeId=rSurvey.Id;
        
        Insert rs;
        
        // update rs update on all fields for code coverage in if condition
        rs.Was_your_call_resolved__c='No';
        update rs;
        rs.How_satisfied_are_you_with_the_agent__c='DisSatisfied';
        update rs;
        rs.Likelihood_of_calling_again__c='Not Likely';
        update rs;
        rs.Was_your_issue_addressed__c='No';
        update rs;
        Test.stopTest();
              
        
        
    }
}