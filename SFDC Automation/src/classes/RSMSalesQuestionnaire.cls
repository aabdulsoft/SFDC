Public class RSMSalesQuestionnaire{

    Public RSM_Sales_Qus__c newRSMSQ {get;set;}
    public String accId{get;set;}
    public String taskId{get;set;}
    Account ac;
    public RSMSalesQuestionnaire(ApexPages.StandardController controller) {
        accId=Apexpages.currentpage().getParameters().get('accId');
        taskId=Apexpages.currentpage().getParameters().get('tId');
        
        newRSMSQ = (RSM_Sales_Qus__c)Controller.getrecord();
        if(accId != null){
            ac=[select Id,OwnerId,AccountNumber,LesseeNo__c,Owner.phone, RSM_Onboarding__c from Account where Id=:accId];
            List<RSM_Sales_Qus__c> lQuestion = [Select r.Title__c, r.Team_Drivers__c, r.SystemModstamp, 
                                                r.Slip_Seating__c, r.Short_Haul__c, r.Sales_Person_Name__c, 
                                                r.Please_describe_the_customer_s_normal_op__c, 
                                                r.Please_describe_the_customer_previous_Te__c, 
                                                r.Please_describe_potential_for_additional__c, 
                                                r.Phone__c, r.Phone_Number__c, r.Name, r.Long_Haul__c, 
                                                r.LastModifiedDate, r.LastModifiedById, r.IsDeleted, r.Id, 
                                                r.How_does_the_customer_intend_to_use_Ryde__c, r.Email__c, 
                                                r.Email_Address__c, r.Does_the_customer_have_specific_ROI_goal__c, 
                                                r.Do_Some_or_All_Drivers_Use_the_Same_Truc__c, r.Date__c, 
                                                r.Customer_RydeSmart_Owner__c, r.Customer_Primary_User__c, 
                                                r.Customer_Primary_RydeSmart_Location__c, r.Customer_Name__c, 
                                                r.Customer_Industry_Business__c,
                                                r.Contact__c, 
                                                r.Can_the_RS_Account_Manager_contact_the_c__c, r.CPU_Title__c, 
                                                r.CPU_Phone__c, r.Are_there_any_shop_specific_information__c, 
                                                r.Additional_Pertinent_Information__c, r.Additional_Customer_RydeSmart_Locations__c, 
                                                r.Account_Number__c From RSM_Sales_Qus__c r where Customer_Name__c =: ac.Id];
            if(lQuestion != null && lQuestion.size() > 0)
            {
                newRSMSQ = lQuestion[0];
            }
            else
            {
                //newRSMSQ.Account_Number__c=ac.AccountNumber;
                newRSMSQ.Account_Number__c=ac.LesseeNo__c;
                newRSMSQ.Customer_Name__c=ac.Id;
                newRSMSQ.Sales_Person_Name__c=ac.OwnerId;
                newRSMSQ.Date__c=System.today();
                newRSMSQ.Phone_Number__c=ac.Owner.phone;
            }
        }
        if(Apexpages.currentpage().getParameters().get('Id')!=null){
            newRSMSQ =[select Id,Additional_Customer_RydeSmart_Locations__c,Title__c,CPU_Title__c,Phone__c,CPU_Phone__c,
            Customer_RydeSmart_Owner__c,Customer_Primary_User__c,Customer_Name__c,
            Customer_Primary_RydeSmart_Location__c,
            Account_Number__c,Sales_Person_Name__c,Date__c,Phone_Number__c,
            Email_Address__c,Email__c,Customer_Industry_Business__c,Contact__c,
            Team_Drivers__c,Short_Haul__c,Slip_Seating__c,Long_Haul__c,
            Do_Some_or_All_Drivers_Use_the_Same_Truc__c,Please_describe_potential_for_additional__c,
            Please_describe_the_customer_s_normal_op__c,Can_the_RS_Account_Manager_contact_the_c__c,
            Please_describe_the_customer_previous_Te__c,How_does_the_customer_intend_to_use_Ryde__c,
            Does_the_customer_have_specific_ROI_goal__c,Are_there_any_shop_specific_information__c,
            Additional_Pertinent_Information__c
            
            from RSM_Sales_Qus__c Where Id=:Apexpages.currentpage().getParameters().get('Id')];    
        }
       
        
    }
        
    Public PageReference Save(){
        
        
        upsert newRSMSQ;
        if(taskId!=null){
        Task updateTask=new Task(Id=taskId,Status='Completed');
        update updateTask;
        }
        if(ac != null)
        {
            ac.RSM_Onboarding__c = 'Researching';
            update ac;
        }
        return new PageReference('/apex/RSM_Sales_Questionnaire_View?id='+newRSMSQ);
    }
}