/***********************************************************************
 Class 			: SmartContactSearchExtension_Test
 Author 		: Appirio
 Created Date 	: 4 march 2014
 Descritption 	: Provide test coverage to SmartContactSearchExtension.cls
 ************************************************************************/
@isTest
private class SmartContactSearchExtension_Test {
	static User uvsUser;
    static testMethod void testContactSearch() {
    	//running the test class on behalf of system admin
        uvsUser = TestUtilUVS.createAdminUser(true);  
     	system.runAs(uvsUser) { 
	    	Test.startTest();
	    	
		        SmartContactSearchExtension controller = new SmartContactSearchExtension();
		        controller.contactFirstNameToSearch = 'FirstName';
		        controller.contactLastNameToSearch = 'LastName';
		        controller.contactEmail = 'test@test.com';
		        controller.contactPhone = 'phone';
		        controller.contactAccount = 'Test Account';
		        
		        System.assert(controller.contactFieldCsv != null , 'If fieldset does not exist then "Name" field should be the default value in the contactFieldCsv else the fields from the fieldset will be set');
		        
		        controller.performSearch();
		        System.assertEquals(controller.filterCriteria.trim(), 'Account.Name like \'%Test Account%\' OR LastName like \'%LastName%\' OR Email like \'%test@test.com%\' OR Phone like \'%phone%\'');
	
				controller.resetTextBoxName = '1';	        
		        controller.resetSearchStatus();
		        System.assertEquals(controller.contactFirstNameToSearch, '');
		        
		        controller.resetTextBoxName = '2';	        
		        controller.resetSearchStatus();
		        System.assertEquals(controller.contactLastNameToSearch, '');
		        
		        controller.resetTextBoxName = '3';	        
		        controller.resetSearchStatus();
		        System.assertEquals(controller.contactEmail, '');
		        
		        controller.resetTextBoxName = '4';	        
		        controller.resetSearchStatus();
		        System.assertEquals(controller.contactPhone, '');
		        
		        controller.resetTextBoxName = '5';	        
		        controller.resetSearchStatus();
		        System.assertEquals(controller.contactAccount, '');
		        
		        controller.resetTextBoxName = '';
		        controller.resetSearchStatus();
		        
		        ApexPages.StandardController std = new ApexPages.StandardController(new Contact(LastName = 'Test Contact'));
		        controller = new SmartContactSearchExtension(std);
		        
		        controller.createNewContact();
		        
	        Test.stopTest();
	        
	    }
    }
}