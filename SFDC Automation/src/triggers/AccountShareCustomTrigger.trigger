trigger AccountShareCustomTrigger on Account (after insert, after update, before delete) {

    List<Account> leligibleAccounts = new List<Account>(); 
    for(Account acct : Trigger.new){
        if((Trigger.oldMap != null) && (Trigger.oldMap.get(acct.Id).OwnerId != acct.OwnerId))
            leligibleAccounts.add(acct);
    }
    
    if (Trigger.isDelete){
        AccountShareCustomTriggerHandler.deleteRecord(Trigger.oldMap);          
    }else{
        if(Trigger.isAfter && ((Trigger.isInsert && LABEL.UVS_Profile_Ids.contains(UserInfo.getProfileId())) || (Trigger.isUpdate && leligibleAccounts != null && leligibleAccounts.size()>0))){
            system.debug('AccountShareCustomTrigger : enter'); 
            AccountShareCustomTriggerHandler.insertRecord(Trigger.new, Trigger.newMap);
        }
    }
}