public with sharing class DedupUtil {
    
    public static Map<Id,Contact> newContactsMap {get;set;}
    public static Map<Id,Contact> oldContactsMap {get;set;}
    public static Map<Contact,Contact> addedToHQ {get;set;}
    public static Map<Contact,Contact> addedToChildDupInsameChild {get;set;}
    public static Map<Contact,Contact> addedToChildDupInDiffChild {get;set;}
    public static Map<Contact,Contact> addedToChildDupInHQ {get;set;}
    public static Map<Contact,Contact> dupsIndiffHierarchy {get;set;}
    public static Map<Id,Contact> contactsOkToUpdate {get;set;}
    
    public static Map<Id,Contact> lastOldContactsMap {get;set;}
    public static Map<Id,Contact> currContactsMapToCompare {get;set;}
    public static Integer execCount=0;
    public static Boolean doNotCheckForExistingContactEmailDups=false;
    public static void intializeTriggerExecution(Map<Id,Contact> oldMap, Map<Id,Contact> newMap)
    {
        System.debug(LoggingLevel.INFO, '$$$$$ BEFORE INIT Old Map' + Trigger.oldMap);
        System.debug(LoggingLevel.INFO, '$$$$$ BEFORE INIT New Map' + Trigger.newMap);
        
        DedupUtil.newContactsMap=newMap;
        if(DedupUtil.execCount==0 || DedupUtil.lastOldContactsMap==null)
        {
            System.debug(LoggingLevel.INFO, '$$$$$ COUNT 0 or LASTMAP NULL ');
            DedupUtil.currContactsMapToCompare = oldMap;
            DedupUtil.lastOldContactsMap = newMap;
        }
        else
        {
            //eventhough count is more than 0 in a recurrsive call, it may be a new insert transaction where the oldMap is null. 
            // In that case use OldMap insead of recent map
            
                //make sure the old and recent collection is still same
                boolean bCollectionChanged = false;
                System.debug(LoggingLevel.INFO, '$$$$$ COUNT > 1 && LASTMAP ! NULL ');
                if(oldMap!=null && DedupUtil.lastOldContactsMap.size()>0)
                {
                    System.debug(LoggingLevel.INFO, '**** OLDMAP ! NULL CHECKING FOR CHANGEDMAPS');
                    System.debug(LoggingLevel.INFO, '****** CHANGEDMAPS NULL = ' + (DedupUtil.lastOldContactsMap.size()));
                    for(Contact tCont: DedupUtil.lastOldContactsMap.values())
                    {
                        if(oldMap.get(tCont.Id)==null)
                        {
                            //collection is changed. Contact no longer exists in the map. Reset most recent map
                            bCollectionChanged = true;
                            break;
                        }
                        //Contact Exists.. continue checking
                    }
                } 
                else
                {
                    bCollectionChanged = true;
                }
                
                if(!bCollectionChanged)
                {
                    System.debug(LoggingLevel.INFO,'Collection not changed. Using most recent map');
                    DedupUtil.currContactsMapToCompare = DedupUtil.lastOldContactsMap;
                }
                else
                {
                    System.debug(LoggingLevel.INFO,'Collection not changed. Using most old map');
                    DedupUtil.currContactsMapToCompare = oldMap;
                }
                
            DedupUtil.lastOldContactsMap = newMap;
            
        }
        
        DedupUtil.execCount = DedupUtil.execCount + 1;
        System.debug(LoggingLevel.INFO, '+++++++++++++ InsertUdpate Trigger Execution Count :' + DedupUtil.execCount );
        System.debug(LoggingLevel.INFO, '$$$$$ Old Map' + Trigger.oldMap);
        //System.debug(LoggingLevel.INFO, '$$$$$ Old recent Map' + DedupUtil.currContactsMapToCompare);
        System.debug(LoggingLevel.INFO, '$$$$$ New Map' + Trigger.newMap);
    }
        
    public static void validateForDupOnInsert(List<Contact> contacts)
    {
        // question? can a contact come with a null email address?
        // is there a chance in the same bulk insert same email address can come in?
        //List<Contact> contactsWithNoDup=new List<Contact>();
         addedToHQ= new Map<Contact,Contact>();
         addedToChildDupInHQ= new Map<Contact,Contact>();
         addedToChildDupInsameChild= new Map<Contact,Contact>();
         addedToChildDupInDiffChild= new Map<Contact,Contact>();
         dupsIndiffHierarchy= new Map<Contact,Contact>();
         Map<string,Contact> emailIds= new Map<string,Contact>();
         system.debug('inside validate method1  ' + contacts);
         
         
        //Map<string, Map<Contact,Contact>> duplicates=new Map<String, Map<Contact,Contact>>();
        // collect email addresses and set the contact source
        for (Contact c: contacts)
        {
            c=setContactSource(c);
            if (c.Email !=null && !emailIds.containskey(c.Email))emailIds.put(c.Email,c); 
        }
        system.debug('inside validate method emailIds  ' + emailIds);
        
        if(emailIds.size()>0)
        {
            List<Contact> duplicateContacts= new List<Contact>();
            duplicateContacts=getDuplicateContacts(emailIds.keyset());
            if(duplicateContacts.size()==0) return;
            //[select id,Email,Is_Duplicate__c,HQ_Account_Id_18__c, AccountId,Contact_Trigger_Toggle__c,Pre_Sales_Contact_Role__c from Contact where Email in :emailIds.keyset()and Is_Duplicate__c = false ];
            system.debug('inside validate method duplicateContacts  ' + duplicateContacts);
            for(Contact c: duplicateContacts)
            {
                Contact newContact= emailIds.get(c.Email);
                system.debug('inside validate method newContact  ' + newContact);
                // same hierarchy 
                if(c.HQ_Account_Id_18__c==newContact.HQ_Account_Id_18__c)
                {
                    //new contact is being added at hq level
                    if(newContact.AccountId==newContact.HQ_Account_Id_18__c )
                    addedToHQ.put(newContact,c);
                    //swetha---commented out----
                // new contact is being added to a child and dup is in hq.
                   else if (c.AccountId==c.HQ_Account_Id_18__c)
                    addedToChildDupInHQ.put(newContact,c);          
                // new contact is being added at child level- same child
                  else if(c.AccountId==newContact.AccountId)addedToChildDupInsameChild.put(newContact,c);               
                
                // new contact is being added to a different child account in the same hierachy
                else if(newContact.AccountId !=c.AccountId)
                addedToChildDupInDiffChild.put(newContact,c);
                }
                // added to a different account
                else dupsIndiffHierarchy.put(newContact,c);
                                    
            }   
             system.debug('addedToHQ  '+ addedToHQ);
            /* system.debug('addedToChildDupInHQ  '+ addedToChildDupInHQ);
             system.debug('addedToChildDupInsameChild' + addedToChildDupInsameChild);
             system.debug('addedToChildDupInDiffChild ' + addedToChildDupInDiffChild);*/
             system.debug('dupsIndiffHierarchy  ' + dupsIndiffHierarchy);
                 handleDupsOnInsert();
                 
        }
    }
    
    private static void handleDupsOnInsert()
    {
        
    List<Contact>contactsToUpdate= new List<Contact>();
    Map<string,AccountContactRole> mapcontactRoles= new Map<string,AccountContactRole>();
    List<Id>acctInAcr= new List<Id>();
    List<Id>conInAcr= new List<Id>();
    
    // if the duplicate is in a different customer record create the new contact and set the duplicate flag.
    // the existing record continues to be primary.
    
    for(Contact c:dupsIndiffHierarchy.keyset())
    {
        string customerType; 
        Contact dupCon=dupsIndiffHierarchy.get(c);
        if(dupCon.Account.Parent.CustomerTypeID__c!=null) customerType=dupCon.Account.Parent.CustomerTypeID__c;
        else customerType=dupCon.Account.CustomerTypeID__c;
        // if the existing contact is for a FMS Rental then the new contact is primary else the existing contact
        // continues to be primary.
        if(customerType=='FMS Rental')
        {
            dupCon.Is_Duplicate__c=true;
            // primary id will be set in update trigger as the id of the new contact is not avaiable in the before insert trigger
            contactsToUpdate.add(dupCon);
        }
        else
        {
        c.Is_Duplicate__c=true;
        // set the id of the existing contact as primary id on the new contact
        c.Primary_Contact_Id__c=dupCon.Id;
        }
        
    }
    
    // if the new contact is being added to a hq in the same hierarchy 
    for(Contact c:addedToHQ.keyset())
    {
        Contact dupCon=addedToHQ.get(c); 
        string role=getRole(dupCon.Pre_Sales_Contact_Role__c);
                   
        string message='A contact with the same email address already exists in the same account.';
        c=createAsDuplicate(c,dupCon,message);
    
        // if duplicate is at a child level move child to parent account and make account contact role entries.
        if(dupCon.AccountId!=dupCon.HQ_Account_Id_18__c)
        
        {   
               AccountContactRole acr= new AccountContactRole();
               acr.AccountId= dupCon.AccountId;
               acr.ContactId=dupCon.Id;
               acr.Role=role;
             //  acr.Role= dupCon.Pre_Sales_Contact_Role__c==null? 'Other' : (dupCon.Pre_Sales_Contact_Role__c.split(','))[0];
               //swetha-----commented----
          //     ContactUtil.MoveContactToParent(dupCon);
               dupCon.Added_As_Key_Contact__c=false;
            
                contactsToUpdate.add(dupCon);
                acctInAcr.add(acr.accountid);
                conInAcr.add(acr.contactid);
                
                if (!mapcontactRoles.containsKey(acr.accountid+'_'+acr.contactid +'_'+acr.role))mapcontactRoles.put(acr.accountid+'_'+acr.contactid+'_'+acr.role,acr);
        }
    }
    // if the contact is being added to a child account and duplicate is in hq in the same hierarchy
    //----swetha---commented------
//  for(Contact c:addedToChildDupInHQ.keyset())
//  {
    //  Contact dupCon=addedToChildDupInHQ.get(c); 
    //  string role=getRole(dupCon.Pre_Sales_Contact_Role__c);
    //  string message='A contact with the same email address already exists in the same account at the HQ level. A new account contact role is created in this account';
    //  c=createAsDuplicate(c,dupCon,message);
                
        // create an accountContact role
    //  AccountContactRole acr= new AccountContactRole();
    //         acr.AccountId= c.AccountId;
    //         acr.ContactId=dupCon.Id;
              // acr.Role= dupCon.Pre_Sales_Contact_Role__c==null? 'Other' : (dupCon.Pre_Sales_Contact_Role__c.split(','))[0];
    //         acr.Role=role;
    //         acctInAcr.add(acr.accountid);
    //          conInAcr.add(acr.contactid);
    //         if (!mapcontactRoles.containsKey(acr.accountid+'_'+acr.contactid+'_'+acr.role))mapcontactRoles.put(acr.accountid+'_'+acr.contactid+'_'+acr.role,acr);
        
//  }
    
    // if the contact is being added to the same child account do not create contact.
    //swetha----commented----
    //for(Contact c:addedToChildDupInsameChild.keyset())
    //{
        //Contact dupCon=addedToChildDupInsameChild.get(c);
    //  string message='A contact with the same email address already exists in the same child account.';
    //  c=createAsDuplicate(c,dupCon,message);
//  }
    
    // if the contact is being added to a child account and the duplicate belongs to a diff child account in the same hierachy
    for(Contact c:addedToChildDupInDiffChild.keyset())
    {                       
        Contact dupCon=addedToChildDupInDiffChild.get(c);
        string role=getRole(dupCon.Pre_Sales_Contact_Role__c);
                    
        string message='A contact with the same email address already exists in the same HQ at a different child account.The primary contact is moved to the HQ and corresponding Account Contact Role entries are created. ';
        c.Primary_Contact_Id__c=dupCon.Id;
        c=createAsDuplicate(c,dupCon,message);
            
        // move the duplicate to parent and add account team entries for both child accounts
        // account team entry for duplicate contact
               AccountContactRole acrDup= new AccountContactRole();
               acrDup.AccountId= dupCon.AccountId;
               acrDup.ContactId=dupCon.Id;
               acrDup.Role=role;
               //acrDup.Role= dupCon.Pre_Sales_Contact_Role__c==null? 'Other' : (dupCon.Pre_Sales_Contact_Role__c.split(','))[0];
               acctInAcr.add(acrDup.accountid);
                conInAcr.add(acrDup.contactid);
               if (!mapcontactRoles.containsKey(acrDup.accountid+'_'+acrDup.contactid +'_'+acrDup.role))mapcontactRoles.put(acrDup.accountid+'_'+acrDup.contactid+'_'+acrDup.role,acrDup);
           // account team entry for the new contact    
               AccountContactRole acrNewCon= new AccountContactRole();
               acrNewCon.AccountId= c.AccountId;
               acrNewCon.ContactId=dupCon.Id;
               acrNewCon.Role= role;
               //acrNewCon.Role= acrDup.Role;
                acctInAcr.add(acrNewCon.accountid);
                conInAcr.add(acrNewCon.contactid);
               if (!mapcontactRoles.containsKey(acrNewCon.accountid+'_'+acrNewCon.contactid+ '_'+acrNewCon.role))mapcontactRoles.put(acrNewCon.accountid+'_'+acrNewCon.contactid+'_'+acrNewCon.role,acrNewCon);
               
       //  ContactUtil.MoveContactToParent(dupCon);
         //dupCon.Added_As_Key_Contact__c=false;
        // contactsToUpdate.add(dupCon);
    }
    system.debug('contactsToUpdate  ' + contactsToUpdate);
    system.debug('accountContactRoles  ' + mapcontactRoles.values());
    
    if(contactsToUpdate.size()>0) Database.update(contactsToUpdate) ;
    
    
    List<AccountContactRole>existingContactRoles= [Select Id, contactId, AccountId, role from AccountContactRole where contactid in :conInAcr and accountid= :acctInAcr];
    for (AccountContactRole acr :existingContactRoles)
    {
    if (mapcontactRoles.containskey(acr.accountid+'_'+acr.contactid + '_'+acr.role))
    mapcontactRoles.remove(acr.accountid+'_'+acr.contactid+'_'+acr.role);
    }
    system.debug('accountContactRoles after ids ' + mapcontactRoles.values());
    if(mapcontactRoles.values().size()>0)Database.upsert(mapcontactRoles.values());
    
    //if(contactsToUpdate.size()>0) update contactsToUpdate;
    //if(accountContactRoles.size()>0)insert accountContactRoles;
    

    }
    /*
    public static void validateForDupOnUpdate()
    {
        // 04/06/2012 Neelima- add logic to validate the contact updates to conform to the unique email requirement for Eloqua
        Map<Id, Profile> sysAdminProfileMap = new Map<Id,Profile>([Select p.Name, p.Id From Profile p where p.Name in ('SSO System Administrator', 'System Administrator')]);
        // if an email address is updated allow the update only if the new email id doesn't exist as a contact in SFDC
        Map<string,Contact> changedEmails= new Map<string,Contact>();
        contactsOkToUpdate=new Map<Id,Contact>();
                
        for(Contact c: newContactsMap.values())
        {
        if(c.Email != null && oldContactsMap.get(c.Id)!=null && c.Email!= oldContactsMap.get(c.Id).Email)
        {
        // compile a list of new email ids when email is changed.
            if (!changedEmails.containskey(c.Email))
                {
                 changedEmails.put(c.Email,c);
                // uncheck the duplicate flag and empty the primary contact id. In case there is no duplicate error later this contact update will mark the contact as primary
                c.Is_Duplicate__c=false;
                c.Primary_Contact_Id__c=null;
                }
        } 
        else if(oldContactsMap.get(c.Id)!=null && c.Is_Duplicate__c !=oldContactsMap.get(c.Id).Is_Duplicate__c 
                && sysAdminProfileMap.get(UserInfo.getProfileId()) == null)
        c.addError('Only admins can update the duplicate flag');
                
        else contactsOkToUpdate.put(c.id,c);
        }
                
        // if any of the new email ids already exist in SFDC as primary do not let the update go through
        for(Contact c: [select id,Email from Contact where Email in :changedEmails.keyset() and Is_Duplicate__c = false])
        {
            
            Contact newCon=changedEmails.get(c.Email);
            if(c.id != newCon.Id)
            {
                newCon.addError('A contact already exists with this email id.');
                contactsOKToUpdate.remove(newCon.Id);
            }
        }
    }
    */
    /*
       public static void validateForDupOnUpdate()
    {
        List<string> incomingEmails= new List<string>();
        Map<contact, Id> contactToPrimary= new Map<contact,Id>();
         // collect all the emails from the incoming contacts.
         for(Contact c: newContactsMap.values())
         {          
            if(c.Email !=null ) incomingEmails.add(c.Email);
         }
            //get a list of primary contacts 
        List<Contact>existingPrimaries= [select id,email from contact where email in :incomingEmails and Is_Duplicate__c=false];
        
        // if a primary exists set the duplicate flag and primary contact id .
        for (contact p: existingPrimaries)
        {
            Contact newcon= new Contact();
            newCon=newContactsMap.get(p.Email);
            newCon.Is_Duplicate__c=true;
            newCon.Primary_Contact_Id__c=p.Id;
            
        }
        //get all the contacts existing in the system with the same email. primary or duplicate.
        List<Contact>existingContacts= [select id,email from contact where email in :incomingEmails];
        // get a list of contacts with no primaries
        AggregateResult allDup= [select count(Id),email,Is_Duplicate__c from contact where email in :incomingEmails group by email,Is_Duplicate__c order by Is_Duplicate__c desc];
        // get map of emails with no primaries but dups existing 
        // when ordered by id duplicate flag primary records comes first. so order it desc so duplicate count comes first
        Map<string,string> allDupEmails = new Map<string,string>();
        for(AggregateResult arCon:allDup )
        {
            boolean isDup=arCon.get('Is_duplicate__c');
            int Count=arCon.get('expr0');
            string email=arCon.get('Email');
            // if the primary count is 0 add it to allduplist by default
            if(Is_duplicate__C=true && count>0)allDupEmails.put(email,email);
            if(Is_duplicate__C=false && count>0 && allDupEmails.containskey(email))
                                        allDupEmails.remove (email);
                
        }
        // get all contacts based on the email list with no primary but existing dups.
        List<Contacts> conWithNoPrimaries=[select id,email,Is_Duplicate__c,Primary_Contact_Id__c from contact where email in :allDupEmails and Is_Duplicate__c=false];
        // create a map of email to duplicate contact list
        Map<string,List<contact>> noPrimaryEmails= new Map<string,List<contact>>();
        for(contact np: conWithNoPrimaries)
        {       
            List<contacts> dupConList=noPrimaryEmails.get(np.email);
            if (dupConList=null || dupConList.count=0) 
            {
            dupConList= new List<contact>();
            noPrimaryEmails.put(np.email,dupconlist); 
            }
            else
            {
            noPrimaryEmails.remove(np.email);
            dupconlist.add(np);
            noPrimaryEmails.put(np.email,dupconlist);
            }
        }
        
        Map<string,contact> aldupEmails= new Map<string,contact>();
        
        Map<Contact,List<contact>> conToAllDupMap= new Map<Contact,List<contact>>();
        for (Contact nc: newContactsMap.values())
        {
            // this means all dups exist without a primary
            if(noPrimaryEmails.containsKey(nc.Email))
            {
                List<contact> allDuplicateCons= noPrimaryEmails.get(nc.Email);
                // select one of those duplicate contacts as primary
                
                
            }
        }
        
    }
        
    }
    */
    //swetha-----commented---new email changes
    
    public static void validateForDupOnUpdate(Map<Id,Contact> oldMap, Map<Id,Contact> newMap){
        Map<Id, Contact> validConMap = new Map<Id, Contact>();
        Set<String> emailIdSet = new Set<String>();
        Map<Id, Contact> oldConMap = new Map<Id, Contact>();
        
        List<Contact> finalUpdateConList = new List<Contact>();
        contactsOkToUpdate=new Map<Id,Contact>();
        
        for(Contact newCon: newMap.values()) {
            contactsOkToUpdate.put(newCon.id,newCon); 
            Contact oldCon = (Contact)oldMap.get(newCon.Id);
            if(oldCon.Email != newCon.Email) {
                //if(oldCon.Email != null) { 
                    validConMap.put(newCon.Id, newCon);
                    if(newCon.Email != null) {                 
                        emailIdSet.add(newCon.Email);               
                    }
                    else
                    {
                        //if new email is null, reset duplicate flag and clear out primary duplicate relation if exists
                        system.debug('*** if new email is null, reset duplicate flag and clear out primary duplicate relation if exists');
                        newCon.Is_Duplicate__c=false;
                        newCon.Primary_Contact_Id__c=null;
                        //finalUpdateConList.add(newCon);
                    }
            }
            else if(oldCon.Email==null && newCon.Email == null 
                && (newCon.Is_Duplicate__c || newCon.Primary_Contact_Id__c!=null)) 
            //this is for bad data cleanup. this condition should not exist in an ideal world. If no email and contact is marked as duplicate, do a self cleanup
            {
                system.debug('*** This is for bad data cleanup. this condition should not exist');
                newCon.Is_Duplicate__c=false;
                newCon.Primary_Contact_Id__c=null;
                //finalUpdateConList.add(newCon);
            }
        }
        if(validConMap.size()>0) {
            List<Contact> validConList = [Select Id, Primary_Contact_Id__c, Email,Invalid_Email__c, (Select Id, Primary_Contact_Id__c, Invalid_Email__c from DuplicateContacts__r) from Contact where Id IN: validConMap.keySet()];
            Map<String, Contact> newPrimaryEmailContactMap = getDuplicateContactsMap(emailIdSet);
            //Set<String> newPrimaryContactEmailSet = newPrimaryEmailContactMap.keySet();
            Map<string,Contact> emailIdsToDedupe = new Map<string,Contact>();
             
            for(Contact con: validConList) {
               
                system.debug('*** valid email change. reset duplicate flag and clear out primary duplicate relation - bad data cleanup');
                //finalUpdateConList.add(con);
                
                //if(con.DuplicateContacts__r.length>0)
                    Contact newPrimaryContact = null; 
                    Contact currentContact = (Contact)newMap.get(con.Id);
                    system.debug('*** newprimarycontactemailset ' + newPrimaryEmailContactMap.keySet());
                    system.debug('*** new Contact email to check against set = ' + ((Contact)newMap.get(con.Id)).Email);
                    if(currentContact!=null)
                    {
                        //if(newPrimaryContactEmailSet.contains( currentContact.Email )) {
                            //system.debug('*** Found new primary contact = ' );
                            //newPrimaryContact = newPrimaryEmailContactMap.get(currentContact.Email);
                            //system.debug('*** Found new primary contact = ' + newPrimaryContact );
                        //}
                        newPrimaryContact = newPrimaryEmailContactMap.get(currentContact.Email);
                        if(newPrimaryContact==null)
                        { 
                            //if no new duplciate primary exists, make the current contact as primary
                            system.debug('*****No new primary - make the contact as primary');
                            currentContact.Is_Duplicate__c=false;
                            currentContact.Primary_Contact_Id__c=null;
                            system.debug('*****Making contact primary - new parent id ' + currentContact.Primary_Contact_Id__c);
                            system.debug('*****Making contact primary - is duplicate ' + currentContact.Is_Duplicate__c);
                            newPrimaryContact = con;
                            system.debug('*****contact to be updated = ' + currentContact);
                        }
                        else
                        {
                            system.debug('*****New primary found - ' + newPrimaryContact.Id);
                            currentContact.Primary_Contact_Id__c = newPrimaryContact.Id;
                            currentContact.Is_Duplicate__c=true;
                        }
                

                        if(con.Primary_Contact_Id__c == null || con.DuplicateContacts__r.size()>0) 
                        {
                            system.debug('*****Dups may exists for updated primary contact ');
                            if(con.Invalid_Email__c) //old contact value is true 
                            {
                                DedupUtil.doNotCheckForExistingContactEmailDups=true;
                                    
                                for(Contact duplicateCon :con.DuplicateContacts__r) 
                                {
                                    contactsOkToUpdate.put(duplicateCon.id,duplicateCon); 
                                    duplicateCon.email = currentContact.email;
                                    if(currentContact.email==null)
                                    {
                                        duplicateCon.Email_does_not_exist__c = currentContact.Email_does_not_exist__c;
                                        duplicateCon.Email_Does_Not_Exist_Reason__c = currentContact.Email_Does_Not_Exist_Reason__c;
                                        duplicateCon.Primary_Contact_Id__c=null;
                                        duplicateCon.Is_Duplicate__c=false;
                                    }
                                    else
                                    {
                                        duplicateCon.Primary_Contact_Id__c=newPrimaryContact.Id;
                                        duplicateCon.Is_Duplicate__c=true;
                                    }
                                    //con.Primary_Contact_Id__c=tempCon.Id;
                                    system.debug('*****con.Primary_Contact_Id__c'+currentContact.Primary_Contact_Id__c);
                                    system.debug('******tempCon.Id: '+newPrimaryContact.Id);
                                    system.debug('******con.Primary_Contact_Id__c: '+currentContact.Primary_Contact_Id__c);
                                    system.debug('******Duplicate.PrimaryConId: '+duplicateCon.Primary_Contact_Id__c);
                                    system.debug('******Duplicate.Id: '+duplicateCon.Id);
                                    system.debug('*** Invalid email is being updated. Propogate change to its duplicates');
                                    finalUpdateConList.add(duplicateCon);
                                    
                                }
                               // con.Primary_Contact_Id__c = tempCon.Id;
                               // finalUpdateConList.add(con);
                            } 
                            else 
                            {
                                //relink existing duplicates and a make one of duplicate as primary.
                                //add new primary detection logic using hierrachy, activity, opportuniy touches
                                //also check if a primary already exists for thsi email address - results of bad data
                                Integer count =0;
                                Id newPriContId = null;
                                for(Contact duplicateCon :con.DuplicateContacts__r) 
                                {
                                    contactsOkToUpdate.put(duplicateCon.id,duplicateCon); 
                                    if(count == 0) 
                                    {
                                        duplicateCon.Primary_Contact_Id__c = null;
                                        duplicateCon.Is_Duplicate__c=false;
                                        //finalUpdateConList.add(duplicateCon);
                                        newPriContId = duplicateCon.Id;
                                        system.debug('******duplicateCon.Id'+duplicateCon.Id);
                                        count++;
                                    } 
                                    else 
                                    {
                                        duplicateCon.Primary_Contact_Id__c=newPriContId;
                                        duplicateCon.Is_Duplicate__c=true;
                                    
                                    }
                                    finalUpdateConList.add(duplicateCon);
                                }
                            }
                        } 
                    }
                    
            }
        }
        
        if(!finalUpdateConList.isEmpty()) {
                system.debug('*** validate dup on update ' + finalUpdateConList);
                update finalUpdateConList;
            } 
     }
     
     
    
    public static Map<String, Contact> getDuplicateContactsMap(set<String> emailIds)
    //Get matching email duplicates that already exists as a primary contact in any account in a map
    {
        system.debug('value emails ' + emailIds);
        Map<String, Contact> newPrimaryEmailContactMap = new Map<String, Contact>();
        /*
        for(Contact con: [select id,Email,Is_Duplicate__c,HQ_Account_Id_18__c, AccountId,Contact_Trigger_Toggle__c,Pre_Sales_Contact_Role__c,FirstName, LastName,Account.ParentId,Account.Parent.CustomerTypeID__c,Account.CustomerTypeID__c  from Contact where Email in :emailIds and Is_Duplicate__c = false ]) {
            system.debug('Found primary contacts for ' + emailIds); 
            newPrimaryEmailContactMap.put(con.Email, con);
        }
        */
        List<Contact> primaryContacts = getDuplicateContacts(emailIds);
        
        for(Contact con: primaryContacts)
        {
             system.debug('adding already existing primary contacts ' + con.Email);
             newPrimaryEmailContactMap.put(con.Email, con);
        }
        
        return newPrimaryEmailContactMap;
    }
    
    
    public static List<Contact> getDuplicateContacts(set<String> emailIds) 
    //Get matching email duplicates that already exists as a primary contact in any account 
    {
        system.debug('value emails ' + emailIds);
        List<Contact> dupContacts=[select id,Email,Is_Duplicate__c,HQ_Account_Id_18__c, AccountId,Contact_Trigger_Toggle__c,Pre_Sales_Contact_Role__c,FirstName, LastName,Account.ParentId,Account.Parent.CustomerTypeID__c,Account.CustomerTypeID__c  from Contact where Email in :emailIds and Is_Duplicate__c = false ];
        
        system.debug('Primary contacts count = ' + dupContacts.size());
        return dupContacts;
    }
    
    public static Contact getDuplicateContacts(String emailId)
    //Get matching email duplicate that already exists as a primary contact in any account. Use this to get an existing primary contact with the same email
    {
        List<Contact> dupContacts= new List<Contact>();
        
        set<String> emailIds = new set<String>();
        emailIds.add(emailId);
        dupContacts = getDuplicateContacts(emailIds);
        //system.debug('value single ' + emailId);
        //dupContacts=[select id,Email,Is_Duplicate__c,HQ_Account_Id_18__c, AccountId,Contact_Trigger_Toggle__c,Pre_Sales_Contact_Role__c,FirstName, LastName,Account.ParentId,Account.Parent.CustomerTypeID__c,Account.CustomerTypeID__c  from Contact where Email = :emailId and Is_Duplicate__c = false ];
        
        
        if(dupContacts.size()>0) return dupContacts[0];
        else return null;
    }
    
    public static Contact getFMSDuplicateContacts(String emailId)
    {
    List<Contact> dupContacts= new List<Contact>();
    system.debug('value single ' + emailId);
    dupContacts=[select id,Email,Is_Duplicate__c,HQ_Account_Id_18__c, AccountId,Contact_Trigger_Toggle__c,Pre_Sales_Contact_Role__c,FirstName, LastName,Account.ParentId,Account.Parent.CustomerTypeID__c,Account.CustomerTypeID__c  from Contact where Email = :emailId and Is_Duplicate__c = false and (not(Account.Parent.CustomerTypeID__c='FMS Rental' or Account.CustomerTypeID__c='FMS Rental')) ];
    if(dupContacts.size()>0) return dupContacts[0];
    else return null;
    }
    
    public static Contact getContactFromSameAccount(String emailId, string accountId)
    {
    List<Contact> existingContacts= new List<Contact>();
    existingContacts=[select id,Email,Is_Duplicate__c,HQ_Account_Id_18__c, AccountId,Contact_Trigger_Toggle__c,
                Pre_Sales_Contact_Role__c,FirstName, LastName,Account.ParentId,Account.Parent.CustomerTypeID__c, 
                Account.CustomerTypeID__c  from Contact where Email = :emailId and Account.Id= :accountid ];
    if(existingContacts.size()>0) return existingContacts[0];
    else return null;
    }
    
    public static Contact getContactFromSameAccountHierarchy(String emailId, string accountId, string parentAccountId)
    {
    List<Contact> existingContacts= new List<Contact>();
    existingContacts=[select id,Email,Is_Duplicate__c,HQ_Account_Id_18__c, AccountId,Contact_Trigger_Toggle__c,
                Pre_Sales_Contact_Role__c,FirstName, LastName,Account.ParentId,Account.Parent.CustomerTypeID__c, 
                Account.CustomerTypeID__c,
                RecordType.Name from Contact where Email = :emailId and (Account.Id= :accountid or Account.Id=:parentAccountId)
                Order by  RecordType.Name desc];
                
                     
        if(existingContacts.size()>0) 
            return existingContacts[0];
        else 
            return null;
    }
    
    public static Contact setContactSource(Contact c)
    {
         if (c.Contact_Source__c != (RyderGlobalVariables.ContactSource.Lead_Conversion.name()).replace('_',' '))
         {
            if(c.Integration_Indicator__c!=null) c.Contact_Source__c= c.Integration_Indicator__c;
            else c.Contact_Source__c=RyderGlobalVariables.ContactSource.Manual.name();
         }
         return c;
     
    }
    
    private static Contact createAsDuplicate(Contact newCon, Contact dupcon,string message)
    {
        newCon.Primary_Contact_Id__c=dupCon.Id;
        newCon.Is_Duplicate__c=true;
        newCon.Note__c=message;
        if(newCon.Contact_Source__c==RyderGlobalVariables.ContactSource.Manual.name()) newCon.Can_Be_Removed__c=true;
        return newCon;
    }
    
    private static string getRole( string role)
    {
        if(role==null) role='Other';
        else if (role.indexOf(';')> -1) role=(role.split(';'))[0];
        else if (role.indexOf(',')> -1) role=(role.split(','))[0];
        else role='Other';
        return role;
    }
      // List<Account> accId = new List<Account>();
     //  List<contact> contId= new List<contact>();
         Public static void createAccountContactRole (List<contact> contacts)  {
         system.debug('inside create contact role');
       //  AccountContactRole accConRole=new  AccountContactRole ();
       // accConRole.AccountId=accId;
         //accConRole.ContactId = contId;
        // Insert accConRole;
         
      }
        
}