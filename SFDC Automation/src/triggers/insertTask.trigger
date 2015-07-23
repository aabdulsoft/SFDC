trigger insertTask on Task (after insert) {
    List<Customer_Branch__c> listofCustomerBranches = new List<Customer_Branch__c>();
    Map<String, Id> creditRecordTypes= CommonFunctions.getRecordTypeMap('Task');
    Customer_Branch__c theWhat=null;
    for(Task T: trigger.new)
    {
        //Commented out since the 'after update' will send out the email
        //system.debug('emailemail RecordType' + creditRecordTypes.get('Credit_Activity_Task'));
        //if(T.RecordTypeId == creditRecordTypes.get('Credit_Activity_Task'))
        //{       
            //EmailUtil.sendMailtoUsers('FromInsert', Trigger.newMap);            
        //}   
        if(T.Type!='Survey') return; 
          
        if(t.WhatId!=null) theWhat= new Customer_Branch__c(id=t.WhatId);
        
        if(theWhat != null)
        {
            theWhat.LastSurveyDate__c= System.today();
            listofCustomerBranches.add(thewhat);
        }
    }
    System.debug('*********updating Customer Branches  ' + listofCustomerBranches );
    if (listofCustomerBranches!= null && !listofCustomerBranches.isEmpty()) update listofCustomerBranches;

}