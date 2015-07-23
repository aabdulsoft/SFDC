public without sharing class CustomerBranchKeyContact {
	
	public Customer_Branch__c customerBranch{get; set;}
    
    public List<Key_Contact__c> keyContacts {set; get;}
    
    public List<KeyContactVO> keyContactList {set; get;}
    
    public boolean displayMoreLink {set; get;}
    
    public String addNewKeyContact {get; set;}  
    
    public String customerBranchToContactRLID {get; set;}
    
     
     public CustomerBranchKeyContact(ApexPages.StandardController stdController) {
        
        this.customerBranch = (Customer_Branch__c)stdController.getRecord();
        this.customerBranch = [Select c.ext_customerbranch_id__c, c.VEH_COUNT__c, c.SystemModstamp, c.Speed_Changes__c, 
            c.Ryder_HQ_Account__c, c.Ryder_Branch__c, c.Risk_Status__c, c.Primary_Contact_Count__c, c.Primary_Account_Contact__c, 
            c.Pre_authorized_Repairs__c, c.Pre_authorized_Repair_Amount__c, c.Other_Misc_Billing_Information__c, 
            c.Other_Instructions__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, 
            c.Customer_Requires_PO__c, c.CurrencyIsoCode, c.CreatedDate, c.CreatedById, c.Components_Not_Included__c, 
            c.Customer_Branch_Status__c, c.Blanket_PO_Number__c, c.Additional_Comments__c From Customer_Branch__c c 
            where c.Id =: this.customerBranch.Id LIMIT 1];
        init();
    }
    
    private void init() {
      
        this.displayMoreLink = false;
        this.customerBranchToContactRLID = RyderGlobalVariables.CUSTOMER_BRANCH_TO_CONTACT_RLID;    
        this.keyContactList = new List<KeyContactVO>();
        String accountId = this.customerBranch.Ryder_HQ_Account__c;
        Integer i = 0;
         //  neelima boppana- commented for key contact rewrite 06/29/11
         /*
        //Get primary CSI contacts
        System.debug(LoggingLevel.INFO, '########################### accountId:'+ accountId);
        List<contact> primaryContactList = [select c.id, c.name,c.CSI_Contact_Type__c, c.Maintenance_Contact_Type__c from Contact c where c.HQ_Account_Id_18__c =: accountId and c.CSI_Contact_Type__c != null];
        System.debug('############## primaryContactList:' + primaryContactList);
        if (primaryContactList != null) {
            for (Contact tempContact: primaryContactList) {
	            keyContactList.add(getKeyContactVO(tempContact, RyderGlobalVariables.PrimaryContactRole.CSI));
	            i++;
            }
        }
        system.debug(LoggingLevel.INFO, 'keyContactList size after CSI: ' + keyContactList.size());
        //Get primary maintenance contacts
        
        List<contact> primaryMaintContactList = [select c.id, c.name,c.CSI_Contact_Type__c, c.Maintenance_Contact_Type__c from Contact c where c.HQ_Account_Id_18__c =: accountId and c.Maintenance_Contact_Type__c != null];
        
        if (primaryMaintContactList != null) {
            for (Contact tempContact: primaryMaintContactList) {
                keyContactList.add(getKeyContactVO(tempContact, RyderGlobalVariables.PrimaryContactRole.Maintenance));
                i++;
            }
        } */
        // neelima boppana- soql updated for key contact rewrite 06/29/11
        if (displayMoreLink == false) {
	        this.keyContacts = [Select k.Id, k.Name, k.Customer_Branch__r.Name, k.Customer_Branch__r.Id, k.Contact__r.Name, k.Contact__r.Id, k.Contact_Type__c, k.Contact_Role__c, 
	                k.Available_To__c, k.Available_From__c, k.Available_24_7__c, k.All_Branch_Contact__c, Contact__r.STATUS_ACTIVE__c, Contact__r.DoNotCall, Contact__r.HasOptedOutofSurvey__c  From Key_Contact__c k where k.Customer_Branch__c =: this.customerBranch.Id LIMIT 6];
	        
	        system.debug(LoggingLevel.INFO, 'keyContactList size after maintenance: ' + keyContactList.size());
	        if (this.keyContacts != null) {
	            for(Key_Contact__c keyContact: this.keyContacts) {
	            	KeyContactVO keyContactVO = new KeyContactVO();
	            	keyContactVO.available247 = keyContact.Available_24_7__c;
	            	keyContactVO.availableFrom = keyContact.Available_From__c;
	            	keyContactVO.availableTo = keyContact.Available_To__c;
	            	keyContactVO.contactName = keyContact.Contact__r.Name;
	            	keyContactVO.contactId = keyContact.Contact__r.Id;
	            	keyContactVO.contactRole = keyContact.Contact_Role__c;
	            	keyContactVO.contactType = keyContact.Contact_Type__c;
	            	keyContactVO.customerBranch = keyContact.Customer_Branch__r.Name;
	            	keyContactVO.customerBranchId = keyContact.Customer_Branch__r.Id;
	            	keyContactVO.id = keyContact.Id;
	            	keyContactVO.Name = keyContact.Name;
	            	 // neelima boppana- added for key contact rewrite 06/29/11
	            	keyContactVO.allBranch=keyContact.All_Branch_Contact__c;
	            	keyContactVO.contactStatus = keyContact.Contact__r.STATUS_ACTIVE__c;
	            	keyContactVO.contactDoNotCall = keyContact.Contact__r.DoNotCall;
	            	keyContactVO.contactSurveyOptOut = keyContact.Contact__r.HasOptedOutofSurvey__c;
	            	keyContactList.add(keyContactVO);
	            	i++;
	            	if (i >= 5) {
	            		displayMoreLink = true;
	            		break;
	            	}
	            }	
	        }
        }
        this.addNewKeyContact = addNewKeyContact();
        system.debug(LoggingLevel.INFO, 'keyContactList size: ' + keyContactList.size());
        system.debug(LoggingLevel.INFO, 'keyContactList : ' + keyContactList);
    }
    
    private KeyContactVO getKeyContactVO(Contact tempContact, RyderGlobalVariables.PrimaryContactRole contactRole) {
    	KeyContactVO keyContactVO = new KeyContactVO();
        keyContactVO.available247 = '';
        keyContactVO.availableFrom = '';
        keyContactVO.availableTo = '';
        keyContactVO.contactName = tempContact.Name;
        keyContactVO.contactId = tempContact.Id;
        if (tempContact.CSI_Contact_Type__c != null && contactRole == RyderGlobalVariables.PrimaryContactRole.CSI) {
           keyContactVO.contactRole = RyderGlobalVariables.CSI_ROLE_TEXT;
           keyContactVO.contactType = tempContact.CSI_Contact_Type__c;
        } 
        if (tempContact.Maintenance_Contact_Type__c != null && contactRole == RyderGlobalVariables.PrimaryContactRole.Maintenance) {
           keyContactVO.contactRole = RyderGlobalVariables.MAINTENANCE_ROLE_TEXT;
           keyContactVO.contactType = tempContact.Maintenance_Contact_Type__c;
        }
        
        keyContactVO.customerBranch = 'All';
        keyContactVO.id = null;
        keyContactVO.Name = '';
        return keyContactVO;
    }

    public String addNewKeyContact() {
    	//Get a reference to the Custom Object and gets its Key
        Schema.DescribeSObjectResult result = Key_Contact__c.sObjectType.getDescribe();
    	//navigate to Add new Page
        PageReference pageRef = New PageReference('/' + result.getKeyPrefix() + '/e?' + RyderGlobalVariables.CUSTOMER_BRANCK_HTML_ID + '=' + System.Encodingutil.urlEncode(this.customerBranch.Name, 'UTF-8') + '&' + RyderGlobalVariables.CUSTOMER_BRANCK_HTML_LK_ID + '=' + this.customerBranch.Id + '&retURL=/' + this.customerBranch.Id);
    	return pageRef.getUrl();
    }
    
     // neelima boppana- added for key contact rewrite 06/29/11
     public static void InsertKeyContactsByCustomerBranch(Map<Id, Customer_Branch__c> newMap)
     {
     	Map<Id,String> branchHqAccounts= new Map<Id,String>();
     	Map<Id,String> contactHqAccounts= new Map<Id,String>();
     	List<Key_Contact__c> keyContactsToInsert=new List<Key_Contact__c>();
     	contactUtil.keyContactRecordTypes=CommonFunctions.getRecordTypeMap('Key_Contact__c');
     	
     	// get the hq accounts on the customers branches.
     	for(Customer_Branch__c cb : newMap.values())
     	{
     		if(cb.Customer_Branch_Status__c=='Active')
     	      branchHqAccounts.put(cb.Id,cb.Ryder_HQ_Account__c );
     	}
     	// get all the customer branches for the  hq account id on the contact. 
        List<Contact>allBranchContacts=[Select c.AccountId, c.Available_24_7__c, c.Available_From__c, c.Available_To__c, c.CSI_Contact_Type__c, HQ_Account_Id_18__c,c.Id, c.Maintenance_Contact_Type__c, c.Original_Account__c,c.Contact_Trigger_Toggle__c from Contact c where c.HQ_Account_Id_18__c in :branchHqAccounts.values() and ((c.CSI_Contact_Type__c!=null)or (c.Maintenance_Contact_Type__c!=null))];
        
    	for(Customer_Branch__c branch: newMap.values())
    	{
    		for(Contact c : allBranchContacts)
    		{
    			if(branch.Ryder_HQ_Account__c==c.HQ_Account_Id_18__c)
    			  {
    			     if (c.CSI_Contact_Type__c!=null) keyContactsToInsert.add(ContactUtil.CreateNewKeyContact(c,branch,RyderGlobalVariables.CSI_ROLE_TEXT,true));
    			     if(c.Maintenance_Contact_Type__c!=null)keyContactsToInsert.add(ContactUtil.CreateNewKeyContact(c,branch,RyderGlobalVariables.MAINTENANCE_ROLE_TEXT,true));
    			  }
    		}
    	}
    	System.debug(LoggingLevel.INFO, '+++++++++++++ keyContactsToInsert:' + keyContactsToInsert);
    	insert keyContactsToInsert;     	
     }
     
      // neelima boppana- added for key contact rewrite 06/29/11
      public static void DeleteKeyContactsByCustomerBranch(Map<Id, Customer_Branch__c> newMap, boolean allBranchOnly)
      {
      	List<Key_Contact__c> keyContactsToDelete=null;
      	if(allBranchOnly)
      	{
        keyContactsToDelete=[Select  k.All_Branch_Contact__c,k.Available_From__c, k.Available_To__c, k.Contact__c, k.Contact_Role__c, k.Contact_Type__c, k.Customer_Branch__c, k.HQ_Account_ID__c, k.Id from Key_Contact__c k where k.Customer_Branch__c in :newMap.keySet() and k.All_Branch_Contact__c=true];
        ContactUtil.isDeleteFromTrigger=true;
      	}
     	//get all the key contacts for the deleted branches 
     	else keyContactsToDelete=[Select  k.All_Branch_Contact__c,k.Available_From__c, k.Available_To__c, k.Contact__c, k.Contact_Role__c, k.Contact_Type__c, k.Customer_Branch__c, k.HQ_Account_ID__c, k.Id from Key_Contact__c k where k.Customer_Branch__c in :newMap.keySet()];
     	System.debug(LoggingLevel.INFO, '+++++++++++++ keyContacts To delete:' + keyContactsToDelete);
     	delete keyContactsToDelete;     	
      }
      
    // This method was added to delete all key contacts from a Customer Branch.  
    public void DeleteAllKEyContactsFromCustomerBranch(){
        List<Key_Contact__c> keyContactsToDelete = new List<Key_Contact__c> ();
        keyContactsToDelete=[Select k.All_Branch_Contact__c,k.Available_From__c, k.Available_To__c, k.Contact__c, k.Contact_Role__c, k.Contact_Type__c, k.Customer_Branch__c, k.HQ_Account_ID__c, k.Id from Key_Contact__c k where k.Customer_Branch__c =:  this.customerBranch.Id];
        if (keyContactsToDelete != null && keyContactsToDelete.size()!=0){
            delete keyContactsToDelete;
            init();
        }  
    }  

}