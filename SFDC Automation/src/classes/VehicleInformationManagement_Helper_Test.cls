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
private class VehicleInformationManagement_Helper_Test {

    static testMethod void UnitTest_SheduleA_InsertUpdate()
    {
        // TO DO: implement unit test
        Test.startTest();
        
        RSMCreateTestData.GetCustomSettingsRecord();
        
        Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '0123123';
        insert Acc1;
        
        Ryder_Branch__c rb = new Ryder_Branch__c();
		rb.Branch_Code__c = '33178';
		rb.name = 'Test';
		insert rb;
			
        Customer_Branch__c CustomerBranch = new Customer_Branch__c();
        CustomerBranch.Ryder_Branch__c = rb.id;
        CustomerBranch.Name = 'Test Customer Branch';
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
    
		// Executing the ScheduleARequestManagement trigger on ScheduleA Request Object
		UVS_SheduleA_Request__c SheduleARequest = new UVS_SheduleA_Request__c(Account_Name__c = Acc1.Id, 
																			Request_Type__c = 'ScheduleA', 
																			Buy_Out_Approved__c = 'New Request', 
																			SalesTax_Exempt__c = 'No', 
																			Contact_Name__c = Cont1.Id);
		insert SheduleARequest;
		
		// Execution of After Insert trigger on SheduleA Request Object where it set the Default User Price Name
		SheduleARequest = [select Request_Type__c, User_Pricing_Name__c, Id from UVS_SheduleA_Request__c where Id = : SheduleARequest.Id];
		System.assertEquals(LABEL.UVS_SA_Pricing_User, SheduleARequest.User_Pricing_Name__c);
		
		// Execute after Udpate and set the Default User Price Name as there is no Vehicle Information record as of now 
		SheduleARequest.Request_Type__c = 'End of Lease';
		update SheduleARequest;
		
		// Execute after Udpate and set the Default User Price Name as Request Type is ScheduleA
		SheduleARequest.Request_Type__c = 'ScheduleA';
		update SheduleARequest;
		
		Test.stopTest();
    }
    static testMethod void UnitTest_SheduleA_Update()
    {
        // TO DO: implement unit test
        Test.startTest();
        
        RSMCreateTestData.GetCustomSettingsRecord();
        
        Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '0123123';
        insert Acc1;
        
        Ryder_Branch__c rb = new Ryder_Branch__c();
		rb.Branch_Code__c = 'Test';
		rb.name = 'Test';
		rb.Zip_Code__c = '33178';
		insert rb;
			
        Customer_Branch__c CustomerBranch = new Customer_Branch__c();
        CustomerBranch.Ryder_Branch__c = rb.id;
        CustomerBranch.Name = 'Test Customer Branch';
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
    
        Vehicle__c Vehicle = new Vehicle__c();
        Vehicle.Name = '1234';
        Vehicle.CUSTOMER_BRANCH__c = CustomerBranch.Id;
        Vehicle.RSM__c = 'Approved';
        Vehicle.Account__c = Acc1.Id;
        insert Vehicle;
        
        User uvsUser = TestUtilUVS.createUser(true);        
		Postal_Code__c Postal_Code = new Postal_Code__c(Name = '33178', Postal_Code__c = '33178', DOS__c = uvsUser.Id, 
                            							City__c = 'Medlay', State__c = 'FL', 
                            							State_Name__c = 'Florida', Country__c = 'US', 
                            							UVS_Assignee__c = uvsUser.Id);
		
      	insert Postal_Code;
		
		// Executing the ScheduleARequestManagement trigger on ScheduleA Request Object
		UVS_SheduleA_Request__c SheduleARequest = new UVS_SheduleA_Request__c(Account_Name__c = Acc1.Id, 
																			Request_Type__c = 'ScheduleA', 
																			Buy_Out_Approved__c = 'New Request', 
																			SalesTax_Exempt__c = 'No', 
																			Contact_Name__c = Cont1.Id);
		insert SheduleARequest;
		
		// Execution of After Insert trigger on SheduleA Request Object where it set the Default User Price Name
		// User_Pricing_Name must be the same as Custom Label User
		SheduleARequest = [select User_Pricing_Name__c, Id from UVS_SheduleA_Request__c where Id = : SheduleARequest.Id];
		System.assertEquals(LABEL.UVS_SA_Pricing_User, SheduleARequest.User_Pricing_Name__c);
		
		// Executing the VehicleInformationManagement trigger on Vehicle Information Object and 
		// validating the use case where where Request_Type__c = 'ScheduleA' and  aVehicle Information record is added
		//SheduleARequest.User_Pricing_Name__c = null;
		SheduleARequest.Request_Type__c = 'End of Lease';
		update SheduleARequest;
		
		// Execution of After Insert trigger on Vehicle Information Object where
        // it set the User Price Name based on Vehicle Information Postal Code field
		UVS_Vehicle_Information__c VehicleInformation = new UVS_Vehicle_Information__c
															(Vehicle_Number__c = Vehicle.id, 
															Anniversary_Date__c = system.today().addDays(50), 
															Buy_Out_Date__c = system.today().addDays(50), 
															ScheduleA_Original_Value__c = 50, 
															ScheduleA_Monthly_Depreciation__c = 1000, 
															ScheduleA_Monthly_Fixed_Rate__c = 800, 
															Comments__c = 'Test', Lease_Term__c = '12', 
															Book_Value__c = 1000, Pre_Paid_Interest__c = 100, 
															Sales_Tax__c = 10, ScheduleA_Request__c = SheduleARequest.Id);
        insert VehicleInformation;
        SheduleARequest = [select User_Pricing_Name__c, Id from UVS_SheduleA_Request__c where Id = : SheduleARequest.Id];
		// User_Pricing_Name must be the same as in postal Code record
		System.assertEquals(uvsUser.Id, SheduleARequest.User_Pricing_Name__c);
		
        Test.stopTest();
    }
}