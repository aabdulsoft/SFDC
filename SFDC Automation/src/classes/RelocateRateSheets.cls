public virtual without sharing class RelocateRateSheets {

    @future (callout=true)
    public static void MoveRateSheetsInRadarFuture(String partialWinResultJSON, String oldOppId){
    
        //Call web service and pass the new opportunity id's and rate sheet id's
        boolean isRelocated = false;
        
        // Create soap request 
        PWRelocateOpportunities.PWRelocateOpportunitiesSoap pwRelocateOpportunitiesSoap = new PWRelocateOpportunities.PWRelocateOpportunitiesSoap();
        PWRelocateOpportunities.CRMCredential credential = new PWRelocateOpportunities.CRMCredential(); 
        credential.UserName = '';
        credential.Password = '';
        credential.SecurityToken = '';
        pwRelocateOpportunitiesSoap.timeout_x = RyderGlobalVariables.WS_TIMEOUT;
        pwRelocateOpportunitiesSoap.endpoint_x = RyderGlobalVariables.RYDER_WS_ENDPOINT + RyderGlobalVariables.PW_RELOCATE_OPPORTUNITIES;
                
        //Bind data to request criteria
        PWRelocateOpportunities.PartialWinRequestCriteria requestCriteria = new PWRelocateOpportunities.PartialWinRequestCriteria();
        requestCriteria.DataToRelocateInJson = partialWinResultJSON;
        requestCriteria.UserRideId = '19368';//currUserRideId; 
        requestCriteria.Id = '';
        
        try
        {
            System.debug('aaaaaaa requestCriteria result: ' + requestCriteria );
            // Make a soap request 
            PWRelocateOpportunities.DCPartialWins pwRelocateOpportunities = pwRelocateOpportunitiesSoap.ProcessRequest(credential, requestCriteria); 
            System.debug('aaaaaaa pwRelocateOpportunities result: ' + pwRelocateOpportunities );
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.ERROR, 'Error making Soap request for PWRelocateOpportunities exception: ' + ex.getMessage());
            throw ex;
        }
        
        
        //Refresh opportunities to sync Salesforce and Radar (this will replicate the same function as when a user opens an Opportunity and pupulates it properly)
        OpportunityDSAndRSVO refreshResult = null;
        
        try
        {
            //Refresh old Opportunity
            refreshResult = DealSummaryRateSheetUtil.SyncDealSummaryAndRateSheetForOpportunity(oldOppId);
            System.debug('aaaaaaa refreshResult result: ' + refreshResult );
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.ERROR, 'Error making Soap request/refresh for Old Oppty: DealSummaryRateSheetUtil.SyncDealSummaryAndRateSheetForOpportunity exception: ' + ex.getMessage());
        }

    }
    
    @future (callout=true)
    public static void RefreshNewOpportunityFuture(String oppId){

        OpportunityDSAndRSVO refreshResult = null;

        try
        {
            //Refresh Opportunity
            refreshResult = DealSummaryRateSheetUtil.SyncDealSummaryAndRateSheetForOpportunity(oppId);
            System.debug('aaaaaaa RefreshNewOpportunityFuture Id: ' + oppId + ' result: ' + refreshResult );
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.ERROR, 'Error making Soap request/refresh for New Oppty: Id: ' + oppId + ' DealSummaryRateSheetUtil.SyncDealSummaryAndRateSheetForOpportunity exception: ' + ex.getMessage());
        }
        
        try
        {
            //Update this opportunity to include in forcasts
            Opportunity updOppty = new Opportunity();
            updOppty.Id = oppId;
            updOppty.Included_in_Monthly_Forecast__c = true;
            updOppty.Included_in_Quarterly_Forecast__c = true;
            System.debug('aaaaaaa updOppty.ext_pipeline_id__c: ' + updOppty.ext_pipeline_id__c );
            if(updOppty.ext_pipeline_id__c == null || updOppty.ext_pipeline_id__c == ''){
                Opportunity updOpptyAutoNum = [select Id, PipelineIDGenerator__c from Opportunity where Id = :oppId];
                updOppty.ext_pipeline_id__c = updOpptyAutoNum.PipelineIDGenerator__c;
                System.debug('aaaaaaa Auto Num In: ' + updOppty.PipelineIDGenerator__c );
                System.debug('aaaaaaa Auto Num In PipelineIDGenerator__c: ' + updOpptyAutoNum.PipelineIDGenerator__c + ' - ' + updOpptyAutoNum);
            }
            update updOppty;
            
            System.debug('aaaaaaa After Update: ' + updOppty );
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.ERROR, 'Error updating opportunity forcast (in salesforce): Oppty Id: ' + oppId + ' exception: ' + ex.getMessage());
        }
        
        try
        {   
            List<Rate_Sheet__c> rsList = new List<Rate_Sheet__c>(); 
            rsList = [select Id, Opportunity__c, Include_In_Quote__c from Rate_Sheet__c where Opportunity__c = :oppId];
            
            System.debug('aaaaaaa Before RS Update rsList: ' + rsList );
            
            if(rsList == null){
                System.debug('aaaaaaa if (null): ' + rsList );
                
                Datetime dtNow = System.now();
                System.debug('aaaaaaa dtNow1: ' + dtNow );
                Datetime dtAddedSeconds = dtNow.addSeconds(60);
                System.debug('aaaaaaa dtAddedSeconds1: ' + dtAddedSeconds );
                while(dtNow < dtAddedSeconds){
                    System.debug('aaaaaaa while ');
                    //This loop with force a wait for (x) seconds to make sure the 
                    //rate sheets have already moved in Radar.
                }
                System.debug('aaaaaaa dtNow: ' + dtNow + ' - dtAddedSeconds: ' + dtAddedSeconds );
                
                //Get list again
                rsList = [select Id, Opportunity__c, Include_In_Quote__c from Rate_Sheet__c where Opportunity__c = :oppId];
                System.debug('aaaaaaa rsList get list again: ' + rsList );
            }

            if(rsList != null){
                System.debug('aaaaaaa else (not null): ' + rsList );
                //Update this opportunity's Rate Sheets to include in quota
                for (Rate_Sheet__c rs :rsList){
                    rs.Include_In_Quote__c = true;
                }
                update rsList;
            }
            
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.ERROR, 'Error updating opportunity Ratesheets (in salesforce): Oppty Id: ' + oppId + ' exception: ' + ex.getMessage());
        }
        
        try
        {
            List<Deal_Summary__c> dsList = [select Id, Opportunity__c, Include_In_Quote__c 
                                            from Deal_Summary__c 
                                            where Opportunity__c = :oppId];
            
            //Update this opportunity's Deal Summaries to include in quota
            for (Deal_Summary__c ds :dsList){
                ds.Include_In_Quote__c = true;
            }
            update dsList;
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.ERROR, 'Error updating opportunity Dealsummaries (in salesforce): Oppty Id: ' + oppId + ' exception: ' + ex.getMessage());
        }
        
    }

}