@isTest
private class test_GetOpportunityLocal {

    static testMethod void DCDealSummaryTest() {
        
        GetOpportunityLocal.ProcessRequestResponse_element prr = new GetOpportunityLocal.ProcessRequestResponse_element();
        GetOpportunityLocal.DCDealSummary ds = new GetOpportunityLocal.DCDealSummary();
        GetOpportunityLocal.ArrayOfDCDealSummary ads = new GetOpportunityLocal.ArrayOfDCDealSummary();
        ads.DCDealSummary = new GetOpportunityLocal.DCDealSummary[1];
        
        ds.ID= 0;
        ds.DealSummaryName= '';
        ds.Status= '';
        ds.GrossRevenue= 0.0;
        ds.NumberOfvehicles= 0;
        ds.EVA = 0.0;
        ds.OpportunityId = '';
        ds.IncludeInQuote = false;
        ds.SfDealSummaryId = '';
        ds.ExtDealSummaryId = 0;
        ads.DCDealSummary[0] = ds;

        GetOpportunityLocal.CRMCredential cc = new GetOpportunityLocal.CRMCredential();
        cc.Password = '';
        cc.SecurityToken = '';
        cc.UserName = '';

        GetOpportunityLocal.OpportunityLocalCollectionRequestCriteria olrc = new GetOpportunityLocal.OpportunityLocalCollectionRequestCriteria();
        olrc.Id = '';
        olrc.SearchByOpportunityId = false;
    }

    static testMethod void DCRateSheetsTest(){
        
        GetOpportunityLocal.ProcessRequestResponse_element prr = new GetOpportunityLocal.ProcessRequestResponse_element();
        GetOpportunityLocal.DCRateSheet rss = new GetOpportunityLocal.DCRateSheet();
        GetOpportunityLocal.ArrayOfDCRateSheet ars = new GetOpportunityLocal.ArrayOfDCRateSheet();
        ars.DCRateSheet = new GetOpportunityLocal.DCRateSheet[1];
        //rss.RateSheets = new GetOpportunityLocal.ArrayOfDCRateSheet();
        GetOpportunityLocal.DCRateSheet rs = new GetOpportunityLocal.DCRateSheet();
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
    }
    
    static testMethod void DCOpportunitySplitTest(){
        
        GetOpportunityLocal.ProcessRequestResponse_element prr = new GetOpportunityLocal.ProcessRequestResponse_element();
        GetOpportunityLocal.DCOpportunitySplit rss = new GetOpportunityLocal.DCOpportunitySplit();
        GetOpportunityLocal.ArrayOfDCOpportunitySplit ars = new GetOpportunityLocal.ArrayOfDCOpportunitySplit();
        ars.DCOpportunitySplit = new GetOpportunityLocal.DCOpportunitySplit[1];
        //rss.RateSheets = new GetOpportunityLocal.ArrayOfDCRateSheet();
        GetOpportunityLocal.DCOpportunitySplit os = new GetOpportunityLocal.DCOpportunitySplit();
        os.ID = '';
        os.ExtPipelineId = '';
        os.MigrationCounter = '';
        os.Name = '';
        os.OpportunityId = '';
        os.PipelineAmount = 0.0;
        os.PipelineSplitAmount = 0.0;
        os.SalesTeamMember = '';
        os.SplitPercentage= 0.0;
        os.UserType = '';
        ars.DCOpportunitySplit[0] = os;
    }
    
