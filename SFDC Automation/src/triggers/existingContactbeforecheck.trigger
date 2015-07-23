trigger existingContactbeforecheck on Contact (before insert,before update) {
    if(!DedupUtil.doNotCheckForExistingContactEmailDups)
    {
        Map<String, Contact> ConMap = new Map<String, Contact>();
        //string Contact_Source__c;
        //if(Contact_Source != 'Lead Conversion'){
        //system.debug('-------Contact_Source:'+Contact_Source);
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String message = 'A contact with this email address already exists in this account ';
    
        
            for (Contact Contact : Trigger.new) {
                   if ((contact.Contact_Source__c != 'Lead Conversion') && (Contact.Email != null) && 
                    (Trigger.isInsert ||
                    (Contact.Email !=
                       Trigger.oldMap.get(Contact.Id).Email))) {
           
                if (ConMap.containsKey(Contact.Email)) {
                    Contact.Email.addError('Another new contact has the '
                                        + 'same email address.');
                } else {
                    ConMap.put(Contact.Email, Contact);
                }
           }
        }
       
       List<Contact> conList = [SELECT Name,Email, AccountId,FirstName,LastName FROM Contact
                          WHERE Email IN : ConMap.KeySet() and Id not in :Trigger.new];
        Map<String, String> emailErrorMap = new Map<String, String>();
        
        for (Contact Contact : conList) {
            Contact newContact = ConMap.get(Contact.Email);
           // message = '';
            
            if(Contact.AccountId == newContact.AccountId && Contact.FirstName == newContact.FirstName && Contact.LastName == newContact.LastName) {                
                if(emailErrorMap.get(Contact.Email) != null ) {
                    message = emailErrorMap.get(Contact.Email);
                    message = message + ',';
                }
                message = message + '<a href="' + sfdcBaseURL +'/'+ contact.id +'">'+ Contact.Name +'</a>' ;
                emailErrorMap.put(Contact.Email, message);
                system.debug('-------message:'+message);
                newContact.Email.adderror(message);                       
            } else {
                newContact.Is_Duplicate__c=true;
            }
        }
//}
  }            
}