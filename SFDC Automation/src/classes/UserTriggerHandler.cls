/**=====================================================================
 * Appirio, Inc
 * Name: UserTriggerHandler
 * Created Date: 01-12-2015
 * Created By: Hari Krishnan (Appirio)
 =====================================================================*/
public without sharing class UserTriggerHandler {
    /*
     * @description Verifies if the UTC code entered by the user (or through batch load) is a valid UTC code by comparing against the Branch_Code__c field in the Ryder_Branch__c object.
     * @param List<User> A list of User objects.
    */
    public static void verifyUTCCode(List<User> listUsers, Map<Id, User> mapOldUsers) {

        Set<String> setUTCCodes = new Set<String>();
        Set<String> setBranchCodes = new Set<String>();

        // Populate the UTC codes only when the UTC code is either updated or during the user record getting created
        for(User u : listUsers) {
            if((mapOldUsers == null && u.UTC__c != null) || (mapOldUsers != null && u.UTC__c != null && u.UTC__c != mapOldUsers.get(u.Id).UTC__c)) { // for the insert case (where the UTC is filled) and update case
                System.debug(LoggingLevel.DEBUG, '$$$:UserTriggerHandler.VerifyUTCCode(): UTCCode is either updated or user record is inserted; user.Id = ' + u.Id +', user.UserName = ' + u.UserName);
                setUTCCodes.add(u.UTC__c);
            }
        }

        // if there is any records eligible, then perform the validation.
        if(setUTCCodes.size() > 0) {
            // Get the branch code from Ryder Branch object.
            for(Ryder_Branch__c ryderBranch : [SELECT Branch_Code__c FROM Ryder_Branch__c WHERE Branch_Code__c IN :setUTCCodes]) {
                setBranchCodes.add(ryderBranch.Branch_Code__c);
            }
            // Check if the UTC code matches the branch code in Ryder Branch.
            for(User u : listUsers) {
                if(!setBranchCodes.contains(u.UTC__c))
                    u.addError('The UTC code that you entered is not valid. Please enter a valid 5 digit UTC code. ');
            }
        }
        else
            System.debug(LoggingLevel.DEBUG, '$$$:UserTriggerHandler.VerifyUTCCode(): None of the user records that got updated has UTC code changed.');
    }
}