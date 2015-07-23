/**
 * This class tests the affect of trigger for updateCompany trigger.
 */
@isTest
private class test_UpdateCompanyTrigger 
{
	
	// Create Account to attach to existing lead convert 
	private static Account createAccount(String country)
	{
		Account account = new Account();
		account.Name = RyderGlobalVariables.TEST_PRIMARY_NAME;
		account.ShippingStreet = RyderGlobalVariables.TEST_ADDRESS_LINE;
		account.ShippingCity = RyderGlobalVariables.TEST_CITY;
		if (country == RyderGlobalVariables.COUNTRIES_USA)
			account.ShippingState = RyderGlobalVariables.TEST_STATE;
		else
			account.ShippingState = RyderGlobalVariables.TEST_STATE_CANADA;
		
		account.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;
		account.ShippingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
		account.CustomerTypeID__c = RyderGlobalVariables.CustomerType.FMS.name();
		account.Type = RyderGlobalVariables.TEST_TYPE_PROSPECT;
		account.BillingState = 'IL';
		account.CustProspectID__c = '8764356';
		
		insert account;
		
		return account;
	}
	
    static testMethod void test_UpdateCompany() 
    {
    	RyderGlobalVariables.IS_TEST = true;
    	RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = true;
    	Account account = createAccount(RyderGlobalVariables.COUNTRIES_CANADA_TEXT);
    	account.CustomerTypeID__c = RyderGlobalVariables.CustomerType.RIL.name();
    	update account;
    	Set<Id> accountIds = new Set<Id>();
    	accountIds.add(account.Id); 
    	updateCompanyFuture.updateCompanyOnRyder(accountIds);
    	
    }
}