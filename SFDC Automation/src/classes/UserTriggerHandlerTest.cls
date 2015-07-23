/**=====================================================================
 * Appirio, Inc
 * Name: UserTriggerHandlerTest
 * Created Date: 01-12-2015
 * Created By: Hari Krishnan
 =====================================================================*/
@isTest
public class UserTriggerHandlerTest {
 
     // positive test case 1:
    static testMethod void whenUserCreatedWithValidUTCCode_CreatesUser() {
        Ryder_Branch__c ryderBranch = TestUtilUVS.createRyderBranch();
        User u = TestUtilUVS.createUser(false);
        u.UTC__c = ryderBranch.Branch_Code__c;
        insert u;
        System.assertEquals(u.UTC__c, ryderBranch.Branch_Code__c);
    }
    
    // positive test case 2:
    static testMethod void whenUserUpdatedWithValidUTCCode_UpdatesUser() {
        Ryder_Branch__c ryderBranch = TestUtilUVS.createRyderBranch();
        User u = TestUtilUVS.createUser(true);
        u.UTC__c = ryderBranch.Branch_Code__c;
        update u;
        System.assertEquals(u.UTC__c, ryderBranch.Branch_Code__c);
        
    }
    
    // negative test case 1:
    static testMethod void whenUserCreatedWithInvalidUTCode_ThrowsError() {
        String errorCode= 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
        User u = TestUtilUVS.createUser(false);
        u.UTC__c = 'abcde';
        try {
            insert u;
        }
        catch(DmlException dmle) {
            System.assertEquals(errorCode, dmle.getDmlStatusCode(0));
        }
    }
    
    // negative test case 2:
    static testMethod void whenUserUpdatedWithInvalidUTCode_ThrowsError() {
        String errorCode = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
        User u = TestUtilUVS.createUser(true);
        u.UTC__c = 'abcde';
        try {
            update u;
        }
        catch(DmlException ex) {
            System.assertEquals(errorCode, ex.getDmlStatusCode(0));
        }
    }
}