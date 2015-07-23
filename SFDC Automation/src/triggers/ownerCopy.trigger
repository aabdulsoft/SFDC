trigger ownerCopy on Lead (before Insert, before Update) {
      Map<string,Lead> EmailIds= new Map<string,Lead>();
      Map<String, Id> leadRecordTypes= CommonFunctions.getRecordTypeMap('Lead');
     // List<Lead> LeadsToUpdate= new List<Lead>();
      
    // handle arbitrary number of opps
    for(Lead x : Trigger.New)
    {

        // check that owner is a user (not a queue)
        if( ((String)x.OwnerId).substring(0,3) == '005' ){
            x.Owner_Copy__c = x.OwnerId;
        }
        else{
            // in case of Queue we clear out our copy field
            x.Owner_Copy__c = null;
        }
  //Start- neelima- april 19th 2012 - added dedup logic for Eloqua leads    
         if(trigger.isInsert || trigger.isUpdate && trigger.oldMap.get(x.Id).Email!=x.Email)
         {
            //uncheck the duplicate flag so the process can reset again if there is a duplicate 
            x.Is_Duplicate__c=false; 
            x.primary_lead_id__c=null;
            // get a list of email Ids
            if (x.Email !=null && !EmailIds.containskey(x.Email))
            EmailIds.put(x.Email,x);
            else if(x.Email!=null) x.Is_Duplicate__c=true;  
         }          
    }
    
    
    // find out if any leads already exist in SFDC with the email ids 
    List<Lead> existingLeads= [Select Id,Email,RecordTypeId,primary_lead_Id__c,Is_Duplicate__c from Lead where email in :EmailIds.keyset() and is_duplicate__c=false and isConverted=false];
    // set the duplicate flag on the newly created leads if email id already exists in salesforce.
    for (Lead l : existingleads)
    {
        Lead newld= EmailIds.get(l.Email);
        
        // if the new lead is a marketing lead and existing lead is not a marketing lead then the new lead gets preference
        // Added null check--swetha--06/15/12
        if (newld != null && !(newld.RecordTypeId==leadRecordTypes.get('MktAutoLead') && l.RecordTypeId!=leadRecordTypes.get('MktAutoLead')))
        {
        
            newld.Is_Duplicate__c=true;  
            newld.primary_lead_Id__c=l.id; 
            
        }
    /*  {
        l.Is_Duplicate__c=true;  
        //ld. id will be null do tis in the after trigger
        //l.primary_lead_Id__c=ld.id; 
        LeadsToUpdate.add(l);
        }
        else
        {
        newld.Is_Duplicate__c=true;  
        newld.primary_lead_Id__c=l.id; 
        }   
        
    }
    if(LeadsToUpdate.size()>0) update LeadsToUpdate;*/
    }
  //End- neelima- april 19th 2012 - added dedup logic for Eloqua leads 
}