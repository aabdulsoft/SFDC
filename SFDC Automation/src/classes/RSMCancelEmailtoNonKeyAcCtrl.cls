//Controller for VF Component 'RSMCancelEmailtoNonKeyAc Comp'
global class RSMCancelEmailtoNonKeyAcCtrl {

    global String conId {get;set;}
    global String accountName { get{
    	System.debug('Nitin---conId->'+conId);
    	System.debug('Nitin---conId->'+[select Name,LesseeNo__c from Account]);
        List<RSM_Contract__c> rcList=[select Id,Lessee__c,Name from RSM_Contract__c where Id=:conId];
        System.debug('Nitin---rcList->'+rcList);
        if(rcList!=null && rcList.size()>0){
            Account Acc = [select Name from Account where LesseeNo__c=:rcList[0].Lessee__c];
            if(Acc != null)
            	accountName = Acc.Name;
        }
        return accountName; 
    } set; }
    global String contractNumber{get{
        List<RSM_Contract__c> rcList=[select Id,Lessee__c,Name from RSM_Contract__c where Id=:conId];
        if(rcList!=null && rcList.size()>0){
            contractNumber=rcList[0].Name;
        }
        return contractNumber;
    }set;}
    global String vehList { get{
        
        System.debug('conId : '+conId);
        string vehStr='';//***** 
        List<RSM_Contract__c> rc=[select Id,Lessee__c,Name from RSM_Contract__c where Id=:conId];
        if(rc!=null && rc.size()>0){
            Account Acc = [select Name from Account where LesseeNo__c=:rc[0].Lessee__c];
            if(Acc != null)
            	accountName = Acc.Name;
            contractNumber=rc[0].Name;
           
           for(RSM_ContractDetail__c rcd:[select Unit_Number__c,Unit_Number__r.Name from RSM_ContractDetail__c where Contract_Number__c=:rc[0].Id]){
                     
           if(vehStr==''){
               vehStr=rcd.Unit_Number__r.Name;
           }else{
               vehStr=vehStr+' , '+rcd.Unit_Number__r.Name;
               }
           
            } 
        }    
        return vehStr;
    } set; }
   
}