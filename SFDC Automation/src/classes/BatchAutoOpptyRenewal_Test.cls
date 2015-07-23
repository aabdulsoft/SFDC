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
private class BatchAutoOpptyRenewal_Test {

	private static Account createAccount(String name, String classification, boolean decisionmaking){
		Account a = new Account();
		a.name = name;
		a.account_classification__c = classification;
		a.central_decisionmaking__c = decisionmaking;
		a.type = 'Customer';
		insert a;
		return a;
	}

	private static Ryder_Branch__c createRyderBranch(String name){
		Ryder_Branch__c rb = new Ryder_Branch__c();
		rb.name = name;
		insert rb;
		return rb;
	}

	private static Customer_Branch__c createCustomerBranch(Id hqAcctId, Id ryderBranchId){
		Customer_Branch__c cb = new Customer_Branch__c();
		cb.ryder_hq_account__c = hqAcctId;
		cb.Ryder_Branch__c = ryderBranchId;
		insert cb;
		return cb;
	}
	
	private static Vehicle__c createVehicle(String unit, String samClass, String productLine, String renewalType, String packageNum, String name, 
		Id custBranchId, Id accountId) {
		Vehicle__c v = new Vehicle__c();
		v.unit__c = unit;
		v.SAM_CLASS__c = samClass;
		v.PRODUCT_LINE__c = productLine;
		v.Renewal_Default_Type__c = renewalType;
		v.PACKAGE_NUM__c = packageNum;
		v.Name = name;
		v.EXPIRATION_DATE__c = date.today().addmonths(9);
		v.CUSTOMER_BRANCH__c = custBranchId;
		v.account__c = accountId;
		v.Ask_Price__c = 20000.0;
		insert v;
		return v;
	}

	private static String getIds(List<Vehicle__c> lv){
		String s = '';
		
		for (Vehicle__c v : lv)
			s = s + '\'' + v.id + '\',';
		
		s = s.substring(0, s.length()-1);
		
		return s;
	}

	private static User createUser(String alias, String email, String lastName, String username){
		profile p = [select id from profile where name = 'Standard User'][0];
        
        user u = new user();
        u.alias = alias;
        u.email = email;
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey ='en_US';
        u.lastname = lastname;
        u.LocaleSidKey = 'en_US';
        u.ProfileId = p.id;
        u.TimeZoneSidKey = 'America/Chicago';
        u.username = username;
        
        insert u;
        return u;
	}

    static testMethod void myUnitTest() {
        
        list<Vehicle__c> lv = new list<Vehicle__c>();
        
        user u = createUser('alias1', 'mherlihy@salesforce.com', 'test1', 'test1@ryder.com.test');
        
		Account a1 = createAccount('local account', 'Local', false);
		Ryder_Branch__c rb1 = createRyderBranch('ryder branch 1');
		Customer_Branch__c cb1 = createCustomerBranch(a1.id, rb1.id);		
		Vehicle__c v1 = createVehicle('100000000', '180 - Dry Trailer', 'FSL', 'Used', 'package1', 'vehicle1', cb1.id, a1.id);
		lv.add(v1);

		Account a2 = createAccount('nat. centralized acct','National', false);
		Ryder_Branch__c rb2 = createRyderBranch('ryder branch 2');
		Customer_Branch__c cb2 = createCustomerBranch(a2.id, rb2.id);
		Customer_Branch__c cb3 = createCustomerBranch(a2.id, rb2.id);
		cb3.Customer_Branch_Owner__c = u.id;
		Vehicle__c v2 = createVehicle('10000001', '180 - Dry Trailer', 'FSL', 'Used', 'package1', 'vehicle2', cb2.id, a2.id);
		Vehicle__c v3 = createVehicle('10000002', '180 - Dry Trailer', 'FSL', 'Used', 'package1', 'vehicle3', cb3.id, a2.id);
		lv.add(v2);
		lv.add(v3);

		Account a3 = createAccount('nat. decentralized acct','National', true);
		Ryder_Branch__c rb3 = createRyderBranch('ryder branch 3');
		Customer_Branch__c cb4 = createCustomerBranch(a3.id, rb3.id);
		Customer_Branch__c cb5 = createCustomerBranch(a3.id, rb3.id);
		cb5.Customer_Branch_Owner__c = u.id;
		Vehicle__c v4 = createVehicle('10000003', '180 - Dry Trailer', 'FSL', 'Used', 'package1', 'vehicle4', cb4.id, a3.id);
		Vehicle__c v5 = createVehicle('10000004', '180 - Dry Trailer', 'FSL', 'Used', 'package1', 'vehicle5', cb5.id, a3.id);
		lv.add(v4);
		lv.add(v5);

		Account a4 = createAccount('local account', 'Local', false);
		Ryder_Branch__c rb4 = createRyderBranch('ryder branch 4');
		Customer_Branch__c cb6 = createCustomerBranch(a1.id, rb4.id);		
		Vehicle__c v6 = createVehicle('100000005', '180 - Dry Trailer', 'FSL', 'Used', 'package1', 'vehicle6', cb6.id, a4.id);
		lv.add(v6);

		System.debug('+++++ vids: '+ getIds(lv));

		test.starttest();
		
		BatchAutoOpptyRenewal baor = new BatchAutoOpptyRenewal();
		baor.queryString = 'Select v.unit__c, v.SAM_CLASS__c, v.PRODUCT_LINE__c, v.Product_name__c, v.PACKAGE_NUM__c, v.Name, v.Id, v.EXPIRATION_DATE__c, v.CUSTOMER_BRANCH__r.Ryder_HQ_Account__c, v.CUSTOMER_BRANCH__r.Id, v.CUSTOMER_BRANCH__c, v.Customer_Branch__r.Customer_Branch_Owner__c, v.rated_revenue__c, v.CurrencyIsoCode, v.Account__c, v.Account__r.id, v.Account__r.owner.id, v.Account__r.name, v.account__r.Account_Classification__c, v.account__r.Central_Decisionmaking__c, v.account__r.parentid, v.account__r.parent.id, v.account__r.parent.name, v.account__r.parent.owner.id, v.account__r.parent.Account_Classification__c, v.account__r.parent.Central_Decisionmaking__c, v.automatedRenewalCreated__c From Vehicle__c v where v.id in (' + getIds(lv) + ') and v.EXPIRATION_DATE__c >= '+ BatchAutoOpptyRenewal.NINE_MONTHS_AHEAD.format('yyyy-MM-dd') + ' and  v.EXPIRATION_DATE__c < ' + BatchAutoOpptyRenewal.TEN_MONTHS_AHEAD.format('yyyy-MM-dd') + ' and v.automatedRenewalCreated__c = false order by v.account__r.parent.id, v.account__r.id, v.Customer_Branch__r.Customer_Branch_Owner__c';
		
		id bpid = database.executebatch(baor);
		
		test.stoptest();
        
    }
}