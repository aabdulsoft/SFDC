trigger InsertUpdateCase on Case (after insert, after update, before insert) 
{
   /*
    *   Associate account if customer branch is populated.
    *   Associate Customer branchc and account if vehicle is populated.
    *   add FIS account.
    */
   system.debug('In Trigger 1');
    if (trigger.isInsert && trigger.isBefore) {
            CaseUtil.associateAccountCustomerBranchInfo(trigger.new);
    }
    //Checks already Triggered or not.
  system.debug('Already Triggered : '+ CaseUtil.isAlreadyTriggered);
  //Trigger is fired when new case created or updated for an existing issue.
  //It is used to send emails to the  Team when a case created or updated and already  cases exist for the same issue.
  //Baskar Venugopal: Created on 05/25/2012.
  if(!CaseUtil.isAlreadyTriggered && trigger.isAfter && (trigger.isInsert || trigger.isUpdate))
  {
        List<Case> allCases = new List<Case>();
        List<String> mailMsgs = new List<String>();
        Map<string,List<Case>> allCaseMap= new Map<string,List<Case>> ();
        List<Id> accountIds= new List<id>();
        List<string> majorCategories= new List<string>();
        List<string> subcategories= new List<string>();
        List<string> excludedCustomers = new List<string>();
        List<string> excludedMajorCategories =  new List<string>();
        List<string> excludedSubCategories = new List<string>();
        excludedCustomers= RyderConfig__c.getOrgDefaults().Duplicate_Case_Excluded_Customers__c.split(',');
        excludedMajorCategories =RyderGlobalVariables.EXCLUDED_MAJOR_CATEGORIES.split(',');
        excludedSubCategories = RyderGlobalVariables.EXCLUDED_SUB_CATEGORIES.split(',');
        system.debug('Excluded Major Catergory' + excludedMajorCategories);
        system.debug('Excluded Sub Catergory' + excludedSubCategories);
        system.debug('Excluded Customers:'+ excludedCustomers);
        for (case c:trigger.new)
        {
            if(c.AccountId!=null)
            {
            	accountIds.add(c.AccountId);
	            if(c.Major_Category__c!=null)
	            { 
	            	majorCategories.add(c.Major_Category__c);
	            	subcategories.add(c.Subcategory__c);
	            }
            }
        }
        
       // allCases = [Select c.AccountId, c.Id, c.Major_Category__c, c.Subcategory__c, c.Account.Name, c.CreatedDate, c.CaseNumber, c.Root_Cause__c, c.Description, c.Status,c.CreatedBy.Email from Case c where  c.CreatedDate=LAST_90_DAYS];
        
        for (case c : [Select c.AccountId, c.Id, c.Major_Category__c, c.Subcategory__c, c.Account.Name, c.CreatedDate, c.CaseNumber, c.Root_Cause__c, c.Description, c.Status,c.CreatedBy.Email from Case c where  c.CreatedDate=LAST_90_DAYS 
                        and  c.AccountId in :accountIds and c.Major_Category__c in :majorCategories and c.Subcategory__c in :subcategories and c.Account.Name not in : excludedCustomers and (Not c.Account.Name like 'Ryder%') and 
                        c.Major_Category__c not in : excludedMajorCategories and c.Subcategory__c not in : excludedSubCategories])
        {
            string key=c.AccountId+'_'+ c.Major_Category__c+' '+ c.Subcategory__c;
            List<Case> existingCases=allCaseMap.get(key);
            if(existingCases==null || existingCases.size()==0) existingCases = new List<Case>();
            existingCases.add(c);
            if(allCaseMap.containsKey(key))allCaseMap.remove(key);
            allCaseMap.put(key,existingCases);
        }
        for(Case newCase: trigger.new)
        {
            if(allCaseMap == null || allCaseMap.size()==0) break;
            string key=newCase.AccountId+'_'+ newCase.Major_Category__c+' '+ newCase.Subcategory__c;
            List<Case> duplicateCases=allCaseMap.get(key);
            system.debug('****duplicateCases****-' + duplicateCases);
            if(duplicateCases!= null && duplicateCases.size()>1)
            {
                // create email message and add to the list of messages
                mailMsgs.add(CaseUtil.ConstructMail(duplicateCases));
                system.debug('MAIL MESSAGES ' + mailMsgs);
                 system.debug('MAIL MESSAGES - AllCaseMap -' + allCaseMap);
                allCaseMap.remove(key);
            }
        }
        if(mailMsgs.size() >0)
        {
            system.debug('Email message size trigger' + mailMsgs.size());
            EMailUtil.sendRyderEmail(mailMsgs,true);
        }
        // call the service with the list of email messages.
        caseUtil.isAlreadyTriggered = true;
        system.debug('Already Triggered : '+ caseUtil.isAlreadyTriggered);
    
  }
}