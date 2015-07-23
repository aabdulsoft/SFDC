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
private class RSMEmailRSSToReactivatebilling_Test {

    static testMethod void myUnitTest()
    {
    	RSMCreateTestData.GetCustomSettingsRecord();
    	
    	Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '123123';
        insert Acc1;
    	
    	Customer_Branch__c CustomerBranch = new Customer_Branch__c();
	    CustomerBranch.Name = 'Test Customer Branch';
	    CustomerBranch.Ryder_HQ_Account__c = Acc1.Id;
	    insert CustomerBranch;
    
    	Vehicle__c Vehicle = new Vehicle__c();
	    Vehicle.Name = '1234';
	    Vehicle.CUSTOMER_BRANCH__c = CustomerBranch.Id;
	    Vehicle.RSM__c = 'Approved';
	    Vehicle.Account__c = Acc1.Id;
	    insert Vehicle;	    
	    
	    RSM_VehicleValidationDetails__c Validation = new RSM_VehicleValidationDetails__c();
	    Validation.Name = 'Test';
	    Validation.Unit_Number__c = Vehicle.Id;
	    Validation.Validation_Rule_Id__c = '11';
	    insert Validation;
	    
	    Vehicle__c Vehicle1 = new Vehicle__c();
	    Vehicle1.Name = '1234';
	    Vehicle1.CUSTOMER_BRANCH__c = CustomerBranch.Id;
	    Vehicle1.RSM__c = 'Approved';
	    Vehicle1.Account__c = Acc1.Id;
	    insert Vehicle1;	    
	    
	    RSM_VehicleValidationDetails__c Validation1 = new RSM_VehicleValidationDetails__c();
	    Validation1.Name = 'Test';
	    Validation1.Unit_Number__c = Vehicle1.Id;
	    Validation1.Validation_Rule_Id__c = '22';
	    insert Validation1;
	    
    	
        RSMEmailRSSToReactivatebilling rerb= new RSMEmailRSSToReactivatebilling(); 
       	rerb.query = 'select Id,Unit_Number__c,Unit_Number__r.Name,Validation_Rule_Id__c';
       	rerb.query += ' from RSM_VehicleValidationDetails__c where Validation_Rule_Id__c=\'11\' OR Validation_Rule_Id__c=\'22\'';
        database.executebatch(rerb,500);
        
        rerb= new RSMEmailRSSToReactivatebilling(); 
       	rerb.query = 'select Id,Unit_Number__c,Unit_Number__r.Name,Validation_Rule_Id__c';
       	rerb.query += ' from RSM_VehicleValidationDetails__c where Validation_Rule_Id__c=\'11\' OR Validation_Rule_Id__c=\'22\'';
        database.executebatch(rerb,500);
    }
}