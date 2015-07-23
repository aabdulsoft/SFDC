@isTest
private class test_insertUpdateCompany {

	private static String GENERIC_COMPANY_NAME = 'Generic Company Name';
	private static String GENERIC_COMPANY_DUNS = '123456789';
	private static String GENERIC_COMPANY_BILLING_STATE = 'IL';

	private static Account createAccount()
	{
		Account account = new Account();
		account.Name = GENERIC_COMPANY_NAME;
		account.Site_Duns__c = GENERIC_COMPANY_DUNS;
		account.BillingState = GENERIC_COMPANY_BILLING_STATE;
		insert account;
		
		return account;
	}

	static testMethod void test_updateCompanyOnRyder_future(){
		Account a = createAccount();
		Set<Id> acctset = new Set<Id>();
		acctset.add(a.id);
		insertUpdateCompany.updateCompanyOnRyder_future(acctset);
	}


	static testMethod void test_insertCompanyOnRyder_future(){
		Account a = createAccount();
		Set<String> dunsset = new Set<String>();
		dunsset.add(a.site_duns__c);
		Map<String, String> pmap = new Map<String, String>();
		
		try{
			insertUpdateCompany.insertCompanyOnRyder_future(dunsset,pmap,a.id);
		}catch(Exception e){
			
		}
		//insertCompanyOnRyder_future(Set<String> dunsNumbers, Map<String, String> mapParentDuns, String accountId)
		/*
			SELECT a.addr_verified_date__c, a.Website, a.Type, a.Top10Account__c,a.Site_Duns__c, a.ShippingStreet, a.ShippingState, 
							a.ShippingPostalCode, a.ShippingCountry, a.ShippingCity, a.STATUS_ACTIVE__c, a.Ryder_Specific_Loc_Type__c, a.RecordTypeId, a.Phone_2__c, 
							a.Phone, a.ParentId, a.PO_NUMBER__c, a.OwnerId, a.NumberOfEmployees, a.Name, a.NATL_RNTL_CUST_ID__c, a.MasterRecordId, a.LesseeNo__c, 
							a.Legal_Entity_Address_Zip_Postal_Code__c, a.Legal_Entity_Address_Street__c, a.Legal_Entity_Address_State_Province__c, a.Legal_Entity_Address_Country__c, 
							a.Legal_Entity_Address_City__c, a.LastActivityDate, a.LOC_ID__c, a.Industry, a.Id, a.Global_Ultimate_DUNS__c, a.FormerCustomer__c, a.Fax, 
							a.Domestic_Ultimate_DUNS__c, a.Description, a.DUNS_HQ__c, a.DB_Loc_Type__c, a.CustomerTypeID__c, a.CustProspectID__c, a.CurrencyIsoCode, 
							a.Central_Decisionmaking__c, a.CUST_REPAIR_LIMIT__c, a.CO_SEGMENT__c, a.CO_RYDER_ANNSRY__c, a.CO_OWNER_ID__c, a.CO_ANNSRY__c, a.BillingStreet, 
							a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity, a.BUSINESS_STATUS__c, a.BAD_ADDR_REASON__c, a.BAD_ADDR_DATE__c, 
							a.BAD_ADDR_CD__c, a.BAD_ADDRESS_BIT__c, a.AnnualRevenue, a.Alias_Name__c, a.ADDR_ID__c, RecordType.Name, a.SIC
							FROM Account a WHERE a.Site_Duns__c IN: dunsNumbers];
		*/
	}

}