public with sharing class OpportunityProductManagement_Helper
{
    public static void ValidateOnInsert(List<OpportunityLineItem> lOpportunityLineItem)
    {
        List<OpportunityLineItem> lOppLineItemToProcess = new List<OpportunityLineItem>();
        Set<Id> sOppIds = new Set<Id>();
        Set<Id> sPriceBookEnteryIds = new Set<Id>();        
        for(OpportunityLineItem ObjItem : lOpportunityLineItem)
        {
            if(ObjItem.OppRecordTypeName__c == 'National Rental Opportunity')
            {
                sPriceBookEnteryIds.add(ObjItem.PricebookEntryId);
                lOppLineItemToProcess.add(ObjItem);
            }
        }
        if(lOppLineItemToProcess.size() > 0)
        {
            Map<Id,PricebookEntry> mPrice = new Map<Id,PricebookEntry>([Select p.UnitPrice, p.Id 
                                                                        From PricebookEntry p 
                                                                        where Id in : sPriceBookEnteryIds]);
            for(OpportunityLineItem ObjItem : lOpportunityLineItem)
            {
                PricebookEntry PricebookEntryObj = mPrice.get(ObjItem.PricebookEntryId);
                
                if(ObjItem.UnitPrice != PricebookEntryObj.UnitPrice)
                {
                    sOppIds.add(ObjItem.OpportunityId);
                }
            }
            Boolean IsError = false;
            if(sOppIds.size() > 0)
            {
                IsError = ValidateProductSalesPriceOnTier99(sOppIds);
                if(!IsError)
                    lOpportunityLineItem[0].addError('You can modify the Sales Price for Tier 99 PriceBook only!!!');
            }
            if(lOppLineItemToProcess.size() > 0)
            {
                for(OpportunityLineItem ObjItem : lOppLineItemToProcess)
                {
                    ObjItem.Quantity__c = ObjItem.Quantity;
                    
                    //sunil; 09-18-2014; just added below line so that able to add products.(getting null exception error.)
                    if(ObjItem.Rental_Period__c == null){
                      ObjItem.Rental_Period__c = 1;
                    }
                    ObjItem.Quantity = ObjItem.Quantity__c * ObjItem.Rental_Period__c;
                }
            }
        }
    }
    public static void ValidateOnUpdate(List<OpportunityLineItem> lOpportunityLineItem, 
                                                            Map<Id,OpportunityLineItem> mOpportunityLineItem)
    {
        Set<Id> sOppIds = new Set<Id>();        
        for(OpportunityLineItem ObjItem : lOpportunityLineItem)
        {
            if(ObjItem.OppRecordTypeName__c == 'National Rental Opportunity')
            {
                String sNew = '';
                String sOld = '';
                if(ObjItem.UnitPrice != null)
                    sNew = ObjItem.UnitPrice + '';
                if(mOpportunityLineItem != null && mOpportunityLineItem.get(ObjItem.Id).UnitPrice != null)
                    sOld = mOpportunityLineItem.get(ObjItem.Id).UnitPrice + '';
                if(sNew != sOld)
                    sOppIds.add(ObjItem.OpportunityId);
                ObjItem.Quantity = ObjItem.Quantity__c * ObjItem.Rental_Period__c;
            }
        }       
        Boolean IsError = false;
        if(sOppIds.size() > 0)
        {
            IsError = ValidateProductSalesPriceOnTier99(sOppIds);
            if(!IsError)
                lOpportunityLineItem[0].addError('You can only modify the Sales Price for Tier 99 PriceBook!');
        }
    }
    private static Boolean ValidateProductSalesPriceOnTier99(Set<Id> sOppIds)
    {       
        ID RentalOppRecordTypeId = [Select r.Id From RecordType r where Name = 'National Rental Opportunity' 
                                        and SobjectType = 'Opportunity'].Id;
        Map<Id,Pricebook2> mPricebook = new Map<Id,Pricebook2>([Select p.Name, p.Id From Pricebook2 p 
                                                                where Name != 'Tier 99' 
                                                                and RecordType.Name = 'National Rental PriceBook']);
        Map<Id,Opportunity> mOpportunity = new Map<Id,Opportunity>([Select o.Id, o.Pricebook2Id from Opportunity o 
                                                                    where Id in : sOppIds and 
                                                                    RecordTypeId = : RentalOppRecordTypeId and 
                                                                    Pricebook2Id in : mPricebook.keySet()]);
        if(mOpportunity.size() > 0)
        {
            return false;
        }
        return true;
    }
    /*
    	This method check if the Opportunity Line Item Quantity is get changed or not
    	If yes then It updates the count on Opportunity!    
    */
    public static void ValidateRentalOpportunityVehicleCount(List<OpportunityLineItem> lOpportunityLineItems, 
    															Map<Id,OpportunityLineItem> mOpportunityLineItem)
    {
		Set<Id> sOppIds = new Set<Id>();        
        for(OpportunityLineItem ObjItem : lOpportunityLineItems)
        {
        	system.debug('Nitin--------->'+ObjItem.OppRecordTypeName__c);
        	if(ObjItem.OppRecordTypeName__c != NULL && ObjItem.OppRecordTypeName__c == 'National Rental Opportunity')
            {
            	String sNew = '';
            	String sOld = '';            	
            	if(ObjItem.Quantity != null)
            		sNew = ObjItem.Quantity + '';
            	if(mOpportunityLineItem != null && mOpportunityLineItem.get(ObjItem.Id).Quantity != null)
            		sOld = mOpportunityLineItem.get(ObjItem.Id).Quantity + '';
            	system.debug('Nitin------sNew--->'+sNew);
            	system.debug('Nitin------sOld--->'+sOld);
            	if(sNew != sOld)
            		sOppIds.add(ObjItem.OpportunityId);
            }
        }
        if(sOppIds.size() > 0)
        	UpdateVehicleCountOnRentalOpportunity(sOppIds);
    }
    private static void UpdateVehicleCountOnRentalOpportunity(Set<Id> sOppIds)
    {
		Set<Id> sIds = new Set<Id>();
		List<Opportunity> lOpportunity = new List<Opportunity>();
		for (AggregateResult result : [SELECT SUM(Quantity__c) numOppLineItems, OpportunityId FROM OpportunityLineItem 
                                		WHERE OpportunityId IN :sOppIds and 
                                		Include_In_Vehicles_Count__c = true 
                                		GROUP BY OpportunityId])
		{
			sOppIds.remove((Id)result.get('OpportunityId'));
			Opportunity OppObj = new Opportunity(Id = (Id)result.get('OpportunityId'));
			OppObj.Total_No_Of_Vehicles_Rental__c = (Decimal)result.get('numOppLineItems');
			lOpportunity.add(OppObj);
		}
		if(sOppIds.size() > 0)
		{
			for(ID IDObj : sOppIds)
			{
				Opportunity OppObj = new Opportunity(Id = IDObj, Total_No_Of_Vehicles_Rental__c = 0);
				lOpportunity.add(OppObj);
			}
		}
		if(lOpportunity.size() > 0)
			update lOpportunity;
    }
    
	public static void ValidateOpportunityTotals(Map<Id,OpportunityLineItem> mOpportunityLineItem)
    {
         Set<Id> sOppIds = new Set<Id>();    
         system.debug('entered******');
         for(OpportunityLineItem ObjItem : mOpportunityLineItem.values())
            {
              if(ObjItem.OppRecordTypeName__c == 'UVS Opportunity')
                 {
                  sOppIds.add(ObjItem.OpportunityId);
                  system.debug('entered1******');
                  }
              } 
              Set<Id> sIds = new Set<Id>();
              Map<Id,Opportunity> map_Opportunities = new Map<Id,Opportunity>
                             (   [   SELECT  Id, Num_of_vehicles__c,EST_DEAL_VAL__c,Stagename FROM    Opportunity
                                    WHERE   Id IN :sOppIds  ] );  
              for ( AggregateResult result : [SELECT  COUNT(Id) numOppLineItems,SUM(UnitPrice) estOppLineItems, OpportunityId 
                                            FROM    OpportunityLineItem WHERE  OpportunityId IN :sOppIds
                                             GROUP BY OpportunityId])
                         {
                           sIds.add((Id) result.get( 'OpportunityId' ));
                           system.debug('entered2******');
                          if(map_Opportunities.get( (Id) result.get( 'OpportunityId' ) ).Stagename != 'Booked')
                          {
                          map_Opportunities.get( (Id) result.get( 'OpportunityId' ) ).Num_of_vehicles__c = (Integer) result.get( 'numOppLineItems' );
                          map_Opportunities.get( (Id) result.get( 'OpportunityId' ) ).EST_DEAL_VAL__c = (Decimal) result.get( 'estOppLineItems' );
                           }} 
                           
                           for(Id oppid : sOppIds)
                           {
                             if(!sIds.contains(oppid))
                              {
                               map_Opportunities.get(oppid).Num_of_vehicles__c = 0;
                               map_Opportunities.get(oppid).EST_DEAL_VAL__c =0;
                              }
                           }
                           
                         update map_Opportunities.values();
                      }}