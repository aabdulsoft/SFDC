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
private class RevenueRollupAccount_Test
{
	static testMethod void myUnitTest()
	{
		RSMCreateTestData.GetCustomSettingsRecord();
		
		Account Acc1=new Account ();
        Acc1.RSM_Billing__c=true;
        Acc1.Name ='Test Account 1';
        Acc1.LesseeNo__c = '0000001';
        Acc1.Update_Revenue__c = true;
        insert Acc1;
        
        Customer_Branch__c cb=new Customer_Branch__c();
        cb.Name='Test Customer Branch Acc';
        cb.Ryder_HQ_Account__c=Acc1.Id;
        insert cb;
        
        Contact c = New Contact (); 
    	c.FirstName = 'TestFirst'; 
    	c.LastName = 'TestLast'; 
    	c.email = 'TestContact@test.com';
    	c.accountId = Acc1.Id;
    	c.Contact_Source__c = 'Lead Conversion';
    	insert c;
    	
    	Vehicle__c v1=new Vehicle__c();
        v1.RSM_Billing_Status__c=True;
        v1.CUSTOMER_BRANCH__c=cb.Id;
        v1.Name='123451';
        v1.Account__c=Acc1.Id;
        v1.RSM__c='Approved';
        v1.RSM_Service_Level__c = 'Plus 1';
        v1.RSM_Service_Level_Prior_value__c = 'Plus';
        v1.EXPIRATION_DATE__c = System.today().addDays(20);
        v1.Life_to_Date_Revenue__c = 100;
        insert v1;
        
    	RSM_Contract__c rc=new RSM_Contract__c();
        rc.Name='98765';
        rc.Lessee__c = '0000001';
        rc.Status_Name__c = 'Approved';
        rc.Account__c = Acc1.id;
        rc.Effective_Date__c = System.now();
        insert rc;
        
        RSM_ContractDetail__c rcd1=new RSM_ContractDetail__c();
        rcd1.Contract_Detail_ID__c = 987651;
        rcd1.Is_Current__c=True;
        rcd1.Unit_Number__c=v1.Id;
        rcd1.Contract_Number__c=rc.Id;
        rcd1.Action_Name__c = 'Add';
        rcd1.Rate__c = 10;
        insert rcd1;
        
        v1.EXPIRATION_DATE__c = System.today().addDays(20);
        v1.Life_to_Date_Revenue__c = 500;
        update v1;
        rc.Effective_Date__c = System.now().addDays(-1);
        update rc;
        rcd1.Rate__c = 20;
        update rcd1;
        
        Test.startTest();
         
        RevenueRollupAccount RevenueRollup = new RevenueRollupAccount(); 
        database.executebatch(RevenueRollup,1);
        
        Test.stopTest();
	}
}