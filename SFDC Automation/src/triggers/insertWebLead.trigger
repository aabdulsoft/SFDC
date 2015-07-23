trigger insertWebLead on Lead (after insert) 
{
   Set<Id> ids=trigger.newmap.keySet();
   List<String> rideIds = new List<String>();
   Map<String,Id> rideUserIdMap = new Map<String,Id>();
   List<Lead> leads= new List<Lead>();
   List<lead> uvsLeads = new List<Lead>();
   List<Lead> leadsToUpdate = new List<Lead>();
   Set<String> postalCodeSet = new Set<String>();
   
   for(Lead ld : [Select Id,OwnerId,Web_Lead_Owner__c,LeadSource,Lead_Source_Detail__c,PostalCode, Is_UVS__c from Lead where id IN :ids ])
    {
    	//AAK 04/02/2015 - Start QC891 Ryder.com Lead to Salesforce (Web to Lead Part 1)
    		// Changes made to accomodoate is_uvs flag
      if(((ld.Leadsource=='Employee Referral' && ld.Lead_Source_Detail__c== 'RIDE Page') || ld.Is_UVS__c) && ld.PostalCode !=null)
      //if(ld.Leadsource=='Employee Referral' && ld.Lead_Source_Detail__c== 'RIDE Page' && ld.PostalCode !=null)
       {
        uvsLeads.add(ld);
        System.debug('@@@Zip code : ' + ld.PostalCode);
        postalCodeSet.add(ld.PostalCode);  
        }
        else if(ld.Web_Lead_Owner__c != null)
        {
        rideIds.add(ld.Web_Lead_Owner__c);
        leads.add(ld); 
        }     
    }
    
    if(uvsLeads.size()>0)
    {
      System.debug('@@@' + postalCodeSet);   
      map<String,Postal_Code__c> postalCodeSelfMap = new map<String,Postal_Code__c>();
      for(Postal_Code__c postCode : [SELECT Postal_Code__c,UVS_Assignee__c FROM Postal_Code__c WHERE Postal_Code__c IN : postalCodeSet]){
        //AAK 04/10/2015 Start - QC 891 removing uvs_Assignee__c taking care lately
        //if(postCode.UVS_Assignee__c !=null && postCode.Postal_Code__c != null)
        if(postCode.Postal_Code__c != null)
        //AAK 04/10/2015 End            
            postalCodeSelfMap.put(postCode.Postal_Code__c ,postCode);                      
          }
      System.debug('@@@' + postalCodeSelfMap);       
      
      for(lead lead :uvsLeads){   
        if(postalCodeSelfMap.containskey(lead.PostalCode))     
         {
         	System.debug('postalCodeSelfMap.get(lead.PostalCode).UVS_Assignee__c ' + postalCodeSelfMap.get(lead.PostalCode).UVS_Assignee__c);
         	System.debug('RyderConfig__c.getOrgDefaults().Default_UVS_Lead_Owner__c ' + RyderConfig__c.getOrgDefaults().Default_UVS_Lead_Owner__c);
         	
         	//AAK 04/10/2015 Start - QC 891 - added to default the leadowner when missing
         	if (postalCodeSelfMap.get(lead.PostalCode).UVS_Assignee__c==null){
         		lead.OwnerId = RyderConfig__c.getOrgDefaults().Default_UVS_Lead_Owner__c;
         	}else{
          		lead.OwnerId = postalCodeSelfMap.get(lead.PostalCode).UVS_Assignee__c;
         	}//AAK 04/10/2015 End
        //  setNewLeadOwners.add(lead.OwnerId);
          lead.Send_Email_to_VSR_VSM__c = true; // to send the notification email. 
          leadsToUpdate.add(lead);       
           }}
      // Add User to Queue - UVS Lead Assignment’ Queue.
      //   addOwnerToQueue(setNewLeadOwners);     
        }
  
        if(rideIds.size()>0)
         {
        //  List<User> rideusers= [Select Id,ride_id__c from User  where  ride_id__c IN :rideIds];
          for (User tempUser : [Select Id,ride_id__c from User  where  ride_id__c IN :rideIds])
            {
            rideUserIdMap.put(tempUser.ride_id__c, tempUser.Id);
            }

         For(Lead lead:leads)
          {

           system.debug(LoggingLevel.INFO, '++++++++++++++++++ Inside trigger old owner ' + lead.OwnerId);
           if (rideUserIdMap.get(lead.Web_Lead_Owner__c) != null)
             {
              lead.OwnerId = rideUserIdMap.get(lead.Web_Lead_Owner__c);
             System.debug(LoggingLevel.INFO, '++++++++++++++++++ Inside trigger old owner ' + lead.OwnerId);
              leadsToUpdate.add(lead); 
             }

            }
            }

  if(leadsToUpdate.size()>0)
    update leadsToUpdate;

}