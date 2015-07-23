public with sharing class updateOpportunityTrigger {
    // piyush -- this is not being used see the trigger for comments by mph
	/*
	public static void updateSplitOwnership(map<id,opportunity> newmap, map<id, opportunity> oldmap){
		
		list<id> listIds = new list<id>();
		Opportunity oldopp = null;
		//determine which opportunities need to have their opportunitysplits updated
		for (Opportunity o : newmap.values()){
			oldopp = oldmap.get(o.id);
			if ( !o.isclosed && (oldopp.ownerid != o.ownerid) ){
				listIds.add( o.id );
			}
		}

		list<Opportunity_Split__c> listos = new list<Opportunity_Split__c>();		
		for (Opportunity_Split__c os : [select id, opportunity__c, sales_team_member__c from Opportunity_Split__c where opportunity__c in :listIds]){
			if (os.Sales_Team_Member__c == oldmap.get(os.opportunity__c).ownerid){
				os.sales_team_member__c = newmap.get(os.opportunity__c).ownerid;
				listos.add(os);
			}
		}
		update listos;
	}
*/
}