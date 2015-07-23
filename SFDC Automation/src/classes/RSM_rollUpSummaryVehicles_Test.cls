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
 * This class contains Test methods for: RSM_rollUpSummaryVehicle and RSM_rollUpSummaryVehicle_Helper
 */
@isTest
private class RSM_rollUpSummaryVehicles_Test {

    static testMethod void myUnitTest()
    {       
        RSMCreateTestData.GetCustomSettingsRecord();
        
        RSM_rollUpSummaryVehicles runLockBatch = new RSM_rollUpSummaryVehicles();
        Database.executeBatch(runLockBatch, 200);
        
        
        // TO DO: implement unit test
        Account parentAcct = new Account(Name='Test Account', ShippingState='LA', ShippingCountry='CA', CustomerTypeID__c='FMS', 
                                            CO_SEGMENT__c='0 - Three trucks or less', CompanyTypeID__c='1 Corporation');  
        insert parentAcct;
        
        // create child account
        Vehicle__c childAccnt1 = new Vehicle__c(Name='Test Vehicle1', Account__c = parentAcct.id, RSM_Service_Level__c='Plus 1',RSM__c = 'Approved');
        insert childAccnt1;
        
        Vehicle__c childAccnt2 = new Vehicle__c(Name='Test Vehicle2', Account__c = parentAcct.id, RSM_Service_Level__c='Plus 1',RSM__c = 'Approved');
        insert childAccnt2;
 
        Vehicle__c childAccnt3 = new Vehicle__c(Name='Test Vehicle3', Account__c = parentAcct.id, RSM_Service_Level__c='STD',RSM__c = 'Approved');
        insert childAccnt3; 
 
        Vehicle__c childAccnt4 = new Vehicle__c(Name='Test Vehicle4', Account__c = parentAcct.id, RSM_Service_Level__c='Plus',RSM__c = 'Approved');
        insert childAccnt4;
 
        Vehicle__History vh = NEW Vehicle__History();
        vh.Field = 'RSM_Service_Level__c';
        vh.ParentId = childAccnt1.Id;
        //vh.Parent.Account__c = parentAcct.Id;
        
        List<Vehicle__History> lVH = new List<Vehicle__History>{};
        lVH.add(vh);
        RSM_RollUpSummaryVehicles_Helper.ProcessVehicleHistory(lVH);
    }
}