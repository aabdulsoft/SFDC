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
private class test_DealSummaryRateSheetUtil {

//public static void UpdateOpportunityTotalsForRateSheet(Map<Id, Rate_Sheet__c> rateSheetMap) {
    static testMethod void UpdateOpportunityTotalsForRateSheetTest() {
    	Account a = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
        a.billingstate = 'IL';
        a.BillingPostalCode = '12347';
        a.BillingCountry = 'US';
        insert a;
        
        Contact c = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = a.Id);
    	insert c;
        
        List<Opportunity> opptyList = new List<Opportunity>();
        Opportunity o = TestUtil.createOppty(a, c, 'Standard Opportunity');
        insert o;
        
        List<OpportunityContactRole> allContactRoles = [Select opp.ContactId, opp.Id, opp.IsPrimary, opp.OpportunityId, opp.Role from OpportunityContactRole opp where OpportunityId =: o.Id];
    
	    for (OpportunityContactRole ocr :allContactRoles)
	    {
	    	System.AssertEquals(ocr.ContactId, c.id);
	    	System.AssertEquals(ocr.Role, 'Decision Maker');
	    	System.AssertEquals(ocr.IsPrimary, true);
	    }
        
        List<Rate_Sheet__c> rtList = new List<Rate_Sheet__c>();
        for(Integer k =0; k<3; k++){
            Rate_Sheet__c rs = TestUtil.createRateSheet(null, o);
            rs.Include_In_Quote__c=true;
            rs.Package_Type__c='Regular';
            rs.Product_Line__c='Full Service Lease 11 (FMS)';
            rtList.add(rs);
        }

        insert rtList;
        Map<Id, Rate_Sheet__c> rateSheetMap = new Map<Id, Rate_Sheet__c>([Select r.ext_ratesheet_id__c, r.SystemModstamp, r.Rate_Sheet_Name__c, r.Product_Line__c, r.Package_Type__c, r.Opportunity__c, r.No_of_Vehicles__c, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsDeleted, r.Include_in_EVA__c, r.Include_In_Quote__c, r.Id, r.Gross_Revenue__c, r.EVA__c, r.Deal_Summary__c, r.CurrencyIsoCode, r.CreatedDate, r.CreatedById From Rate_Sheet__c r where r.Opportunity__c =: o.id]); 
        Test.startTest();
        
        DealSummaryRateSheetUtil.UpdateOpportunityTotalsForRateSheet(rateSheetMap);
        Test.stopTest();
    }

//public static void UpdateOpportunityTotalsForDealSummary(Map<Id, Deal_Summary__c> dealSummaryMap) {
    static testMethod void UpdateOpportunityTotalsForDealSummaryTest() {
        Account a = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
        a.billingstate = 'IL';
        a.BillingPostalCode = '12347';
        a.BillingCountry = 'US';
        insert a;
        
        Contact c = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = a.Id);
    	insert c;
        
        List<Opportunity> opptyList = new List<Opportunity>();
        Opportunity o = TestUtil.createOppty(a, c, 'Standard Opportunity');
        insert o;
        
        List<OpportunityContactRole> allContactRoles = [Select opp.ContactId, opp.Id, opp.IsPrimary, opp.OpportunityId, opp.Role from OpportunityContactRole opp where OpportunityId =: o.Id];
    
	    for (OpportunityContactRole ocr :allContactRoles)
	    {
	    	System.AssertEquals(ocr.ContactId, c.id);
	    	System.AssertEquals(ocr.Role, 'Decision Maker');
	    	System.AssertEquals(ocr.IsPrimary, true);
	    }
        
        List<Deal_Summary__c> dsList = new List<Deal_Summary__c>();
        for(Integer j=0; j<3; j++){
            Deal_Summary__c d = TestUtil.createDealSummary(o);
            d.Include_In_Quote__c=true;
            dsList.add(d);
        }
        insert dsList;
        
        Map<Id, Deal_Summary__c > dealSummaryMap = new Map<Id, Deal_Summary__c>([Select d.ext_dealsummary_id__c, d.SystemModstamp, d.Status__c, d.Opportunity__c, d.No_of_Vehicles__c, d.Name, d.LastModifiedDate, d.LastModifiedById, d.IsDeleted, d.Include_in_EVA__c, d.Include_In_Quote__c, d.Id, d.Gross_Revenue__c, d.EVA__c, d.CurrencyIsoCode, d.CreatedDate, d.CreatedById From Deal_Summary__c d where d.Opportunity__c =: o.id]); 
        Test.startTest();
        DealSummaryRateSheetUtil.UpdateOpportunityTotalsForDealSummary(dealSummaryMap);
        Test.stopTest();
    }
    
    // public static List<Rate_Sheet__c> parseRateSheetResponse(List<GetOpportunityLocal.DCRateSheet> rateSheetList) {
    static testMethod void parseRateSheetResponseTest() {
    	List<GetOpportunityLocal.DCRateSheet> rateSheetList = new List<GetOpportunityLocal.DCRateSheet>();
    	GetOpportunityLocal.DCRateSheet dcRateSheet = new GetOpportunityLocal.DCRateSheet();
    	dcRateSheet.DealSummaryId = 123;
    	dcRateSheet.DealSummaryName = 'Deal Summary Name';
    	dcRateSheet.EVA = 10.0;
    	dcRateSheet.GrossRevenue = 120.0;
    	dcRateSheet.ID = 1248977;
    	dcRateSheet.IsEVA = false;
    	dcRateSheet.NumberOfvehicles = 12;
    	dcRateSheet.OpportunityId = '1234567';
    	dcRateSheet.PakageType = 'PackageType';
    	dcRateSheet.ProductLine = 'ProductLine';
    	dcRateSheet.RateSheetName = 'RateSheet Name';
    	dcRateSheet.IncludeInEVA = true;
        dcRateSheet.FuelType = 'Fuel Type';
        dcRateSheet.OriginalCreateDate = datetime.now();
        dcRateSheet.OldRevenue = 100.00;
        //dcRateSheet.Name = 'Name';
    	rateSheetList.add(dcRateSheet);
    	
    	Test.startTest();
        List<Rate_Sheet__c> result = DealSummaryRateSheetUtil.parseRateSheetResponse(rateSheetList);
        Test.stopTest();
    }

