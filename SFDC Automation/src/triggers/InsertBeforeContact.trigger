//InsertBeforeContact is a trigger that allows the creation of contact on the parent account when contact inserted/updated manually.
//  Swetha Mandadi    |        |08.06.2012 |

trigger InsertBeforeContact on Contact (before insert,before update,after insert,after update) {
    Set<Id> accIdSet = new Set<Id>();
    for(Contact con: Trigger.new) {
        accIdSet.add(con.AccountId);
 
    }
   Map<Id,Account> accMap = new Map<Id,Account>([Select Id,ParentId,Type from Account where Id IN :accIdset And ParentId !=null]);
   System.debug('--------------------'+accMap+'ss'+accidSet);
    
    for (Contact con: Trigger.new) {
         // set marketing address
            if(trigger.isBefore) ContactUtil.SetMarketingAddress(con);
            if(trigger.isUpdate && trigger.isBefore) ContactUtil.SetLastUpdatedDates(con,trigger.oldMap.get(con.Id));
       Account tempAcc =accMap.get (con.AccountId);
       system.debug('----------------'+tempAcc+con.AccountId);
           if (tempAcc !=null) {
            //   if(tempAcc.Type == 'Customer')
                  con.Original_Account__c=con.AccountId;
               con.AccountId =tempAcc.ParentId;
             }
            }
                       
          if (trigger.isInsert && trigger.isAfter) {
            List<AccountContactRole> accContRoleList = new List<AccountContactRole>();
            for (contact c:trigger.new) {
                
                //  //Contact oldCon = Trigger.oldMap.get(c.Id);
                // //     system.debug('--------------------------------------22-------------------------------------------');
                // //    system.debug('------------------------------------------c.AccountId:'+c.AccountId);
                //    // system.debug('------------------------------------------oldCon.AccountId:'+oldCon.AccountId);
                //    // if(c.AccountId!= null && c.AccountId!= oldCon.AccountId) {
                //  //        system.debug('--------------------------------------26-------------------------------------------');
                if(c.Contact_Source__c != 'Lead Conversion') {
                    System.debug('Originalaccount'+ c.Original_Account__c);
                    AccountContactRole accConRole=new  AccountContactRole ();
                    if( c.Original_Account__c!=null)
                        accConRole.AccountId = c.Original_Account__c;
                    else
                        accConRole.AccountId = c.AccountId;
                //  accConRole.AccountId = oldCon.AccountId;
                    accConRole.ContactId = c.Id;
                    accContRoleList.add(accConRole);
                }
                //if(!accContRoleList.isEmpty())  
                //insert accContRoleList;
            }
            if(!accContRoleList.isEmpty())  
                insert accContRoleList;
        }      
    }