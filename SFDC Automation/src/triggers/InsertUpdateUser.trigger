trigger InsertUpdateUser on User (before insert, before update) {
    Map<string,string> territoryMap= new Map<string,string>();
    List<string> territories= new List<string>();
    // get the list of territories from the newly inserted/updated territory.
    system.debug('****enter****');
    for(User u: trigger.new)
    {
        if(u.Sales_Territory__c!=null)territories.add(u.Sales_Territory__c);
        else u.Sales_Territory_Code__c=null;
    }
    if(territories.size()>0)
    {
    // get a map of teriitories desc/code
        for(Sales_Territory__c t: [Select Sales_Territory_Desc__c,Sales_Territory_code__c from Sales_Territory__c where Sales_Territory_Desc__c in :territories])
        {
            if(!territoryMap.containskey(t.Sales_Territory_Desc__c))
            territoryMap.put(t.Sales_Territory_Desc__c,t.Sales_Territory_code__c);
        }
        system.debug('*****territoryMap******' + territoryMap);
        for(User u: trigger.new)
        {
            if(u.Sales_Territory__c!=null) 
            {
            u.Sales_Territory_Code__c= territoryMap.get(u.Sales_Territory__c);
            // doing the null check here just in case sales territiory match found but has null as code (besides not finding a match) 
            if(u.Sales_Territory_Code__c==null) u.addError('Please enter a valid sales territory');
            
            }
        }
    }
    // Hari Krishnan (01/12/2015): Verify if the UTC code is valid
    UserTriggerHandler.verifyUTCCode(trigger.new, trigger.oldMap);         
}