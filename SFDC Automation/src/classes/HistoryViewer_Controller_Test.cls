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
private class HistoryViewer_Controller_Test {

    static testMethod void UnitTest_ForAll_Errors()
    {
        // TO DO: implement unit test
        RSMCreateTestData.GetCustomSettingsRecord();
    	
    	Test.StartTest();
    	        
		Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '0123123';
        insert Acc1;
        Acc1.Account_Classification__c = 'Local';
        update Acc1;
    	
    	ApexPages.StandardController Control = new ApexPages.StandardController(Acc1);
	    HistoryViewer_Controller ClassObj = new HistoryViewer_Controller(Control);
	    // SearchHistory method will return Null as there is an error
	    System.assertEquals(null, ClassObj.SearchHistory());
	    ClassObj.ObjectName = 'Vehicle__c';
	    ClassObj.FieldName = 'CUSTOMER_BRANCH__c';
	    ClassObj.VehicleName = 'None';
	    // SearchHistory method will return Null as there is an error
	    System.assertEquals(null, ClassObj.SearchHistory());
    	
    	Customer_Branch__c CustomerBranch = new Customer_Branch__c();
	    CustomerBranch.Name = 'Test Customer Branch';
	    CustomerBranch.Ryder_HQ_Account__c = Acc1.Id;
	    insert CustomerBranch;
	    
	    Vehicle__c Vehicle = new Vehicle__c(Unit__c = '123456');
	    Vehicle.Name = '1234';
	    Vehicle.CUSTOMER_BRANCH__c = CustomerBranch.Id;
	    Vehicle.RSM__c = 'Approved';
	    Vehicle.Account__c = Acc1.Id;
	    insert Vehicle;
	    	    
	    Control = new ApexPages.StandardController(Acc1);
	    ClassObj = new HistoryViewer_Controller(Control);
	    // SearchHistory method will return Null as there is an error as ObjectName, FieldName is None
	    System.assertEquals(null, ClassObj.SearchHistory());
	    ClassObj.ObjectName = 'Vehicle__c';
	    ClassObj.FieldName = 'CUSTOMER_BRANCH__c';
	    ClassObj.VehicleName = 'None';
	    // SearchHistory method will return Null as there is an error as VehicleName is None
	    System.assertEquals(null, ClassObj.SearchHistory());
	    ClassObj.VehicleName = Vehicle.Id;
	    // Below Account Date fields are used as place holder on the VF page to take user input. Based on these dates history is queried
	    ClassObj.AccDate.addr_verified_date__c = null;
	    // SearchHistory method will return Null as there is an error as date is null
	    System.assertEquals(null, ClassObj.SearchHistory());
	    // Below Account Date fields are used as place holder on the VF page to take user input. Based on these dates history is queried
	    ClassObj.AccDate.addr_verified_date__c = System.today().addDays(-15);
	    ClassObj.AccDate.BAD_ADDR_DATE__c = System.today().addDays(15);
	    ClassObj.SearchHistory();	    	    
	    ClassObj.ReturnBack();
	    Test.StopTest();
    }
    static testMethod void UnitTest_For_AccountHistoryView()
    {
        // TO DO: implement unit test
        RSMCreateTestData.GetCustomSettingsRecord();
    	
    	Test.StartTest();
    	        
		Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.Type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '0123123';
        insert Acc1;
        Acc1.Account_Classification__c = 'Local';
        update Acc1;
    	
	    ApexPages.StandardController Control = new ApexPages.StandardController(Acc1);
	    HistoryViewer_Controller ClassObj = new HistoryViewer_Controller(Control);	 
	    ClassObj.getObjectNames();
	    ClassObj.ObjectName = 'Account';
	    ClassObj.getFieldNames();
	    ClassObj.FieldName = 'Account_Classification__c';
	    ClassObj.Action = 'Local';
	    ClassObj.AccDate.addr_verified_date__c = System.today().addDays(-15);
	    // Below Account Date fields are used as place holder on the VF page to take user input. Based on these dates history is queried
	    ClassObj.AccDate.BAD_ADDR_DATE__c = System.today().addDays(15);
	    ClassObj.SearchHistory();
	    // This must return 0 Account History record As in Test method history never populates
	    System.assertEquals(0, ClassObj.InnerClassObj.size());
	    
	    
	    HistoryViewer_Controller.InnerClass InnerC = new HistoryViewer_Controller.InnerClass();
	    InnerC.sDate = system.now().format();
	    InnerC.sUser = 'Test User';
	    InnerC.sOldValue = 'Local';
	    InnerC.sNewValue = 'National';
	    InnerC.sAction = 'Changed Account Classification from Local to National';
	    HistoryViewer_Controller.InnerClass InnerC1 = new HistoryViewer_Controller.InnerClass();
	    InnerC1.sDate = system.now().format();
	    InnerC1.sUser = 'Test User';
	    InnerC1.sOldValue = 'National';
	    InnerC1.sNewValue = 'Local';
	    InnerC1.sAction = 'Changed Account Classification from National to Local';
	    ClassObj.InnerClassObj.add(InnerC);
	    ClassObj.InnerClassObj.add(InnerC1);
	    ClassObj.FilterData();	    	    	    
	    ClassObj.ReturnBack();
	    Test.StopTest();
    }
    static testMethod void UnitTest_For_VehicleHistoryView()
    {
        // TO DO: implement unit test
        RSMCreateTestData.GetCustomSettingsRecord();
    	
    	Test.StartTest();
    	        
		Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.Type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '0123123';
        insert Acc1;
        Acc1.Account_Classification__c = 'Local';
        update Acc1;
    	
    	Customer_Branch__c CustomerBranch = new Customer_Branch__c();
	    CustomerBranch.Name = 'Test Customer Branch';
	    CustomerBranch.Ryder_HQ_Account__c = Acc1.Id;
	    insert CustomerBranch;
	    Customer_Branch__c CustomerBranch1 = new Customer_Branch__c();
	    CustomerBranch1.Name = 'Test Customer Branch';
	    CustomerBranch1.Ryder_HQ_Account__c = Acc1.Id;
	    insert CustomerBranch1;
        
    	Vehicle__c Vehicle = new Vehicle__c(Unit__c = '123456');
	    Vehicle.Name = '1234';
	    Vehicle.CUSTOMER_BRANCH__c = CustomerBranch.Id;
	    Vehicle.RSM__c = 'Approved';
	    Vehicle.Account__c = Acc1.Id;
	    insert Vehicle;
	    Vehicle.CUSTOMER_BRANCH__c = CustomerBranch1.Id;
		update Vehicle;
		
		ApexPages.currentPage().getParameters().put('extid', Vehicle.Id);
	    ApexPages.StandardController Control = new ApexPages.StandardController(Acc1);
	    HistoryViewer_Controller ClassObj = new HistoryViewer_Controller(Control);
	    ClassObj.getVehicleNames();
	    ClassObj.ObjectName = 'Vehicle__c';
	    ClassObj.FieldName = 'CUSTOMER_BRANCH__c';
	    ClassObj.VehicleName = Vehicle.Id;
	    // Below Account Date fields are used as place holder on the VF page to take user input. Based on these dates history is queried
	    ClassObj.AccDate.addr_verified_date__c = System.today().addDays(-15);
	    ClassObj.AccDate.BAD_ADDR_DATE__c = System.today().addDays(15);
	    ClassObj.SearchHistory();
	    ClassObj.ObjectSelected();
	    // This must return 0 Vehicle History record As in Test method history never populates
	    System.assertEquals(0, ClassObj.InnerClassObj.size());
	    
	    ClassObj.VehicleName = 'All';
	    // Below Account Date fields are used as place holder on the VF page to take user input. Based on these dates history is queried
	    ClassObj.AccDate.addr_verified_date__c = System.today().addDays(-15);
	    ClassObj.AccDate.BAD_ADDR_DATE__c = System.today().addDays(15);
	    ClassObj.SearchHistory();
	    System.assertEquals(0, ClassObj.InnerClassObj.size());	    	    
	    ClassObj.ReturnBack();
	    
	    Test.StopTest();
    }
    static testMethod void UnitTest_For_ContractHistoryView()
    {
        // TO DO: implement unit test
        RSMCreateTestData.GetCustomSettingsRecord();
    	
    	Test.StartTest();
    	        
		Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.Type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '0123123';
        insert Acc1;
        Acc1.Account_Classification__c = 'Local';
        update Acc1;
    	
    	Customer_Branch__c CustomerBranch = new Customer_Branch__c();
	    CustomerBranch.Name = 'Test Customer Branch';
	    CustomerBranch.Ryder_HQ_Account__c = Acc1.Id;
	    insert CustomerBranch;
	    
	    Vehicle__c Vehicle = new Vehicle__c(Unit__c = '123456');
	    Vehicle.Name = '1234';
	    Vehicle.CUSTOMER_BRANCH__c = CustomerBranch.Id;
	    Vehicle.RSM__c = 'Approved';
	    Vehicle.Account__c = Acc1.Id;
	    insert Vehicle;
	    
    	RSM_Contract__c Contrt1 = new RSM_Contract__c(Account__c = Acc1.Id);
	    Contrt1.Lessee__c = Acc1.LesseeNo__c;
	    Contrt1.Contract_Number__c = 2434;
	    Contrt1.Status_Name__c = 'Approved';	    
	    insert Contrt1;
	    
	    RSM_ContractDetail__c Contrt1Detail = new RSM_ContractDetail__c();
	    Contrt1Detail.Contract_Number__c = Contrt1.id;
	    Contrt1Detail.Action_Name__c = 'Cancel';
	    Contrt1Detail.Is_Current__c = True;
	    Contrt1Detail.Unit_Number__c = Vehicle.Id;
	    insert Contrt1Detail;
	    Contrt1Detail.EffectiveDate__c = System.today().addDays(-5);
	    update Contrt1Detail;
	    
	    ApexPages.StandardController Control = new ApexPages.StandardController(Acc1);
	    HistoryViewer_Controller ClassObj = new HistoryViewer_Controller(Control);	    
	    ClassObj.ObjectName = 'RSM_Contract__c';
	    ClassObj.FieldName = 'EffectiveDate__c';
	    ClassObj.VehicleName = Vehicle.Id;
	    // Below Account Date fields are used as place holder on the VF page to take user input. Based on these dates history is queried
	    ClassObj.AccDate.addr_verified_date__c = System.today().addDays(-15);
	    ClassObj.AccDate.BAD_ADDR_DATE__c = System.today().addDays(15);
	    ClassObj.SearchHistory();
	    // This must return 0 Contract History record As in Test method history never populates
	    System.assertEquals(0, ClassObj.InnerClassObj.size());	    	    
	    ClassObj.ReturnBack();
	    
	    Test.StopTest();
    }
    static testMethod void UnitTest_For_ComponentHistoryView()
    {
        // TO DO: implement unit test
        RSMCreateTestData.GetCustomSettingsRecord();
    	
    	Test.StartTest();
    	        
		Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.Type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '0123123';
        insert Acc1;
        Acc1.Account_Classification__c = 'Local';
        update Acc1;
    	
    	Customer_Branch__c CustomerBranch = new Customer_Branch__c();
	    CustomerBranch.Name = 'Test Customer Branch';
	    CustomerBranch.Ryder_HQ_Account__c = Acc1.Id;
	    insert CustomerBranch;
	    
    	Vehicle__c Vehicle = new Vehicle__c(Unit__c = '123456');
	    Vehicle.Name = '1234';
	    Vehicle.CUSTOMER_BRANCH__c = CustomerBranch.Id;
	    Vehicle.RSM__c = 'Approved';
	    Vehicle.Account__c = Acc1.Id;
	    insert Vehicle;
	    
	    RSM_Component__c RSMComponent = new RSM_Component__c(Name = 'HistoryViewer Controller Test', 
	    														I_P_Address__c = '120.120.120.1', Unit_Number__c = Vehicle.Id);
	    insert RSMComponent;
	    RSMComponent.I_P_Address__c = '120.120.120.2';
	    update RSMComponent;
	    
	    ApexPages.StandardController Control = new ApexPages.StandardController(Acc1);
	    HistoryViewer_Controller ClassObj = new HistoryViewer_Controller(Control);	    
	    ClassObj.ObjectName = 'RSM_Component__c';
	    ClassObj.FieldName = 'I_P_Address__c';
	    ClassObj.VehicleName = Vehicle.Id;
	    // Below Account Date fields are used as place holder on the VF page to take user input. Based on these dates history is queried
	    ClassObj.AccDate.addr_verified_date__c = System.today().addDays(-15);
	    ClassObj.AccDate.BAD_ADDR_DATE__c = System.today().addDays(15);
	    ClassObj.SearchHistory();
	    // This must return 0 Account History record As in Test method history never populates
	    System.assertEquals(0, ClassObj.InnerClassObj.size());
	    
	    Test.StopTest();
    }
    static testMethod void UnitTest_For_POHistoryView()
    {
        // TO DO: implement unit test
        RSMCreateTestData.GetCustomSettingsRecord();
    	
    	Test.StartTest();
    	        
		Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.Type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '0123123';
        insert Acc1;
        Acc1.Account_Classification__c = 'Local';
        update Acc1;
    	
    	Customer_Branch__c CustomerBranch = new Customer_Branch__c();
	    CustomerBranch.Name = 'Test Customer Branch';
	    CustomerBranch.Ryder_HQ_Account__c = Acc1.Id;
	    insert CustomerBranch;
	    
	    Vehicle__c Vehicle = new Vehicle__c(Unit__c = '123456');
	    Vehicle.Name = '1234';
	    Vehicle.CUSTOMER_BRANCH__c = CustomerBranch.Id;
	    Vehicle.RSM__c = 'Approved';
	    Vehicle.Account__c = Acc1.Id;
	    insert Vehicle;
	    
	    RSM_PO__c RSM_PO = new RSM_PO__c(DateOrdered__c = System.today(), 
	    									Name = 'Test PO',
	    									DateReceived__c = System.today(), 
	    									Account__c = Acc1.Id, Unit_Number__c = Vehicle.Id);
	    insert RSM_PO;
	    
	    ApexPages.StandardController Control = new ApexPages.StandardController(Acc1);
	    HistoryViewer_Controller ClassObj = new HistoryViewer_Controller(Control);	    
	    ClassObj.ObjectName = 'RSM_PO__c';
	    ClassObj.FieldName = 'DateReceived__c';
	    ClassObj.VehicleName = Vehicle.Id;
	    // Below Account Date fields are used as place holder on the VF page to take user input. Based on these dates history is queried
	    ClassObj.AccDate.addr_verified_date__c = System.today().addDays(-15);
	    ClassObj.AccDate.BAD_ADDR_DATE__c = System.today().addDays(15);
	    ClassObj.SearchHistory();
	    // This must return 0 Account History record As in Test method history never populates
	    System.assertEquals(0, ClassObj.InnerClassObj.size());
	    
	    Test.StopTest();
    }
}