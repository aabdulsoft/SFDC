@isTest
private class test_insertUpdateDealSummary {

    static testMethod void testDealSummary() {
    	
    	Account a = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
    	a.billingstate = 'IL';
    	a.BillingPostalCode = '12347';
    	a.BillingCountry = 'US';
    	insert a;
    	System.debug('Account - '+a);
    	System.assert(a.Id!=null);
    	
    	Contact c = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = a.Id);
    	insert c;
    	
    	List<Opportunity> opptyList = new List<Opportunity>();
    	for(Integer i=0; i<3; i++){
    		Opportunity o = TestUtil.createOppty(a, c, 'Standard Opportunity');
    		opptyList.add(o);
    	}
    	//Opportunity o = TestUtil.createOppty(a, 'Parent Opportunity');
    	insert opptyList;
    	System.assert(opptyList.size()>0);
    	System.debug('Opportunity - '+opptyList);
    	
    	//o = [Select VEH_NO__c, Type, Num_of_vehicles__c, NET_REVENUE__c, Id, Gross_Revenue__c, EVA__c, CloseDate From Opportunity  where Id=:o.id];
    	//System.debug(o);
    	
    	List<Deal_Summary__c> dsList = new List<Deal_Summary__c>();
    	for(Integer j=0; j<3; j++){
    		Deal_Summary__c d = TestUtil.createDealSummary(opptyList[j]);
    		d.Include_In_Quote__c=true;
    		dsList.add(d);
    	}
    	insert dsList;
    	System.debug(dsList.size()>0);
    	System.debug('Deal Summary - '+dsList);
    }
    
    static testMethod void testRateSheet() {
    	
    	Account a = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
    	a.billingstate = 'IL';
    	a.BillingPostalCode = '12347';
    	a.BillingCountry = 'US';
    	insert a;
    	System.debug('Account - '+a);
    	System.assert(a.Id!=null);
    	
    	Contact c = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = a.Id);
    	insert c;
    	
    	List<Opportunity> opptyList = new List<Opportunity>();
    	for(Integer i=0; i<3; i++){
    		Opportunity o = TestUtil.createOppty(a, c, 'Standard Opportunity');
    		opptyList.add(o);
    	}
    	
    	//Opportunity o = TestUtil.createOppty(a, 'Parent Opportunity');
    	insert opptyList;
    	System.assert(opptyList.size()>0);
    	System.debug('Opportunity - '+opptyList);
    	//o = [Select VEH_NO__c, Type, Num_of_vehicles__c, NET_REVENUE__c, Id, Gross_Revenue__c, EVA__c, CloseDate From Opportunity  where Id=:o.id];
    	//System.debug(o);
		
		
		List<Rate_Sheet__c> rtList = new List<Rate_Sheet__c>();
    	for(Integer k =0; k<3; k++){
    		Rate_Sheet__c rs = TestUtil.createRateSheet(null, opptyList[k]);
    		rs.Include_In_Quote__c=true;
    		rs.Package_Type__c='Regular';
    		rs.Product_Line__c='Full Service Lease 11 (FMS)';
    		rtList.add(rs);
    	}

    	insert rtList;
    	System.assert(rtList.size()>0);
    	System.debug('RateSheet List is - '+rtList);

    }
}