// public static List<Deal_Summary__c> parseDealSummaryResponse(List<GetOpportunityLocal.DCDealSummary> dsList) {
    static testMethod void parseDealSummaryResponseTest() {
        List<GetOpportunityLocal.DCDealSummary> dsList = new List<GetOpportunityLocal.DCDealSummary>();
        GetOpportunityLocal.DCDealSummary ds = new GetOpportunityLocal.DCDealSummary();
        ds.ID = 123;
        ds.DealSummaryName = 'Deal Summary Name';
        ds.EVA= 10.0;
        ds.GrossRevenue= 120.0;
        ds.Status = 'Status';
        ds.NumberOfvehicles = 12;
        ds.OpportunityId = '1234567';
        dsList.add(ds);
        
        Test.startTest();
        List<Deal_Summary__c> result = DealSummaryRateSheetUtil.parseDealSummaryResponse(dsList);
        Test.stopTest();
    }

//public static OpportunityDSAndRSVO SyncDealSummaryAndRateSheetForOpportunity (String opportunityId)
    static testMethod void SyncDealSummaryAndRateSheetForOpportunityTest() {
        Account a = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
        a.billingstate = 'IL';
        a.BillingPostalCode = '12347';
        a.BillingCountry = 'US';
        insert a;
        
        Contact c = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = a.Id);
    	insert c;
    	
        List<Opportunity> opptyList = new List<Opportunity>();
        Opportunity o = TestUtil.createOppty(a, c, 'Standard Opportunity');
        insert o;
        
        List<OpportunityContactRole> allContactRoles = [Select opp.ContactId, opp.Id, opp.IsPrimary, opp.OpportunityId, opp.Role from OpportunityContactRole opp where OpportunityId =: o.Id];
    
	    for (OpportunityContactRole ocr :allContactRoles)
	    {
	    	System.AssertEquals(ocr.ContactId, c.id);
	    	System.AssertEquals(ocr.Role, 'Decision Maker');
	    	System.AssertEquals(ocr.IsPrimary, true);
	    }
        
        List<Rate_Sheet__c> rtList = new List<Rate_Sheet__c>();
        for(Integer k =0; k<3; k++){
            Rate_Sheet__c rs = TestUtil.createRateSheet(null, o);
            rs.Include_In_Quote__c=true;
            rs.Package_Type__c='Regular';
            rs.Product_Line__c='Full Service Lease 11 (FMS)';
            rtList.add(rs);
        }

        insert rtList;
        
        Test.startTest();
        DealSummaryRateSheetUtil.SyncDealSummaryAndRateSheetForOpportunity(o.id);
        Test.stopTest();
    }

