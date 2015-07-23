public virtual without sharing class DealSummaryRateSheetUtil {

    public static Map<String, Integer> rateSheetToDealSummaryMap = new Map<String, Integer>();

    public static OpportunityDSAndRSVO SyncDealSummaryAndRateSheetForOpportunity (String opportunityId) {

        OpportunityDSAndRSVO result = new OpportunityDSAndRSVO();

        try {
            system.debug(LoggingLevel.INFO, '+++++++++++++++++++ Passed In opportunityId:' + opportunityId);
            system.debug(LoggingLevel.INFO, '+++++++++++++++++++ user id:' + UserInfo.getUserId());
            system.debug(LoggingLevel.INFO, '+++++++++++++++++++ user profile:' + UserInfo.getProfileId());
            system.debug(LoggingLevel.INFO, '+++++++++++++++++++ user name:' + UserInfo.getName());

            // Instantiate controls from salesforce
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
                                        where o.id = :opportunityId];

            List<OpportunityLineItem> opptyLineItemResult = [Select o.ID, o.Product_Detail__c, o.Product_Line__c, o.Quantity, o.TotalPrice, o.Transaction_Type__c, o.Unit_Number__c, o.OpportunityId, o.Automatic_Renewed__c
                                        From OpportunityLineItem o
                                        where o.OpportunityId = :opportunityId];

            List<Deal_Summary__c> dealSummaryIncInQuoteResult = [Select d.ID, d.No_of_Vehicles__c, d.EVA__c, d.ext_dealsummary_id__c, d.Gross_Revenue__c, d.Include_in_EVA__c, d.Include_In_Quote__c, d.Opportunity__c, d.Status__c
                                        From Deal_Summary__c d
                                        where d.Opportunity__c = :opportunityId]; // and d.Include_In_Quote__c = true

            List<Rate_Sheet__c> rateSheetIncInQuoteResult = [Select r.ID, r.No_of_Vehicles__c, r.Branch_No__c, r.Deal_Summary__c, r.EVA__c, r.ext_ratesheet_id__c, r.FuelType__c, r.Gross_Revenue__c, r.Include_in_EVA__c, r.Include_In_Quote__c, r.Old_Revenue__c, r.Opportunity__c, r.Package_Type__c, r.Product_Line__c, r.Rate_Sheet_Name__c, r.Transaction_Type__c
                                        From Rate_Sheet__c r
                                        where r.Opportunity__c = :opportunityId]; // and r.Include_In_Quote__c = true

            List<Opportunity_Split__c> opptySplitResult = [Select os.ID, os.ext_pipeline_id__c, os.Migration_Counter__c, os.OC_Amount__c, os.OC_Count__c, os.Opportunity__c, os.Pipeline_Amount__c, os.Pipeline_Split_Amount__c, os.Sales_Team_Member__c, os.SH_Amount__c, os.SH_Count__c, os.Split_Percentage__c, os.User_Type__c, os.WSO_Amount__c,  os.WSO_Count__c, os.CurrencyIsoCode, os.Name
                                        From Opportunity_Split__c os
                                        Where os.Opportunity__c = :opportunityId];
            //check if value is null
            for(Opportunity_Split__c os : opptySplitResult){
                if(os.Pipeline_Amount__c == null)
                    os.Pipeline_Amount__c = 0;
            }


            // Declare salesforce lists
            List<Deal_Summary__c> dealSummaryList = new List<Deal_Summary__c>();
            List<Rate_Sheet__c> rateSheetList = new List<Rate_Sheet__c>();
            List<Pipeline_Detail__c> pipelineDetailList = new List<Pipeline_Detail__c>();
            List<Opportunity_Split__c> opportunitySplitListCUSTOM = new List<Opportunity_Split__c>();
            //List<OpportunitySplit> opportunitySplitList = new List<OpportunitySplit>();
            List<OpportunityLineItem> opportunityLineItemList = new List<OpportunityLineItem>();

            // Call webservice and get collection
            List<GetOpportunityLocal.DCOpportunityLocalCollection> opportunityLocalCollection = getOpportunityLocal(opportunityId, opptyResult, opptyLineItemResult, dealSummaryIncInQuoteResult, rateSheetIncInQuoteResult, opptySplitResult);

            System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa Collection returned from ws ');

            if (opportunityLocalCollection != null && opportunityLocalCollection.size() > 0){
                // Declare collection lists
                List<GetOpportunityLocal.DCDealSummary> dsList = new List<GetOpportunityLocal.DCDealSummary>();
                System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa dsList' + dsList);
                List<GetOpportunityLocal.DCRateSheet> rsList = new List<GetOpportunityLocal.DCRateSheet>();
                System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa rsList' + rsList);
                List<GetOpportunityLocal.DCPipelineDetail> pdList = new List<GetOpportunityLocal.DCPipelineDetail>();
                System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa pdList' + pdList);
                List<GetOpportunityLocal.DCOpportunitySplit> osList = new List<GetOpportunityLocal.DCOpportunitySplit>();
                System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa osList' + osList);
                List<GetOpportunityLocal.DCOpportunityProductLineItem> oliList = new List<GetOpportunityLocal.DCOpportunityProductLineItem>();
                System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa oliList' + oliList);
                // Go through the collection
                for (GetOpportunityLocal.DCOpportunityLocalCollection collection : opportunityLocalCollection)
                {
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa Start collection seperation');

                    dsList = collection.DealSummary.DCDealSummary;
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa dsList' + dsList);

                    rsList = collection.RateSheet.DCRateSheet;
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa rsList' + rsList);

                    pdList = collection.PipelineDetail.DCPipelineDetail;
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa pdList' + pdList);

                    osList = collection.OpportunitySplit.DCOpportunitySplit;
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa osList' + osList);

                    oliList = collection.OpportunityProductLineItem.DCOpportunityProductLineItem;
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa oliList' + oliList);
                }

                System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa Start parsing');
                //parse lists:
                if(dsList != null){
                    dealSummaryList = parseDealSummaryResponse(dsList);
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa dealSummaryList returned' + dealSummaryList);
                }
                if(rsList != null){
                    rateSheetList = parseRateSheetResponse(rsList);
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa rateSheetList returned' + rateSheetList);
                }
                if(osList != null){
                    opportunitySplitListCUSTOM = parseOpportunitySplitCUSTOMResponse(osList);
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa opportunitySplitListCUSTOM returned' + opportunitySplitListCUSTOM);
                }
                //opportunitySplitList = parseOpportunitySplitResponse(osList);
                //System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa opportunitySplitList returned' + opportunitySplitList);

                /* --- Commented out Temporarily --- */
                /* -- BEGIN -- Uncomment when Oppty Splits are being automatically populated again - */
                /* Opportunity Split CUSTOM
                // Delete the existing CUSTOM Opportunity Split
                List<Opportunity_Split__c> oldopportunitySplitListCUSTOM = [Select r.Id From Opportunity_Split__c r where r.Opportunity__c =: opportunityId];
                if (oldopportunitySplitListCUSTOM != null && oldopportunitySplitListCUSTOM.size() > 0) {

                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaaa before deleting os oldOS CUSTOM ' + oldopportunitySplitListCUSTOM);
                    delete oldopportunitySplitListCUSTOM;
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaaa after deleting os oldOS CUSTOM ' + oldopportunitySplitListCUSTOM);
                }
                // Insert the new Opportunity Split
                if (opportunitySplitListCUSTOM != null && opportunitySplitListCUSTOM.size() > 0)
                {
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaaa before inserting os CUSTOM ' + opportunitySplitListCUSTOM);
                    insert opportunitySplitListCUSTOM;
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaaa after inserting os CUSTOM ' + opportunitySplitListCUSTOM);
                    result.opportunitySplitsListCUSTOM = opportunitySplitListCUSTOM;
                }
                */
                /* -- END -------------------- */
                
				/* --- Commented out Temporarily --- */
                /* -- BEGIN -- Uncomment when the IsDeleted bug issue is resolved - */
                /* Pipeline Detail
                System.debug(LoggingLevel.INFO, 'aaaaaaaaaaaa starting pipelineDetailList ');
                if(pdList != null){
                    pipelineDetailList = parsePipelineDetailResponse(pdList);
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaaa check to delete pipelineDetailList ');
                }
                
                // Delete the existing Pipeline Detail
                List<Pipeline_Detail__c> oldPipelineDetailList = [Select r.Id From Pipeline_Detail__c r where r.Opportunity__c =: opportunityId];
                if (oldPipelineDetailList != null && oldPipelineDetailList.size() > 0) {
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaaa before deleting pd oldPD ' + oldPipelineDetailList);
                    delete oldPipelineDetailList;
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaaa after deleting pd oldPD ' + oldPipelineDetailList);
                }
                // Insert the new Pipeline Detail
                if (pipelineDetailList != null && pipelineDetailList.size() > 0)
                {
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaaa before inserting pd ' + pipelineDetailList);
                    insert pipelineDetailList;
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaaa after inserting pd ' + pipelineDetailList);
                    result.pipelineDetailsList = pipelineDetailList;
                }
				*/
				/* -- END -------------------- */

            }


            //Get map of existing dealsummary by external id and includeInquote flag
            Map<Decimal, boolean> dealSummaryExtIdToIncludeInQuoteFlagMap = getDealSummaryExtIdToIncludeInQuoteFlagMap(opportunityId);
            //Get latest deal summary by calling web serivce
            //List<Deal_Summary__c> dealSummaryList = getDealSummaryListFromRyder(opportunityId); // commented out by Albert Miranda
            //Merge Include In quote flag for deal summaries
            if (dealSummaryList != null && dealSummaryList.size() > 0) {
                for (Deal_Summary__c dealSummary: dealSummaryList) {
                    dealSummary.Opportunity__c = opportunityId;
                    if (dealSummaryExtIdToIncludeInQuoteFlagMap.get(dealSummary.ext_dealsummary_id__c) != null) {
                        dealSummary.Include_In_Quote__c = true;
                    }
                }
            }

            //Get map of existing rate sheet by external id and includeInquote flag
            Map<Decimal, boolean> rateSheetExtIdToIncludeInQuoteFlagMap = getRateSheetExtIdToIncludeInQuoteFlagMap(opportunityId);
            //Get latest rate sheet by calling web serivce
            //List<Rate_Sheet__c> rateSheetList = getRateSheetListFromRyder(opportunityId); // commented out by Albert Miranda
            //Merge Include In quote flag for deal summaries
            if (rateSheetList != null && rateSheetList.size() > 0) {
            for (Rate_Sheet__c rateSheet: rateSheetList) {
                rateSheet.Opportunity__c = opportunityId;
                if (rateSheetExtIdToIncludeInQuoteFlagMap.get(rateSheet.ext_ratesheet_id__c) != null) {
                    rateSheet.Include_In_Quote__c = true;
                }
                System.debug(LoggingLevel.INFO, '+++++++++++++++ rateSheet: ' + rateSheet.Deal_Summary__c);
            }
            }
            //delete the existing dealSummaryList
            List<Deal_Summary__c> oldDealSummaryList = [Select d.Id From Deal_Summary__c d where d.Opportunity__c =: opportunityId];

            System.debug(LoggingLevel.INFO, 'ffffffffffffffff oldDealSummaryList' + oldDealSummaryList);

            if (oldDealSummaryList != null && oldDealSummaryList.size() > 0) {

                System.debug(LoggingLevel.INFO, 'ffffffffffffffff before deleting oldDealSummaryList');
                delete oldDealSummaryList;
                System.debug(LoggingLevel.INFO, 'ffffffffffffffff after deleting ');
            }

            if (dealSummaryList != null && dealSummaryList.size() > 0) {
                for (Deal_Summary__c currDS: dealSummaryList) {
                    List<Deal_Summary__c> ds2 = [Select r.Id From Deal_Summary__c r where r.ext_dealsummary_id__c =: currDS.ext_dealsummary_id__c and r.Opportunity__c !=: opportunityId ] ;
                    if (ds2 != null && ds2.size() > 0)
                    {
                        //Delete if any
                        System.debug(LoggingLevel.INFO, 'ffffffffffffffff deleting ds 2 ' + ds2);
                        delete ds2;
                    }
                }
            }

            if (dealSummaryList != null && dealSummaryList.size() > 0) {
                //insert the new deal summaries

                System.debug(LoggingLevel.INFO, 'ffffffffffffffff before inserting ds' + dealSummaryList);
                insert dealSummaryList;
                System.debug(LoggingLevel.INFO, 'ffffffffffffffff after inserting ds' + dealSummaryList);
                result.dealSummariesList = dealSummaryList;
            }
            List<Integer> dealSummaryExtIdList = new List<Integer>();
            dealSummaryExtIdList = rateSheetToDealSummaryMap.values();

            // Traverse through the objects to get map of external id to SF Id
            Map<String, Id> dealSummaryExtIdToSFIdMap = new Map<String, Id>();
            List<Deal_Summary__c> newDealSummaryList = [Select d.opportunity__r.account.CustProspectID__c, d.ext_dealsummary_id__c, d.Id From Deal_Summary__c d where d.ext_dealsummary_id__c in: dealSummaryExtIdList];
            if (newDealSummaryList != null) {
                for(Deal_Summary__c ds :newDealSummaryList) {
                    dealSummaryExtIdToSFIdMap.put(String.valueOf(ds.ext_dealsummary_id__c), ds.Id);
                }
            }
            System.debug(LoggingLevel.INFO, '++++++++++++++ dealSummaryExtIdToSFIdMap: ' + dealSummaryExtIdToSFIdMap);
            System.debug(LoggingLevel.INFO, '++++++++++++++ rateSheetToDealSummaryMap: ' + rateSheetToDealSummaryMap);

            if (rateSheetList != null && rateSheetList.size() > 0) {
                for (Rate_Sheet__c rs: rateSheetList) {
                    rs.Deal_Summary__c = dealSummaryExtIdToSFIdMap.get(String.valueOf(rateSheetToDealSummaryMap.get(String.valueOf(rs.ext_ratesheet_id__c))));
                    System.debug(LoggingLevel.INFO, '++++++++++++++ rs.Deal_Summary__c: ' + rs.Deal_Summary__c);
                }
            }

            //delete the existing oldRateSheetList
            List<Rate_Sheet__c> oldRateSheetList = [Select r.Id From Rate_Sheet__c r where r.Opportunity__c =: opportunityId];
            if (oldRateSheetList != null && oldRateSheetList.size() > 0) {

                System.debug(LoggingLevel.INFO, 'ffffffffffffffff before deleting rs oldRS ' + oldRateSheetList);
                delete oldRateSheetList;
                System.debug(LoggingLevel.INFO, 'ffffffffffffffff after deleting rs oldRS ' + oldRateSheetList);
            }

            ////Exist for other oppty?
            if (rateSheetList != null && rateSheetList.size() > 0) {
                //get the IDs
                List<Decimal>deletedRS= new List<Decimal>();
                For (Rate_Sheet__c currRateSheet: rateSheetList) {
                    deletedRS.add(currRateSheet.ext_ratesheet_id__c);
                }

                //Delete if any
                if (deletedRS != null && deletedRS.size() > 0) {
                    System.debug(LoggingLevel.INFO, 'ffffffffffffffff before deleting rs ' + deletedRS);

                    List<Rate_Sheet__c> otherOpptyRateSheetList = [Select r.Id From Rate_Sheet__c r where r.Opportunity__c !=: opportunityId and ext_ratesheet_id__c in :deletedRS];
                    if (otherOpptyRateSheetList != null && otherOpptyRateSheetList.size() > 0) {
                        System.debug(LoggingLevel.INFO, 'ffffffffffffffff before deleting rs ' + otherOpptyRateSheetList);
                        delete otherOpptyRateSheetList;
                        System.debug(LoggingLevel.INFO, 'ffffffffffffffff after deleting rs ' + otherOpptyRateSheetList);
                    }
                }
            }

            if (rateSheetList != null && rateSheetList.size() > 0)
            {
                //insert the new rate sheet
                System.debug(LoggingLevel.INFO, 'ffffffffffffffff before inserting rs ' + rateSheetList);
                insert rateSheetList;
                System.debug(LoggingLevel.INFO, 'ffffffffffffffff after inserting rs ' + rateSheetList);
            }
            result.rateSheetsList = rateSheetList;

        } catch(Exception ex) {
            system.debug(LoggingLevel.ERROR, 'aaaaaaaaaaaaaaaaaa Message: ' + ex.getMessage());
            system.debug(LoggingLevel.ERROR, 'aaaaaaaaaaaaaaaaaa Cause: ' + ex.getCause());
            system.debug(LoggingLevel.ERROR, 'aaaaaaaaaaaaaaaaaa Line number: ' + ex.getLineNumber());
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'Error while Synchronizing Deal Summary and Rate Sheet Information with RADAR System.' + ex);
            ApexPages.addmessage(errorMsg);
        }
        return result;
    }


    /*
    * Create map of existing deal summary external id where include in quote flag is true
    */
    private static Map<Decimal, boolean> getDealSummaryExtIdToIncludeInQuoteFlagMap(String opportunityId) {
        Map<Decimal, boolean> result = new Map<Decimal, boolean>();
        List<Deal_Summary__c> dealSummaryList = [Select d.opportunity__r.account.CustProspectID__c, d.ext_dealsummary_id__c, d.Id From Deal_Summary__c d where d.Opportunity__c =: opportunityId and d.Include_In_Quote__c = true ];
        for (Deal_Summary__c dealSummary: dealSummaryList) {
            result.put(dealSummary.ext_dealsummary_id__c, true);
        }
        return result;
    }


    /*
    * Create map of existing rate sheet external id where include in quote flag is true
    */
    private static Map<Decimal, boolean> getRateSheetExtIdToIncludeInQuoteFlagMap(String opportunityId) {
        Map<Decimal, boolean> result = new Map<Decimal, boolean>();
        List<Rate_Sheet__c> rateSheetList = [Select r.ext_ratesheet_id__c, r.Id From Rate_Sheet__c r where r.Opportunity__c =: opportunityId and r.Include_In_Quote__c = true ];
        for (Rate_Sheet__c rs: rateSheetList) {
            result.put(rs.ext_ratesheet_id__c, true);
        }
        return result;
    }

    /*
    *   update Opportunity total when Deal summary is being updated
    */
    public static void UpdateOpportunityTotalsForDealSummary(Map<Id, Deal_Summary__c> dealSummaryMap) {
        List<Id> opportunityIds = new List<Id>();
        // create opportunityIds list
        Set<Id> dealSummaryIds = dealSummaryMap.keySet();
        for (Id dealSummaryId: dealSummaryIds) {
            Deal_Summary__c ds = dealSummaryMap.get(dealSummaryId);
            opportunityIds.add(ds.Opportunity__c);
        }
        OpportunityUtil.UpdateOpportunityTotals(opportunityIds);
    }

    /*
    *   update Opportunity total when Rate Sheet is being updated
    */
    public static void UpdateOpportunityTotalsForRateSheet(Map<Id, Rate_Sheet__c> rateSheetMap) {
        List<Id> opportunityIds = new List<Id>();
        // create opportunityIds list
        Set<Id> rateSheetIds = rateSheetMap.keySet();
        for (Id rateSheetId: rateSheetIds) {
            Rate_Sheet__c rs = rateSheetMap.get(rateSheetId);
            opportunityIds.add(rs.Opportunity__c);
        }
        OpportunityUtil.UpdateOpportunityTotals(opportunityIds);
    }

    /*
    *   update Opportunity total when Deal summary is being updated
    */
    public static void UpdateOpportunityTotalsForOpportunityLineItems(Map<Id, OpportunityLineItem> OppLineItemSummaryMap) {
        List<Id> opportunityIds = new List<Id>();
        // create opportunityIds list
        Set<Id> OppLineItemIds = OppLineItemSummaryMap.keySet();
        for (Id OppLineItemId: OppLineItemIds) {
        	  OpportunityLineItem oli = OppLineItemSummaryMap.get(OppLineItemId);
              opportunityIds.add(oli.opportunityid);
        }

        /*// sunil; 9-18-3014; below condition added to avoid the UVS opportunities.
        // exclude UVS Opportunities from above list.
        Set<Id> nonUVSOppIds = new Set<Id>();
        Id uvsRecordTypeId = UVS_Util.UVSRecordType_Opp;
        for(Opportunity opp :[SELECT Id FROM Opportunity WHERE RecordTypeId = :nonUVSOppIds AND Id IN :opportunityIds]){
        	for(Id oppId :opportunityIds){
        	  nonUVSOppIds.add(opp.Id);
        	}
        }
        opportunityIds.clear();
        opportunityIds.addAll(nonUVSOppIds);*/

        // end

        OpportunityUtil.UpdateOpportunityTotals(opportunityIds);
    }

    public static List<GetOpportunityLocal.DCOpportunityLocalCollection> getOpportunityLocal(String opportunityId, Opportunity opptyResult, List<OpportunityLineItem> opptyLineItemResult, List<Deal_Summary__c> dealSummaryIncInQuoteResult, List<Rate_Sheet__c> rateSheetIncInQuoteResult, List<Opportunity_Split__c> opptySplitResult) {

        system.debug(LoggingLevel.INFO, 'aaaaaaaaaaaaaaaaaa opptyResult:' + opptyResult);

        // Create criteria
        GetOpportunityLocal.OpportunityLocalCollectionRequestCriteria requestCriteria = new GetOpportunityLocal.OpportunityLocalCollectionRequestCriteria();
        requestCriteria.Id= opportunityId;
        requestCriteria.SearchByOpportunityId = true;

        requestCriteria.Name = opptyResult.Name;
        requestCriteria.Account_Classification_xc = opptyResult.Account_Classification__c;
        requestCriteria.AccountId = opptyResult.AccountId;
        requestCriteria.Actual_Close_Date_xc = opptyResult.Actual_Close_Date__c != null ? opptyResult.Actual_Close_Date__c : datetime.now();
        requestCriteria.CloseDate = opptyResult.CloseDate;
        requestCriteria.CurrencyIsoCode = opptyResult.CurrencyIsoCode;
        requestCriteria.Description = opptyResult.Description != null ? opptyResult.Description : ''; //opptyResult.Description;
        requestCriteria.EST_DEAL_VAL_xc = opptyResult.EST_DEAL_VAL__c != null ? opptyResult.EST_DEAL_VAL__c : 0;
        requestCriteria.Estimated_Proposal_Date_xc = opptyResult.Estimated_Proposal_Date__c != null ? opptyResult.Estimated_Proposal_Date__c : datetime.now();
        requestCriteria.EVA_xc = opptyResult.EVA__c != null ? opptyResult.EVA__c : 0;
        requestCriteria.EVA_VEH_xc = opptyResult.EVA_VEH__c != null ? opptyResult.EVA_VEH__c : '0';
        requestCriteria.ext_pipeline_id_xc = opptyResult.ext_pipeline_id__c != null ? opptyResult.ext_pipeline_id__c : '0';
        requestCriteria.Fiscal = opptyResult.Fiscal;
        requestCriteria.FiscalQuarter = opptyResult.FiscalQuarter;
        requestCriteria.FiscalYear = opptyResult.FiscalYear;
        requestCriteria.ForecastCategory = opptyResult.ForecastCategory;
        requestCriteria.ForecastCategoryName = opptyResult.ForecastCategoryName;
        requestCriteria.HasAccount_xc = opptyResult.HasAccount__c;
        requestCriteria.HasOpportunityLineItem = opptyResult.HasOpportunityLineItem;
        requestCriteria.IsClosed = opptyResult.IsClosed;
        requestCriteria.IsPrivate = opptyResult.IsPrivate;
        requestCriteria.IsWon = opptyResult.IsWon;
        requestCriteria.LastActivityDate = opptyResult.LastActivityDate != null ? opptyResult.LastActivityDate : datetime.now();
        requestCriteria.Num_of_vehicles_xc = Integer.valueOf(opptyResult.Num_of_vehicles__c) != null ? Integer.valueOf(opptyResult.Num_of_vehicles__c) : 0;
        requestCriteria.OwnerId = opptyResult.OwnerId;
        requestCriteria.Pricebook2Id = opptyResult.Pricebook2Id;
        requestCriteria.Probability = opptyResult.Probability;
        requestCriteria.Reason_Won_Lost_xc = opptyResult.Reason_Won_Lost__c != null ? opptyResult.Reason_Won_Lost__c : '';
        requestCriteria.RecordTypeId = opptyResult.RecordTypeId;
        requestCriteria.SPLIT_VALUE_xc = opptyResult.SPLIT_VALUE__c;
        requestCriteria.StageName = opptyResult.StageName;
        requestCriteria.LastModifiedById = opptyResult.LastModifiedById;
        requestCriteria.LastModifiedDate = opptyResult.LastModifiedDate != null ? opptyResult.LastModifiedDate : datetime.now();
        requestCriteria.CreatedById = opptyResult.CreatedById;
        requestCriteria.CreatedDate = opptyResult.CreatedDate != null ? opptyResult.CreatedDate : datetime.now();
        requestCriteria.Old_Revenue_xc = opptyResult.Old_Revenue__c != null ? opptyResult.Old_Revenue__c : 0;
        requestCriteria.Total_EVA_xc = opptyResult.Total_EVA__c != null ? opptyResult.Total_EVA__c : 0;
        requestCriteria.Included_in_Monthly_Forecast_xc = opptyResult.Included_in_Monthly_Forecast__c;
        requestCriteria.Included_in_Quarterly_Forecast_xc = opptyResult.Included_in_Quarterly_Forecast__c;
        requestCriteria.Automatic_Renewed_xc = opptyResult.Automatic_Renewed__c;

        try
        {
            String opptyLineItemJSON = JSON.serialize(opptyLineItemResult);
            requestCriteria.OpportunityProductLineItemJson = opptyLineItemJSON;
            System.debug('Serialized list 1: ' + opptyLineItemJSON);

            String dealSummaryIncInQuoteJSON = JSON.serialize(dealSummaryIncInQuoteResult);
            requestCriteria.DealSummaryIncludeInQuoteJson = dealSummaryIncInQuoteJSON;
            System.debug('Serialized list 2: ' + dealSummaryIncInQuoteJSON);

            String rateSheetIncInQuoteJSON = JSON.serialize(rateSheetIncInQuoteResult);
            requestCriteria.RateSheetIncludeInQuoteJson = rateSheetIncInQuoteJSON;
            System.debug('Serialized list 3: ' + rateSheetIncInQuoteJSON);

            String opptySplitJSON = JSON.serialize(opptySplitResult);
            requestCriteria.OpportunitySplitJson = opptySplitJSON;
            System.debug('Serialized list 4: ' + opptySplitJSON);
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.ERROR, 'aaaaaaaaaaaaaaaaaa JSON Results Message: ' + ex.getMessage());
            system.debug(LoggingLevel.ERROR, 'aaaaaaaaaaaaaaaaaa JSON Results Exception: ' + ex.getStackTraceString());
            throw ex;
        }

        // Create soap request
        GetOpportunityLocal.GetOpportunityLocalSoap opportunityLocalSoap = new GetOpportunityLocal.GetOpportunityLocalSoap();
        GetOpportunityLocal.CRMCredential credential = new GetOpportunityLocal.CRMCredential();
        credential.UserName = '';
        credential.Password = '';
        credential.SecurityToken = '';
        opportunityLocalSoap.timeout_x = RyderGlobalVariables.WS_TIMEOUT;
        opportunityLocalSoap.endpoint_x = RyderGlobalVariables.RYDER_WS_ENDPOINT + RyderGlobalVariables.GET_OPPORTUNITY_LOCAL;

        // Declare opportunity collection
        List<GetOpportunityLocal.DCOpportunityLocalCollection> lOpportunityLocalCollections = null;

        try
        {
            // Make a soap request
            system.debug(LoggingLevel.INFO, 'aaaaaaaaaaaaaaaaaa requestCriteria:' + requestCriteria);

            GetOpportunityLocal.DCOpportunityLocalCollections opportunityLocal = new GetOpportunityLocal.DCOpportunityLocalCollections();
            if(!Test.isRunningTest())
            {
            	opportunityLocal = opportunityLocalSoap.ProcessRequest(credential, requestCriteria);
            	system.debug(LoggingLevel.INFO, 'aaaaaaaaaaaaaaaaaa opportunityLocal:' + opportunityLocal);
            }
            else
            {
            	opportunityLocal = null;
            }
            if (opportunityLocal != null)
            {
                // Fill collection
                lOpportunityLocalCollections = opportunityLocal.OpportunityLocalCollections.DCOpportunityLocalCollection;
            }
            return lOpportunityLocalCollections;
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.ERROR, 'Error making Soap request for GetOpportunityLocal exception: ' + ex.getMessage());
            throw ex;
        }

    }

    /*
        Parse Deal summary Response.
    */
    public static List<Deal_Summary__c> parseDealSummaryResponse(List<GetOpportunityLocal.DCDealSummary> dsList) {
        List<Deal_Summary__c> result = new List<Deal_Summary__c>();
        // Go through the company info and set the account information to display
        for (GetOpportunityLocal.DCDealSummary ds : dsList)
        {
            Deal_Summary__c dealSummarySF = new Deal_Summary__c();
            dealSummarySF.Name = ds.DealSummaryName;
            dealSummarySF.EVA__c = ds.EVA;
            dealSummarySF.Gross_Revenue__c = ds.GrossRevenue;
            dealSummarySF.ext_dealsummary_id__c = ds.ID;
            dealSummarySF.No_of_Vehicles__c = ds.NumberOfvehicles;
            dealSummarySF.Status__c = ds.Status;
            result.add(dealSummarySF);
        }
        return result;
    }

    /*
        Parse Rate Sheet Response.
    */
    public static List<Rate_Sheet__c> parseRateSheetResponse(List<GetOpportunityLocal.DCRateSheet> rateSheetList) {

        List<Rate_Sheet__c> result = new List<Rate_Sheet__c>();

        for (GetOpportunityLocal.DCRateSheet rs : rateSheetList)
        {
            Rate_Sheet__c rateSheetSF = new Rate_Sheet__c();
            Ryder_Branch__c branch= new Ryder_Branch__c();
            branch.Branch_Code__c=rs.BranchNo;
            rateSheetSF.EVA__c = rs.EVA;
            rateSheetSF.Gross_Revenue__c = rs.GrossRevenue;
            rateSheetSF.ext_ratesheet_id__c = rs.ID;
            rateSheetSF.No_of_Vehicles__c = rs.NumberOfvehicles;
            rateSheetSF.Package_Type__c = rs.PakageType;
            rateSheetSF.Transaction_Type__c=rs.TransactionType;
            rateSheetSF.Product_Line__c = rs.ProductLine;
            rateSheetSF.Rate_Sheet_Name__c = rs.RateSheetName;
            rateSheetSF.Include_in_EVA__c = rs.IsEVA;
            rateSheetSF.FuelType__c = rs.FuelType;
            rateSheetSF.Original_Create_Date__c = rs.OriginalCreateDate;
            rateSheetSF.Net_Investment__c = rs.NetInvestment;
            // neelima- added old revenue and branch code fields-08/04/2011
            rateSheetSF.Old_Revenue__c=rs.OldRevenue;
             if(branch.Branch_Code__c!=null) rateSheetSF.Branch_No__r= branch;
            rateSheetSF.Name=String.valueOf(rs.ID);

            if (rs.DealSummaryId != null) {
                rateSheetToDealSummaryMap.put(String.valueOf(rs.ID), Integer.valueOf(rs.DealSummaryId));
            }
            result.add(rateSheetSF);
        }
        return result;
    }

    /*
        Parse Pipeline Detail Response.
    */
    public static List<Pipeline_Detail__c> parsePipelineDetailResponse(List<GetOpportunityLocal.DCPipelineDetail> pipelineDetailList) {

        List<Pipeline_Detail__c> result = new List<Pipeline_Detail__c>();

        for (GetOpportunityLocal.DCPipelineDetail pd : pipelineDetailList)
        {
            Pipeline_Detail__c pipelineDetailSF = new Pipeline_Detail__c();
            pipelineDetailSF.Name = pd.Name;
            pipelineDetailSF.Product_Line__c = pd.ProductLine;
            pipelineDetailSF.Product_Line_number__c = pd.ProductLineNumber;
            pipelineDetailSF.Transaction_Type__c = pd.TransactionType;
            pipelineDetailSF.Number_of_Vehicles__c = pd.NumberOfvehicles;
            pipelineDetailSF.EVA__c = pd.EVA;
            pipelineDetailSF.Opportunity__c = pd.OpportunityId;
            pipelineDetailSF.User__c = pd.UserId;
            pipelineDetailSF.Split_Amount__c = pd.SplitAmount;
            pipelineDetailSF.Split_percentage__c = pd.SplitPercentage;
            pipelineDetailSF.extref_Pipeline_Detail_Id__c = pd.ExtrefPipelineDetailId;
            pipelineDetailSF.Total_Amount__c = pd.TotalAmount;
            pipelineDetailSF.Total_Vehicle__c = pd.TotalVehicle;
            pipelineDetailSF.Group_Key_WO_Splits__c = pd.GroupingKeyWOSplits;
            pipelineDetailSF.Report_On_User__c = pd.ReportOnUser;
            pipelineDetailSF.Product_Detail__c = pd.ProductDetail;
            pipelineDetailSF.Report_Amount__c = pd.ReportAmount;

            Date newCloseDate = Date.newInstance(pd.CloseDate.year(),pd.CloseDate.month(),pd.CloseDate.day());
            pipelineDetailSF.Close_Date__c = newCloseDate;


            result.add(pipelineDetailSF);
        }
        return result;
    }

    /*
        Parse "CUSTOM" Opportunity Split Response.
    */
    public static List<Opportunity_Split__c> parseOpportunitySplitCUSTOMResponse(List<GetOpportunityLocal.DCOpportunitySplit> opportunitySplitList) {

        List<Opportunity_Split__c> result = new List<Opportunity_Split__c>();

        for (GetOpportunityLocal.DCOpportunitySplit os : opportunitySplitList)
        {
            Opportunity_Split__c opportunitySplitSF = new Opportunity_Split__c();
            //opportunitySplitSF.ext_pipeline_id__c = decimal.valueOf(os.ExtPipelineId);
            //opportunitySplitSF.Migration_Counter__c = os.MigrationCounter;
            //opportunitySplitSF.Name = os.Name;
            opportunitySplitSF.Opportunity__c = os.OpportunityId;
            opportunitySplitSF.Pipeline_Amount__c = os.PipelineAmount;
            //opportunitySplitSF.Pipeline_Split_Amount__c = os.PipelineSplitAmount;
            opportunitySplitSF.Sales_Team_Member__c = os.SalesTeamMember;
            opportunitySplitSF.Split_Percentage__c = os.SplitPercentage;
            opportunitySplitSF.User_Type__c = os.UserType;

            result.add(opportunitySplitSF);
        }
        return result;
    }

}