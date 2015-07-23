trigger SolutionsInterestDuplicateCheck on Solutions_Interest__c (before insert) {

    Map<String, Solutions_Interest__c> solutioninterestsMap = new Map<String, Solutions_Interest__c>();
    String SIMatchKey = '';

   for(Solutions_Interest__c si : Trigger.new)
   {   
        System.debug('1');
        if ((si.Product_Line__c != null && si.Product_Detail__c != null))
        {
            System.debug('2');
            if((si.Lead_Id__c != null) && (Trigger.isInsert))
            {
                System.debug('3');
                SIMatchKey = 'Lead,' + si.Lead_Id__c + ',' + si.Product_Line__c + ',' + si.Product_Detail__c;
                System.debug('SIMatchKey : ' + SIMatchKey);
                if (solutioninterestsMap.containsKey(SIMatchKey))
                {
                    System.debug('4');
                    Trigger.oldMap.get(si.Id).Product_Detail__c.addError('Another new Solution Interest for Lead has the same Product Details');
                } else {
                    System.debug('5');
                    solutioninterestsMap.put(SIMatchKey,si);
                }               
            }
            else
            {
            if((si.Contact_Id__c != null) && (Trigger.isInsert))
            {
                  System.debug('3x');
                   SIMatchKey = 'Contact,' + si.Contact_Id__c + ',' + si.Product_Line__c + ',' + si.Product_Detail__c;
                   System.debug('SIMatchKey : ' + SIMatchKey);
                   if (solutioninterestsMap.containsKey(SIMatchKey))
                   {
                       System.debug('4x');
                       //si.Product_Detail__c.addError('Another new Solution Interest has the same Product Details');
                       Trigger.oldMap.get(si.Id).Product_Detail__c.addError('Another new Solution Interest for Contact has the same Product Details');
                   } else {
                       System.debug('5x');
                       solutioninterestsMap.put(SIMatchKey,si);
                   }               
              }
           }
        }
    }
    
    for (String nsi : solutioninterestsMap.KeySet())
    {
        List<Solutions_Interest__c> lstSI;
        System.debug('nsi - ' + nsi);
        String[] arrsi = nsi.split('\\,');
        System.debug('arrsi[1] -' + arrsi.get(1) + ', arrsi[2] : '  + arrsi.get(2) +  ', arrsi[3] : ' +  arrsi.get(3));
        If (arrsi.get(0) == 'Lead'){
            lstSI = [SELECT Contact_Id__c,Latest_Source__c,Lead_Id__c,Original_Source__c,Product_Detail__c,Product_Line__c,Score__c,Stage__c FROM Solutions_Interest__c WHERE Lead_Id__c =: arrsi.get(1) and Product_Line__c =: arrsi.get(2) and Product_Detail__c =: arrsi.get(3)];
            //List<SolutionsInterest__c> lstSI = [SELECT Contact_Id__c,Latest_Source__c,Lead_Id__c,Original_Source__c,Product_Detail__c,Product_Line__c,Score__c,Stage__c FROM SolutionsInterest__c WHERE Lead_Id__c = '00Q6000000g3JSLEA2' and Product_Line__c = 'Lease' and Product_Detail__c = 'Standard'];
        }else {
            lstSI = [SELECT Contact_Id__c,Latest_Source__c,Lead_Id__c,Original_Source__c,Product_Detail__c,Product_Line__c,Score__c,Stage__c FROM Solutions_Interest__c WHERE Contact_Id__c =: arrsi.get(1) and Product_Line__c =: arrsi.get(2) and Product_Detail__c =: arrsi.get(3)];          
        }
        System.debug('lstSI : ' + lstSI);

            if(lstSI.size() > 0)
            {
                System.debug('6');
                for(Solutions_Interest__c newSI : lstSI)
                {
                    Solutions_Interest__c newsolint = solutioninterestsMap.get(nsi);
                    newsolint.addError('A Solution Interest for with this Details already exists.');
                }
            }   
    }
  
 
}