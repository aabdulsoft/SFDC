trigger insertUpdateContact on Contact (before insert,after insert, before update, after update) {
    system.debug('--------------------------------------2-------------------------------------------');
    boolean bOtherUpdated=false;
    if(UserInfo.getUserName()==RyderGlobalVariables.ETLUSER) return;
    // trigger created for key contact rewrite project-06/15/2011
    Map<String, Contact> validatedForKeyContactInsert= new Map<String, Contact>();
    Map<String, Contact> validatedForKeyContactUpdate= new Map<String, Contact>();
    Map<String, Contact> validatedForKeyContactDelete= new Map<String, Contact>();
    //Swetha-----Acccountcontactrole----list---- 
   // List<AccountContactRole> accContRoleList = new List<AccountContactRole>();
        
    String csiErrorMsg = 'Can not assign as CSI Contact for all branches as another CSI Contact already exists or Contact is assigned as CSI Contact to one or more branches.';
    String maintenanceErrorMsg = 'Can not assign as Maintenance Contact for all branches as another Maintenance Contact already exists or Contact is assigned as Maintenance Contact to one or more branches.';
     
    // for before insert trigger
    // neelima 04/10/2012 added logic to handle dups to conform to unique email requirement by Eloqua
    System.debug('New MAP of contact - ' + Trigger.newMap);
    
    if(trigger.isInsert && trigger.isBefore)
    {       
        DedupUtil.intializeTriggerExecution(Trigger.oldMap, Trigger.newMap);// merge
        DedupUtil.validateForDupOnInsert(trigger.new);
            
    }
    
    // check that no other contact is set as Primary Contact
    if (trigger.isInsert && trigger.isAfter) {
        List<Contact> contactsToUpdate= new List<Contact>();
        // if a primary is being inserted and primary contact id is null set the primary contact id.
        Map<string,Contact> newPrimaryCons= new Map<string,Contact>();
        for (contact c:trigger.new)
        {
            if(c.Is_Duplicate__c==false && c.Email!=null)
            {
        
                newPrimaryCons.put(c.Email,c);
            }
        }
          system.debug('newPrimaryCons' + newPrimaryCons);              
        for(Contact c: [select id,Email,Primary_Contact_Id__c from Contact where Email in :newPrimaryCons.keyset() and Is_Duplicate__c = true and (Primary_Contact_Id__c=null or Primary_Contact_Id__c='')])
        {
            
            system.debug('existing primary' + c);
            
            Contact newCon=newPrimaryCons.get(c.Email);
            system.debug('new contact' + newCon);
            c.Primary_Contact_Id__c=newCon.Id;
            contactsToUpdate.add(c);
                  
        }
        
        // check that only one primary contact is associated per account
        boolean canAssignPrimary = true;
        Map<Id, boolean> primaryContactValidationResult = ContactUtil.validatePrimaryContacts(trigger.newMap, RyderGlobalVariables.PrimaryContactRole.CSI);
        system.debug('Returned results: ' + primaryContactValidationResult);
        for (Id tempId: primaryContactValidationResult.keySet()) {
            if (primaryContactValidationResult.get(tempId) == true) {
                canAssignPrimary = false;
                Trigger.newMap.get(tempId).CSI_Contact_Type__c.addError(csiErrorMsg);                                          
            }
            // mark contact as validated if csi contact type changed
            else if(Trigger.newMap.get(tempId).CSI_Contact_Type__c != null) validatedForKeyContactInsert.put(tempId+ '_'+ RyderGlobalVariables.CSI_ROLE_TEXT,Trigger.newMap.get(tempId));           
        }
        
        Map<Id, boolean> primaryMaintContactValidationResult = ContactUtil.validatePrimaryContacts(trigger.newMap, RyderGlobalVariables.PrimaryContactRole.Maintenance);
        boolean canAssignPrimaryMaint = true;
        for (Id tempId: primaryMaintContactValidationResult.keySet()) {
            if (primaryMaintContactValidationResult.get(tempId) == true) {
                canAssignPrimaryMaint = false;
                Trigger.newMap.get(tempId).Maintenance_Contact_Type__c.addError(maintenanceErrorMsg);
            }
            // mark contact as validated if maint contact type is changed
          else if (Trigger.newMap.get(tempId).Maintenance_Contact_Type__c != null) validatedForKeyContactInsert.put(tempId+ '_'+ RyderGlobalVariables.MAINTENANCE_ROLE_TEXT,Trigger.newMap.get(tempId));
        }
               
        System.debug(LoggingLevel.INFO, '+++++++++++++ validated Contacts:' + validatedForKeyContactInsert);
        // insert all branch key contacts .
        if(!validatedForKeyContactInsert.isEmpty())
        ContactUtil.InsertAllBranchContacts(trigger.newMap,validatedForKeyContactInsert, true); 
        System.debug('contactsToUpdate' + contactsToUpdate);
        // update accounts
        if(contactsToUpdate.size()>0) update contactsToUpdate;
            
    }
        
    // trigger is before update
    if (trigger.isUpdate && trigger.isBefore)
    {
        DedupUtil.intializeTriggerExecution(Trigger.oldMap, Trigger.newMap);// merge
        // 04/06/2012 Neelima- add logic to validate the contact updates to conform to the unique email requirement for Eloqua
        Map<Id,Contact> contactsOkToUpdate= new Map<Id,Contact>();
        //DedupUtil.newContactsMap=trigger.newMap;
        // DedupUtil.oldContactsMap=trigger.oldMap;
        //DedupUtil.oldContactsMap=DedupUtil.currContactsMapToCompare;  // merge
        if(!DedupUtil.doNotCheckForExistingContactEmailDups)
            DedupUtil.validateForDupOnUpdate(DedupUtil.currContactsMapToCompare, DedupUtil.newContactsMap);
            
        contactsOkToUpdate=DedupUtil.contactsOkToUpdate;
                
        /* if csi contact type or maint contact type is changed add to insert list if csi cype or maint type is null before
        add to the update list if the type changed. non null to non null value.
        add to the delete list if the type changed from a non null value to null.
        */
         // check that only one primary contact is associated per account
         // 04/10/2012 Neelima- update the check for key contacts only if all the above validations pass.
        //Map<Id, boolean> primaryCSIContactValidationResult = ContactUtil.validatePrimaryContacts(trigger.newMap, RyderGlobalVariables.PrimaryContactRole.CSI);
        Map<Id, boolean> primaryCSIContactValidationResult = ContactUtil.validatePrimaryContacts(contactsOKToUpdate, RyderGlobalVariables.PrimaryContactRole.CSI);
        boolean canAssignPrimaryCSI = true;
        system.debug('Returned results: ' + primaryCSIContactValidationResult);
        for (Id tempId: primaryCSIContactValidationResult.keySet()) {
                if (primaryCSIContactValidationResult.get(tempId) == true) {
                canAssignPrimaryCSI = false;
                DedupUtil.newContactsMap.get(tempId).CSI_Contact_Type__c.addError(csiErrorMsg);           
            }
            else   // mark contact as validated
            {    system.debug('-----------------tempId:'+tempId);
                 system.debug('-----------------DedupUtil.currContactsMapToCompare:'+DedupUtil.currContactsMapToCompare);
                 system.debug('-----------------Trigger.newMap before key contact Check:'+DedupUtil.newContactsMap);
                 system.debug('-----------------Check 1:'+DedupUtil.currContactsMapToCompare.get(tempId));
                 //system.debug('-----------------Check 2:'+DedupUtil.currContactsMapToCompare.get(tempId).Available_24_7__c);
                 //system.debug('-----------------Check 3:'+DedupUtil.currContactsMapToCompare.get(tempId).Available_From__c);
                 //system.debug('-----------------Check 4:'+DedupUtil.currContactsMapToCompare.get(tempId).Available_To__c);
                 
                // check if any other fields such as availability are updated.
                if(DedupUtil.currContactsMapToCompare.get(tempId) != null) 
                {
                    
                    if( DedupUtil.currContactsMapToCompare.get(tempId).Available_24_7__c !=DedupUtil.newContactsMap.get(tempId).Available_24_7__c
                        ||DedupUtil.currContactsMapToCompare.get(tempId).Available_From__c !=DedupUtil.newContactsMap.get(tempId).Available_From__c
                        || DedupUtil.currContactsMapToCompare.get(tempId).Available_To__c !=DedupUtil.newContactsMap.get(tempId).Available_To__c)
                    {
                         bOtherUpdated=true;
                    }              
                    else
                    { 
                        bOtherUpdated=false;
                    }
                 } 
                 else
                 { 
                    bOtherUpdated=false;
                    continue;
                 }
                 
                 system.debug('-----------------Check bOtherUpdated:'+bOtherUpdated);
                 //system.debug('-----------------Check 5:'+DedupUtil.newContactsMap.get(tempId).CSI_Contact_Type__c);
                 system.debug('-----------------End Check :');
            // add to the validation list only if there is change in csi contact type
                if(bOtherUpdated || (DedupUtil.newContactsMap.get(tempId).CSI_Contact_Type__c!=DedupUtil.currContactsMapToCompare.get(tempId).CSI_Contact_Type__c))
                {
                    if(DedupUtil.currContactsMapToCompare.get(tempId).CSI_Contact_Type__c==null && DedupUtil.newContactsMap.get(tempId).CSI_Contact_Type__c != null)
                             validatedForKeyContactInsert.put(tempId+ '_'+ RyderGlobalVariables.CSI_ROLE_TEXT,DedupUtil.newContactsMap.get(tempId));
                    if(DedupUtil.currContactsMapToCompare.get(tempId).CSI_Contact_Type__c!=null && DedupUtil.newContactsMap.get(tempId).CSI_Contact_Type__c == null)
                             validatedForKeyContactDelete.put(tempId+ '_'+ RyderGlobalVariables.CSI_ROLE_TEXT,DedupUtil.newContactsMap.get(tempId));
                     if((DedupUtil.currContactsMapToCompare.get(tempId).CSI_Contact_Type__c!=null && DedupUtil.newContactsMap.get(tempId).CSI_Contact_Type__c != null) || bOtherUpdated)
                     validatedForKeyContactUpdate.put(tempId+ '_'+ RyderGlobalVariables.CSI_ROLE_TEXT,DedupUtil.newContactsMap.get(tempId));
                }
            }
        }
         // 04/10/2012 Neelima- update the check for key contacts only if all the above validations pass.
       // Map<Id, boolean> primaryMaintContactValidationResult = ContactUtil.validatePrimaryContacts(trigger.newMap, RyderGlobalVariables.PrimaryContactRole.Maintenance);
        Map<Id, boolean> primaryMaintContactValidationResult = ContactUtil.validatePrimaryContacts(contactsOKToUpdate, RyderGlobalVariables.PrimaryContactRole.Maintenance);
        boolean canAssignPrimaryMaint = true;
        for (Id tempId: primaryMaintContactValidationResult.keySet()) {
            if (primaryMaintContactValidationResult.get(tempId) == true) {
                canAssignPrimaryMaint = false;
                DedupUtil.newContactsMap.get(tempId).Maintenance_Contact_Type__c.addError(maintenanceErrorMsg);           
            }
            else   // mark contact as validated
            {
                if(DedupUtil.currContactsMapToCompare.get(tempId) != null) 
                {
                    // check if any other fields such as availability are updated.
                    if( DedupUtil.currContactsMapToCompare.get(tempId).Available_24_7__c !=DedupUtil.newContactsMap.get(tempId).Available_24_7__c
                        || DedupUtil.currContactsMapToCompare.get(tempId).Available_From__c !=DedupUtil.newContactsMap.get(tempId).Available_From__c
                        || DedupUtil.currContactsMapToCompare.get(tempId).Available_To__c !=DedupUtil.newContactsMap.get(tempId).Available_To__c)
                    {
                        bOtherUpdated=true; 
                    }
                    else{bOtherUpdated=false;}
                    // add to the validation list only if there is change in csi contact type
                    if(DedupUtil.newContactsMap.get(tempId).Maintenance_Contact_Type__c!=DedupUtil.currContactsMapToCompare.get(tempId).Maintenance_Contact_Type__c || bOtherUpdated)
                    {
                        system.debug('-----------------Inside CSI Contact check:');
                        if(DedupUtil.currContactsMapToCompare.get(tempId).Maintenance_Contact_Type__c==null && DedupUtil.newContactsMap.get(tempId).Maintenance_Contact_Type__c != null)
                                 validatedForKeyContactInsert.put(tempId+ '_'+RyderGlobalVariables.MAINTENANCE_ROLE_TEXT,DedupUtil.newContactsMap.get(tempId));
                        if(DedupUtil.currContactsMapToCompare.get(tempId).Maintenance_Contact_Type__c!=null && DedupUtil.newContactsMap.get(tempId).Maintenance_Contact_Type__c == null)
                                 validatedForKeyContactDelete.put(tempId+ '_'+ RyderGlobalVariables.MAINTENANCE_ROLE_TEXT,DedupUtil.newContactsMap.get(tempId));
                         if((DedupUtil.currContactsMapToCompare.get(tempId).Maintenance_Contact_Type__c!=null && DedupUtil.newContactsMap.get(tempId).Maintenance_Contact_Type__c != null) || bOtherUpdated)
                         validatedForKeyContactUpdate.put(tempId+ '_'+ RyderGlobalVariables.MAINTENANCE_ROLE_TEXT,DedupUtil.newContactsMap.get(tempId));
                    }
                }
                else {continue;}
            }
            
        } 
        System.debug(LoggingLevel.INFO, '+++++++++++++ validated Contacts for delete' + validatedForKeyContactDelete);
        System.debug(LoggingLevel.INFO, '+++++++++++++ validated Contacts for Insert' + validatedForKeyContactInsert);
        System.debug(LoggingLevel.INFO, '+++++++++++++ validated Contacts for Update' + validatedForKeyContactUpdate);
               
        // insert all branch key contacts .
        if(!validatedForKeyContactInsert.isEmpty())
        ContactUtil.InsertAllBranchContacts(DedupUtil.newContactsMap,validatedForKeyContactInsert, false);
        // update all branch key contacts
        if(!validatedForKeyContactUpdate.isEmpty())
        ContactUtil.UpdateAllBranchContacts(DedupUtil.newContactsMap, validatedForKeyContactUpdate);
          // delete all branch key contacts.
         if(!validatedForKeyContactDelete.isEmpty())
         ContactUtil.DeleteAllBranchContacts(DedupUtil.newContactsMap, validatedForKeyContactDelete);
    } 
     
   //  if(!accContRoleList.isEmpty())  
     //   insert accContRoleList;
}