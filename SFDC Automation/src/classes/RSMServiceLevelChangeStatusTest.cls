@isTest
private class RSMServiceLevelChangeStatusTest {
        
    static testmethod void unitTest()
    {
        RSMCreateTestData.GetCustomSettingsRecord();
        Test.startTest();

        Account Acc1=new Account ();
        Acc1.RSM_Billing__c=true;
        Acc1.Name ='Test Account 1';
        Acc1.LesseeNo__c = '0000001';
        insert Acc1;
        
        Account Acc2=new Account ();
        Acc2.RSM_Billing__c=true;
        Acc2.Name ='Test Account 2';
        Acc2.LesseeNo__c = '0000002';
        insert Acc2;
        
        Customer_Branch__c cb=new Customer_Branch__c();
        cb.Name='Test Customer Branch Acc';
        cb.Ryder_HQ_Account__c=Acc1.Id;
        insert cb;
        
        Vehicle__c v1=new Vehicle__c();
        v1.RSM_Billing_Status__c=True;
        v1.CUSTOMER_BRANCH__c=cb.Id;
        v1.Name='123451';
        v1.Account__c=Acc1.Id;
        v1.RSM__c='Approved';
        v1.RSM_Service_Level__c = 'Plus 1';
        v1.RSM_Service_Level_Prior_value__c = 'Plus';
        insert v1;
        
        Vehicle__c v2=new Vehicle__c();
        v2.RSM_Billing_Status__c=True;
        v2.CUSTOMER_BRANCH__c=cb.Id;
        v2.Name='123452';
        v2.Account__c=Acc1.Id;
        v2.RSM__c='Approved';
        v2.RSM_Service_Level__c = 'Plus 1';
        v2.RSM_Service_Level_Prior_value__c = 'Std';
        insert v2;
        
        Vehicle__c v3=new Vehicle__c();
        v3.RSM_Billing_Status__c=True;
        v3.CUSTOMER_BRANCH__c=cb.Id;
        v3.Name='123453';
        v3.Account__c=Acc1.Id;
        v3.RSM__c='Approved';
        v3.RSM_Service_Level__c = 'Plus';
        v3.RSM_Service_Level_Prior_value__c = 'Std';
        insert v3;
        
        Vehicle__c v4=new Vehicle__c();
        v4.RSM_Billing_Status__c=True;
        v4.CUSTOMER_BRANCH__c=cb.Id;
        v4.Name='123454';
        v4.Account__c=Acc1.Id;
        v4.RSM__c='Approved';
        v4.RSM_Service_Level__c = 'Plus';
        v4.RSM_Service_Level_Prior_value__c = 'Plus 1';
        insert v4;
        
        Vehicle__c v5=new Vehicle__c();
        v5.RSM_Billing_Status__c=True;
        v5.CUSTOMER_BRANCH__c=cb.Id;
        v5.Name='123455';
        v5.Account__c=Acc1.Id;
        v5.RSM__c='Approved';
        v5.RSM_Service_Level__c = 'Std';
        v5.RSM_Service_Level_Prior_value__c = 'Plus';
        insert v5;
        
        Vehicle__c v6=new Vehicle__c();
        v6.RSM_Billing_Status__c=True;
        v6.CUSTOMER_BRANCH__c=cb.Id;
        v6.Name='123456';
        v6.Account__c=Acc1.Id;
        v6.RSM__c='Approved';
        v6.RSM_Service_Level__c = 'Std';
        v6.RSM_Service_Level_Prior_value__c = 'Plus 1';
        insert v6;
        
        Vehicle__c v7=new Vehicle__c();
        v7.RSM_Billing_Status__c=True;
        v7.CUSTOMER_BRANCH__c=cb.Id;
        v7.Name='123457';
        v7.Account__c=Acc1.Id;
        v7.RSM__c='Approved';
        v7.RSM_Service_Level__c = 'Plus 1';
        v7.RSM_Service_Level_Prior_value__c = 'Plus 1';
        v7.RSM_Additional_Services__c = 'Navigation';
        v7.RSM_Addition_Service_prior_count__c = 0;
        insert v7;
        
        Vehicle__c v8=new Vehicle__c();
        v8.RSM_Billing_Status__c=True;
        v8.CUSTOMER_BRANCH__c=cb.Id;
        v8.Name='123458';
        v8.Account__c=Acc1.Id;
        v8.RSM__c='Approved';
        v8.RSM_Service_Level__c = 'Plus 1';
        v8.RSM_Service_Level_Prior_value__c = 'Plus 1';
        v8.RSM_Additional_Services__c = NULL;
        v8.RSM_Addition_Service_prior_count__c = 1;
        insert v8;
        
        Vehicle__c v9=new Vehicle__c();
        v9.Name='123459';
        v9.Account__c=Acc2.Id;
        v9.RSM__c='Approved';
        v9.RSM_Service_Level__c = 'Plus 1';
        v9.RSM_Service_Level_Prior_value__c = 'Plus 1';
        v9.RSM_Additional_Services__c = NULL;
        v9.RSM_Addition_Service_prior_count__c = 1;
        insert v9;
        
        Vehicle__c v=new Vehicle__c();
        v.Name='123450';
        v.Account__c=Acc1.Id;
        v.RSM__c='Approved';
        v.RSM_Service_Level__c = 'Plus 1';
        v.RSM_Service_Level_Prior_value__c = 'Plus 1';
        v.RSM_Additional_Services__c = NULL;
        v.RSM_Addition_Service_prior_count__c = 1;
        insert v;
        
        RSM_Contract__c rc=new RSM_Contract__c();
        rc.Name='98765';
        rc.Lessee__c = '0000001';
        rc.Status_Name__c = 'Approved';
        rc.Account__c = Acc1.id;
        insert rc;
        
        RSM_ContractDetail__c rcd1=new RSM_ContractDetail__c();
        rcd1.Contract_Detail_ID__c = 987651;
        rcd1.Is_Current__c=True;
        rcd1.Unit_Number__c=v1.Id;
        rcd1.Contract_Number__c=rc.Id;
        rcd1.Action_Name__c = 'Add';
        insert rcd1;
        
        RSM_ContractDetail__c rcd2=new RSM_ContractDetail__c();
        rcd2.Contract_Detail_ID__c = 987652;
        rcd2.Is_Current__c=True;
        rcd2.Unit_Number__c=v2.Id;
        rcd2.Contract_Number__c=rc.Id;
        rcd2.Action_Name__c = 'Add';
        insert rcd2;
        
        RSM_ContractDetail__c rcd3=new RSM_ContractDetail__c();
        rcd3.Contract_Detail_ID__c = 987653;
        rcd3.Is_Current__c=True;
        rcd3.Unit_Number__c=v3.Id;
        rcd3.Contract_Number__c=rc.Id;
        rcd3.Action_Name__c = 'Add';
        insert rcd3;
        
        RSM_ContractDetail__c rcd4=new RSM_ContractDetail__c();
        rcd4.Contract_Detail_ID__c = 987654;
        rcd4.Is_Current__c=True;
        rcd4.Unit_Number__c=v4.Id;
        rcd4.Contract_Number__c=rc.Id;
        rcd4.Action_Name__c = 'Add';
        insert rcd4;
        
        RSM_ContractDetail__c rcd5=new RSM_ContractDetail__c();
        rcd5.Contract_Detail_ID__c = 987655;
        rcd5.Is_Current__c=True;
        rcd5.Unit_Number__c=v6.Id;
        rcd5.Contract_Number__c=rc.Id;
        rcd5.Action_Name__c = 'Add';
        insert rcd5;
        
        RSM_ContractDetail__c rcd6=new RSM_ContractDetail__c();
        rcd6.Contract_Detail_ID__c = 987656;
        rcd6.Is_Current__c=True;
        rcd6.Unit_Number__c=v6.Id;
        rcd6.Contract_Number__c=rc.Id;
        rcd6.Action_Name__c = 'Add';
        insert rcd6;
        
        RSM_ContractDetail__c rcd7=new RSM_ContractDetail__c();
        rcd7.Contract_Detail_ID__c = 987657;
        rcd7.Is_Current__c=True;
        rcd7.Unit_Number__c=v7.Id;
        rcd7.Contract_Number__c=rc.Id;
        rcd7.Action_Name__c = 'Add';
        insert rcd7;
        
        RSM_ContractDetail__c rcd8=new RSM_ContractDetail__c();
        rcd8.Contract_Detail_ID__c = 987658;
        rcd8.Is_Current__c=True;
        rcd8.Unit_Number__c=v8.Id;
        rcd8.Contract_Number__c=rc.Id;
        rcd8.Action_Name__c = 'Add';
        insert rcd8;
        
        RSM_ContractDetail__c rcd9=new RSM_ContractDetail__c();
        rcd9.Contract_Detail_ID__c = 987659;
        rcd9.Is_Current__c=True;
        rcd9.Unit_Number__c=v9.Id;
        rcd9.Contract_Number__c=rc.Id;
        rcd9.Action_Name__c = 'Add';
        insert rcd9;
        
        RSM_ContractDetail__c rcd=new RSM_ContractDetail__c();
        rcd.Contract_Detail_ID__c = 987650;
        rcd.Is_Current__c=True;
        rcd.Unit_Number__c=v.Id;
        rcd.Contract_Number__c=rc.Id;
        rcd.Action_Name__c = 'Cancel';
        insert rcd;
        
        RSMServiceLevelChangeStatus rssls= new RSMServiceLevelChangeStatus(); 
        rssls.query='select r.Unit_Number__r.RSM__c, r.Action_Name__c, r.Unit_Number__r.RSM_Add_Service_current_count__c, r.Unit_Number__r.RSM_Addition_Service_prior_count__c, r.Unit_Number__r.RSM_Service_Level__c, r.Unit_Number__r.RSM_Service_Level_Prior_value__c, r.Contract_Number__r.Account__c, r.Unit_Number__c, r.Unit_Number__r.Account__c from RSM_ContractDetail__c r where r.Is_Current__c=true and r.Unit_Number__r.RSM__c=\'Approved\'';
        database.executebatch(rssls);
    }
}