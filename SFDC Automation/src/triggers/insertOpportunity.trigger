trigger insertOpportunity on Opportunity (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        system.debug(LoggingLevel.INFO, '!!!! before Split');
        InsertOpportunityTrigger.insertOpportunitySplit(Trigger.newMap);
        system.debug(LoggingLevel.INFO, '!!!! before CR'); 
        InsertOpportunityTrigger.insertOpportunityContactRole(Trigger.newMap);
        system.debug(LoggingLevel.INFO, '!!!! after CR');
        //InsertOpportunityTrigger.emailNotificationToNIAM(Trigger.newMap); //commented out on 8/15/2014 by Albert M. per Corey's request. Business will review specs for better solution.
        
    }
}