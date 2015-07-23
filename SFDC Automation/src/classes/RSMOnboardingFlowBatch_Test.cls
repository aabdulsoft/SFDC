@isTest
private class RSMOnboardingFlowBatch_Test{

    static testmethod void unitTest(){
    Test.startTest();
	RSMCreateTestData.GetCustomSettingsRecord();
    
    Account Ac=new Account ();
    Ac.Name ='Test';
    Ac.RSM_Onboarding__c='Initiation';
    Ac.RSM_AC_Classification__c='Key Account';
    Ac.RSM_CCMs__c=UserInfo.getUserId();
    Ac.RSM_CCM_manual_Update__c=true;
    insert Ac;
    
    RSMOnboardingFlowBatch robf= new RSMOnboardingFlowBatch (); 
    robf.query='select Id from Account where Id=\''+Ac.Id+'\' Limit 1'; 
    database.executebatch(robf);
    
    Test.stopTest();

}
}