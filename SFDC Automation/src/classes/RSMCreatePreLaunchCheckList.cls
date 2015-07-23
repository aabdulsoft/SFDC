//Batch Class to create 11 records in Pre-Launch checklist object and to populate start and End dates. 
global class RSMCreatePreLaunchCheckList implements Database.Batchable<SObject>{

  public String query;
  global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<Account> scope){
       Set<String> LesseeSet=new Set<String>();
       for(Account acc :scope)
       {
            System.debug('Nitin---acc->'+acc);
            LesseeSet.add(acc.LesseeNo__c);       
       }
       
       Map<String,List<RSM_Contract__c>> rsmCoMap = new Map<String,List<RSM_Contract__c>>();
       List<RSM_Contract__c> rsCoList=[select Id,Lessee__c,CreatedDate__c from RSM_Contract__c where Lessee__c in:LesseeSet and Status_Name__c = 'Approved' order by Lessee__c]; 
       for(RSM_Contract__c rc: rsCoList){
           if(rsmCoMap!=null && rsmCoMap.get(rc.Lessee__c)==null){
               rsmCoMap.put(rc.Lessee__c,new List<RSM_Contract__c>{rc});    
           }else{
               rsmCoMap.get(rc.Lessee__c).add(rc);
           }
       }
       Set<String> LesseeNo =new Set<String>();
       for(String str: rsmCoMap.keyset()){
           if(rsmCoMap.get(str).size() > 0)
           {
               LesseeNo.add(str);
           }        
       }
       System.debug('Nitin---LesseeNo->'+LesseeNo);
    /*   System.debug('Nitin---Account->'+[select Id,LesseeNo__c,RSM_AC_Classification__c from Account]);*/
       List<RSM_Pre_Launch_Checklist__c> preCheckList=new List<RSM_Pre_Launch_Checklist__c>();
       List<Account> listAccounts = [select Id,LesseeNo__c from Account where LesseeNo__c in :LesseeNo and RSM_AC_Classification__c='Key Account'];
       System.debug('Nitin---listAccounts->'+listAccounts);
       for(Account acc: listAccounts){
        acc.RSM_PLC_Flag__c = true;
           for(integer i=0;i<12;i++){
               RSM_Pre_Launch_Checklist__c plc=new RSM_Pre_Launch_Checklist__c();
               plc.Account__c =acc.Id;
               if(i==0){
                   plc.Description__c='Contact Ryder Service Managers for installation prep / Create Install Schedule'; 
                   plc.Start_Date__c= rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date();
                   plc.End_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(5);
               }else if(i==1){
                   plc.Description__c='Finalize custom configurations'; 
                   plc.Start_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(10);
                   plc.End_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(15);
               }else if(i==2){
                   plc.Description__c='Schedule initial training'; 
                   plc.Start_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(15);
                   plc.End_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(15);
               }else if(i==3){
                   plc.Description__c='Installations  begin – Should be automated'; 
                   plc.Start_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(30);
                   plc.End_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(30);
               }else if(i==4){
                   plc.Description__c='Create Master Admin Login for Customer "Super User"'; 
                   plc.Start_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(30);
                   plc.End_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(45);
               }else if(i==5){
                   plc.Description__c='Assist Customer in Creating Driver IDs per best Practice'; 
                   plc.Start_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(30);
                   plc.End_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(45);
               }else if(i==6){
                   plc.Description__c='Finish installations – Should be automated'; 
                   plc.Start_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(45);
                   plc.End_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(45);
               }else if(i==7){
                   plc.Description__c='Schedule weekly status meeting'; 
                   plc.Start_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(52);
                   plc.End_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(52);
               }else if(i==8){
                   plc.Description__c='Complete training'; 
                   plc.Start_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(52);
                   plc.End_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(52);
               }else if(i==9){
                   plc.Description__c='Move to Paperless Only Driver Logs or conduct supplemental driver training'; 
                   plc.Start_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(66);
                   plc.End_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(66);
               }else if(i==10){
                   plc.Description__c='Move to paperless Trip Records'; 
                   plc.Start_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(66);
                   plc.End_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(90);
               }else if(i==11){
                   plc.Description__c='Transition Account to steady state Operations'; 
                   plc.Start_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(90);
                   plc.End_Date__c=rsmCoMap.get(acc.LesseeNo__c)[0].CreatedDate__c.date().addDays(90);
               }
               preCheckList.add(plc);
           }                
       }
       insert preCheckList;
       update listAccounts;
   }

   global void finish(Database.BatchableContext BC){
   }
}