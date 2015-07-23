trigger insertUpdateLeadAfter on Lead (after insert, after update) {
    
    Map<string,Lead> EmailIds= new Map<string,Lead>();
    List<Lead> leadsToUpdate= new List<Lead>();
    // get the leads that are coming in as primary
        for(Lead l: trigger.new)
            {
                if(trigger.isInsert || trigger.isUpdate && trigger.oldMap.get(l.Id).Email!=l.Email)
                {
                    if(l.is_duplicate__c==false && l.isConverted==false)
                    {
                        if (l.Email !=null && !EmailIds.containskey(l.Email))
                        EmailIds.put(l.Email,l);
                    }
                }
            }
    system.debug('EmailIds' + EmailIds);    
    // update all the existing leads as duplicates and set the primary ids accordingly
    leadsToUpdate=[Select Id,Email,RecordTypeId,primary_lead_Id__c,Is_Duplicate__c from Lead where email IN :EmailIds.keyset()and id not in :trigger.new and isConverted=false];
       system.debug('leadsToUpdate before' + leadsToUpdate);
        for(Lead l: leadsToUpdate)  
            {
                Lead correspondingNewLead=EmailIds.get(l.Email);
                l.Is_Duplicate__c=true;
                l.Primary_Lead_Id__c=(correspondingNewLead==null ? null :correspondingNewLead.Id ); 
    
            }
         system.debug('leadsToUpdate after' + leadsToUpdate);   
            if(leadsToUpdate.size()>0) update leadsToUpdate;
 
}