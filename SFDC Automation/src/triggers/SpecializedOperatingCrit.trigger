/*The safety directors need to be notified when an opportunity is flagged with a "Specialized Operating Criteria".
Whenever the opportunity record is created or updated by a user an email notification is sent to the corresponding 
safety directors based on the opportunity owner region*/

// trigger on opportunity the email notification which occurs on two events (insertion and update)
trigger SpecializedOperatingCrit on Opportunity (after insert, after update)
{
    if(trigger.isAfter)
    { 
        SendEmailToSafetyDirectors(trigger.new, trigger.oldMap);
    }

//create a set of safetydirectors based on the region and generate the email list nased on the Users owner map
    private static void SendEmailToSafetyDirectors(List<Opportunity> lOpp, Map<Id, Opportunity> mOldOpp)
    {
        List<Messaging.SingleEmailMessage> lSendEmail = new List<Messaging.SingleEmailMessage>();
        Set<String> safetyDirectorRegions = new Set<String>{'Northeast','Southeast','Central','West'};
        Map<String, User> safetyDirectorRegionMap = new Map<String, User>();
        Set<Id> sOwnerIds = new Set<Id>();
        Set<Id> sOppIds = new Set<Id>();
        Map<Id, User> ownerUserMap = null;
        for(Opportunity Opp : lOpp)
        {
            String newOperatingCriteria = '';
            String oldOperatingCriteria = '';
            if(Opp.Specialized_Operating_Criteria__c != null)
                newOperatingCriteria = Opp.Specialized_Operating_Criteria__c;
            if(mOldOpp != null && mOldOpp.get(Opp.Id).Specialized_Operating_Criteria__c != null)
                oldOperatingCriteria = mOldOpp.get(Opp.Id).Specialized_Operating_Criteria__c;
            if(newOperatingCriteria != oldOperatingCriteria)
            {
                sOwnerIds.add(Opp.OwnerId);
                sOppIds.add(Opp.Id);
            }
        }
        if(sOppIds.size() > 0)
        {
            ownerUserMap = new Map<Id, User>([Select u.Short_Title__c, u.Region__c, 
                                        u.Id From User u where Id in: sOwnerIds and Region__c != null]);
            
            List<User> lUser = [Select u.Email, u.Short_Title__c, u.Region__c, 
                                u.Id From User u where 
                                Region__c in : safetyDirectorRegions and 
                                Short_Title__c = 'Safety'];
            for(User UserObj : lUser)
            {
                safetyDirectorRegionMap.put(UserObj.Region__c, UserObj);
            }
        
     
            String nEmails = Label.NewsafetyDirectors;
            List<String> eValues = nEmails.split('#');     
            List<Opportunity> lOppty = [Select o.Specialized_Operating_Criteria__c, o.Owner.Region__c, 
                                        o.Owner.Name, o.OwnerId, o.Name, o.Id, o.CreatedDate, o.CloseDate, 
                                        o.Account.OwnerId, o.Account.Owner.Name, o.Account.Name, 
                                        o.Account.Id, o.AccountId From Opportunity o where 
                                        Id in : sOppIds];
            String sEmailContent = 'An opportunity has been flagged with "Specialized Operating Criteria"';
            
            for(Opportunity Opp : lOppty)
            {
                Boolean bAlreadyExist = false;              
                User OwnerU = ownerUserMap.get(Opp.OwnerId);
                String sRegion = '';
                if(OwnerU != null && OwnerU.Region__c != null)
                sRegion = OwnerU.Region__c;
                //User SafetyDirector = safetyDirectorRegionMap.get(sRegion);                
                sEmailContent += '\n\n\n';
                 if(Opp.AccountId != null)
                {
                    sEmailContent += 'Account Name: ' + Opp.Account.Name + '\n';
                    sEmailContent += 'Account Owner: ' + Opp.Account.Owner.Name + '\n';
                }
                 if(Opp.OwnerId != null)
                {
                    sEmailContent += 'Opportunity Owner: ' + Opp.Owner.Name + '\n';
                }
                sEmailContent += 'Opportunity Name: ' + Opp.Name + '\n';
                sEmailContent += 'Created Date: ' + String.valueOf(Opp.CreatedDate) + '\n';
                sEmailContent += 'Close Date: ' + String.valueOf(Opp.CloseDate) + '\n';
                sEmailContent += 'Owner Region: ' + Opp.Owner.Region__c + '\n';
                sEmailContent += 'Specialized Operating Criteria: ' + Opp.Specialized_Operating_Criteria__c + '\n';
                
                List<String> sPicklistValues = String.valueOf(Opp.Specialized_Operating_Criteria__c).split(';');
                for(String sValue : sPicklistValues)
                {
                    Set<String> sEmailAddress = new Set<String>();
                    List<String> lEmailAddress = new List<String>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setPlainTextBody(sEmailContent);
                    System.debug('-----EmailAddress->'+LABEL.SafetyDirectors.split(';')[0].split('#')[1]);
                    System.debug('-----EmailAddress->'+LABEL.SafetyDirectors.split(';')[1].split('#')[1]);
                    if(sValue == 'Parking Lot')
                        sEmailAddress.add(LABEL.SafetyDirectors.split(';')[0].split('#')[1]);
                    else if(sValue == 'Natural Gas')
                        sEmailAddress.add(LABEL.SafetyDirectors.split(';')[1].split('#')[1]);
                    else if(!bAlreadyExist)
                    {
                        for(String sMRegion : safetyDirectorRegionMap.keySet())
                        {
                            bAlreadyExist = true;
                            if(sMRegion.contains(sRegion))
                                sEmailAddress.add(safetyDirectorRegionMap.get(sMRegion).Email);
                                 if(Opp.Owner.Region__c != null && Opp.Owner.Region__c == 'Northeast')
                                sEmailAddress.add(eValues[0].split(',')[2]);
                            if(Opp.Owner.Region__c != null && Opp.Owner.Region__c == 'Central')
                                sEmailAddress.add(eValues[1].split(',')[2]);
                            if(Opp.Owner.Region__c != null && Opp.Owner.Region__c == 'Southeast')
                                sEmailAddress.add(eValues[2].split(',')[2]);
                            if(Opp.Owner.Region__c != null && Opp.Owner.Region__c == 'West')
                                sEmailAddress.add(eValues[3].split(',')[2]);
                            
                        }
                    }
                    
                    for(String uniqueEmail : sEmailAddress)
                    lEmailAddress.add(uniqueEmail);
                        
                    System.debug('-----lEmailAddress->'+lEmailAddress);
                    if(lEmailAddress.size() > 0)
                    {
                        mail.setToAddresses(lEmailAddress);
                        mail.setSubject('An opportunity has been flagged with "Specialized Operating Criteria"');
                        lSendEmail.add(mail);
                    }   
                }
            }
        }
        System.debug('-----lSendEmail->'+lSendEmail);
        if(lSendEmail.size() > 0)
        {
            Messaging.sendEmail(lSendEmail);
        } 
    }  
}