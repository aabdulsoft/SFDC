@isTest
private class test_OpportunityControllerExtension {

    static testMethod void testOpttyDetailPage() {
    	Account a = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
    	a.BillingState = 'IL';
    	a.BillingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
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
    	
    	List<Deal_Summary__c> dsList = new List<Deal_Summary__c>();
    	for(Integer j=0; j<3; j++){
    		Deal_Summary__c d = TestUtil.createDealSummary(opptyList[j]);
    		d.Include_In_Quote__c=true;
    		dsList.add(d);
    	}
    	insert dsList;
    	System.debug(dsList.size()>0);
    	System.debug('Deal Summary - '+dsList);
    	
    	//https://c.cs4.visual.force.com/apex/OpportunityDetail?id=006P0000001uFkO&sfdc.override=1
    	
    	System.assert(opptyList[0].Id!=null);
    	PageReference pRef = new Pagereference('/apex/OpportunityDetail?id='+opptyList[0].Id);
    	Test.setCurrentPage(pRef);
    	ApexPages.StandardController stdController = new ApexPages.Standardcontroller(opptyList[0]);
    	OpportunityControllerExtension2 opttyExt = new OpportunityControllerExtension2(stdController);
    	
    	opttyExt.isTest=true;
    	opttyExt.retrieveRateSheetsAndDealSummaries();
    	
    	opttyExt.isTest=false;
    	opttyExt.retrieveRateSheetsAndDealSummaries();
    	
    }
    
    static testMethod void testOpttyDetailPage2() {
        Account a = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
        a.BillingState = 'IL';
        a.BillingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
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
        
        List<Deal_Summary__c> dsList = new List<Deal_Summary__c>();
        for(Integer j=0; j<3; j++){
            Deal_Summary__c d = TestUtil.createDealSummary(opptyList[j]);
            d.Include_In_Quote__c=true;
            dsList.add(d);
        }
        insert dsList;
        System.debug(dsList.size()>0);
        System.debug('Deal Summary - '+dsList);
        
        //https://c.cs4.visual.force.com/apex/OpportunityDetail?id=006P0000001uFkO&sfdc.override=1
        
        System.assert(opptyList[0].Id!=null);
        PageReference pRef = new Pagereference('/apex/OpportunityDetail?id='+opptyList[0].Id + '&validOppty=true');
        Test.setCurrentPage(pRef);
        ApexPages.StandardController stdController = new ApexPages.Standardcontroller(opptyList[0]);
        OpportunityControllerExtension2 opptyExt = new OpportunityControllerExtension2(stdController);
        
        opptyExt.isTest=true;
        opptyExt.retrieveRateSheetsAndDealSummaries();
        
        PageReference pageRef2 = opptyExt.updateDSAndRS();
        
        PageReference pageRef = opptyExt.backtoOppty();
    }
    
    static testMethod void testOpttyDetailPage3() {
        Account a = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
        a.BillingState = 'IL';
        a.BillingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
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
        
        List<Deal_Summary__c> dsList = new List<Deal_Summary__c>();
        for(Integer j=0; j<3; j++){
            Deal_Summary__c d = TestUtil.createDealSummary(opptyList[j]);
            d.Include_In_Quote__c=true;
            dsList.add(d);
        }
        insert dsList;
        System.debug(dsList.size()>0);
        System.debug('Deal Summary - '+dsList);
        
        //https://c.cs4.visual.force.com/apex/OpportunityDetail?id=006P0000001uFkO&sfdc.override=1
        
        System.assert(opptyList[0].Id!=null);
        PageReference pRef = new Pagereference('/apex/OpportunityDetail?id='+opptyList[0].Id);
        Test.startTest();
        Test.setCurrentPage(pRef);
        ApexPages.StandardController stdController = new ApexPages.Standardcontroller(opptyList[0]);
        OpportunityControllerExtension2 opptyExt = new OpportunityControllerExtension2(stdController);
        
        opptyExt.isTest=false;
        opptyExt.retrieveRateSheetsAndDealSummaries();
        PageReference pageRef2 = opptyExt.updateDSAndRS();
        PageReference pageRef = opptyExt.backtoOppty();
        Test.stopTest();
    }
    
}