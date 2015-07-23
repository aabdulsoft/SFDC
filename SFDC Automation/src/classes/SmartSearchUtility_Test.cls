/***********************************************************************
 Class 			: SmartSearchUtility_Test
 Author 		: Appirio
 Created Date 	: 4 march 2014
 Descritption 	: Provide test coverage to SmartSearchUtility.cls
 ************************************************************************/
 
@isTest
private class SmartSearchUtility_Test {
	static User uvsUser;
    static testMethod void testGetAutoFillValues() {
        //running the test class on behalf of system admin
        uvsUser = TestUtilUVS.createAdminUser(true);
        TestUtilUVS.createCustomSettingData(); 
        system.runAs(uvsUser) {
	        Account account = new Account(Name = 'Test Account');
	        account.ShippingState = 'AL';
	        insert account;
	        
	        Id [] fixedSearchResults= new Id[1];
	        fixedSearchResults[0] = account.Id;
	        Test.setFixedSearchResults(fixedSearchResults);
	        
	        Test.startTest();
	        	List<String> lstAutoFillResult = SmartSearchUtility.getAutoFillValues('Test', 'Account', 'Name');
	        	System.assertEquals(lstAutoFillResult[0], 'Test Account', 'Method should return the name value "Test Account"');
	        Test.stopTest();
    	}
    }
    
    static testMethod void testCreateFieldCsv() {
    	//running the test class on behalf of system admin
        uvsUser = TestUtilUVS.createAdminUser(true);
        system.runAs(uvsUser) {
	    	// We can not create fieldset in the test class, so passing a rendom field set name
	    	String fieldCSV = SmartSearchUtility.createFieldCsv('Account', 'testFieldSet');
	    	System.assertEquals(fieldCSV, 'Name,Id', 'If field set does not exist then "Name,Id" should be the default value return by the method.');
        }
    }
    
    static testMethod void testgetPrefix() {
    	//running the test class on behalf of system admin
        uvsUser = TestUtilUVS.createAdminUser(true);
        system.runAs(uvsUser) {
        	System.assertEquals(SmartSearchUtility.getPrefix('Account'),'001');
        }
    }
}