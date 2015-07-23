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
private class UVS_ProcessBillOfSales_Test
{
    static testMethod void ProcessBillOfSalesRecords()
    {
        // TO DO: implement unit test
        Test.startTest();        
	        RSMCreateTestData.GetCustomSettingsRecord();
	        CreateCustomSettingsData();
	        
	        Account Acc1 = new Account();
	        Acc1.name = 'Test';
	        Acc1.account_classification__c = 'Key Account';
	        Acc1.central_decisionmaking__c = False;
	        Acc1.type = 'Customer';
	        Acc1.Account_Classification__c = 'National';
	        Acc1.LesseeNo__c = '0123123';
	        Acc1.SAM_Cust_ID__c = '12';
	        insert Acc1;
	        system.assertEquals('12', Acc1.SAM_Cust_ID__c);
	        Ryder_Branch__c rb = new Ryder_Branch__c();
			rb.Branch_Code__c = '123';
			rb.name = 'Test';
			insert rb;
			system.assertEquals('123', rb.Branch_Code__c);			
			Customer_Branch__c CustomerBranch = new Customer_Branch__c();
	        CustomerBranch.Ryder_branch__c = rb.id;
	        CustomerBranch.Name = '12 123 Test';
	        CustomerBranch.Ryder_HQ_Account__c = Acc1.Id;
	        insert CustomerBranch;
	    
	        Contact Cont1 = new Contact();
	        Cont1.AccountId = Acc1.Id;
	        Cont1.FirstName = 'Test Contact';
	        Cont1.LastName = 'Sample';
	        Cont1.Email = 'test8979123@rydertest.com';
	        Cont1.Maintenance_Contact_Type__c = 'Primary';
	        Cont1.Phone = '(123) 456-8789';
	        Cont1.Contact_Source__c = 'Lead Conversion';
	        insert Cont1;
	    	system.assertEquals('Sample', Cont1.LastName);
	        Vehicle__c Vehicle = new Vehicle__c();
	        Vehicle.Name = '1234';
	        Vehicle.Unit__c = '1234';
	        Vehicle.CUSTOMER_BRANCH__c = CustomerBranch.Id;
	        Vehicle.RSM__c = 'Approved';
	        Vehicle.Account__c = Acc1.Id;
	        insert Vehicle;
	    	
	    	Opportunity Opp = new Opportunity();
	        Opp.AccountId = Acc1.id;
	        Opp.Original_Decision_Maker__c = Cont1.id;
	        Opp.CloseDate = date.today()+2;
	        Opp.StageName = 'Qualifying';
	        Opp.name = 'test opportunity';
	        Opp.Estimated_Proposal_Date__c = System.today() + 1;
	        Opp.ext_pipeline_id__c = '12345';
	        insert Opp;
	    	system.assertEquals('12345', Opp.ext_pipeline_id__c);
	    	// Use case where new Customer Branch inserted
	    	UVS_Bill_of_Sale__c ObjBill = new UVS_Bill_of_Sale__c();
	    	ObjBill.UNIT_ID__c = '1234';
	    	ObjBill.OPPORTUNITYID__c = '12345';
	    	ObjBill.PROCESSED__c = false;
	    	ObjBill.TOTAL_COST_OF_SALE__c = 1000;
	    	ObjBill.SOLD_LOCATION_CODE__c = '123';
	    	insert ObjBill;
	    	system.assertEquals(false, ObjBill.PROCESSED__c);	
	        UVS_ProcessBillOfSales UVS_ProcessBillOfSalesObj = new UVS_ProcessBillOfSales(); 
	        database.executebatch(UVS_ProcessBillOfSalesObj,200);
	        
	        // Use case where existing Customer Branch used
	        UVS_Bill_of_Sale__c ObjBill1 = new UVS_Bill_of_Sale__c();
	    	ObjBill1.UNIT_ID__c = '1234';
	    	ObjBill1.OPPORTUNITYID__c = '12345';
	    	ObjBill1.PROCESSED__c = false;
	    	ObjBill1.TOTAL_COST_OF_SALE__c = 1000;
	    	ObjBill1.SOLD_LOCATION_CODE__c = '123';
	    	insert ObjBill1;
	    	system.assertEquals(false, ObjBill1.PROCESSED__c);	
	        database.executebatch(UVS_ProcessBillOfSalesObj,200);	        
        Test.stopTest();
    }
    public static void CreateCustomSettingsData()
    {
    	RecordType RT = [Select r.Id From RecordType r where SobjectType = 'Customer_Branch__c' and Name = 'UVS'];
    	Global_Settings__c Customer_BranchRecordType = new Global_Settings__c(Name = '11');
    	Customer_BranchRecordType.IsActive__c = True;
    	Customer_BranchRecordType.Comment__c = 'RecordType';
    	Customer_BranchRecordType.Type__c = 'RecordType';
    	Customer_BranchRecordType.Object_Name__c = 'Customer / Branch';
    	Customer_BranchRecordType.Value__c = RT.ID;
    	insert Customer_BranchRecordType;
    	
    	Global_Settings__c EmailAddress = new Global_Settings__c(Name = '12');
    	EmailAddress.IsActive__c = True;
    	EmailAddress.Comment__c = 'Used in class UVS_ProcessBillOfSales.';
    	EmailAddress.Type__c = 'Email Address';
    	EmailAddress.Object_Name__c = 'EmailAddress';
    	EmailAddress.Value__c = 'nitin_gupta@ryder.com';
    	insert EmailAddress;
    }
}