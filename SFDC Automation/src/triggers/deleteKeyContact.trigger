trigger deleteKeyContact on Key_Contact__c (after delete) {
    // if(UserInfo.getUserName()==RyderGlobalVariables.ETLUSER) return;
    // added for key contacts rewrite project- neelima-07/06/2011
    List<Id>deletedIds= new List<id>();
    List<Id>deletedIdsupdated= new List<id>();
    List<Contact>deletedContacts= new List<Contact>();
    Map<Id,Id>keyContacts= new Map<Id,Id>();
   ////----Swetha---commented out----- MA Changes
    /*  
    for (Key_Contact__c kc : trigger.old)
    {
        
        // by pass trigger logic for all branch contacts
        if(kc.All_Branch_Contact__c==false) deletedIds.add(kc.Contact__c);
       else if(kc.All_Branch_Contact__c && ContactUtil.isDeleteFromTrigger==null)
        kc.AddError('All Branch key Contacts Cannot be deleted.');
        
    }
    if (deletedIds==null) return;
    
    ContactUtil.MoveContactsAfterKeyContactDelete(deletedIds);
    */
    ////END ----Swetha---commented out----- MA Changes
    for (Key_Contact__c kc : trigger.old)
    {
        // by pass trigger logic for all branch contacts
        if(kc.All_Branch_Contact__c && ContactUtil.isDeleteFromTrigger==null)
            kc.AddError('All Branch key Contacts Cannot be deleted.');
        
    }
    
    /*
    -- Commented out by Neelima for key contact and contact dedup changes
    List<Key_Contact__c> existingKeyContacts= [Select Id,Contact__c  from Key_Contact__c where Contact__c in :deletedIds];
    
    // see if the contacts have any more key contacts existing.
    for(Key_Contact__c kcon: existingKeyContacts)
    {
     if(keyContacts.get(kcon.Contact__c)==null) keyContacts.put(kcon.Contact__c,kcon.Id);   
    }
    for(Id id:deletedIds){
        // if there are no more key contacts for this contact add it to the updated list
        if(keyContacts.get(id)==null) deletedIdsupdated.add(id);
    }
    // move the contact to the child for all the contacts from the updated list
    deletedContacts=[Select c.AccountId, c.Id, c.Original_Account__c from Contact c where id in :deletedIdsupdated];
    for(Contact c: deletedContacts)
    ContactUtil.MoveContactToChild(c);
    
    update deletedContacts;
    */
}