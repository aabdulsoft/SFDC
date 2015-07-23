public without sharing class OpportunityUtil {
/*
String opptyId = '0066000000FsHwX';
// DealSummaryRateSheetUtil.SyncDealSummaryForOpportunity(opptyId);
//DealSummaryRateSheetUtil.SyncRateSheetForOpportunity(opptyId);
Id oppty = '0066000000FsHwX';
List<Id> opptyIds = new List<Id>();
opptyIds.add(oppty);
OpportunityUtil.updateOpportunityTotals(opptyIds);
*/
    /*
    *   This function calculates total for following fields of Opportunity
    *       EVA__c
    *       Gross_Revenue__c
            Num_of_vehicles__c
    *   Above fields are calculated as below:
        Sum of all Deal Summaries and Rate Sheets with "Include_In_Quote__c" flag is TRUE.
        If no Deal summaries and Rate Sheets have "Include_In_Quote__c" flag of TRUE then we revert above fields to corresponding following
        fields:
            original_EVA__c
            original_Gross_Revenue__c
            original_Num_of_Vehicles__c
    */
    public static void UpdateOpportunityTotals(List<Id> opportunityIds) {
        // Get map of opportunityId and DealSummaries
        // neelima- commented out the call for deal summaries as we are going to do all calculations from ratesheets going forward.
      //  Map<Id, RollupOpptyTotalsVO> opptyIdToDealSummaryListMap = getDealSummaryListForOpportunity(opportunityIds);
      
         Map<Id, RollupOpptyTotalsVO> opptyIdToRateSheetListMap = getRateSheetListForOpportunity(opportunityIds);
         Map<Id, RollupOpptyTotalsVO> opptyIdToLineItemsListMap = getOpportunityLineItemRollups(opportunityIds);
        
        List<Opportunity> opptyList = [Select o.Amount,o.Num_of_vehicles__c, o.Id, o.Gross_Revenue__c, o.EVA__c, o.EST_DEAL_VAL__c, o.Parent_Opportunity__c, o.recordTypeId, o.stagename,Total_EVA__c,Old_Revenue__c,EVA_VEH__c,NVI_Total__c From Opportunity o where o.id in: opportunityIds];
        boolean resetToOrg = true;
        boolean addRSTotal = false;
        
        Opportunity oldOppty = new Opportunity();
        boolean updateOppty = false;
        
        for(Opportunity oppty: opptyList) {
            if (oppty.stagename != 'Booked'){
                
                //ffffff                
                oldOppty.Num_of_vehicles__c = oppty.Num_of_vehicles__c;
                oldOppty.EST_DEAL_VAL__c = oppty.EST_DEAL_VAL__c;
                oldOppty.EVA__c = oppty.EVA__c;
                oldOppty.Total_EVA__c=oppty.Total_EVA__c;
                oldOppty.Old_Revenue__c=oppty.Old_Revenue__c;
                oldOppty.EVA_VEH__c=oppty.EVA_VEH__c;
                oldOppty.NVI_Total__c=oppty.NVI_Total__c; 
                System.debug(LoggingLevel.INFO, 'fffffffffffff Old Oppty:' + oldOppty);             
                
                oppty.EVA__c = 0;
                oppty.EST_DEAL_VAL__c = oppty.Amount;
              //  oppty.Num_of_vehicles__c = 0;
                oppty.Total_EVA__c=0;
                oppty.Old_Revenue__c=0;
               oppty.EVA_VEH__c=String.valueof(0);
               oppty.NVI_Total__c = 0;
              

                System.debug(LoggingLevel.INFO, '++++++++++++++ Before update of Oppty: ' + oppty);
              //  System.debug(LoggingLevel.INFO, '++++++++++++++ opptyIdToDealSummaryListMap: ' + opptyIdToDealSummaryListMap);
           // 08/15-- Logic to calculate totals from deal summaries is 
            /*
                if (opptyIdToDealSummaryListMap.containsKey(oppty.Id)) {
                    resetToOrg = false;
                    addRSTotal = true;
                    RollupOpptyTotalsVO tempRollupOpptyTotals = opptyIdToDealSummaryListMap.get(oppty.Id);
                    oppty.EVA__c = tempRollupOpptyTotals.eva;
                    oppty.EST_DEAL_VAL__c = tempRollupOpptyTotals.grossRevenue;
                    oppty.Num_of_vehicles__c = tempRollupOpptyTotals.numOfVehicles;
                    
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp Dealsummary : addRSTotal ' + addRSTotal);                    
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp Dealsummary : EVA__c ' + oppty.EVA__C);                    
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp Dealsummary : EST_DEAL_VAL__c ' + oppty.EST_DEAL_VAL__c);
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp Dealsummary : Num_of_vehicles__c ' + oppty.Num_of_vehicles__c);
                    
                    //Any Chages to Oppty
                    if (Double.valueOf(oldOppty.Num_of_vehicles__c) != Double.valueOf(oppty.Num_of_vehicles__c) || Double.valueOf(oldOppty.EST_DEAL_VAL__c) != Double.valueOf(oppty.EST_DEAL_VAL__c ) || Double.valueOf(oldOppty.EVA__c) != Double.valueOf(oppty.EVA__c))
                    {
                        updateOppty = true;                     
                    }
                }
                */
            
//                System.debug(LoggingLevel.INFO, '++++++++++++++ opptyIdToRateSheetListMap: ' + opptyIdToRateSheetListMap);
            
                if (opptyIdToRateSheetListMap.containsKey(oppty.Id)) {
                    System.debug(LoggingLevel.INFO, '++++++++++++++ found Rate sheets that are inclued');
                    resetToOrg = false;
                    RollupOpptyTotalsVO tempRollupOpptyTotals = opptyIdToRateSheetListMap.get(oppty.Id);
                  //  System.debug(LoggingLevel.INFO, '+++++++++++++ adding ratesheet totals: ' + tempRollupOpptyTotals);
                
                        System.debug(LoggingLevel.INFO, '++++++++++++++ Only Rate sheets that are inclued');
                        oppty.Total_EVA__c = tempRollupOpptyTotals.eva;
                        oppty.EST_DEAL_VAL__c = tempRollupOpptyTotals.grossRevenue;
                        oppty.Num_of_vehicles__c = tempRollupOpptyTotals.numOfVehicles;
                        oppty.Old_Revenue__c=tempRollupOpptyTotals.oldRevenue;
                        oppty.NVI_Total__c = tempRollupOpptyTotals.netInvestment;
                        System.debug(LoggingLevel.INFO, 'aaaaaaaaaaaaa NVI_Total__c 1: ' + oppty.NVI_Total__c);
                        if(tempRollupOpptyTotals.eva_veh!=0)
                        {
                        oppty.EVA_VEH__c= String.valueof(tempRollupOpptyTotals.eva_veh);
                        // calculate the average
                        oppty.EVA__c = tempRollupOpptyTotals.eva/tempRollupOpptyTotals.eva_veh;
                        }
                        else 
                        {
                        oppty.EVA__c=0;
                        oppty.EVA_VEH__c='0';
                        }
                        
                // 08/15/2011-- neelima- commented out the logic to check if the deal summary totals exist as all the 
               // calculations will be done at ratesheet level. also added old reveue to the opportunity totals.
                  /* 
                    if (addRSTotal) {
                        System.debug(LoggingLevel.INFO, '++++++++++++++ Adding Rate sheets that are included');
                        oppty.EVA__c += tempRollupOpptyTotals.eva;
                        oppty.EST_DEAL_VAL__c += tempRollupOpptyTotals.grossRevenue;
                        oppty.Num_of_vehicles__c += tempRollupOpptyTotals.numOfVehicles;
                        addRSTotal = false;
                    } else {
                        System.debug(LoggingLevel.INFO, '++++++++++++++ Only Rate sheets that are inclued');
                        oppty.EVA__c = tempRollupOpptyTotals.eva;
                        oppty.EST_DEAL_VAL__c = tempRollupOpptyTotals.grossRevenue;
                        oppty.Num_of_vehicles__c = tempRollupOpptyTotals.numOfVehicles;
                    }
                    */
                    
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp RateSheet : addRSTotal ' + addRSTotal);                    
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp RateSheet : EVA__c ' + oppty.EVA__c);                    
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp RateSheet : EST_DEAL_VAL__c ' + oppty.EST_DEAL_VAL__c);
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp RateSheet : Num_of_vehicles__c ' + oppty.Num_of_vehicles__c);
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp RateSheet : oldRevenue ' + oppty.Old_Revenue__c);                   
                    
                    //Any Chages to Oppty
                    /*
                    if (Double.valueOf(oldOppty.Num_of_vehicles__c) != Double.valueOf(oppty.Num_of_vehicles__c) || Double.valueOf(oldOppty.EST_DEAL_VAL__c) != Double.valueOf(oppty.EST_DEAL_VAL__c ) || Double.valueOf(oldOppty.EVA__c) != Double.valueOf(oppty.EVA__c)|| Double.valueOf(oldOppty.Old_Revenue__c) != Double.valueOf(oppty.Old_Revenue__c)|| Double.valueOf(oldOppty.EVA_VEH__c) != Double.valueOf(oppty.EVA_VEH__c))
                    {
                        updateOppty = true;                     
                    }*/
                }
              
                  // 08/25/2011- updated by Neelima
              //  if ( !opptyIdToDealSummaryListMap.containsKey(oppty.Id) && !opptyIdToRateSheetListMap.containsKey(oppty.Id) && opptyIdToLineItemsListMap.containsKey(oppty.Id) ){
              if (!opptyIdToRateSheetListMap.containsKey(oppty.Id) && opptyIdToLineItemsListMap.containsKey(oppty.Id)){
                    RollupOpptyTotalsVO tempRollupOpptyTotals = opptyIdToLineItemsListMap.get(oppty.Id);
                    oppty.EVA__c = null;
                    oppty.EST_DEAL_VAL__c = tempRollupOpptyTotals.grossRevenue;
                    
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp LineItems Before : oldOppty.Num_of_vehicles__c: ' + Double.valueOf(oldOppty.Num_of_vehicles__c));
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp LineItems Before : oppty.Num_of_vehicles__c: ' + Double.valueOf(oppty.Num_of_vehicles__c));
                    
                    oppty.Num_of_vehicles__c = tempRollupOpptyTotals.numOfVehicles;
                    
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp LineItems After : oldOppty.Num_of_vehicles__c: ' + Double.valueOf(oldOppty.Num_of_vehicles__c));
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp LineItems After : oppty.Num_of_vehicles__c: ' + Double.valueOf(oppty.Num_of_vehicles__c));
                    
                    
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp LineItems : addRSTotal ' + addRSTotal);                    
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp LineItems : EVA__c ' + oppty.EVA__C);                    
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp LineItems : EST_DEAL_VAL__c ' + oppty.EST_DEAL_VAL__c);
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp LineItems : Num_of_vehicles__c ' + oppty.Num_of_vehicles__c);
                    
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp LineItems : oldOppty.Num_of_vehicles__c: ' + Double.valueOf(oldOppty.Num_of_vehicles__c));
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp LineItems : oppty.Num_of_vehicles__c: ' + Double.valueOf(oppty.Num_of_vehicles__c));
                    
                    //double noofvehicles = Double.parseDouble(oldOppty.Num_of_vehicles__c);
                 /*   if (Double.valueOf(oldOppty.Num_of_vehicles__c) != Double.valueOf(oppty.Num_of_vehicles__c) || Double.valueOf(oldOppty.EST_DEAL_VAL__c) != Double.valueOf(oppty.EST_DEAL_VAL__c )|| Double.valueOf(oldOppty.EVA__c) != Double.valueOf(oppty.EVA__c)|| Double.valueOf(oldOppty.Old_Revenue__c) != Double.valueOf(oppty.Old_Revenue__c)|| Double.valueOf(oldOppty.EVA_VEH__c) != Double.valueOf(oppty.EVA_VEH__c))
                    {
                        updateOppty = true;                     
                    }                    
                    System.debug(LoggingLevel.INFO, 'fffffffffffff RolledUp LineItems : updateOppty ' + updateOppty);
                    */
                    
                    oppty.NVI_Total__c = tempRollupOpptyTotals.netInvestment;
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaaaa netInvestment: ' + tempRollupOpptyTotals.netInvestment);
                    System.debug(LoggingLevel.INFO, 'aaaaaaaaaaaaa NVI_Total__c: ' + oppty.NVI_Total__c);
                }
                 System.debug(LoggingLevel.INFO, '++++++++++++++ oldOppty.EST_DEAL_VAL__c: ' + oldOppty.EST_DEAL_VAL__c + '****oppty.EST_DEAL_VAL__c*** ' + oppty.EST_DEAL_VAL__c);
                // opportunity is not resetting if all the rs/ds are excluded and there are no products. so moved the logic to set the update oppor flag
                // outside the if conditions.
                if (Double.valueOf(oldOppty.Num_of_vehicles__c) != Double.valueOf(oppty.Num_of_vehicles__c) || Double.valueOf(oldOppty.EST_DEAL_VAL__c) != Double.valueOf(oppty.EST_DEAL_VAL__c ) || Double.valueOf(oldOppty.EVA__c) != Double.valueOf(oppty.EVA__c)|| Double.valueOf(oldOppty.Old_Revenue__c) != Double.valueOf(oppty.Old_Revenue__c) || Double.valueOf(oldOppty.NVI_Total__c) != Double.valueOf(oppty.NVI_Total__c))
                    {
                        updateOppty = true;                     
                    }

                System.debug(LoggingLevel.INFO, '++++++++++++++ Updated Oppty Total: ' + oppty);
            }
        }
        
        if (updateOppty )
        {        
            if (opptyList != null && opptyList.size() > 0) {
                
                System.debug(LoggingLevel.INFO, 'fffffffffffff Updating Opportunity ' + opptyList);
                update opptyList;
            }
            
            // if (UserInfo.getUserId() == '005P0000000QLIyIAO') {
            
                System.debug(LoggingLevel.INFO, 'fffffffffffff Updating ParentTotal ' + opptyList);
                updateParentTotals(opptyList);
            // }        
        }
        else
        {
                System.debug(LoggingLevel.INFO, 'fffffffffffff NO Updating Opportunity ');
        }        
    }
    
    /*
    *   Get totals for Deal Summaries by Opportunity 
    */
    private static Map<Id, RollupOpptyTotalsVO> getDealSummaryListForOpportunity(List<Id> opportunityIds) {
        Map<Id, RollupOpptyTotalsVO> result = new Map<Id, RollupOpptyTotalsVO>();
        List<Deal_Summary__c> dealSummaries = [Select d.Opportunity__c, d.opportunity__r.account.CustProspectID__c, d.No_of_Vehicles__c, d.Include_In_Quote__c, d.Gross_Revenue__c, 
               d.EVA__c, include_in_eva__c From Deal_Summary__c d where d.Opportunity__c in: opportunityIds order by d.Opportunity__c ];
        System.debug(LoggingLevel.INFO, '++++++++++++++ dealSummaries Included count: ' + dealSummaries.size());
        System.debug(LoggingLevel.INFO, '++++++++++++++ dealSummaries Included : ' + dealSummaries);
        if (dealSummaries != null && dealSummaries.size() > 0) {
            Id tempOpptyId = null;
            RollupOpptyTotalsVO tempRollupOpptyTotalsVO = new RollupOpptyTotalsVO();
            
            for (Deal_Summary__c ds: dealSummaries) {
                if (ds.Include_In_Quote__c){
                    
                    if (tempOpptyId == null || ds.opportunity__c != tempOpptyId ) {
                        if (tempOpptyId != null){
                            result.put(tempOpptyId, tempRollupOpptyTotalsVO);
                            tempRollupOpptyTotalsVO = new RollupOpptyTotalsVO();
                        }
                        tempOpptyId = ds.Opportunity__c;
                    }
                    
                    if (ds.Include_in_EVA__c)
                        tempRollupOpptyTotalsVO.eva += ds.EVA__c;
                    
                    if (ds.Gross_Revenue__c != null) {
                        tempRollupOpptyTotalsVO.grossRevenue += ds.Gross_Revenue__c;
                    }
                    if ( ds.No_of_Vehicles__c != null) {
                        tempRollupOpptyTotalsVO.numOfVehicles += ds.No_of_Vehicles__c;
                    }
                }
            }
            
            if (tempOpptyId != null && tempRollupOpptyTotalsVO != null) {
                result.put(tempOpptyId, tempRollupOpptyTotalsVO);
            }
        }       
        return result;
    }
    
    /*
    *   Get totals for Rate sheet by Opportunity 
    */
    private static Map<Id, RollupOpptyTotalsVO> getRateSheetListForOpportunity(List<Id> opportunityIds) {
        Map<Id, RollupOpptyTotalsVO> result = new Map<Id, RollupOpptyTotalsVO>();
        boolean includedInQuote= false;
        
        //01/05/2014 - Updated by Saad: Added Transaction_Type__c in the query 
        //08/15/2011- updated by neelima to calculate the oportunity totals only from ratesheets.
        List<Rate_Sheet__c> rateSheets = [Select r.Opportunity__c, r.No_of_Vehicles__c, r.Include_In_Quote__c, r.Deal_Summary__r.Include_In_Quote__c,r.Id,  
                r.Gross_Revenue__c,r.Old_Revenue__c, r.EVA__c, r.include_in_eva__c,r.Net_Investment__c, r.Transaction_Type__c From Rate_Sheet__c r where 
                r.Opportunity__c in: opportunityIds order by r.Opportunity__c]; 
        
                       
      /*  List<Rate_Sheet__c> rateSheets = [Select r.Opportunity__c, r.No_of_Vehicles__c, r.Include_In_Quote__c, r.Id,  
                r.Gross_Revenue__c,r.Old_Revenue__c, r.EVA__c, r.include_in_eva__c From Rate_Sheet__c r where r.Opportunity__c in: opportunityIds and 
                r.Deal_Summary__c = null order by r.Opportunity__c ];*/
                
        System.debug(LoggingLevel.INFO, '++++++++++++++ rateSheets Included count: ' + rateSheets.size());
        System.debug(LoggingLevel.INFO, '++++++++++++++ rateSheets Included : ' + rateSheets);
        if (rateSheets != null && rateSheets.size() > 0) {
            Id tempOpptyId = null;
            RollupOpptyTotalsVO tempRollupOpptyTotalsVO = new RollupOpptyTotalsVO();
            for (Rate_Sheet__c rs: rateSheets) {
                if((rs.Deal_Summary__c==null && rs.Include_In_Quote__c)|| (rs.Deal_Summary__c!=null && rs.Deal_Summary__r.Include_In_Quote__c)) includedInQuote=true;
                else includedInQuote=false;
                if(includedInQuote){
                    System.debug(LoggingLevel.INFO, '++++++++++++++ rateSheet: ' + rs);
                    System.debug(LoggingLevel.INFO, '++++++++++++++ deal summary: ' + rs.Deal_Summary__r);
                   // if (rs.Include_In_Quote__c || rs.Deal_Summary__r.Include_In_Quote__c){
                    if (tempOpptyId == null || rs.opportunity__c != tempOpptyId ) {
                        if (tempOpptyId != null){
                            result.put(tempOpptyId, tempRollupOpptyTotalsVO);
                            tempRollupOpptyTotalsVO = new RollupOpptyTotalsVO();
                        }
                        tempOpptyId = rs.Opportunity__c;
                    }
                
                    if (rs.Include_in_EVA__c!=null && rs.Include_in_EVA__c)
                    {
                        tempRollupOpptyTotalsVO.eva += rs.EVA__c;
                        tempRollupOpptyTotalsVO.eva_veh +=rs.No_of_Vehicles__c;
                    }
                    //01/05/2014 - Updated by Saad: Added the logic that if the Transaction_Type__c = 'Contract Change' or 'Conversion to Contract Change' then the value 
                    //of the opportunity should be the net revenue (Gross Revenue - Old Revenue) instead of gross revenue  
                    /*    
                    if (rs.Gross_Revenue__c != null) {
                        tempRollupOpptyTotalsVO.grossRevenue += rs.Gross_Revenue__c;
                    }
                    */
                    if (rs.Gross_Revenue__c != null) {
                        if ((rs.Transaction_Type__c == 'Contract Change') || (rs.Transaction_Type__c == 'Conversion to Contract Change'))
                        {
                            tempRollupOpptyTotalsVO.grossRevenue += rs.Gross_Revenue__c - rs.Old_Revenue__c;
                        }
                        else
                        {
                            tempRollupOpptyTotalsVO.grossRevenue += rs.Gross_Revenue__c;
                        }
                    }
                                      
                     // neelima- added old revenue- 08/05/2011
                      if (rs.Old_Revenue__c!= null) {
                        tempRollupOpptyTotalsVO.oldRevenue += rs.Old_Revenue__c;
                    }
                    if (rs.No_of_Vehicles__c != null) {
                        tempRollupOpptyTotalsVO.numOfVehicles += rs.No_of_Vehicles__c;
                    }
                    
                    // Added by Albert M. - 9/18/2014 - #545
                    if (rs.Net_Investment__c != null) {
                        //System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa Net_Investment__c : ' + rs.Net_Investment__c);
                        tempRollupOpptyTotalsVO.netInvestment += rs.Net_Investment__c; 
                        //System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa Net_Investment__c 2');
                    }
                }           
            }
            
            if (tempOpptyId != null && tempRollupOpptyTotalsVO != null) {
                result.put(tempOpptyId, tempRollupOpptyTotalsVO);
            }
        }       
        return result;
    }
    
    private static Map<Id, RollupOpptyTotalsVO> getOpportunityLineItemRollups(List<Id> opportunityIds) {
            Map<Id, RollupOpptyTotalsVO> result = new Map<Id, RollupOpptyTotalsVO>();
            List<OpportunityLineItem> oppLineItems = [Select o.Quantity, o.OpportunityId, o.totalprice, o.Net_Revenue__c, o.product_line__c, o.PricebookEntryId From OpportunityLineItem o where o.OpportunityId in: opportunityIds order by o.Opportunityid ];
            System.debug(LoggingLevel.INFO, '++++++++++++++ oppLineItems Included count: ' + oppLineItems.size());
            System.debug(LoggingLevel.INFO, '++++++++++++++ oppLineItems Included : ' + oppLineItems);
            
            // Added by Albert M. - 9/18/2014 - #545
            Set<ID> sPricebookEntryIds = new Set<ID>();
            Set<ID> sProductIds = new Set<ID>();
            Map<String, Integer> mapNVIDefaultQueue = new Map<String, Integer>();
            for(OpportunityLineItem OppLitem : oppLineItems)
            {
                sPricebookEntryIds.add(OppLitem.PricebookEntryId);
            }
            
            Map<Id,PricebookEntry> mProductIds = new Map<Id,PricebookEntry>([Select Product2Id, Name From PricebookEntry where Id in: sPricebookEntryIds]);
            List<PricebookEntry> productIds = [Select Product2Id From PricebookEntry where Id in: sPricebookEntryIds];
            
            for(PricebookEntry ProdId : productIds)
            {
                sProductIds.add(ProdId.Product2Id);
            }
            
            Map<Id,Product2> mProduct2SamClass = new Map<Id,Product2>([SELECT SAM_Class__c, Description, VHC_TYPE__c FROM Product2 WHERE Id in: sProductIds]);
            
            // Get the Custom Label values and split them (NVI Default Amount)
            for(String QueueItems : String.ValueOf(LABEL.NVI_Default_Amount).split('#'))
            {
                List<String> Queue = QueueItems.split(',');
                mapNVIDefaultQueue.put(Queue[0], integer.valueOf(Queue[1]));
            }
            // End -- #545
            
            if (oppLineItems  != null && oppLineItems.size() > 0) {
                Id tempOpptyId = null;
                RollupOpptyTotalsVO tempRollupOpptyTotalsVO = new RollupOpptyTotalsVO();
                tempRollupOpptyTotalsVO.eva = 0;
                for (OpportunityLineItem oli: OppLineItems) {
                    
                    if (tempOpptyId == null) {
                        tempOpptyId = oli.OpportunityId;
                    }
                    
                    if (tempOpptyId != null && tempOpptyId != oli.OpportunityId){
                        result.put(tempOpptyId, tempRollupOpptyTotalsVO);
                        tempOpptyId = oli.Opportunityid;
                        tempRollupOpptyTotalsVO = new RollupOpptyTotalsVO();
                    }
                    if (oli.TotalPrice != null) {
                        tempRollupOpptyTotalsVO.grossRevenue += oli.TotalPrice;
                    }
                    if (oli.quantity != null) {
                        if (oli.product_line__c != 'Rydesmart' && oli.product_line__c != 'Insurance')
                            tempRollupOpptyTotalsVO.numOfVehicles += oli.quantity;
                    }
                    
                    // Added by Albert M. - 9/18/2014 - #545
                    try{
                        
                        PricebookEntry priceBk = mProductIds.get(oli.PricebookEntryId);
                        Product2 samClass = mProduct2SamClass.get(priceBk.Product2Id);
                        
                        // Only rollup values that are FSL New and FSL Takeover
                        if(priceBk.Name.contains('FSL') && (samClass.VHC_TYPE__c == 'New' || samClass.VHC_TYPE__c == 'Takeover')){
                            
                            if(samClass.SAM_Class__c.contains('Tractor')){ 
                                tempRollupOpptyTotalsVO.netInvestment += mapNVIDefaultQueue.get('Tractor')*oli.quantity;
                            }
                            if(samClass.SAM_Class__c.contains('Truck')){
                                tempRollupOpptyTotalsVO.netInvestment += mapNVIDefaultQueue.get('Truck')*oli.quantity;
                            }
                            if(samClass.SAM_Class__c.contains('Trailer')){
                                tempRollupOpptyTotalsVO.netInvestment += mapNVIDefaultQueue.get('Trailer')*oli.quantity;
                            }
                            if(samClass.SAM_Class__c.contains('Van')){
                                tempRollupOpptyTotalsVO.netInvestment += mapNVIDefaultQueue.get('Van')*oli.quantity;
                            }
                            if(samClass.SAM_Class__c.contains('Refrigerated') || samClass.Description.contains('Refrigerated')){
                                tempRollupOpptyTotalsVO.netInvestment += mapNVIDefaultQueue.get('Refrigerated')*oli.quantity;
                            }
                        }
                    }
                    catch(Exception ex){
                        
                    }
                                        
                }
                if (tempOpptyId != null && tempRollupOpptyTotalsVO != null) {
                    result.put(tempOpptyId, tempRollupOpptyTotalsVO);
                }
            }       
        return result;
    }
    
     /*
    *   Here are the fields that should roll-up, and to which fields we should sum the value.

If a record has a Parent Opportunity listed, the following fields should be used to roll-up on the named Parent Opportunity.

Num_of_vehicles__c   >>>  Total_Number_of_Vehicles_Child__c

Amount  (renamed Estimated Deal Value)  >>>  Total_Child_Opportunity_Amount__c


Criteria are to only include pending or won stages.   LOST opportunity stages should be ignored from the roll-up.
    
    */
    public static void updateParentTotals(List<Opportunity> opportunityList) {
        //1. loop through list to get list of all parent oppty that needs to be recalculated.
        List<ID> parentOpptyTobeRecalculated = new List<ID>();
        Id parentRecordTypeId = '012P00000008V7LIAU';
        Id childRecordTypeId = '012P00000008V7GIAU';
        for (Opportunity temp: opportunityList) {
            if (temp.recordTypeId == parentRecordTypeId) {
                parentOpptyTobeRecalculated.add(temp.Id);
            } else if (temp.RecordTypeId == childRecordTypeId) {
                parentOpptyTobeRecalculated.add(temp.Parent_Opportunity__c);
            }
        }
        //2. recalculate parent oppty totals
        System.debug(LoggingLevel.INFO, '++++++++++++++++++ parentOpptyTobeRecalculated:' + parentOpptyTobeRecalculated);
        if (parentOpptyTobeRecalculated != null && parentOpptyTobeRecalculated.size() > 0) {
            Double totalVehicle = 0.00;
            Double totalEVA = 0.00;
            Map<Id, OpptyTotals> parentOpptyTotals = new Map<Id, OpptyTotals>();
    
            List<Opportunity> opptyList = [Select o.Num_of_vehicles__c, o.Id, o.EST_DEAL_VAL__c, o.Parent_Opportunity__c 
                          From Opportunity o where o.StageName != 'Lost' and o.Parent_Opportunity__c in: parentOpptyTobeRecalculated  
                          order by o.Parent_Opportunity__c LIMIT 10000];
            Id oldParentId = null;
            OpptyTotals opptyTotals = new OpptyTotals();
                   
            if (opptyList != null && opptyList.size() > 0) {
                for (Opportunity oppty: opptyList) {
                    if (oldParentId == null || oldParentId != oppty.Parent_Opportunity__c) {
                        if (oldParentId != null) {
                         parentOpptyTotals.put(oldParentId, opptyTotals);
                        }
                        oldParentId = oppty.Parent_Opportunity__c;
                        opptyTotals = new OpptyTotals();
                        opptyTotals.totalEVA = 0.0;
                        opptyTotals.totalVehicleCount = 0.0;
                    }
                    if (oppty.Num_of_vehicles__c != null) {
                        opptyTotals.totalVehicleCount += oppty.Num_of_vehicles__c;
                    }
                    if (oppty.EST_DEAL_VAL__c != null) {
                        opptyTotals.totalEVA += oppty.EST_DEAL_VAL__c;
                    }
                }
                parentOpptyTotals.put(oldParentId, opptyTotals);
            } else  {
                // loop through parent ids and set values to zero
                for (Id tempId : parentOpptyTobeRecalculated) {
                    parentOpptyTotals.put(tempId, opptyTotals);
                }
            }
            System.debug(LoggingLevel.INFO, '++++++++++++++++++ parentOpptyTotals:' + parentOpptyTotals);
            System.debug(LoggingLevel.INFO, '++++++++++++++++++ parentOpptyTotals.keySet():' + parentOpptyTotals.keySet());
            if (parentOpptyTotals != null && parentOpptyTotals.size() > 0) {
                List<Opportunity> opptyToUpdateList = [Select o.Total_Number_of_Vehicles_Child__c, o.Id, o.Total_Child_Opportunity_Amount__c, o.Parent_Opportunity__c 
                          From Opportunity o where o.id in: parentOpptyTotals.keySet()];
                System.debug(LoggingLevel.INFO, '++++++++++++++++++ opptyToUpdateList:' + opptyToUpdateList);
                if (opptyToUpdateList != null && opptyToUpdateList.size() > 0) {
                    for (Opportunity parentOppty: opptyToUpdateList) {
                        OpptyTotals parentOpptyTotal = parentOpptyTotals.get(parentOppty.Id);
                        System.debug(LoggingLevel.INFO, '++++++++++++++++++ parentOppty:' + parentOppty);
                        System.debug(LoggingLevel.INFO, '++++++++++++++++++ parentOpptyTotal:' + parentOpptyTotal);
                        parentOppty.Total_Number_of_Vehicles_Child__c = parentOpptyTotal.totalVehicleCount;
                        parentOppty.Total_Child_Opportunity_Amount__c = parentOpptyTotal.totalEVA;
                    }
                    System.debug(LoggingLevel.INFO, '############################### opptyToUpdateList:' + opptyToUpdateList);
                    update opptyToUpdateList;
                }       
            }
        }
    }
    
    public with sharing class OpptyTotals {
        public OpptyTotals () {
            this.totalEVA = 0.0;
            this.totalVehicleCount = 0.0;
        }
        public Double totalEVA {get; set;}
        public Double totalVehicleCount {get; set;} 
    }
    
    static testMethod void test_OpptyTotals() {
        OpptyTotals tempVO = new OpptyTotals();
        tempVO.totalEVA = 1.0;
        tempVO.totalVehicleCount = 1.0;
        
        system.assertEquals(tempVO.totalEVA, 1.0);
        system.assertEquals(tempVO.totalVehicleCount, 1.0);
    }
    
}