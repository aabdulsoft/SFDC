@istest
private class test_GetRateSheets {


    static testMethod void test_GetRateSheets(){
        
        GetRateSheets.ProcessRequestResponse_element prr = new GetRateSheets.ProcessRequestResponse_element();
        GetRateSheets.DCRateSheets rss = new GetRateSheets.DCRateSheets();
        GetRateSheets.ArrayOfDCRateSheet ars = new GetRateSheets.ArrayOfDCRateSheet();
        ars.DCRateSheet = new GetRateSheets.DCRateSheet[1];
        rss.RateSheets = new GetRateSheets.ArrayOfDCRateSheet();
        GetRateSheets.DCRateSheet rs = new GetRateSheets.DCRateSheet();
        rs.DealSummaryId = 0;
        rs.DealSummaryName = '';
        rs.EVA = 0.0;
        rs.GrossRevenue = 0.0;
        rs.ID = 0;
        rs.NumberOfvehicles = 0;
        rs.PakageType = '';
        rs.ProductLine = '';
        rs.RateSheetName = '';
        ars.DCRateSheet[0] = rs;
        rss.RateSheets = ars;
        
        prr.ProcessRequestResult = rss;
        
        GetRateSheets.CRMCredential cc = new GetRateSheets.CRMCredential();
        cc.Password = '';
        cc.SecurityToken = '';
        cc.UserName = '';
        
        GetRateSheets.RateSheetRequestCriteria rsrc = new GetRateSheets.RateSheetRequestCriteria();
        rsrc.Id = '';
        rsrc.SearchByCompanyId = false;
        rsrc.SearchByOpportunityId = false;
    }

}