    static testMethod void DCPipelineDetailTest(){
        
        GetOpportunityLocal.ProcessRequestResponse_element prr = new GetOpportunityLocal.ProcessRequestResponse_element();
        GetOpportunityLocal.DCPipelineDetail rss = new GetOpportunityLocal.DCPipelineDetail();
        GetOpportunityLocal.ArrayOfDCPipelineDetail ars = new GetOpportunityLocal.ArrayOfDCPipelineDetail();
        ars.DCPipelineDetail = new GetOpportunityLocal.DCPipelineDetail[1];
        GetOpportunityLocal.DCPipelineDetail pd = new GetOpportunityLocal.DCPipelineDetail();
        pd.ID = '';
        pd.Name= '';
        pd.ProductLine= '';
        pd.ProductLineNumber= '';
        pd.TransactionType= '';
        pd.NumberOfvehicles= 0.0;
        pd.EVA= 0.0;
        pd.OpportunityId= '';
        pd.OpportunitySplitId= '';
        pd.RateSheet= '';
        pd.UserId= '';
        pd.SplitAmount = 0.0;
        pd.SplitPercentage = 0.0;
        pd.ExtrefPipelineDetailId = '';
        pd.TotalAmount = 0.0;
        pd.TotalVehicle = 0.0;
        pd.GroupingKeyWOSplits = '';
        pd.ReportOnUser = '';
        pd.ProductDetail = '';
        pd.ReportAmount = 0.0;
        ars.DCPipelineDetail[0] = pd;
    }
    
    static testMethod void DCOpportunityLocalTest(){
        
        GetOpportunityLocal.ProcessRequestResponse_element prr = new GetOpportunityLocal.ProcessRequestResponse_element();
        GetOpportunityLocal.DCOpportunityLocal rss = new GetOpportunityLocal.DCOpportunityLocal();
        GetOpportunityLocal.ArrayOfDCOpportunityLocal ars = new GetOpportunityLocal.ArrayOfDCOpportunityLocal();
        ars.DCOpportunityLocal = new GetOpportunityLocal.DCOpportunityLocal[1];
        GetOpportunityLocal.DCOpportunityLocal ol = new GetOpportunityLocal.DCOpportunityLocal();
        ol.ID = '';
        ol.OpportunityName= '';
        ol.Editable= false;
        ol.IsSuccess= false;
        ars.DCOpportunityLocal[0] = ol;
    }
    
    static testMethod void DCOpportunityProductLineItemTest(){
        
        GetOpportunityLocal.ProcessRequestResponse_element prr = new GetOpportunityLocal.ProcessRequestResponse_element();
        GetOpportunityLocal.DCOpportunityProductLineItem rss = new GetOpportunityLocal.DCOpportunityProductLineItem ();
        GetOpportunityLocal.ArrayOfDCOpportunityProductLineItem ars = new GetOpportunityLocal.ArrayOfDCOpportunityProductLineItem();
        ars.DCOpportunityProductLineItem = new GetOpportunityLocal.DCOpportunityProductLineItem[1];
        GetOpportunityLocal.DCOpportunityProductLineItem opl = new GetOpportunityLocal.DCOpportunityProductLineItem();
        opl.ID = '';
        opl.Product_Detail_xc= '';
        opl.Product_Line_xc = '';
        opl.Quantity = 0.0;
        opl.TotalPrice = 0.0;
        opl.Transaction_Type_xc = '';
        opl.Unit_Number_xc = '';
        opl.OpportunityId = '';
        opl.Automatic_Renewed_xc = false;
        ars.DCOpportunityProductLineItem[0] = opl;
    }
    
    static testMethod void OpportunityLocalCollectionRequestCriteriaTest(){
        
        GetOpportunityLocal.OpportunityLocalCollectionRequestCriteria olc = new GetOpportunityLocal.OpportunityLocalCollectionRequestCriteria();
        olc.Id= '';
        olc.SearchByOpportunityId = false;
        olc.Name= '';
        olc.Account_Classification_xc = '';
        olc.AccountId = '';
        olc.CurrencyIsoCode= '';
        olc.Description= '';
        olc.EST_DEAL_VAL_xc = 0.0;
        olc.EVA_xc = 0.0;
        olc.EVA_VEH_xc = '';
        olc.ext_pipeline_id_xc = '';
        olc.Fiscal = '';
        olc.FiscalQuarter = 0;
        olc.FiscalYear = 0;
        olc.ForecastCategory = '';
        olc.ForecastCategoryName = '';
        olc.HasAccount_xc = false;
        olc.HasOpportunityLineItem = false;
        olc.IsClosed = false;
        olc.IsPrivate = false;
        olc.IsWon = false;
        olc.Num_of_vehicles_xc = 0;
        olc.OwnerId = '';
        olc.Pricebook2Id = '';
        olc.Probability = 0.0;
        olc.Reason_Won_Lost_xc = '';
    }
    
}