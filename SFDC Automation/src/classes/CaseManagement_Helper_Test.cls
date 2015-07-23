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
private class CaseManagement_Helper_Test
{
    static testMethod void myUnitTest()
    {
    	// TO DO: implement unit test
    	RSMCreateTestData.GetCustomSettingsRecord();       
        FetchCustomSettingsData();
        Account acc = new Account();
        acc.name = 'Test Account';    
        acc.ShippingState = RyderGlobalVariables.TEST_STATE_CANADA;        
        acc.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;        
        insert acc;
		
		system.assertEquals(acc.ShippingState, RyderGlobalVariables.TEST_STATE_CANADA);
        
        Contact c = New Contact (); 
        c.FirstName = 'TestFirst'; 
        c.LastName = 'TestLast'; 
        c.email = 'TestContact@test.com';
        c.accountId = acc.Id;
        c.Contact_Source__c = 'Lead Conversion';
        insert c;
        system.assertEquals(c.AccountId, acc.Id);
        
        Case case1 = new Case();
        case1.AccountId = acc.Id;
        case1.ContactId = c.id;
        case1.Resources_requeste__c = 'Credit';
        case1.Solutions_Interest__c = 'Rental';
        case1.Proposal_Due_Date__c = System.today().addDays(10);
        String CaseProposalRecordTypeId = '';
		Global_Settings__c CaseProposalRecordType = Global_Settings__c.getValues('1');
		if(CaseProposalRecordType != null)
			CaseProposalRecordTypeId = CaseProposalRecordType.Value__c;
		case1.RecordTypeId = CaseProposalRecordTypeId;
        insert case1;
        system.assertEquals(case1.RecordTypeId, CaseProposalRecordType.Value__c);
        system.assertEquals(false, case1.IsClosed);
        case1.Proposal_Due_Date__c = System.today();
        case1.Corrective_Action__c = 'Test';
        update case1;
        
        case1.Status = 'Closed';
        case1.Corrective_Action__c = 'Test';
        update case1;
        
        Case case2 = new Case();
        case2.AccountId = acc.Id;
        case2.ContactId = c.id;
        case2.Resources_requeste__c = 'Credit';
        case2.Solutions_Interest__c = 'Rental';
        case2.Proposal_Due_Date__c = System.today().addDays(10);
        case2.Run_Assign_Rule_From_Mobile__c = true;
        String CaseProposalRecordTypeId1 = '';
		Global_Settings__c CaseProposalRecordType1 = Global_Settings__c.getValues('5');
		if(CaseProposalRecordType1 != null)
			CaseProposalRecordTypeId1 = CaseProposalRecordType1.Value__c;
		case2.RecordTypeId = CaseProposalRecordTypeId1;
        insert case2;
        
    }
    public static void FetchCustomSettingsData()
    {
    	RecordType RT = [Select r.SobjectType, r.Name, r.Id From RecordType r where sObjectType = 'Case' and Name = 'Proposal Response'];
    	Global_Settings__c CaseProposalRecordType = new Global_Settings__c(Name = '1');
    	CaseProposalRecordType.IsActive__c = True;
    	CaseProposalRecordType.Comment__c = 'RecordType';
    	CaseProposalRecordType.Type__c = 'RecordType';
    	CaseProposalRecordType.Object_Name__c = 'Case';
    	CaseProposalRecordType.Value__c = RT.ID;
    	insert CaseProposalRecordType;
    	
    	Global_Settings__c CaseProposalRecordType1 = new Global_Settings__c(Name = '2');
    	CaseProposalRecordType1.IsActive__c = True;
    	CaseProposalRecordType1.Comment__c = 'Used at: CaseManagement trigger as email content';
    	CaseProposalRecordType1.Type__c = 'Email Content';
    	CaseProposalRecordType1.Object_Name__c = 'Case';
    	CaseProposalRecordType1.Value__c = 'new Case created';
    	insert CaseProposalRecordType1;
    	
    	Global_Settings__c CaseProposalRecordType2 = new Global_Settings__c(Name = '3');
    	CaseProposalRecordType2.IsActive__c = True;
    	CaseProposalRecordType2.Comment__c = 'Used at: CaseManagement trigger as email content';
    	CaseProposalRecordType2.Type__c = 'Email Content';
    	CaseProposalRecordType2.Object_Name__c = 'Case';
    	CaseProposalRecordType2.Value__c = 'Case Updated';
    	insert CaseProposalRecordType2;
    	
    	Global_Settings__c CaseProposalRecordType3 = new Global_Settings__c(Name = '4');
    	CaseProposalRecordType3.IsActive__c = True;
    	CaseProposalRecordType3.Comment__c = 'Used at: CaseManagement trigger as email content';
    	CaseProposalRecordType3.Type__c = 'Email Content';
    	CaseProposalRecordType3.Object_Name__c = 'Case';
    	CaseProposalRecordType3.Value__c = 'Case Closed';
    	insert CaseProposalRecordType3;
    	
    	RT = [Select r.SobjectType, r.Name, r.Id From RecordType r where sObjectType = 'Case' and Name = 'Legal Cases'];
    	Global_Settings__c CaseProposalRecordType4 = new Global_Settings__c(Name = '5');
    	CaseProposalRecordType4.IsActive__c = True;
    	CaseProposalRecordType4.Comment__c = 'RecordType';
    	CaseProposalRecordType4.Type__c = 'RecordType';
    	CaseProposalRecordType4.Object_Name__c = 'Case';
    	CaseProposalRecordType4.Value__c = RT.ID;
    	insert CaseProposalRecordType4;
    }
}