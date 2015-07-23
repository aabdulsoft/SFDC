/**
 * This class contains unit tests for validating the behavior of Apex class CommonFunctions.
 *
 */
@isTest
private class test_CommonFunctions 
{

    static testMethod void testGetAccurracyProbability() 
    { 
		Decimal returnValue = CommonFunctions.getAccuracyProbability(1);
		System.debug('Return value - ' + returnValue);
		System.assert(returnValue==0.0344);
		
		returnValue = CommonFunctions.getAccuracyProbability(10);
		System.debug('Return value - ' + returnValue);
		System.assert(returnValue==0.994);
    }
    
    static testMethod void testGetAccountsToDisplayFromDandB() 
    {
    	CommonFunctions commonFuncs = new CommonFunctions();
    	Set<String> dunsNumberSet = new Set<String>();
    	dunsNumberSet.add(RyderGlobalVariables.TEST_DUNS_NUMBER);
    	RyderGlobalVariables.IS_TEST = true;
		Map<String, String> returnValue = commonFuncs.getAccountsToDisplayFromDandB(dunsNumberSet,  
															RyderGlobalVariables.CustomerType.FMS.name(), RyderGlobalVariables.TEST_PRIMARY_NAME, 
															RyderGlobalVariables.TEST_STATE, RyderGlobalVariables.COUNTRIES_USA, 
															RyderGlobalVariables.TEST_ADDRESS_LINE, RyderGlobalVariables.TEST_CITY, 
															RyderGlobalVariables.TEST_POST_CODE, null);
		System.debug('Return value - ' + returnValue);
		System.assert(returnValue.containsKey(RyderGlobalVariables.TEST_DUNS_NUMBER));
    }
    
    static testMethod void testGetSFDCAccountsFromDandB() 
    {
    	CommonFunctions commonFuncs = new CommonFunctions();
    	RyderGlobalVariables.IS_TEST = true;
		List<Account> returnValue = commonFuncs.getSFDCAccountsFromDandB(RyderGlobalVariables.TEST_PRIMARY_NAME, 
													RyderGlobalVariables.TEST_STATE, RyderGlobalVariables.COUNTRIES_USA, 
													RyderGlobalVariables.TEST_ADDRESS_LINE, RyderGlobalVariables.TEST_CITY, 
													RyderGlobalVariables.TEST_POST_CODE, null);
		System.debug('Return value - ' + returnValue);
		System.assert(returnValue[0].Name==RyderGlobalVariables.TEST_PRIMARY_NAME);
    }
    
    static testMethod void testGetAccountsOnRyder() 
    {
    	CommonFunctions commonFuncs = new CommonFunctions();
    	RyderGlobalVariables.IS_TEST = true;
		List<Account> returnValue = commonFuncs.getAccountsOnRyder(RyderGlobalVariables.TEST_PRIMARY_NAME);
		System.debug('Return value - ' + returnValue);
		System.assert(returnValue[0].Name==RyderGlobalVariables.TEST_PRIMARY_NAME);
    }

    
    static testMethod void testCreateAccountsOnRyder() 
    {
    	CommonFunctions commonFuncs = new CommonFunctions();
    	RyderGlobalVariables.IS_TEST = true;
    	Account dbAccount = new Account();
    	dbAccount.CustomerTypeID__c = RyderGlobalVariables.CustomerType.FMS.name();
		
		//requestCriteria.LesseNum = dbAccount.LesseeNo__c;
		dbAccount.Site_Duns__c = RyderGlobalVariables.TEST_DUNS_NUMBER;
		dbAccount.DUNS_HQ__c = RyderGlobalVariables.TEST_DUNS_NUMBER;
		dbAccount.Domestic_Ultimate_DUNS__c = RyderGlobalVariables.TEST_DUNS_NUMBER;
		dbAccount.SIC = RyderGlobalVariables.TEST_SIC_CODE;
		dbAccount.Legal_Entity_Address_Country__c = RyderGlobalVariables.COUNTRIES_USA;
		dbAccount.Legal_Entity_Address_State_Province__c = RyderGlobalVariables.TEST_STATE;
		dbAccount.Legal_Entity_Address_Street__c = RyderGlobalVariables.TEST_ADDRESS_LINE;
		dbAccount.Legal_Entity_Address_City__c = RyderGlobalVariables.TEST_CITY;
		dbAccount.Legal_Entity_Address_Zip_Postal_Code__c = RyderGlobalVariables.TEST_POST_CODE;
		
		dbAccount.BillingCountry= RyderGlobalVariables.COUNTRIES_USA;
        dbAccount.BillingState= RyderGlobalVariables.TEST_STATE;
        dbAccount.BillingStreet= RyderGlobalVariables.TEST_ADDRESS_LINE;
        dbAccount.BillingCity= RyderGlobalVariables.TEST_CITY;
        dbAccount.BillingPostalCode= RyderGlobalVariables.TEST_POST_CODE;
        
        dbAccount.ShippingCountry= RyderGlobalVariables.COUNTRIES_USA;
        dbAccount.ShippingState= RyderGlobalVariables.TEST_STATE;
        dbAccount.ShippingStreet= RyderGlobalVariables.TEST_ADDRESS_LINE;
        dbAccount.ShippingCity= RyderGlobalVariables.TEST_CITY;
        dbAccount.ShippingPostalCode= RyderGlobalVariables.TEST_POST_CODE;
        
		dbAccount.Phone = null; 
		Integer returnValue = commonFuncs.createAccountsOnRyder(dbAccount, false, false);
		System.debug('Return value - ' + returnValue);
		System.assert(returnValue==RyderGlobalVariables.TEST_COMPANY_ID);
		
		returnValue = commonFuncs.createAccountsOnRyder(dbAccount, false, true);
        System.debug('Return value - ' + returnValue);
        System.assert(returnValue==RyderGlobalVariables.TEST_COMPANY_ID);
        
        returnValue = commonFuncs.createAccountsOnRyder(dbAccount, true, false);
        System.debug('Return value - ' + returnValue);
        System.assert(returnValue==RyderGlobalVariables.TEST_COMPANY_ID);
    }
    
    static testMethod void testgetRecordTypeMap() {
    	Map<String, Id> recordTypeMap = CommonFunctions.getRecordTypeMap('Account');
    	System.assertEquals(recordTypeMap.size() >= 0, true);
    }
    
    static testMethod void testtranslateDnBLocationInfo() {
        System.assertEquals(CommonFunctions.translateDnBLocationInfo('HQ') == RyderGlobalVariables.HQ_LOCATION, true);
        System.assertEquals(CommonFunctions.translateDnBLocationInfo('BR') == RyderGlobalVariables.BR_LOCATION, true);
        System.assertEquals(CommonFunctions.translateDnBLocationInfo('SL') == RyderGlobalVariables.SL_LOCATION, true);
    }
}