global class UVS_CreateOpportunities {

    webservice static String ProcessBuy_Out_Status(String Id)
    { 
        system.debug(LoggingLevel.INFO, '------------>' + Id);
        UVS_SheduleA_Request__c scheduleA = [SELECT Id, Buy_Out_Approved__c, User_Pricing_Name__c 
        									FROM UVS_SheduleA_Request__c 
        									WHERE Id = :Id and User_Pricing_Name__c != null];
		system.debug(LoggingLevel.INFO, '------------>' + scheduleA);
		if(scheduleA != null)
		{
			if(scheduleA.User_Pricing_Name__c != UserInfo.getUserId())
			{
				if(scheduleA.Buy_Out_Approved__c == 'New Request')
				{
					scheduleA.Buy_Out_Approved__c = 'Sent to Pricing';
					update scheduleA;
				}
				else if(scheduleA.Buy_Out_Approved__c != null && scheduleA.Buy_Out_Approved__c == 'Sent to Lease')
				{
					scheduleA.Buy_Out_Approved__c = 'Approved';
					update scheduleA;
					CreateScheduleAOpportunity(scheduleA.Id);
				}
				else
					return 'Request was already processed.';
			}
			else if(scheduleA.User_Pricing_Name__c == UserInfo.getUserId() && 
				scheduleA.Buy_Out_Approved__c != null && 
				scheduleA.Buy_Out_Approved__c == 'Sent to Pricing')
			{
				scheduleA.Buy_Out_Approved__c = 'Sent to Lease';
				update scheduleA;
			}
			else
				return 'Request was already processed.';
			return 'Request Processed!';
		}
		return 'Request Missing User Pricing Name!';
    }
	
    public static void CreateScheduleAOpportunity(String sScheduleAId){
        
        UVS_SheduleA_Request__c scheduleA = [SELECT Id, Account_Name__c, Name, OwnerId FROM UVS_SheduleA_Request__c WHERE Id = : sScheduleAId];
        List<Opportunity> opportunityResultCollection = new List<Opportunity>();
        
        //Get all location codes (grouped) to create opportunities.
        AggregateResult[] lVehicleInfo = [select Location_Code__c, MAX(Buy_Out_Date__c) from UVS_Vehicle_Information__c 
                                                            where ScheduleA_Request__c =: sScheduleAId
                                                            group by Location_Code__c];
                                                            
        system.debug(LoggingLevel.INFO, 'aaaaaaaa lVehicleInfo: ' + lVehicleInfo);
                                                            
        //Set the original decision maker for the opportunities being created. 
        String originalDecisionMaker = getOriginalDecisionMaker(scheduleA.Account_Name__c);
        system.debug(LoggingLevel.INFO, 'aaaaaaaa originalDecisionMaker: ' + originalDecisionMaker);

		//Map<Id, Opportunity> opportunityResult = new Map<Id, Opportunity>();
        //Loop through all location codes to create an opportunity for each location code listed
        integer i = 1;
        for(AggregateResult vehicle : lVehicleInfo){
            
            Opportunity opportunityResult = CreateOpportunity('ScheduleA UVS ' + i + '-' + scheduleA.Name, 'Overcome Concerns', scheduleA.Account_Name__c, scheduleA.OwnerId, originalDecisionMaker, date.today().addMonths(1), Date.valueOf(vehicle.get('expr0')), null); //expr0 is (Buy_Out_Date__c)
            opportunityResultCollection.add(opportunityResult);
            i++;
        }
        system.debug(LoggingLevel.INFO, 'aaaaaaaa opportunityResultCollection: ' + opportunityResultCollection);
        
        // In order to create price book entry for custom price books, first we need to create price book entries for standard price books
        PriceBook2 UVSPriceBook = [Select Id from PriceBook2 where Name = 'UVS' limit 1];
        // list of opportunity line items to be inserted
        List<OpportunityLineItem> listNewOppLineItem = new List<OpportunityLineItem>();
        //Loop through created opportunities (from result) to create line items based off vehicles from location codes. 
        for (Opportunity oppty: opportunityResultCollection) {
        	
        	
            //listNewOppLineItem.add(createOpportunityLineItem(vehicle, pbe.Id,pbe.Product2.Family));
        }
        
    }
   
    public static String getOriginalDecisionMaker(String accountId){

        Contact origDecMakerContact = null;
        String origDecisionMaker = '';
        
        //Check if there is a Parent Id in Account
        Account parentAccount = [SELECT ParentId FROM Account WHERE Id = :accountId];
        
        if(parentAccount.ParentId == null){
            
            //If there is no ParentId then use the oppty AccountId
            origDecMakerContact = [SELECT Id FROM Contact WHERE AccountId = :accountId AND STATUS_ACTIVE__c = true LIMIT 1];
            origDecisionMaker = origDecMakerContact.Id;
            
        }else{
            
            origDecMakerContact = [SELECT Id FROM Contact WHERE AccountId = :parentAccount.ParentId AND STATUS_ACTIVE__c = true LIMIT 1];
            origDecisionMaker = origDecMakerContact.Id;
        }
        return origDecisionMaker;
    }
    
    public static Opportunity CreateOpportunity(String oppName, 
                                                         String stageName, 
                                                         String accountId, 
                                                         String ownerId, 
                                                         String originalDecisionMaker, 
                                                         Date estimatedProposalDate, 
                                                         Date buyoutDate, 
                                                         String purchaseReason
                                                         ) {

        RecordType uvsOpptyRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'UVS_Opportunity'];
        //Map<Id, Opportunity> result = new Map<Id, Opportunity>();
        Opportunity newOpportunity = new Opportunity();
        
        newOpportunity.StageName = stageName;
        newOpportunity.Estimated_Proposal_Date__c = estimatedProposalDate;
        newOpportunity.AccountId = accountId;
        newOpportunity.OwnerId = ownerId;
        newOpportunity.Original_Decision_Maker__c = originalDecisionMaker;
        newOpportunity.Estimated_Proposal_Date__c = estimatedProposalDate;
        newOpportunity.CloseDate = buyoutDate;
        newOpportunity.Purchase_Reason__c = purchaseReason;
        newOpportunity.RecordTypeId = uvsOpptyRecordTypeId.Id; //'UVS Opportunity';
        newOpportunity.Name = oppName;
        insert newOpportunity;
        
        system.debug(LoggingLevel.INFO, 'aaaaaaaa newOpportunity: ' + newOpportunity);
        
        //result.put(newOpportunity.Id, newOpportunity);
        
        return newOpportunity;
    }
    
    // method to create opportunity line item
    // Vehicle : Vehicle Object record
    // pbeId : Id of price book entry record
    private OpportunityLineItem createOpportunityLineItem(String oppId, Vehicle__c vehicle, Id pbeId,String family){
        system.debug('::vehicle::::'+vehicle);
        OpportunityLineItem OLI = new OpportunityLineItem(Quantity=1,
                                                        Unit_Number__c = vehicle.Id,
                                                        Take_Price2__c = vehicle.Take_Price__c,
                                                        //Book_Value__c = vehicle.NBV__c,
                                                        UnitPrice = 0,
                                                        OpportunityId = oppId,
                                                        Product_Line__c  = family,
                                                        PriceBookEntryId = pbeId
                                                        );
        if(Vehicle.Ask_Price__c != null)
            OLI.UnitPrice = Vehicle.Ask_Price__c;    
        return OLI;
    }
    
}