@isTest
public class UpdAccPostalCdPlus4TriggerHelperTest {
    
    static testMethod void myUnitTest()
    {
        Test.startTest();
        
        RSMCreateTestData.GetCustomSettingsRecord();
        
        Account acc1 = new Account();
        acc1.Name = 'Test Account1';
        acc1.LesseeNo__c = '0000001';
        acc1.ShippingPostalCode = '33025';
        acc1.ShippingCountry = 'US';
        insert acc1;
        
        acc1.ShippingPostalCode = '33178';
        update acc1;
        
        Account acc2 = new Account();
        acc2.Name = 'Test Account2';
        acc2.LesseeNo__c = '0000002';
        acc2.ShippingPostalCode = 'N1H 1E9';
        acc2.ShippingCountry = 'CA';
        insert acc2;
        
        acc2.ShippingCountry = 'V3K1A5';
        update acc2;
                
        Test.stopTest();  
    }        
}