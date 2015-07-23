public with sharing class TestUtil {

    public static final String USER_EMAIL_ENCODING = 'UTF-8';
    public static final String USER_TIMEZONE = 'America/Los_Angeles';
    	
	//get RecordType values as list
	public static Map<String, Id> getRecordType(String sObjType){
    	Map<String, Id> recordTypeMap = new Map<String, Id>();
    	for(RecordType r : [Select r.SobjectType, r.Name, r.IsActive, r.Id From RecordType r where  r.SobjectType=:sObjType AND r.IsActive=true]){
    		recordTypeMap.put(r.Name, r.Id);
    	}
    	return recordTypeMap;
    }
    
	//create Account
	public  static Map<String, Id> accRecordTypeMap = getRecordType('Account');
	
	public static Account createAccount(String rt, String custType){
		Account a = new Account();
		a.Name='Abc Group Inc';
		a.Type='Customer';
		a.BillingStreet='13335 Seventh Concession';
		a.BillingCity='Miami';
		a.BillingState='FL';
		a.BillingCountry='US';
		a.BillingPostalCode = '33378';
		a.ShippingStreet='13335 Seventh Concession';
		a.ShippingCity='Miami';
		a.ShippingState='FL';
		a.ShippingCountry='US';
		a.ShippingPostalCode = '33378';  //RyderGlobalVariables.TEST_POST_CODE;
		if(accRecordTypeMap!=null)
			a.RecordTypeId=accRecordTypeMap.get(rt);
		return a;	
	}
	
	//create contact
	public static Contact createContact(Id accountId) {
		Contact c = new Contact();
		c.accountId = accountId;
		c.FirstName = 'Test contact';
		c.LastName = 'Sample';
		c.Email = 'test8979123@rydertest.com';
		c.Phone = '(123) 456-8789';
		return c;
	}
	
	public static Contact createContact(Id accountId, String Email) {
		Contact c = new Contact();
		c.accountId = accountId;
		c.FirstName = 'Test contact';
		c.LastName = 'Sample';
		c.Email = Email;
		c.Is_Duplicate__c = true;
		c.Phone = '(123) 456-8789';
		return c;
	}
	//create Oppty
	public  static Map<String, Id> opptyRecordTypeMap = getRecordType('Opportunity');
	
	public static Opportunity createOppty(Account acc, Contact cnt, String rtName){
		Opportunity o = new Opportunity();
		o.Name='DADE PAPER Test';
		o.AccountId=acc.Id;
		o.Original_Decision_Maker__c = cnt.id;
		o.StageName='Qualifying';
		o.Probability=10;
		o.CloseDate = System.today()+12;
		o.Estimated_Proposal_Date__c = System.today()+1; 
		if(opptyRecordTypeMap!=null)
			o.RecordTypeId=opptyRecordTypeMap.get(rtName);
		return o;
	}
	
	//create Deal Summary Test method
	public static Deal_Summary__c createDealSummary(Opportunity op){
		Deal_Summary__c d = new Deal_Summary__c();
		d.Opportunity__c=op.id;
		d.Name='Test deal with more rate sheets';
		d.Status__c='In Process';
		d.EVA__c=200;
		d.No_of_Vehicles__c=10;
		d.Gross_Revenue__c=20000;
		
		return d;
	}
	
	//create Rate Sheet
	public static Rate_Sheet__c createRateSheet(Deal_Summary__c ds, Opportunity op){
		Rate_Sheet__c rs = new Rate_Sheet__c();
		rs.Deal_Summary__c=null;
		if(ds!=null){
			rs.Deal_Summary__c=ds.Id;
		}
		rs.Opportunity__c=op.Id;
		rs.Rate_Sheet_Name__c='New Yest<Ext Promo';
		rs.Package_Type__c='Equipment Only';
		rs.No_of_Vehicles__c=10;
		rs.Gross_Revenue__c=30000;
		rs.EVA__c=200;
		//rs.ext_ratesheet_id__c=9999;
		return rs;
	}
	
	public static User createUser() {
	   	Profile p = [select p.id from Profile p where p.Name not in ('SSO System Administrator', 'System Administrator') LIMIT 1];
	   	//Creating the user
        User u = new User( Username = 'standarduser@rydertest.com', 
                                    Alias = 'standt', FirstName = 'Ryder', LastName = 'Tester', Email = 'standarduser@rydertest.com',
                                    EmailEncodingKey = USER_EMAIL_ENCODING, LanguageLocaleKey = 'en_US',
                                    LocalesIdKey = 'en_US', ProfileId = p.Id, TimeZonesIdKey = USER_TIMEZONE,
                                    isActive = true);
        return u;
	}
	public static User createUser(String profileName) 
	{
	   	Profile p = [select p.id from Profile p where p.Name =: profileName LIMIT 1];
	   	User usr = new User();
	   	if(p != null)
	   	{
		   	
		   	//Creating the user
	        usr = new User( Username = 'standarduser@rydertest.com', 
	                                    Alias = 'standt', FirstName = 'Ryder', LastName = 'Tester', Email = 'standarduser@rydertest.com',
	                                    EmailEncodingKey = USER_EMAIL_ENCODING, LanguageLocaleKey = 'en_US',
	                                    LocalesIdKey = 'en_US', ProfileId = p.Id, TimeZonesIdKey = USER_TIMEZONE,
	                                    isActive = true);
		}
		else
		{
			usr = createUser();
		}
        return usr;
	}
}