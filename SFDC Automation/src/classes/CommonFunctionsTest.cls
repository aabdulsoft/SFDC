/**=============================================================================
 * Created By: Hari Krishnan (Appirio, Inc)
 * Created Date: 02/28/2015
 * Description: Test class for CommonFunctions

==============================================================================*/
@isTest(SeeAllData=true)
private class CommonFunctionsTest {
    static testMethod void testGetAccuracyProbability() {
        Decimal dc = CommonFunctions.getAccuracyProbability(10);
        Map<String, Id> mapRT = CommonFunctions.getRecordTypeMap('Account');
        Map<String, Id> mapRT1 = CommonFunctions.getRecordType('Account');
        String locInfo1 = CommonFunctions.translateDnBLocationInfo('HQ');
        String locInfo2 = CommonFunctions.translateDnBLocationInfo('BR');
        String locInfo3 = CommonFunctions.translateDnBLocationInfo('SL');
        String zip = CommonFunctions.formatZipCode('123456789');
        
    }
    static testMethod void TestgetValidatedFMSParentWithNoProspectID()
    {
    	User testUser = TestUtil.createUser('BDM');
    	insert testUser;
    	system.runAs(testUser)
    	{
	    	Account a = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
	    	insert a;
			CommonFunctions commonFunction = new CommonFunctions();
			Account syncAccount = commonFunction.getValidatedFMSParentWithNoProspectID(a);
			//Get valid Parent should return the same account because its a valid record type
			system.assertEquals(a.Id, syncAccount.Id);
			
			Account b = TestUtil.createAccount('Ryder FMS Branch Account', 'FMS');
			b.ParentId = a.Id;
			insert b;
			Account syncAccount2 = commonFunction.getValidatedFMSParentWithNoProspectID(b);
			//Get valid Parent should return account a because it was set as parent
			system.assertEquals(a.Id, syncAccount2.Id);
			
			Account c = TestUtil.createAccount('Ryder FMS Branch Account', 'FMS');
			insert c;
			Account syncAccount3 = commonFunction.getValidatedFMSParentWithNoProspectID(c);
			//Get valid Parent should return null because its not valid type and no parent
			system.assert(syncAccount3 == null);
			
			//Lastly set CustProspectID__c and should not get an account either
			a.CustProspectID__c = '123456789';
			update a;
			Account syncAccount4 = commonFunction.getValidatedFMSParentWithNoProspectID(a);
			system.assert(syncAccount4 == null);
    	}
    }
    static testMethod void TestgetAccountByCustProspectId()
    {
    	CommonFunctions commonFunction = new CommonFunctions();
    	Account a = commonFunction.getAccountByCustProspectId(123456);
    	system.assert(a != null);    	
    }
    static testMethod void TestgetValidFMSOpportunityRecordTypes()
    {
    	CommonFunctions commonFunction = new CommonFunctions();
    	Map<String,RecordType> ValidRecTypes = commonFunction.getValidFMSOpportunityRecordTypes();
    	system.assert(ValidRecTypes.size() > 0);
    }
    static testMethod void TestgetUpdateCustProspect()
    {
		Account c = TestUtil.createAccount('Ryder FMS Branch Account', 'FMS');
		insert c;
		//Force a negative test result by using a branch account with no parent
    	Boolean result = CommonFunctions.UpdateCustProspect(c.Id);
    	system.assert(result == false);
    }
    static testMethod void TestUpdateCustProspectFuture()
    {
		Account c = TestUtil.createAccount('Ryder FMS Branch Account', 'FMS');
		insert c;
		//Force a negative test result by using a branch account with no parent
    	CommonFunctions.UpdateCustProspectFuture(c.Id);
    	System.debug('@@@#### Cust Prospect' + c.CustProspectID__c);
    	system.assert(c.CustProspectID__c == '' || c.CustProspectID__c == null);
    }
}