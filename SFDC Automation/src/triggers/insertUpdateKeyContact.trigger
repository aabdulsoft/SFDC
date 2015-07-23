trigger insertUpdateKeyContact on Key_Contact__c (before insert,after insert, before update) {
    
    if(UserInfo.getUserName()==RyderGlobalVariables.ETLUSER) return;
        // added for key contacts rewrite project- neelima-07/06/2011
    List<Contact>contactsToParent= new List<Contact>();
    List<Contact>contactsToChild= new List<Contact>();
    List<Id>contactToParentIds= new List<Id>();
    List<Id>contactToChildIds= new List<Id>();
    List<Contact>contactsToUpdate= new List<Contact>();
    Contact oldContact=null;
    
    ////----Swetha--- MA Changes
    // copy the hq account id to account id if it is before inser or before update.
    if(Trigger.isBefore)
    {
        for(Key_Contact__c kc : trigger.new)
        {
            kc.AccountId__c=kc.HQ_Account_ID__c;
        }
    }
    ////END ----Swetha--- MA Changes
    /*
    ////----Swetha---commented out----- MA Changes
    
    // copy the hq account id to account id if it is before inser or before update.
    if(Trigger.isBefore)
    {
        for(Key_Contact__c kc : trigger.new)
        {
            kc.AccountId__c=kc.HQ_Account_ID__c;
            System.debug(LoggingLevel.INFO, '+++++++++++++ Inside insertUpdateKeyContact trigger- kc' + kc);
            if((Trigger.isUpdate) && kc.Contact__c!= trigger.oldMap.get(kc.Id).Contact__c && kc.All_Branch_Contact__c==false)
            { 
                contactToChildIds.add(trigger.oldMap.get(kc.Id).Contact__c);
                contactToParentIds.add(kc.Contact__c);
            }
        }
        System.debug(LoggingLevel.INFO, '+++++++++++++ contactToChildIds' + contactToChildIds);
        if(contactToChildIds!=null)
        {
            // if the contact is updated in a key contact update old contact accountid and original account id if there are no more existing key contacts.
            contactsToChild=[Select c.AccountId, c.Id, c.Original_Account__c,c.account.ParentId,c.Contact_Trigger_Toggle__c from Contact c where id in :contactToChildIds];
            ContactUtil.MoveContactsAfterKeyContactDelete(contactsToChild);
        }
    
    }
    // on key contact insert update the contact original account to account id and then overwrite account with parent id if the contacts belongs to a child account.
    else if(Trigger.isInsert) 
    {
        for(Key_Contact__c kc : trigger.new)
        {
            if(kc.All_Branch_Contact__c==false) contactToParentIds.add(kc.Contact__c);
        }
    }
    
    System.debug(LoggingLevel.INFO, '+++++++++++++ contactToParentIds' + contactToParentIds);
    if(contactToParentIds==null) return;
        
    contactsToParent=[Select c.AccountId, c.Id, c.Original_Account__c,c.account.ParentId,c.Contact_Trigger_Toggle__c from Contact c where id in :contactToParentIds];
    for(Contact c:contactsToParent)
    {
        ContactUtil.MoveContactToParent(c);
        contactsToUpdate.add(c);
    }
    
    if(Trigger.isInsert && contactsToUpdate!=null)
    { 
        update contactsToUpdate;
    }
    else if(Trigger.isUpdate && ContactUtil.isAllBranchInsUpd==null)
    {
        update contactsToUpdate;
        update contactsToChild;
    }
    
    ////END ----Swetha---commented out----- MA Changes  
    */
}