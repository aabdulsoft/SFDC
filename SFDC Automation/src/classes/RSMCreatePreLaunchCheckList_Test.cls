@isTest
private class RSMCreatePreLaunchCheckList_Test
{
	static testmethod void unitTest()
	{
		Test.startTest();
		RSMCreateTestData.GetCustomSettingsRecord();
        
        Account ac = new Account();
        ac.Name = 'Test Accounts';
        ac.LesseeNo__c ='1234567';
        ac.RSM_AC_Classification__c = 'Key Account';
        ac.RSM_Manual_Update__c = true;
        insert ac;
        
        RSM_Contract__c rCon1=new RSM_Contract__c();    
        rCon1.Name='123';
        rCon1.Lessee__c='1234567';
        rCon1.Status_Name__c = 'Approved';
        rCon1.CreatedDate__c = System.now();
        insert rCon1;
        
        RSM_Contract__c rCon2=new RSM_Contract__c();    
        rCon2.Name='1234';
        rCon2.Lessee__c='1234567';
        rCon2.Status_Name__c = 'Approved';        
        rCon2.CreatedDate__c = System.now();     
        insert rCon2; 
        
        RSMCreatePreLaunchCheckList rcpc = new RSMCreatePreLaunchCheckList();
        //rcpc.query='select Id,Lessee__c,CreatedDate__c from RSM_Contract__c where Id in(\''+rCon1.Id+'\')'; 
        rcpc.query='select Id,LesseeNo__c,RSM_PLC_Flag__c from Account where Id in(\''+ac.Id+'\')';
        Database.executeBatch(rcpc);
        
        Test.stopTest();
    }
}