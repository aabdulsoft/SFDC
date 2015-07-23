trigger deleteContact on Contact (before delete) {
    
   // neelima-04April2012-adding logic to avoid deleting contacts marked as primary for Eloqua synch.
 
    Map<Id,Contact> contactsOKToDelete= new Map<Id,Contact>();
  
    Map<Id,Id>contactsWithRelations= new Map<Id,Id>();
   List<Id> contactids = new List<Id>();
   RecordType rt=[Select Id from RecordType Where Name='Duplicate' AND SObjectType = 'Contact'];
   
   for (Contact c: trigger.old) {
     if (c.Is_Duplicate__c == true)
      contactids.add(c.id);
     if(rt.id == c.RecordTypeId)
      contactids.add(c.id);
    }    
    List<AggregateResult> actlist = [SELECT Count(Id) Total, WhoId FROM Task Where WhoId IN :trigger.old GROUP BY WhoId having count(Id)>0];
    Map<Id, Integer> map1 = new Map<Id, Integer>();
    for(AggregateResult a: actlist)
    {
        string conId=String.valueOf(a.get('WhoId'));
        // collect contact ids with existing activities.
        contactsWithRelations.put(conId,conId);
        //if(Integer.valueOf(a.get('Total')) > 0)
        //map1.put(String.valueOf(a.get('WhoId')),Integer.valueOf(a.get('Total')));
    }
        
     // collect Contact ids related to opportunities.
      List<AggregateResult> contRoleList =[SELECT Count(Id) Total, ContactId FROM OpportunityContactRole WHERE ContactId IN :contactids GROUP BY ContactId HAVING count(Id)>0];
      for(AggregateResult b: contRoleList)
    {
        string conId2=String.valueOf(b.get('ContactId'));
        // collect contact ids with existing activities.
        contactsWithRelations.put(conId2,conId2);
        //if(Integer.valueOf(a.get('Total')) > 0)
        //map1.put(String.valueOf(a.get('WhoId')),Integer.valueOf(a.get('Total')));
    }
       //  Map<Id,Integer> map2 =new Map<Id,Integer>();
       
        for(Contact c: trigger.old)
        {   
   /*   
        if(c.Is_Duplicate__c==false) 
        {
        c.addError('Cannot delete a contact that is already synched with Eloqua');
        }

        else if (c.Is_Duplicate__c== true) {
            //    system.debug('-------30-------');
           if(map1.get(c.Id)!=null) c.addError('Cannot delete a duplicate contact that had activities');
        }   
        else contactsOKToDelete.put(c.Id,c);
        
        */
        
        if (contactsWithRelations.get(c.id) !=null)
        c.addError('Cannot delete a contact that is related to activities,cases or opportunity');
        else contactsOKToDelete.put(c.Id,c);
     
    }
         // DeleteAllBranchContacts method deletes all key contacts if any exist.
 // neelima-april 4th- do not delete key contacts for all contacts in trigger.old. Delete only those key contacts
 // for contacts that are not in Eloqua
          
         // ContactUtil.DeleteAllBranchContacts(Trigger.oldMap,null);
    ContactUtil.DeleteAllBranchContacts(contactsOKToDelete,null);   

    
   }