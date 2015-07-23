@istest
private class test_GetDealSummaries {    
    static testMethod void test_GetDealSummaries (){                
        GetDealSummaries.ProcessRequestResponse_element prr = new GetDealSummaries.ProcessRequestResponse_element();
        GetDealSummaries.DCDealSummary ds = new GetDealSummaries.DCDealSummary();
        GetDealSummaries.DCDealSummaries dss = new GetDealSummaries.DCDealSummaries();
        GetDealSummaries.ArrayOfDCDealSummary ads = new GetDealSummaries.ArrayOfDCDealSummary();
        ads.DCDealSummary = new GetDealSummaries.DCDealSummary[1];
        dss.DealSummaries = new GetDealSummaries.ArrayOfDCDealSummary();
        
        ds.DealSummaryName = '';
        ds.EVA = 0.0;
        ds.GrossRevenue = 0.0;
        ds.ID = 0;
        ds.NumberOfvehicles = 0;
        ads.DCDealSummary[0] = ds;
        prr.ProcessRequestResult = dss;

        GetDealSummaries.CRMCredential cc = new GetDealSummaries.CRMCredential();
        cc.Password = '';
        cc.SecurityToken = '';
        cc.UserName = '';

        GetDealSummaries.DealSummaryRequestCriteria dsrc = new GetDealSummaries.DealSummaryRequestCriteria();
        dsrc.Id = '';
        dsrc.SearchByCompanyId = false;
        dsrc.SearchByOpportunityId = false;
    }
}