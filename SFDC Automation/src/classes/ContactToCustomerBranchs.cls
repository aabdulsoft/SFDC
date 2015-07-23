public without sharing class ContactToCustomerBranchs {
    public Contact contact {get; set;}
    
    public List<Key_Contact__c> keyContacts {set; get;}
    
    public List<KeyContactVO> keyContactList {set; get;}
    
    public boolean displayMoreLink {set; get;}
    
    public boolean canRenderNewKeyContact {set; get;}
    
    public String addNewKeyContact {get; set;}
    
    public String contactToCustomerBranchRLID {get; set;}
    
    
    public ContactToCustomerBranchs(ApexPages.StandardController stdController) {
        this.contact = (Contact)stdController.getRecord();
        init();
    }
    
    private void init() {
    	this.canRenderNewKeyContact = true;
        this.contactToCustomerBranchRLID = RyderGlobalVariables.CONTACT_TO_CUSTOMER_BRANCH_RLID;
        this.contact = [Select c.addr_verified_date__c, c.VOICE_MAIL__c, c.Title, c.SystemModstamp, c.Survey__c, c.Salutation, c.STATUS_ACTIVE__c, 
            c.SPOUSE_NAME__c, c.ReportsToId,  
            c.CSI_Contact_Type__c, c.Maintenance_Contact_Type__c, 
            c.Phone, c.Personal_Fax__c, c.PAGER__c, c.OwnerId, c.OtherStreet, 
            c.OtherState, c.OtherPostalCode, c.OtherPhone, c.OtherCountry, c.OtherCity, c.ONSITE__c, c.Name, c.MobilePhone, c.MasterRecordId, 
            c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity, c.Legacy_Last_Modified_Date__c, 
            c.Legacy_Last_Modified_By__c, c.Legacy_Contact_Id__c, c.LeadSource, c.LastName, c.LastModifiedDate, c.LastModifiedById, 
            c.LastCUUpdateDate, c.LastCURequestDate, c.LastActivityDate, c.LOC_ID__c, c.Email_does_not_exist__c, c.IsDeleted, c.Id, c.HomePhone, 
            c.HOME_ADD_ID__c, c.HOBBIES__c, c.FirstName, c.Fax, c.EmailBouncedReason, c.EmailBouncedDate, c.Email, c.Description, c.Department, 
            c.DUP_UPD_DATE__c, c.DUP_PROCESSED_DATE__c, c.DUP_PROCESSED_BY__c, c.DUP_GROUP_NO__c, c.DUP_FLAG__c, c.DOB_CARD__c, c.CurrencyIsoCode, 
            c.CreatedDate, c.CreatedById, c.Contact_Type__c, c.CT_NICK_NAME__c, c.CO_ID__c, c.COLLEGE__c, c.COA_CARD__c, c.CHILDREN_DESC__c, 
            c.CELL__c, c.Birthdate, c.BUSS_PHONE2__c, c.BUSS_PHONE2_EXTN__c, c.BUSS_PHONE1_EXTN__c, c.AssistantPhone, c.AssistantName, 
            c.AccountId, c.ASST_PHONE_EXTN__c, c.ANVR_DATE__c, c.ANVR_CARD__c, c.HQ_Account_ID__c,
            c.Account.Type From Contact c
                where c.Id =: this.contact.Id];
        this.displayMoreLink = false;
        this.keyContacts = [Select k.Id, k.Name, k.Customer_Branch__r.Name, k.Customer_Branch__r.Id, k.Contact__r.Id, k.Contact__r.Name, k.Contact_Type__c, k.Contact_Role__c, 
                k.Available_To__c, k.Available_From__c, k.Available_24_7__c, k.All_Branch_Contact__c From Key_Contact__c k where k.Contact__c =: this.contact.Id and k.All_Branch_Contact__c=false LIMIT 6];
        
        this.canRenderNewKeyContact = canKeyContactBeAssociated(this.contact.Account);
        
        this.keyContactList = new List<KeyContactVO>();
        integer i = 0;
        
        if (this.contact.CSI_Contact_Type__c != null) {
            KeyContactVO keyContactVO = new KeyContactVO();
            keyContactVO.available247 = '';
            keyContactVO.availableFrom = '';
            keyContactVO.availableTo = '';
            keyContactVO.contactName = this.contact.Name;
            keyContactVO.contactId = this.contact.Id;
            keyContactVO.contactRole = RyderGlobalVariables.CSI_ROLE_TEXT;
            keyContactVO.contactType = this.contact.CSI_Contact_Type__c;
            keyContactVO.customerBranch = 'All';
            keyContactVO.customerBranchId = null;
            keyContactVO.id = null;
            keyContactVO.Name = '';
            keyContactList.add(keyContactVO);
            i++;
        }
        
        if (this.contact.Maintenance_Contact_Type__c != null) {
            KeyContactVO keyContactVO = new KeyContactVO();
            keyContactVO.available247 = '';
            keyContactVO.availableFrom = '';
            keyContactVO.availableTo = '';
            keyContactVO.contactName = this.contact.Name;
            keyContactVO.contactId = this.contact.Id;
            keyContactVO.contactRole = RyderGlobalVariables.MAINTENANCE_ROLE_TEXT;
            keyContactVO.contactType = this.contact.Maintenance_Contact_Type__c;
            keyContactVO.customerBranch = 'All';
            keyContactVO.customerBranchId = null;
            keyContactVO.id = null;
            keyContactVO.Name = '';
            keyContactList.add(keyContactVO);
            i++;
        }
        

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
                keyContactList.add(keyContactVO);
                i++;
                if (i == 5) {
                    displayMoreLink = true;
                    break;
                }
            }   
        }
        this.addNewKeyContact = addNewKeyContact();
    }
    
    public String addNewKeyContact() {
        //Get a reference to the Custom Object and gets its Key
        Schema.DescribeSObjectResult result = Key_Contact__c.sObjectType.getDescribe();
        //navigate to Add new Page
        PageReference pageRef = New PageReference('/' + result.getKeyPrefix() + '/e?' + RyderGlobalVariables.CONTACT_BRANCK_HTML_ID + '=' + System.Encodingutil.urlEncode(this.contact.Name, 'UTF-8') + '&' + RyderGlobalVariables.CONTACT_BRANCK_HTML_LK_ID + '=' + this.contact.Id + '&retURL=/' + this.contact.Id);
        return pageRef.getUrl();
    }
    
    private boolean canKeyContactBeAssociated(Account acct) {
    	boolean result = true;
 
    	if (acct != null && acct.Type == RyderGlobalVariables.AccountType.Prospect.name()) {
    		result = false;
    		System.debug(LoggingLevel.INFO, '############ Account Type:' + acct.Type);
    	}
    	return result;
    }   
    
    // This method was added to delete all key contacts from a Customer Branch.  
    public void DeleteAllKEyContactsContact(){
        List<Key_Contact__c> keyContactsToDelete = new List<Key_Contact__c> ();
        keyContactsToDelete=[Select k.All_Branch_Contact__c,k.Available_From__c, k.Available_To__c, k.Contact__c, k.Contact_Role__c, k.Contact_Type__c, k.Customer_Branch__c, k.HQ_Account_ID__c, k.Id from Key_Contact__c k where k.Contact__c =: this.contact.Id];
        if (keyContactsToDelete != null && keyContactsToDelete.size()!=0){
            delete keyContactsToDelete;
            init();
        }  
    }  
}