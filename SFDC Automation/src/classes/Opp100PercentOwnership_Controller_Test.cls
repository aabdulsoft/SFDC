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
@isTest (seeAllData=true)
private class Opp100PercentOwnership_Controller_Test {

    static testMethod void myUnitTest()
    {
        // TO DO: implement unit test
        Test.startTest();
        
        //RSMCreateTestData.GetCustomSettingsRecord();
        List<User> lUser = [select Id, ManagerId from User where IsActive = true and ManagerId != null limit 1];
        Opportunity Opp = new Opportunity();
        System.runAs(lUser[0])
    	{
    		ApexPages.StandardController stdController = new ApexPages.StandardController(new Opportunity());
	        Opp100PercentOwnership_Controller ClassObj = new Opp100PercentOwnership_Controller(stdController);
	        
	        Account ac = new Account();
	        ac.Name = 'Test1';
	        ac.LesseeNo__c = '123';
	        ac.RSM_CCMs__c = UserInfo.getUserId();
	        ac.RSM_Onboarding__c = '';
	        ac.RSM_AC_Classification__c  =  'National';
	        ac.ShippingState = 'CA';
	        insert ac;
			
			Contact c1 = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = ac.Id);
	    	insert c1;
	    
	        
	        Opp.accountid = ac.id;
	        Opp.name = 'test acct1';
	        Opp.stagename='Weight Solution Options';
	        Opp.Original_Decision_Maker__c = c1.id;
	        Opp.closedate=date.today()+1;
	        Opp.estimated_proposal_date__c = date.today();
	        Opp.recordtypeid = [select id from recordtype where name = 'Standard Opportunity'][0].id;	        
	        insert Opp;
	        
	        Opp.StageName = 'Signed';
	        Opp.Reason_Won_Lost__c = 'Ability To Extend Insurence';
	        Opp.Deal_lost_to_Won_from_whom__c = 'Ownership';
	        Opp.Customer_100_Ownership__c = 'Yes';        
	        update Opp;
    	}
    	lUser = [select Id, ManagerId from User where Id =: lUser[0].ManagerId limit 1];
    	System.runAs(lUser[0])
    	{
	        ApexPages.StandardController stdController = new ApexPages.StandardController(Opp);
	        Opp100PercentOwnership_Controller ClassObj = new Opp100PercentOwnership_Controller(stdController);
	        ClassObj.getOwnership100();
	        for(Opp100PercentOwnership_Controller.InnerClass Obj : ClassObj.InnerClassObj)
	        {
	        	Obj.IsSelected = true;
	        	Obj.sComment = 'Test';
	        }
	        ClassObj.SubmitData();
    	}
        Test.stopTest();
    }
}