//public static void UpdateOpportunityTotalsForOpportunityLineItems(Map<Id, OpportunityLineItem> OppLineItemSummaryMap) {
    static testMethod void UpdateOpportunityTotalsForOpportunityLineItemsTest() {
        List<Id> opportunityIds = new List<Id>();
		Map<Id, OpportunityLineItem> OppLineItemSummaryMap = new Map<Id, OpportunityLineItem>();
		
        Set<Id> OppLineItemIds = OppLineItemSummaryMap.keySet();
        for (Id OppLineItemId: OppLineItemIds) {
            OpportunityLineItem oli = OppLineItemSummaryMap.get(OppLineItemId);
            opportunityIds.add(oli.opportunityid);
        }
        OpportunityUtil.UpdateOpportunityTotals(opportunityIds);
        
        Test.startTest();
        DealSummaryRateSheetUtil.UpdateOpportunityTotalsForOpportunityLineItems(OppLineItemSummaryMap);
        Test.stopTest();
    }
    
//private static List<GetOpportunityLocal.DCOpportunityLocalCollection> getOpportunityLocal(String opportunityId, Opportunity opptyResult, List<OpportunityLineItem> opptyLineItemResult, List<Deal_Summary__c> dealSummaryIncInQuoteResult, List<Rate_Sheet__c> rateSheetIncInQuoteResult, List<Opportunity_Split__c> opptySplitResult)
	static testMethod void getOpportunityLocalTest() {
		Opportunity opptyResult = [Select o.Name,
                                          o.Account_Classification__c,
                                          o.AccountId,
                                          o.Actual_Close_Date__c,
                                          o.CloseDate,
                                          o.CurrencyIsoCode,
                                          o.Description,
                                          o.EST_DEAL_VAL__c,
                                          o.Estimated_Proposal_Date__c,
                                          o.EVA__c,
                                          o.EVA_VEH__c,
                                          o.ext_pipeline_id__c,
                                          o.Fiscal,
                                          o.FiscalQuarter,
                                          o.FiscalYear,
                                          o.ForecastCategory,
                                          o.ForecastCategoryName,
                                          o.HasAccount__c,
                                          o.HasOpportunityLineItem,
                                          o.IsClosed,
                                          o.IsPrivate,
                                          o.IsWon,
                                          o.LastActivityDate,
                                          o.Num_of_vehicles__c,
                                          o.OwnerId,
                                          o.Pricebook2Id,
                                          o.Probability,
                                          o.Reason_Won_Lost__c,
                                          o.RecordTypeId,
                                          o.SPLIT_VALUE__c,
                                          o.StageName,
                                          o.LastModifiedById,
                                          o.LastModifiedDate,
                                          o.CreatedById,
                                          o.CreatedDate,
                                          o.IsDeleted,
                                          o.Old_Revenue__c,
                                          o.Total_EVA__c,
                                          o.Included_in_Monthly_Forecast__c,
                                          o.Included_in_Quarterly_Forecast__c,
                                          o.Automatic_Renewed__c
                                        From Opportunity o 
                                        where o.id = '0066000000NDO8VAAX']; 
		GetOpportunityLocal.OpportunityLocalCollectionRequestCriteria requestCriteria = new GetOpportunityLocal.OpportunityLocalCollectionRequestCriteria();
		requestCriteria.Id= '1234567';
        requestCriteria.SearchByOpportunityId = true;
        requestCriteria.Name = 'Name';
        requestCriteria.Account_Classification_xc = 'Account Classification';
        requestCriteria.AccountId = 'AccountId';
        requestCriteria.Actual_Close_Date_xc = datetime.now();        
        requestCriteria.CloseDate = datetime.now();
        requestCriteria.CurrencyIsoCode = 'CurrencyIsoCode';
        requestCriteria.Description ='Description';
        requestCriteria.EST_DEAL_VAL_xc = 0;
        requestCriteria.Estimated_Proposal_Date_xc = datetime.now();
        requestCriteria.EVA_xc = 0;
        requestCriteria.EVA_VEH_xc = '0';
        requestCriteria.ext_pipeline_id_xc = '0';
        requestCriteria.Fiscal = 'Fiscal';
        requestCriteria.FiscalQuarter = 2;
        requestCriteria.FiscalYear = 2014;
        requestCriteria.ForecastCategory = 'ForecastCategory';
        requestCriteria.ForecastCategoryName = 'ForecastCategoryName';
        requestCriteria.HasAccount_xc = true;
        requestCriteria.HasOpportunityLineItem = false;
        requestCriteria.IsClosed = false;
        requestCriteria.IsPrivate = false;
        requestCriteria.IsWon = false;
        requestCriteria.LastActivityDate = datetime.now();
        requestCriteria.Num_of_vehicles_xc = 12;
        requestCriteria.OwnerId = '1234567';
        requestCriteria.Pricebook2Id = 'Pricebook2Id';
        requestCriteria.Probability = 10.0;
        requestCriteria.Reason_Won_Lost_xc = '';
        requestCriteria.RecordTypeId = 'RecordTypeId';
        requestCriteria.SPLIT_VALUE_xc = true;
        requestCriteria.StageName = 'StageName';
        requestCriteria.Old_Revenue_xc = 0;
        requestCriteria.Total_EVA_xc = 100;
        requestCriteria.Included_in_Monthly_Forecast_xc = true;
        requestCriteria.Included_in_Quarterly_Forecast_xc = true;
        requestCriteria.Automatic_Renewed_xc = false;
        requestCriteria.OpportunityProductLineItemJson = '';
        requestCriteria.DealSummaryIncludeInQuoteJson = '';
        requestCriteria.RateSheetIncludeInQuoteJson = '';
        requestCriteria.OpportunitySplitJson = '';
        
        GetOpportunityLocal.GetOpportunityLocalSoap opportunityLocalSoap = new GetOpportunityLocal.GetOpportunityLocalSoap();
        GetOpportunityLocal.CRMCredential credential = new GetOpportunityLocal.CRMCredential(); 
        credential.UserName = '';
        credential.Password = '';
        credential.SecurityToken = '';
        opportunityLocalSoap.timeout_x = 120;
        opportunityLocalSoap.endpoint_x = 'GET_OPPORTUNITY_LOCAL';
        
        Test.startTest();
        List<GetOpportunityLocal.DCOpportunityLocalCollection> result = DealSummaryRateSheetUtil.getOpportunityLocal(opptyResult.Id, opptyResult, null, null, null, null);
        Test.stopTest();
	}

	//public static List<Pipeline_Detail__c> parsePipelineDetailResponse(List<GetOpportunityLocal.DCPipelineDetail> pipelineDetailList)
    static testMethod void parsePipelineDetailResponseTest() {
        List<GetOpportunityLocal.DCPipelineDetail> pdList = new List<GetOpportunityLocal.DCPipelineDetail>();
        
        GetOpportunityLocal.DCPipelineDetail pipelineDetailSF = new GetOpportunityLocal.DCPipelineDetail();
        pipelineDetailSF.Name = 'Name';
        pipelineDetailSF.ProductLine = 'ProductLine';
        pipelineDetailSF.ProductLineNumber = 'ProductLineNumber';
        pipelineDetailSF.TransactionType = 'TransactionType';
        pipelineDetailSF.NumberOfvehicles = 12;
        pipelineDetailSF.EVA = 100.0;
        pipelineDetailSF.OpportunityId = '0066000000NDO8VAAX';
        pipelineDetailSF.UserId = '00560000001NgTe';
        pipelineDetailSF.SplitAmount = 0.0;
        pipelineDetailSF.SplitPercentage = 100;
        pipelineDetailSF.ExtrefPipelineDetailId = '1234567';
        pipelineDetailSF.TotalAmount = 0.00;
        pipelineDetailSF.TotalVehicle = 12.0;
        pipelineDetailSF.GroupingKeyWOSplits = '';
        pipelineDetailSF.ReportOnUser = '00560000001NgTe'; 
        pipelineDetailSF.ProductDetail = 'ProductDetail'; 
        pipelineDetailSF.ReportAmount = 0.0;
        Date newCloseDate = Date.newInstance(2014,1,1);
        pipelineDetailSF.CloseDate = newCloseDate;
        pdList.add(pipelineDetailSF);
        
        Test.startTest();
        List<Pipeline_Detail__c> result = DealSummaryRateSheetUtil.parsePipelineDetailResponse(pdList);
        Test.stopTest();
    }
    
    //public static List<Opportunity_Split__c> parseOpportunitySplitCUSTOMResponse(List<GetOpportunityLocal.DCOpportunitySplit> opportunitySplitList) {
    static testMethod void parseOpportunitySplitCUSTOMResponseTest() {
        List<GetOpportunityLocal.DCOpportunitySplit> osList = new List<GetOpportunityLocal.DCOpportunitySplit>();
                
        GetOpportunityLocal.DCOpportunitySplit opportunitySplitSF = new GetOpportunityLocal.DCOpportunitySplit();
        opportunitySplitSF.OpportunityId = '1234567';
        opportunitySplitSF.PipelineAmount = 100.00;
        opportunitySplitSF.SalesTeamMember = '1234567';
        opportunitySplitSF.SplitPercentage = 100;
        opportunitySplitSF.UserType = 'UserType';
        
        Test.startTest();
        List<Opportunity_Split__c> result = DealSummaryRateSheetUtil.parseOpportunitySplitCUSTOMResponse(osList);
        Test.stopTest();
        
    }
}