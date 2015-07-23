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
private class RSM_NonLeaseContract_Controller_Test
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
	public static Vehicle__c InsertVehicle(String AccId, String CustomerBranchId, String sRecordType, String sNumber)
	{
		
		Vehicle__c Vehicle = new Vehicle__c();
	    Vehicle.Name = '1234';
	    Vehicle.CUSTOMER_BRANCH__c = CustomerBranchId;
	    Vehicle.RSM__c = 'Approved';
	    Vehicle.Account__c = AccId;
	    Vehicle.RecordTypeId = sRecordType;
	    Vehicle.Unit__c = sNumber;
	    insert Vehicle;
	    return Vehicle;
	}
	
    static testMethod void TestCovrage_For_RSM_AutoRegContractDetails()
    {
        // TO DO: implement unit test
        Test.startTest();
	    	RSMCreateTestData.GetCustomSettingsRecord();
	    	String AccRecordTypeId = [select Id from RecordType where SobjectType = 'Account' and Name = 'Ryder FMS Branch Account'].Id;
	    	
			Account Acc1 = InsertAccount(AccRecordTypeId);    	
	    	Customer_Branch__c CustomerBranch = InsertCustomerBranch(Acc1.id);    
			Contact Cont1 = InsertContact(Acc1.Id);    	
	    	Key_Contact__c Key_Contact = InsertKeyContact(Acc1.Id, Cont1.Id, CustomerBranch.Id);    	
	    	List<RecordType> lRecordType = [Select r.SobjectType, r.Name, r.Id From RecordType r 
	    									where SobjectType = 'Vehicle__c' and 
	    									(Name = 'Non Ryder Vehicle (NRV)' OR Name = 'Rental')];
	    	Vehicle__c Vehicle = null;
	    	Vehicle__c Vehicle1 = null;
	    	if(lRecordType.size() > 0)
	    	{
		    	Global_Settings__c CaseProposalRecordType = new Global_Settings__c(Name = '7');
		    	CaseProposalRecordType.IsActive__c = True;
		    	CaseProposalRecordType.Comment__c = 'RecordType';
		    	CaseProposalRecordType.Type__c = 'RecordType';
		    	CaseProposalRecordType.Object_Name__c = 'Vehicle';
		    	CaseProposalRecordType.Value__c = lRecordType[0].ID;
		    	insert CaseProposalRecordType;
		    	Vehicle = InsertVehicle(Acc1.Id, CustomerBranch.Id, lRecordType[0].Id, '700000');
	    	}
	    	if(lRecordType.size() > 1)
	    	{
		    	Global_Settings__c CaseProposalRecordType1 = new Global_Settings__c(Name = '8');
		    	CaseProposalRecordType1.IsActive__c = True;
		    	CaseProposalRecordType1.IsActive__c = True;
		    	CaseProposalRecordType1.Comment__c = 'RecordType';
		    	CaseProposalRecordType1.Type__c = 'RecordType';
		    	CaseProposalRecordType1.Object_Name__c = 'Vehicle';
		    	CaseProposalRecordType1.Value__c = lRecordType[1].ID;
		    	insert CaseProposalRecordType1;
		    	Vehicle1 = InsertVehicle(Acc1.Id, CustomerBranch.Id, lRecordType[1].Id, '700001');
	    	}
	    	
	    	RSM_NonLeaseContract_Controller ClassObj = new RSM_NonLeaseContract_Controller();
	    	ClassObj.RSM_Contract.Account__c = Acc1.Id;
	    	ClassObj.QueryVehicleData();
	    	ApexPages.currentPage().getParameters().put('rowno', '4');
	    	ClassObj.DeleteRow();
	    	ClassObj.ResetData();
	    	ClassObj.SaveData();
	    	for(RSM_NonLeaseContract_Controller.InnerClass Obj : ClassObj.InnerClassObj)
			{
				Obj.Vehicle = Vehicle.Id;				
			}
	    	ClassObj.SaveData();
	    	for(RSM_NonLeaseContract_Controller.InnerClass Obj : ClassObj.InnerClassObj)
			{
				Obj.Vehicle = Vehicle.Id;
				Obj.RSM_ContractDetail.Rate__c = 123;
				Obj.RSM_ContractDetail.EffectiveDate__c = null;
			}
	    	ClassObj.SaveData();
	    	for(RSM_NonLeaseContract_Controller.InnerClass Obj : ClassObj.InnerClassObj)
			{
				Obj.Vehicle = Vehicle.Id;
				Obj.RSM_ContractDetail.Rate__c = 123;
				Obj.RSM_ContractDetail.EffectiveDate__c = System.now();
			}
	    	ClassObj.SaveData();
	    	Integer i = 0;
	    	for(RSM_NonLeaseContract_Controller.InnerClass Obj : ClassObj.InnerClassObj)
			{
				i++;
				Obj.RSM_ContractDetail.Rate__c = 123;
				Obj.RSM_ContractDetail.EffectiveDate__c = System.now();
				Obj.RSM_ContractDetail.Is_Current__c = true;
				if(i == 1)
				{
					Obj.Vehicle = Vehicle.Id;
				}
				else if(i == 2)
				{
					Obj.Vehicle = Vehicle1.Id;
				}
				else
				{
					Obj.Vehicle = '--None--';
					Obj.RSM_ContractDetail.Rate__c = 123;
					Obj.RSM_ContractDetail.EffectiveDate__c = System.now();
				}
			}
			ClassObj.getDocumentTypeNames();
			ClassObj.getStatusNames();
			ClassObj.DocumentTypeName = 'RPM';
			system.debug('--------------------------------->'+ClassObj.InnerClassObj);
	    	ClassObj.SaveData();
	    	system.debug('--------------------------------->'+ApexPages.getMessages());
	    	
        Test.stopTest();
    }
}