@isTest (SeeAllData=true)
public class UpdateUTCNameOnUserTriggerHelperTest{

    static List<string> lProfiles = new List<string>(LABEL.UVSProfileForUTC.split(','));
    static User userBDM = createUser(true, 'BDM', 'test1@rydertest.com', 'test1', NULL);
    static User userDAM = createUser(true, 'DAM', 'test2@rydertest.com', 'test2', '03198');    
    static User userVSMVSR = createUser(true, 'VSM_VSR', 'test3@rydertest.com', 'test3', '03196'); 

    static testmethod void UnitTest() 
    {

        Test.startTest();

        userBDM.UTC__c = '03262';
        update userBDM;
                
        userDAM.UTC__c = '03196';
        update userDAM;        
        
        userVSMVSR.UTC__c = '03198';        
        update userVSMVSR;      
        
        Test.stopTest();
        
    }
    
    //create user
    private static User createUser(Boolean isInsert, string strProfileName, string strUserName, string strAlias, string strUTC) {
        Profile p = [select p.id from Profile p where p.Name =: strProfileName LIMIT 1];

        //Creating the user
        User u = new User(Username = strUserName, Alias = strAlias, FirstName = 'Ryder', LastName = 'Tester', 
                        Email = strUserName, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                        LocalesIdKey = 'en_US', ProfileId = p.Id, TimeZonesIdKey = 'America/Los_Angeles',
                        UTC__c = strUTC, isActive = true);
        if(isInsert){
            insert u;
        }
        return u;
    }
}