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
private class RSM_Phase3_AllTestCoverage
{
	public static Account InsertAccount(String RecordTypeId)
	{
		Account Acc1 = new Account();
	    Acc1.Name = 'Test';
	    Acc1.account_classification__c = 'Key Account';
	    Acc1.central_decisionmaking__c = False;
	    Acc1.type = 'Customer';
	    Acc1.Account_Classification__c = 'National';
	    Acc1.LesseeNo__c = '0123123';
        Acc1.Type='Customer';
        Acc1.BillingStreet='13335 Seventh Concession';
        Acc1.BillingCity='Miami';
        Acc1.ShippingState='FL';
        Acc1.ShippingCountry='US';
        //Acc1.CustomerTypeID__c=;
        Acc1.BillingPostalCode = '33378';
        Acc1.RecordTypeId = RecordTypeId;
        insert Acc1;
        return Acc1;
    }
	public static Customer_Branch__c InsertCustomerBranch(String AccId)
	{
		Customer_Branch__c CustomerBranch = new Customer_Branch__c();
	    CustomerBranch.Name = 'Test Customer Branch';
	    CustomerBranch.Ryder_HQ_Account__c = AccId;
	    insert CustomerBranch;
	    return CustomerBranch;
	}
	public static Contact InsertContact(String AccId)
	{
		Contact Cont1 = new Contact();
		Cont1.AccountId = AccId;
		Cont1.FirstName = 'Test Contact';
		Cont1.LastName = 'Sample';
		Cont1.Email = 'test8979123@rydertest.com';
		Cont1.Maintenance_Contact_Type__c = 'Primary';
		Cont1.Phone = '(123) 456-8789';
		Cont1.Contact_Source__c = 'Lead Conversion';
		insert Cont1;
	    return Cont1;
	}
	public static Key_Contact__c InsertKeyContact(String AccId, String ContId, String CustomerBranchId)
	{
		Key_Contact__c Key_Contact = new Key_Contact__c(Contact_Role__c = 'RydeSmart',
    													Contact__c = ContId, AccountId__c = AccId, 
    													Customer_Branch__c = CustomerBranchId, Available_24_7__c = 'YES', 
    													Contact_Type__c = 'Primary');
    	insert Key_Contact;
	    return Key_Contact;
	}
	public static Vehicle__c InsertVehicle(String AccId, String CustomerBranchId)
	{
		Vehicle__c Vehicle = new Vehicle__c();
	    Vehicle.Name = '1234';
	    Vehicle.CUSTOMER_BRANCH__c = CustomerBranchId;
	    Vehicle.RSM__c = 'Approved';
	    Vehicle.Account__c = AccId;
	    insert Vehicle;
	    return Vehicle;
	}
	public static RSM_VehicleValidationDetails__c InsertVehicleValidation(String VehicleId, String Validation_Rule_Id)
	{
		RSM_VehicleValidationDetails__c VehicleValidation = new RSM_VehicleValidationDetails__c();
	    VehicleValidation.Name = 'Test Validate';
	    VehicleValidation.Validation_Rule_Id__c = Validation_Rule_Id;
	    VehicleValidation.Unit_Number__c = VehicleId;
	    VehicleValidation.Status_Date__c = System.now();
	    VehicleValidation.External_Key__c = 'Test' + Validation_Rule_Id;
	    return VehicleValidation;
	}
	public static void InsertTask(Vehicle__c Vehicle, String RecordTypeId, String SubjectLast)
	{
		Task TaskObj = new Task(WhatId = Vehicle.Id, RecordTypeId = RecordTypeId);
		TaskObj.Subject = 'Unit No.' + Vehicle.Unit__c  + SubjectLast;
		//TaskObj.WhoId = UserInfo.getUserId();
		TaskObj.Priority = 'Normal';
		TaskObj.Status = 'Completed';
		TaskObj.ActivityDate = System.today();
		TaskObj.OwnerId = UserInfo.getUserId();
		insert TaskObj;
	}
	public static void InsertCustomSettingsData()
    {
    	RecordType RT = [Select r.SobjectType, r.Name, r.Id From RecordType r where sObjectType = 'Task' and Name = 'RydeSmart Task'];
    	Global_Settings__c TaskRecordType = new Global_Settings__c(Name = '6');
    	TaskRecordType.IsActive__c = True;
    	TaskRecordType.Comment__c = 'RecordType';
    	TaskRecordType.Type__c = 'RecordType';
    	TaskRecordType.Object_Name__c = 'Task';
    	TaskRecordType.Value__c = RT.ID;
    	insert TaskRecordType;
    }
    static testMethod void UnitTest_For_RSM_OrderReportWOContractFR083_Batch()
    {
        // TO DO: implement unit test
        Test.startTest();
	    	RSMCreateTestData.GetCustomSettingsRecord();
	    	String AccRecordTypeId = [select Id from RecordType where SobjectType = 'Account' and Name = 'Ryder FMS Branch Account'].Id;
	    	
			Account Acc1 = InsertAccount(AccRecordTypeId);    	
	    	Customer_Branch__c CustomerBranch = InsertCustomerBranch(Acc1.id);    
			Contact Cont1 = InsertContact(Acc1.Id);    	
	    	Key_Contact__c Key_Contact = InsertKeyContact(Acc1.Id, Cont1.Id, CustomerBranch.Id);    	
	    	Vehicle__c Vehicle = InsertVehicle(Acc1.Id, CustomerBranch.Id);
	    	Vehicle__c Vehicle1 = InsertVehicle(Acc1.Id, CustomerBranch.Id);
	    	
	    	List<RSM_VehicleValidationDetails__c> lVehicleValidation = new List<RSM_VehicleValidationDetails__c>();
		    lVehicleValidation.add(InsertVehicleValidation(Vehicle.Id, '7'));
		    lVehicleValidation.add(InsertVehicleValidation(Vehicle1.Id, '7'));
		    insert lVehicleValidation;
		    
	    	InsertCustomSettingsData();
	    	String TaskRecordTypeId = '';
			Global_Settings__c TaskRecordType = Global_Settings__c.getValues('6');
			if(TaskRecordType != null)
				TaskRecordTypeId = TaskRecordType.Value__c;
			InsertTask(Vehicle1, TaskRecordTypeId, 'is Reporting with no Contract');
			RSM_OrderReportWOContractFR083_Batch ClassObj = new RSM_OrderReportWOContractFR083_Batch();
		 	database.executebatch(ClassObj,200);
	 	
	    Test.stopTest();
    }
    static testMethod void UnitTest_For_RSM_OrderReportWOContractGT30FR085_Batch()
    {
        // TO DO: implement unit test
        Test.startTest();
	    	RSMCreateTestData.GetCustomSettingsRecord();
	    	String AccRecordTypeId = [select Id from RecordType where SobjectType = 'Account' and Name = 'Ryder FMS Branch Account'].Id;
	    	
			Account Acc1 = InsertAccount(AccRecordTypeId);
			Acc1.RSM_CCMs__c = UserInfo.getUserId();
			Acc1.RSM_CCM_manual_Update__c = true;
			update Acc1;
			
	    	Customer_Branch__c CustomerBranch = InsertCustomerBranch(Acc1.id);    
			Contact Cont1 = InsertContact(Acc1.Id);    	
	    	Key_Contact__c Key_Contact = InsertKeyContact(Acc1.Id, Cont1.Id, CustomerBranch.Id);    	
	    	Vehicle__c Vehicle = InsertVehicle(Acc1.Id, CustomerBranch.Id);
	    	Vehicle__c Vehicle1 = InsertVehicle(Acc1.Id, CustomerBranch.Id);
	    	List<RSM_VehicleValidationDetails__c> lVehicleValidation = new List<RSM_VehicleValidationDetails__c>();
		    lVehicleValidation.add(InsertVehicleValidation(Vehicle.Id, '38'));
		    lVehicleValidation.add(InsertVehicleValidation(Vehicle1.Id, '38'));
		    insert lVehicleValidation;
		    
	    	InsertCustomSettingsData();
	    	String TaskRecordTypeId = '';
			Global_Settings__c TaskRecordType = Global_Settings__c.getValues('6');
			if(TaskRecordType != null)
				TaskRecordTypeId = TaskRecordType.Value__c;
			InsertTask(Vehicle1, TaskRecordTypeId, 'is Reporting with no Contract for more than 30 Days');
			
	    	RSM_OrderReportWOContractGT30FR085_Batch ClassObj = new RSM_OrderReportWOContractGT30FR085_Batch();
		 	database.executebatch(ClassObj,200);
	 	
	    Test.stopTest();
    }
    static testMethod void UnitTest_For_RSM_VehicleActiveReportGT60FR087_Batch()
    {
        // TO DO: implement unit test
        Test.startTest();
	    	RSMCreateTestData.GetCustomSettingsRecord();
	    	String AccRecordTypeId = [select Id from RecordType where SobjectType = 'Account' and Name = 'Ryder FMS Branch Account'].Id;
	    	
			Account Acc1 = InsertAccount(AccRecordTypeId);
			Acc1.RSM_CCMs__c = UserInfo.getUserId();
			Acc1.RSM_CCM_manual_Update__c = true;
			update Acc1;
			
	    	Customer_Branch__c CustomerBranch = InsertCustomerBranch(Acc1.id);    
			Contact Cont1 = InsertContact(Acc1.Id);    	
	    	Key_Contact__c Key_Contact = InsertKeyContact(Acc1.Id, Cont1.Id, CustomerBranch.Id);    	
	    	Vehicle__c Vehicle = InsertVehicle(Acc1.Id, CustomerBranch.Id);
	    	Vehicle__c Vehicle1 = InsertVehicle(Acc1.Id, CustomerBranch.Id);
	    	List<RSM_VehicleValidationDetails__c> lVehicleValidation = new List<RSM_VehicleValidationDetails__c>();
		    lVehicleValidation.add(InsertVehicleValidation(Vehicle.Id, '40'));
		    lVehicleValidation.add(InsertVehicleValidation(Vehicle1.Id, '40'));
		    insert lVehicleValidation;
		    
	    	RSM_VehicleActiveReportGT60FR087_Batch ClassObj = new RSM_VehicleActiveReportGT60FR087_Batch();
		 	database.executebatch(ClassObj,200);
	 	
	    Test.stopTest();
    }
    static testMethod void UnitTest_For_RSM_SoldVehicleReportFR077_Batch()
    {
        // TO DO: implement unit test
        Test.startTest();
	    	RSMCreateTestData.GetCustomSettingsRecord();
	    	String AccRecordTypeId = [select Id from RecordType where SobjectType = 'Account' and Name = 'Ryder FMS Branch Account'].Id;
	    	
			Account Acc1 = InsertAccount(AccRecordTypeId);
			Acc1.RSM_CCMs__c = UserInfo.getUserId();
			Acc1.RSM_CCM_manual_Update__c = true;
			update Acc1;
			
	    	Customer_Branch__c CustomerBranch = InsertCustomerBranch(Acc1.id);    
			Contact Cont1 = InsertContact(Acc1.Id);    	
	    	Key_Contact__c Key_Contact = InsertKeyContact(Acc1.Id, Cont1.Id, CustomerBranch.Id);    	
	    	Vehicle__c Vehicle = InsertVehicle(Acc1.Id, CustomerBranch.Id);
	    	Vehicle__c Vehicle1 = InsertVehicle(Acc1.Id, CustomerBranch.Id);
	    	List<RSM_VehicleValidationDetails__c> lVehicleValidation = new List<RSM_VehicleValidationDetails__c>();
		    lVehicleValidation.add(InsertVehicleValidation(Vehicle.Id, '43'));
		    lVehicleValidation.add(InsertVehicleValidation(Vehicle1.Id, '43'));
		    insert lVehicleValidation;
		    
	    	RSM_SoldVehicleReportFR077_Batch ClassObj = new RSM_SoldVehicleReportFR077_Batch();
		 	database.executebatch(ClassObj,200);
	 	
	    Test.stopTest();
    }
    static testMethod void UnitTest_For_RSM_OrderReportWOContractFR083_Scheduler()
    {
        Test.startTest();
	    	RSM_OrderReportWOContractFR083_Scheduler ClassObj = new RSM_OrderReportWOContractFR083_Scheduler();	 
	    	System.debug('--->'+System.schedule('Job1', '0 05 * * * ?', ClassObj));	
	    Test.stopTest();
    }
    static testMethod void UnitTest_For_RSM_OrdRepWOContractGT30FR085_Scheduler()
    {
        Test.startTest();
	    	RSM_OrdRepWOContractGT30FR085_Scheduler ClassObj = new RSM_OrdRepWOContractGT30FR085_Scheduler();
	    	System.debug('--->'+System.schedule('Job2', '0 10 * * * ?', ClassObj));		 	
	    Test.stopTest();
    }
    static testMethod void UnitTest_For_RSM_VehicleActReportGT60FR087_Scheduler()
    {
        Test.startTest();
	    	RSM_VehicleActReportGT60FR087_Scheduler ClassObj = new RSM_VehicleActReportGT60FR087_Scheduler();
	    	System.debug('--->'+System.schedule('Job3', '0 15 * * * ?', ClassObj));		 	
	    Test.stopTest();
    }
    static testMethod void UnitTest_For_RSM_SoldVehicleReportFR077_Scheduler()
    {
        Test.startTest();
	    	RSM_SoldVehicleReportFR077_Scheduler ClassObj = new RSM_SoldVehicleReportFR077_Scheduler();
	    	System.debug('--->'+System.schedule('Job4', '0 15 * * * ?', ClassObj));		 	
	    Test.stopTest();
    }
}