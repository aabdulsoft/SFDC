public with sharing class ContactUtil {

       public static boolean isDeleteFromTrigger {set; get;}
       public static boolean isAllBranchInsUpd {set; get;}
       public static Map<String, Id> keyContactRecordTypes;
       public static Map<string,List<String>>addrFieldMap= new Map<string,List<String>>{'Default'=>new List<String>{'Street', 'City', 'State', 'PostalCode', 'Country'},'Marketing_'=> new List<String>{'Street__c', 'City__c', 'State__c', 'Zip__c', 'Country__c'}};
       
       

    /*
    * check that only one contact is associated as primary contact
    */
    // update by Neelima for key contact rewrite-06/30/2011
    public static Map<Id, boolean> validatePrimaryContacts(Map<Id, Contact> updatedContacts, RyderGlobalVariables.PrimaryContactRole contactRole) {
        System.debug(LoggingLevel.INFO, '+++++++++++++ updatedContacts' + updatedContacts);
              
        Map<Id, boolean> result = new Map<Id, boolean>();
        
        
        List<Id> accountIds = new List<Id>();
        List<String> account15Ids = new List<String>();
        Map<String, String> accountContactIds = new Map<String,String>();
       // Map<String, Id> keyContactIds = new Map<String,Id>();
        Map<String, Key_Contact__c> kc = new Map<String,Key_Contact__c>();
        
        if(updatedContacts!=null){
        for (Contact temp : updatedContacts.values()) {
              accountIds.add(temp.HQ_Account_Id_18__c);
              account15Ids.add(temp.HQ_Account_Id__c);
              result.put(temp.Id, false);
        }
            }
            
        // this same contact cannot be tied to any branches in keyContact with same role.
        List<Key_Contact__c> otherKeyContacts = null;
        
        /*
            Nitin: Commenting as the below query is giving Non selective exception
        if (contactRole == RyderGlobalVariables.PrimaryContactRole.CSI) 
        {
            otherKeyContacts = [Select k.Id, k.HQ_Account_ID__c, k.Customer_Branch__c, k.Contact__c, k.Contact_Type__c, k.Contact_Role__c
                    From Key_Contact__c k where k.HQ_Account_ID__c in: account15Ids and k.Contact_Role__c =: RyderGlobalVariables.CSI_ROLE_TEXT];
        }
        if (contactRole == RyderGlobalVariables.PrimaryContactRole.Maintenance) {
             otherKeyContacts = [Select k.Id, k.HQ_Account_ID__c, k.Customer_Branch__c, k.Contact__c, k.Contact_Type__c, k.Contact_Role__c
                    From Key_Contact__c k where k.HQ_Account_ID__c in: account15Ids and k.Contact_Role__c =: RyderGlobalVariables.MAINTENANCE_ROLE_TEXT];
        }
        */        
        
        if (otherKeyContacts != null) {
            System.debug(LoggingLevel.INFO, '+++++++++++++ otherKeyContacts ' + otherKeyContacts );
            for (Key_Contact__c otherKeyContact: otherKeyContacts) {
               // keyContactIds.put(otherKeyContact.HQ_Account_ID__c + '_' + otherKeyContact.Contact_Type__c , otherKeyContact.Id); 
                kc.put(otherKeyContact.HQ_Account_ID__c + '_' + otherKeyContact.Contact_Type__c , otherKeyContact);  
            }
        } 

       // System.debug(LoggingLevel.INFO, '+++++++++++++ keyContactIds ' + keyContactIds );
        if(updatedContacts !=null){
        for (Contact temp : updatedContacts.values()) {
            System.debug(LoggingLevel.INFO, 'temp.CSI_Contact_Type__c: ' + temp);
            if (contactRole == RyderGlobalVariables.PrimaryContactRole.CSI) {
                if (temp.CSI_Contact_Type__c != null) {
                   // Id otherKeyContactId = keyContactIds.get(temp.HQ_Account_Id__c + '_' + temp.CSI_Contact_Type__c);
                   Key_Contact__c kcExisting = kc.get(temp.HQ_Account_Id__c + '_' + temp.CSI_Contact_Type__c);
                    if (kcExisting != null && kcExisting.Contact__c!=temp.Id) {
                        System.debug(LoggingLevel.INFO, 'Inside validatePrimaryContacts:  kcExisting1:' + kcExisting);
                        result.put(temp.Id, true);
                    }
                }
            }
           
            if (contactRole == RyderGlobalVariables.PrimaryContactRole.Maintenance) {
                if (temp.Maintenance_Contact_Type__c != null) {
                  //  Key_Contact__c kcExisting = keyContactIds.get(temp.HQ_Account_Id__c + '_' + temp.Maintenance_Contact_Type__c);
                  Key_Contact__c kcExisting = kc.get(temp.HQ_Account_Id__c + '_' + temp.Maintenance_Contact_Type__c);
                    if (kcExisting != null && kcExisting.Contact__c!=temp.Id) {
                        System.debug(LoggingLevel.INFO, 'Inside validatePrimaryContacts:  kcExisting2:' + kcExisting);
                        result.put(temp.Id, true);
                    }
                }
            }
        }
        }
        System.debug(LoggingLevel.INFO, '+++++++++++++ updated result:' + result); 
        return result;
    }
       
    // Not in use any more after key contact rewrite. this validation is replaced by the new code in the trigger itself.- Neelima.
   
 /*   public static Map<Id, String> validateKeyContactsOld(Map<Id, Key_Contact__c> updatedKeyContacts, RyderGlobalVariables.PrimaryContactRole contactRole) {

        System.debug(LoggingLevel.INFO, '+++++++++++++ updatedKeyContacts' + updatedKeyContacts);
        
        List<Id> contactIds = new List<Id>();
        List<Id> customerBranchIds = new List<Id>();
               
        Map<Id, String> result = new Map<Id, String>();
        Map<String, Id> contactToKeyContactMap = new Map<String,Id>();
        Map<String, Id> primaryContactTypeToCustomerBranchMap = new Map<String,Id>();
        
        for (Key_Contact__c temp : updatedKeyContacts.values()) {
            
              contactIds.add(temp.Contact__c);
              customerBranchIds.add(temp.Customer_Branch__c);
              result.put(temp.Id, '0:0:0');
        }        
        System.debug(LoggingLevel.INFO, '+++++++++++++ contactIds' + contactIds);
        //check if this contact is associated to same branch as primary/secondary/tertiary for same role
        List<Key_Contact__c> otherKeyContacts = null;
        List<Key_Contact__c> primaryKeyContacts = null;
        if (contactRole == RyderGlobalVariables.PrimaryContactRole.CSI) {
            otherKeyContacts = [Select k.Id, k.Customer_Branch__c, k.Contact__c, k.Contact_Type__c, k.Contact_Role__c From Key_Contact__c k
                where k.Contact__c in: contactIds and k.Id not in: updatedKeyContacts.keySet() and k.Contact_Role__c =: RyderGlobalVariables.CSI_ROLE_TEXT];
            primaryKeyContacts = [Select k.Id, k.Customer_Branch__c, k.Contact__c, k.Contact_Type__c, k.Contact_Role__c From Key_Contact__c k
                where k.Customer_Branch__c in: customerBranchIds and k.Id not in: updatedKeyContacts.keySet() and k.Contact_Type__c != null and k.Contact_Role__c =: RyderGlobalVariables.CSI_ROLE_TEXT];
        }
        
        if (contactRole == RyderGlobalVariables.PrimaryContactRole.Maintenance) {
            otherKeyContacts = [Select k.Id, k.Customer_Branch__c, k.Contact__c, k.Contact_Type__c, k.Contact_Role__c From Key_Contact__c k
                where k.Contact__c in: contactIds and k.Id not in: updatedKeyContacts.keySet() and k.Contact_Role__c =: RyderGlobalVariables.MAINTENANCE_ROLE_TEXT];
            primaryKeyContacts = [Select k.Id, k.Customer_Branch__c, k.Contact__c, k.Contact_Type__c, k.Contact_Role__c From Key_Contact__c k
                where k.Customer_Branch__c in: customerBranchIds and k.Id not in: updatedKeyContacts.keySet() and k.Contact_Type__c != null and k.Contact_Role__c =: RyderGlobalVariables.MAINTENANCE_ROLE_TEXT];
        }
        
        if (contactRole == RyderGlobalVariables.PrimaryContactRole.Billing) {
            otherKeyContacts = [Select k.Id, k.Customer_Branch__c, k.Contact__c, k.Contact_Type__c, k.Contact_Role__c From Key_Contact__c k
                where k.Contact__c in: contactIds and k.Id not in: updatedKeyContacts.keySet() and k.Contact_Role__c =: RyderGlobalVariables.BILLING_ROLE_TEXT];
            primaryKeyContacts = [Select k.Id, k.Customer_Branch__c, k.Contact__c, k.Contact_Type__c, k.Contact_Role__c From Key_Contact__c k
                where k.Customer_Branch__c in: customerBranchIds and k.Id not in: updatedKeyContacts.keySet() and k.Contact_Type__c = 'Primary' and k.Contact_Role__c =: RyderGlobalVariables.BILLING_ROLE_TEXT];
        }
        
        System.debug(LoggingLevel.INFO, '+++++++++++++ otherKeyContacts ' + otherKeyContacts );
        if (otherKeyContacts != null) {
            for (Key_Contact__c otherKeyContact: otherKeyContacts) {
                contactToKeyContactMap.put(otherKeyContact.Contact__c + '_' + otherKeyContact.Contact_Type__c, otherKeyContact.Id);     
            }
        }        
        System.debug(LoggingLevel.INFO, '+++++++++++++ primaryKeyContacts ' + primaryKeyContacts );
        if (primaryKeyContacts != null) {
            for (Key_Contact__c primaryKeyContact: primaryKeyContacts) {
                primaryContactTypeToCustomerBranchMap.put(primaryKeyContact.Contact_Type__c + '_' + primaryKeyContact.Contact_Role__c + '_' + primaryKeyContact.Customer_Branch__c, primaryKeyContact.Id);     
            }
        }
        System.debug(LoggingLevel.INFO, '+++++++++++++ contactToKeyContactMap ' + contactToKeyContactMap );
        System.debug(LoggingLevel.INFO, '+++++++++++++ primaryContactTypeToCustomerBranchMap ' + primaryContactTypeToCustomerBranchMap );
        
        // CHECK if there are no other primary contact at account level for customer branch
        List<Contact> contactList = [select c.Id, c.accountId, c.HQ_Account_Id_18__c from Contact c where c.id in: contactIds];
        Map<Id,Id> contactToAccountMap = new Map<Id, Id>();
        Map<Id,String> accountToContactTypeMap = new Map<Id,String>();
        List<Id> accountIds = new List<Id>();
        if (contactList != null) {
            for(Contact temp: contactList) {
                //accountIds.add(temp.accountId);
                accountIds.add(temp.HQ_Account_Id_18__c);
                contactToAccountMap.put(temp.Id,temp.HQ_Account_Id_18__c);
            }
        }
        
        // get list of all contactIds that are associated at all branches level.
        List<Contact> primaryContactList = null;
        if (contactRole == RyderGlobalVariables.PrimaryContactRole.CSI) {
            primaryContactList = [select c.accountId, c.Id, c.HQ_Account_Id_18__c, c.CSI_Contact_Type__c from contact c where c.HQ_Account_Id_18__c in: accountIds and c.CSI_Contact_Type__c !=null];
        }
        if (contactRole == RyderGlobalVariables.PrimaryContactRole.Maintenance) {
            primaryContactList = [select c.accountId, c.Id, c.HQ_Account_Id_18__c, c.Maintenance_Contact_Type__c from contact c where c.HQ_Account_Id_18__c in: accountIds and c.Maintenance_Contact_Type__c != null];
        }
        
        System.debug(LoggingLevel.INFO, '+++++++++++++ primaryContactList ' + primaryContactList );
        if (primaryContactList != null) {
            for(Contact temp: primaryContactList) {
                String tempContactRoleType = accountToContactTypeMap.get(temp.HQ_Account_Id_18__c); 
                if (tempContactRoleType != null) {
                    if (contactRole == RyderGlobalVariables.PrimaryContactRole.CSI) {
                       tempContactRoleType = tempContactRoleType + ':' + temp.CSI_Contact_Type__c; 
                    }
                    if (contactRole == RyderGlobalVariables.PrimaryContactRole.Maintenance) {
                       tempContactRoleType = tempContactRoleType + ':' + temp.Maintenance_Contact_Type__c;  
                    }
                    accountToContactTypeMap.put(temp.HQ_Account_Id_18__c, tempContactRoleType);
                } else {
                    if (contactRole == RyderGlobalVariables.PrimaryContactRole.CSI) {
                       accountToContactTypeMap.put(temp.HQ_Account_Id_18__c, temp.CSI_Contact_Type__c);
                    }
                    if (contactRole == RyderGlobalVariables.PrimaryContactRole.Maintenance) {
                       accountToContactTypeMap.put(temp.HQ_Account_Id_18__c, temp.Maintenance_Contact_Type__c);  
                    }
                }
            }
        }
        
        System.debug(LoggingLevel.INFO, '+++++++++++++ accountToContactTypeMap ' + accountToContactTypeMap );
        for (Key_Contact__c temp : updatedKeyContacts.values()) {
             if (contactRole == RyderGlobalVariables.PrimaryContactRole.CSI) {
                String tempResult = '0:0:0';
                String error1 = '0';
                String error2 = '0';
                String error3 = '0';
                if (temp.Contact_Role__c == RyderGlobalVariables.CSI_ROLE_TEXT) {
                    Id otherKeyContactId = contactToKeyContactMap.get(temp.Contact__c + '_' + temp.Contact_Type__c);
                    if (otherKeyContactId != null) {
                        // tempResult = '1:0:0';
                        error1 = '1';
                    }
                    Id accountId = contactToAccountMap.get(temp.Contact__c);
                    System.debug(LoggingLevel.INFO, '+++++++++++++ accountId ' + accountId );
                    String otherAllBranchContactTypes = accountToContactTypeMap.get(accountId);
                    System.debug(LoggingLevel.INFO, '+++++++++++++ otherAllBranchContactTypes :' + otherAllBranchContactTypes );
                    if (otherAllBranchContactTypes != null && otherAllBranchContactTypes.contains(temp.Contact_Type__c)) {
                        error2 = '1';
                       // if (tempResult == '1:0:0') {
                      //      tempResult = '1:1:0';
                       // } else {
                       //     tempResult = '0:1:0';
                      //  }
                      
                    }
                    Id otherPrimaryKeyContactId = primaryContactTypeToCustomerBranchMap.get(temp.Contact_Type__c + '_' + temp.Contact_Role__c + '_' + temp.Customer_Branch__c);
                    System.debug(LoggingLevel.INFO, '+++++++++++++ CSI otherPrimaryKeyContactId ' + otherPrimaryKeyContactId);
                    if (otherPrimaryKeyContactId != null) {
                        error3 = '1';
                    }
                    tempResult = error1 + ':' + error2 + ':' + error3;                      
                    result.put(temp.Id, tempResult);
                    System.debug(LoggingLevel.INFO, '+++++++++++++ CSI result ' + result);
                }
            }
            if (contactRole == RyderGlobalVariables.PrimaryContactRole.Maintenance) {
                String tempResult = '0:0:0';
                String error1 = '0';
                String error2 = '0';
                String error3 = '0';
                if (temp.Contact_Role__c == RyderGlobalVariables.MAINTENANCE_ROLE_TEXT) {
                    Id otherKeyContactId = contactToKeyContactMap.get(temp.Contact__c + '_' + temp.Contact_Type__c);
                    if (otherKeyContactId != null) {
                        //tempResult = '1:0:0';
                        error1 = '1';
                    }
                    Id accountId = contactToAccountMap.get(temp.Contact__c);
                    System.debug(LoggingLevel.INFO, '+++++++++++++ accountId ' + accountId );
                    String otherAllBranchContactTypes = accountToContactTypeMap.get(accountId);
                    System.debug(LoggingLevel.INFO, '+++++++++++++ temp.Contact_Type__c ' + temp.Contact_Type__c );
                    System.debug(LoggingLevel.INFO, '+++++++++++++ otherAllBranchContactTypes :' + otherAllBranchContactTypes );
                    if (otherAllBranchContactTypes != null && otherAllBranchContactTypes.contains(temp.Contact_Type__c)) {
                        //if (tempResult == '1:0:0') {
                         //   tempResult = '1:1:0';
                       // } else {
                       //     tempResult = '0:1:0';
                      //  }
                    
                        error2 = '1';
                    }      
                    Id otherPrimaryKeyContactId = primaryContactTypeToCustomerBranchMap.get(temp.Contact_Type__c + '_' + temp.Contact_Role__c + '_' + temp.Customer_Branch__c);
                    if (otherPrimaryKeyContactId != null) {
                        error3 = '1';
                    }
                    tempResult = error1 + ':' + error2 + ':' + error3;
                    result.put(temp.Id, tempResult);
                    System.debug(LoggingLevel.INFO, '+++++++++++++ Maintenance result ' + result);
                }
            }
            if (contactRole == RyderGlobalVariables.PrimaryContactRole.Billing) {
                String tempResult = '0:0:0';
                String error1 = '0';
                String error2 = '0';
                String error3 = '0';
                if (temp.Contact_Role__c == RyderGlobalVariables.BILLING_ROLE_TEXT) {
                    Id otherKeyContactId = contactToKeyContactMap.get(temp.Contact__c + '_' + temp.Contact_Type__c);
                    if (otherKeyContactId != null) {
                        //tempResult = '1:0:0';
                        error1 = '1';
                    }
                    Id otherPrimaryKeyContactId = primaryContactTypeToCustomerBranchMap.get(temp.Contact_Type__c + '_' + temp.Contact_Role__c + '_' + temp.Customer_Branch__c);
                    if (otherPrimaryKeyContactId != null) {
                        error3 = '1';
                    }
                    tempResult = error1 + ':' + error2 + ':' + error3;
                    result.put(temp.Id, tempResult);
                    System.debug(LoggingLevel.INFO, '+++++++++++++ Billing result ' + result);
                }
            }
        }
        
        System.debug(LoggingLevel.INFO, '+++++++++++++ updated result:' + result); 
        return result;
    }*/
    
     //added for key contacts rewrite- neelima              
    public static void InsertAllBranchContacts(Map<Id, Contact> newMap, Map<String, Contact> Contacts, boolean bAfterInsTrigger)
    {
        isAllBranchInsUpd=true;
         Map<String , Key_Contact__c> KeyContactsToInsert= new Map<String,Key_Contact__c>();
         List<Contact> contactsToUpdate= new List<Contact>();
         Key_Contact__c keyContact=null;
         List<Contact> inputContacts= new List<Contact>();
         Map<Id,Id> contactParentIds= new Map<Id,Id>();
         Contact c=null;
         Map<Id,Contact> ContactsAfterInsert= new Map<Id,Contact>();
         // updated null check to avoid un necessary soql calls- neelima-09/26/2011
         if(keyContactRecordTypes==null) keyContactRecordTypes=CommonFunctions.getRecordTypeMap('Key_Contact__c');
           // if request comes from a update trigger values are editable else they are read only
         inputContacts=[Select contact.account.ParentId,c.AccountId, c.Available_24_7__c, c.Available_From__c, c.Available_To__c, c.CSI_Contact_Type__c, HQ_Account_Id_18__c,c.Id, c.Maintenance_Contact_Type__c, c.Original_Account__c, c.Contact_Trigger_Toggle__c from Contact c, contact.account where c.Id in :newMap.keySet()];
         for(Contact con: inputContacts)
         {
         if(bAfterInsTrigger) ContactsAfterInsert.put(con.Id,con);
         else contactParentIds.put(con.Id,con.account.ParentId);
         }
         
        for (Id tempId : newMap.keySet()) 
        {   
            if(bAfterInsTrigger) c=ContactsAfterInsert.get(tempId); 
            else 
            c= newMap.get(tempId);
             // get all the customer branches for the  hq account id on the contact. 
                 List<Customer_Branch__c>branches = [Select cb.Id, cb.Ryder_HQ_Account__c from Customer_Branch__c cb where  cb.Ryder_HQ_Account__c = :c.HQ_Account_Id_18__c]; //and cb.Customer_Branch_Status__c = :'Active'
                 // for each branch create a key Contact.
                 for (Customer_Branch__c  cb : branches)
                 {                                       
                 // create a csi key contact if csi contact type is selected.   
                    if(Contacts.containsKey(tempId+'_'+RyderGlobalVariables.CSI_ROLE_TEXT)) 
                    {
                    keyContact= CreateNewKeyContact(c,cb,RyderGlobalVariables.CSI_ROLE_TEXT,true);//'CSI Contact'
                    KeyContactsToInsert.put(cb.id+'-'+'CSI', keyContact);
                    }
                 // create a maint key contact if maint contact type is selected.
                  if(Contacts.containsKey(tempId+'_'+RyderGlobalVariables.MAINTENANCE_ROLE_TEXT)) 
                    {
                     keyContact= CreateNewKeyContact(c,cb,RyderGlobalVariables.MAINTENANCE_ROLE_TEXT,true);
                     KeyContactsToInsert.put(cb.id+'-'+'Maint',keyContact);
                    }               
                 } 
                        if(bAfterInsTrigger) MoveContactToParent(c); else MoveContactToParent(c,contactParentIds.get(c.Id));
                        if (bAfterInsTrigger) contactsToUpdate.add(c);      
        }
        System.debug(LoggingLevel.INFO, '+++++++++++++ InsertAllBranchContacts-Key Contact To Insert:' + KeyContactsToInsert);
        
        if(!KeyContactsToInsert.isEmpty()) insert KeyContactsToInsert.values();
        // update the contacts only if this called from insert trigger. If called from an update trigger it is automatically taken care of 
        if(bAfterInsTrigger && !contactsToUpdate.isEmpty()) update contactsToUpdate;            
    }
      // added for key contacts rewrite project- neelima-
    public static void MoveContactToParent(Contact c)
    {
      c.Contact_Trigger_Toggle__c= !c.Contact_Trigger_Toggle__c;
        c.Added_As_Key_Contact__c=true;
        System.debug(LoggingLevel.INFO, '+++++++++++++ MoveContactToParent-Contact :' + c);
        System.debug(LoggingLevel.INFO, '+++++++++++++ MoveContactToParent-c.Account.ParentId:' + c.Account.ParentId);
       // don't do anything if account id is already a parent account
        if(c.Account.ParentId==null) return;
        /* if a contact is from child account update original account id to contact corresponding to parent id of the
             child account and populate original account id with Child id. If contact is from parent account update original 
             account id with child account id.
             */
                c.Original_Account__c=c.AccountId; 
              c.AccountId= (c.Account.ParentId !=null) ?  c.Account.ParentId : c.AccountId;
                        
    }
    // added for key contacts rewrite project- neelima-
     public static void MoveContactToParent(Contact c, Id ParentId)
    {
        c.Contact_Trigger_Toggle__c= !c.Contact_Trigger_Toggle__c;
        c.Added_As_Key_Contact__c=true;
         System.debug(LoggingLevel.INFO, '+++++++++++++ MoveContactToParent-Contact :' + c);
         System.debug(LoggingLevel.INFO, '+++++++++++++ MoveContactToParent-ParentId:' + ParentId);
        // don't do anything if account id is already a parent account
        if(ParentId==null) return;
        /* if a contact is from child account update original account id to contact corresponding to parent id of the
             child account and populate original account id with Child id. If contact is from parent account update original 
             account id with child account id.
             */
              //  c.Original_Account__c=c.AccountId; 
                //c.AccountId= (ParentId !=null) ? ParentId : c.AccountId;
                        
    }
    /*----Swetha---commented out-----
    // added for key contacts rewrite project- neelima-
     public static void MoveContactToChild(Contact c)
    {
        c.Contact_Trigger_Toggle__c= !c.Contact_Trigger_Toggle__c;
        c.Added_As_Key_Contact__c=false;
        if(c.Original_Account__c==null) return;
        System.debug(LoggingLevel.INFO, '+++++++++++++ Inside MoveContactToChild- Contact c:' + c);     
        /* if a contact is from child account update  account id to original account id()
             child account and populate original account id with Child id. If contact is from parent account update original 
             account id with child account id.
             */
             /*
                c.AccountId=c.Original_Account__c; 
                c.Original_Account__c=null;
             
                        
    }
    */
    
     //added for key contacts rewrite- neelima
    public static Key_Contact__c CreateNewKeyContact(Contact c, Customer_Branch__c cb, string Role, boolean ballBranch)
    {
                    Key_Contact__c keyContact= new Key_Contact__c();
                    // if it is an all branch key contact set the record type to All branch Contact
                    if(ballBranch) keyContact.RecordTypeId=keyContactRecordTypes.get('All_branch_Contact'); 
                    keyContact.All_Branch_Contact__c=ballBranch;
                    keyContact.Available_24_7__c= c.Available_24_7__c;
                    keyContact.Available_From__c=c.Available_From__c;
                    keyContact.Available_To__c=c.Available_To__c;
                    keyContact.Contact__c=c.Id;
                    keyContact.Customer_Branch__c=cb.Id;
                    keyContact.Contact_Role__c=role; //'CSI Contact'
                    if (role==RyderGlobalVariables.CSI_ROLE_TEXT)keyContact.Contact_Type__c=c.CSI_Contact_Type__c;
                    else if(role==RyderGlobalVariables.MAINTENANCE_ROLE_TEXT) keyContact.Contact_Type__c=c.Maintenance_Contact_Type__c;
                    
                    return keyContact;
                    
    
    }
    
     //added for key contacts rewrite- neelima
    public static void UpdateAllBranchContacts(Map<Id, Contact> newMap,Map<String, Contact> Contacts)
    {
       //  public string id;
        isAllBranchInsUpd=true;
       
        List<Key_Contact__c> keyContacts= new List<Key_Contact__c>(); 
        Contact c=null;
        // get all the keycontacts for the contact ids
        keyContacts=[Select k.All_Branch_Contact__c, k.Available_24_7__c, k.Available_From__c, k.Available_To__c, k.Contact__c, k.Contact_Role__c, k.Contact_Type__c, k.Customer_Branch__c, k.HQ_Account_ID__c, k.Id, k.Contact_Trigger_Toggle__c from Key_Contact__c k where k.Contact__c in :newMap.keySet() and k.All_Branch_Contact__c=true];
        
        // get the keycontacts where a contact type is updated from a non null value to non null ( eg: primary to secondary)  value but for  some reason not in key contact table yet.
        // to do later
        Set<Id> contIdSet = new Set<Id>(); 
        for(Key_Contact__c kc : keyContacts)
        {
            contIdSet.add(kc.Contact__c);
            c= newMap.get(kc.Contact__c);
            kc.Available_24_7__c=c.Available_24_7__c;
            kc.Available_From__c=c.Available_From__c;
            kc.Available_To__c=c.Available_To__c;
            // toggle the flag to identify that this update is coming from a contact trigger.
            kc.Contact_Trigger_Toggle__c= (!kc.Contact_Trigger_Toggle__c);
            
            // if this is a csi contact and CSI role is updated for that contact
            if(kc.Contact_Role__c==RyderGlobalVariables.CSI_ROLE_TEXT && Contacts.containsKey(kc.Contact__c+'_'+ RyderGlobalVariables.CSI_ROLE_TEXT))
            kc.Contact_Type__c=c.CSI_Contact_Type__c;
                       
            else if(kc.Contact_Role__c==RyderGlobalVariables.MAINTENANCE_ROLE_TEXT && Contacts.containsKey(kc.Contact__c+'_'+ RyderGlobalVariables.MAINTENANCE_ROLE_TEXT))
            kc.Contact_Type__c=c.Maintenance_Contact_Type__c;
                                    
        } 
        System.debug(LoggingLevel.INFO, '+++++++++++++ Inside UpdateAllBranchContacts- Key Contact To be updated:' + keyContacts);
        update keyContacts; 
         List<Key_Contact__c> newKeyContList = new List<Key_Contact__c>();
         for(Contact con: newMap.values()) {
             if(!contIdSet.contains(con.Id)) {
                 Key_Contact__c kc = new Key_Contact__c();
                 if(kc.Available_24_7__c!= null) {
                 kc.Available_24_7__c=c.Available_24_7__c;
                 kc.Available_From__c=c.Available_From__c;
                 kc.Available_To__c=c.Available_To__c;
                 kc.Contact_Type__c=c.CSI_Contact_Type__c;
                 newKeyContList.add(kc);
             }
         }
         }
         if(!newKeyContList.isEmpty())
             insert newKeyContList;
      /*
      //  for(Key_Contact__c kc : keyContacts)  
        list<Customer_branch__c> Custbranch=new list<Customer_branch__c>();

        custbranch=[SELECT id FROM customer_branch__c WHERE id NOT IN (SELECT customer_branch__c FROM key_contact__c)];
        for(Key_Contact__c kc : custbranch)
        
       // for(contact cont:custbranch)

        {
            kc.Available_24_7__c=c.Available_24_7__c;
            kc.Available_From__c=c.Available_From__c;
            kc.Available_To__c=c.Available_To__c;
            kc.Contact_Type__c=c.CSI_Contact_Type__c;


         if(kc.Contact_Role__c==RyderGlobalVariables.CSI_ROLE_TEXT && Contacts.containsKey(kc.Contact__c+'_'+ RyderGlobalVariables.CSI_ROLE_TEXT))
            kc.Contact_Type__c=c.CSI_Contact_Type__c;
                       
            else if(kc.Contact_Role__c==RyderGlobalVariables.MAINTENANCE_ROLE_TEXT && Contacts.containsKey(kc.Contact__c+'_'+ RyderGlobalVariables.MAINTENANCE_ROLE_TEXT))
            kc.Contact_Type__c=c.Maintenance_Contact_Type__c;
                                    
}
        insert keyContacts;
        
      */     
    
    }
    
    //added for key contacts rewrite- neelima
     public static void DeleteAllBranchContacts(Map<Id, Contact> newMap,Map<String, Contact> Contacts)
     {
        List<Key_Contact__c> keyContactsToDelete= new List<Key_Contact__c>();
        List<Key_Contact__c> keyContacts= new List<Key_Contact__c>(); 
        
        // get all the keycontacts for the contact ids
        keyContacts=[Select k.All_Branch_Contact__c, k.Available_24_7__c, k.Available_From__c, k.Available_To__c, k.Contact__c, k.Contact_Role__c, k.Contact_Type__c, k.Customer_Branch__c, k.HQ_Account_ID__c, k.Id,k.Contact_Trigger_Toggle__c from Key_Contact__c k where k.Contact__c in :newMap.keySet()];
        // if this method is called from a delete trigger Contacts will be null. In that case delete all key contacts.
        // If this method is called from a update trigger Contacts will have values.Delete only those key contacts that exist in Contacts.
        if(Contacts==null)
        {
            // set the flag to identify that this delete is coming from a contact trigger.
            for(Key_Contact__c kc : keyContacts ) isDeleteFromTrigger= true;
            System.debug(LoggingLevel.INFO, '+++++++++++++ DeleteAllBranchContacts- keyContactsToDelete1:' + keyContacts);
        delete keyContacts;
        }
        else
        {
                for(Key_Contact__c kc : keyContacts)
        {
            // set the flag to identify that this delete is coming from a contact trigger.
            isDeleteFromTrigger= true;
            // if this is a csi contact and is in the deleted list or if this is a maint contact and is in the deleted list
            if((kc.All_Branch_Contact__c && kc.Contact_Role__c==RyderGlobalVariables.CSI_ROLE_TEXT && Contacts.containsKey(kc.Contact__c+'_'+ RyderGlobalVariables.CSI_ROLE_TEXT)) ||
             (kc.All_Branch_Contact__c && kc.Contact_Role__c==RyderGlobalVariables.MAINTENANCE_ROLE_TEXT && Contacts.containsKey(kc.Contact__c+'_'+ RyderGlobalVariables.MAINTENANCE_ROLE_TEXT))
              )
             keyContactsToDelete.add(kc);           
        }
        System.debug(LoggingLevel.INFO, '+++++++++++++ DeleteAllBranchContacts- keyContactsToDelete2:' + keyContactsToDelete);
        delete keyContactsToDelete;
        }
        // if this method is called from a update trigger update the contact account id and original account id based on if any key contacts exist.
          //if(Contacts==null)deletedContactIds.addAll(newMap.keySet());
          //  if(Contacts!=null) MoveContactsAfterKeyContactDelete(Contacts.values());   
          // updated by Neelima-09/26/2011
           if(Contacts!=null)  MoveContactsAfterAllBranchContactUpdate(Contacts.values());         
     }
        // added for key contacts rewrite project- neelima-07/08/2011
        public static void MoveContactsAfterKeyContactDelete(List<Id> deletedContactIds)
        {
        
                       List<Id>deletedIdsupdated= new List<id>();
                       List<Contact>contactsToUpdate= new List<Contact>();
                       Map<Id,Id>keyContacts= new Map<Id,Id>();
         System.debug(LoggingLevel.INFO, '+++++++++++++ Inside MoveContactsAfterKeyContactDelete- deletedContactIds:' + deletedContactIds);             
         List<Key_Contact__c> existingKeyContacts= [Select Id,Contact__c  from Key_Contact__c where Contact__c in :deletedContactIds];
    
               // see if the contacts have any more key contacts existing.
           for(Key_Contact__c kcon: existingKeyContacts)
                {
                if(keyContacts.get(kcon.Contact__c)==null) keyContacts.put(kcon.Contact__c,kcon.Id);    
                }
            for(Id id:deletedContactIds){
            // if there are no more key contacts for this contact add it to the updated list
            if(keyContacts.get(id)==null) deletedIdsupdated.add(id);
            }
                // move the contact to the child for all the contacts from the updated list
              //  System.debug(LoggingLevel.INFO, '+++++++++++++ Inside MoveContactsAfterKeyContactDelete- contactsToUpdate:' + contactsToUpdate);
            //    contactsToUpdate=[Select c.AccountId, c.Id, c.Original_Account__c,c.Contact_Trigger_Toggle__c from Contact c where id in :deletedIdsupdated];
           //  for(Contact c: contactsToUpdate)
           //     ContactUtil.MoveContactToChild(c);
          
          update contactsToUpdate;
        }
        // added for key contacts rewrite project- neelima-07/08/2011
        public static void MoveContactsAfterKeyContactDelete(List<Contact> Contacts)
        {
            //List<Id>deletedContactIds=new List<id>();
            Map<Id,Contact>deletedContacts=new Map<Id,Contact>();
            Map<Id,Id>keyContacts= new Map<Id,Id>();
            Map<Id,Id> ContactsToChild= new Map<Id,Id>();
           
                        for(Contact c : Contacts)
              // deletedContactIds.add(c.Id);
              if(deletedContacts.get(c.Id)==null) deletedContacts.put(c.Id,c);
         System.debug(LoggingLevel.INFO, '+++++++++++++ Inside MoveContactsAfterKeyContactDelete2- deletedContactIds:' + deletedContacts);             
        // List<Key_Contact__c> existingKeyContacts= [Select Id,Contact__c  from Key_Contact__c where Contact__c in :deletedContacts.keySet()];
        //w_09232011 release.neelima.
         List<AggregateResult> existingKeyContacts= [Select count(Id) ,Contact__c  from Key_Contact__c where Contact__c in :deletedContacts.keySet()  group by Contact__c having count(Id)=1];
    
        System.debug(LoggingLevel.INFO, '+++++++++++++ Inside MoveContactsAfterKeyContactDelete2- existingKeyContacts:' + existingKeyContacts);
        for(AggregateResult ar: existingKeyContacts)
        {
            Id con=(Id) ar.get('Contact__c');
            ContactsToChild.put(con,con);
        }
       /* for(Contact c: Contacts){
            // if there are no more key contacts for this contact move the contact to child if it originally belongs to a child account.
            if(ContactsToChild.get(c.Id) !=null)
             ContactUtil.MoveContactToChild(c);
            }
            */
               // see if the contacts have any more key contacts existing.
          /* for(Key_Contact__c kcon: existingKeyContacts)
                {
                if(keyContacts.get(kcon.Contact__c)==null) keyContacts.put(kcon.Contact__c,kcon.Id);    
                } 
            for(Contact c: deletedContacts.values()){
            // if there are no more key contacts for this contact move the contact to child if it originally belongs to a child account.
            if(keyContacts.get(c.id)==null) 
            ContactUtil.MoveContactToChild(c);
            }*/
                       
        }
                 
        public static void MoveContactsAfterAllBranchContactUpdate(List<Contact> Contacts)
        {
            Map<Id,Contact>deletedContacts=new Map<Id,Contact>();
            Map<Id,Id>keyContacts= new Map<Id,Id>();
            Map<Id,Id> ContactsToChild= new Map<Id,Id>();
           
              for(Contact c : Contacts)
              if(deletedContacts.get(c.Id)==null) deletedContacts.put(c.Id,c);
         System.debug(LoggingLevel.INFO, '+++++++++++++ Inside MoveContactsAfterAllBranchContactUpdate- deletedContactIds:' + deletedContacts);             
         List<Key_Contact__c> existingKeyContacts= [Select Id,Contact__c  from Key_Contact__c where Contact__c in :deletedContacts.keySet()];
         System.debug(LoggingLevel.INFO, '+++++++++++++ Inside MoveContactsAfterAllBranchContactUpdate- existingKeyContacts:' + existingKeyContacts);
      
                     // see if the contacts have any more key contacts existing.
          for(Key_Contact__c kcon: existingKeyContacts)
                {
                if(keyContacts.get(kcon.Contact__c)==null) keyContacts.put(kcon.Contact__c,kcon.Id);    
                } 
          //  for(Contact c: deletedContacts.values()){
            // if there are no more key contacts for this contact move the contact to child if it originally belongs to a child account.
          //  if(keyContacts.get(c.id)==null) 
          //  ContactUtil.MoveContactToChild(c);
            }    
            
        public static boolean hasAddress(Contact c, String type) {
            List<string> addressFields= addrFieldMap.get(type)!=null? addrFieldMap.get(type):addrFieldMap.get('Default');
             system.debug('addressFields*******' + addressFields);
             system.debug('type*******' + type);
            for (String f : addressFields)              
                if (c.get(type+f) != null) return true;
        
        return false;
    }
    
        public static boolean addressChanged(Contact newC, Contact oldC, String type) {
            List<string> addressFields= addrFieldMap.get(type)!=null? addrFieldMap.get(type):addrFieldMap.get('Default');
            for (String f : addressFields) 
                        if ( (String) newC.get(type+f) != (String) oldC.get(type+f) ) return true; 
        return false;
        }   
        
        public static void CopyAddress(Contact c, String fromType, String toType) {
            
        List<string> fromAddressFields= addrFieldMap.get(fromType)!=null? addrFieldMap.get(fromType):addrFieldMap.get('Default');
        List<string> toAddressFields= addrFieldMap.get(toType)!=null? addrFieldMap.get(toType):addrFieldMap.get('Default');
        system.debug('fromAddressFields*******' + fromAddressFields);
         system.debug('toAddressFields*******' + toAddressFields);
        for (integer i=0;i<fromAddressFields.size();i++)
        {
            c.put(toType+toAddressFields[i], c.get(fromType+fromAddressFields[i]));
        }
        /*c.put(fromType+'Street', c.get(toType+'Street'));
        c.put(fromType+'City', c.get(toType+'City'));
        c.put(fromType+'State', c.get(toType+'State'));
        c.put(fromType+'PostalCode', c.get(toType+'PostalCode'));
        c.put(fromType+'Country', c.get(toType+'Country'));*/
    }  
    
        public static void SetMarketingAddress(Contact newC)
        {
            //check if marketing address on new contact is null.
            boolean marAddrExists =hasAddress(newC,'Marketing_'); 
            system.debug('marAddrExists*******' + marAddrExists);
            if (marAddrExists) return; 
            // copy mailing adress to marketing address if marketing address is null.           
            if(!marAddrExists && hasAddress(newC,'Mailing'))  CopyAddress(newC,'Mailing','Marketing_');                 
            
            //Convert full named countries with the abbreviated format
            if(newC.MailingCountry != null){
                string marketingCountry = newC.MailingCountry;
                           
                if(marketingCountry.toLowerCase() == 'united states'){
                    newC.Marketing_Country__c = 'US';
                }else if(marketingCountry.toLowerCase() == 'canada'){
                    newC.Marketing_Country__c = 'CA';
                }
            }
            
            if(newC.Phone != null){
                newC.Phone = FormatPhone(newC.Phone);
            }
        }
        public static void SetLastUpdatedDates(Contact newC, Contact oldC)
        {
            if (addressChanged(newC, oldC, 'Mailing')) newC.Mailing_Address_Last_Updated__c=system.now();
            if (addressChanged(newC, oldC, 'Marketing_')) newC.Marketing_Address_Last_Updated__c=system.now();
            
        }
        
        public static String FormatPhone(String Phone) {
          if(Phone.toLowerCase().contains('x'))
          {
              string nondigits = '[^0-9]';
              string PhoneDigits;
              
              // remove all non numeric
              PhoneDigits = Phone.replaceAll(nondigits,'');

              // 11 digit: if starts with 1, format as 10 digit 
              if (PhoneDigits.length() > 10) {
                if (PhoneDigits.substring(0,1) == '1') {
                  Phone = PhoneDigits.substring(1,4) + '-' +
                          PhoneDigits.substring(4,7) + '-' +
                          PhoneDigits.substring(7,11);
                }
              }
          }
          return( Phone );
        }  
          
                            
                     
}