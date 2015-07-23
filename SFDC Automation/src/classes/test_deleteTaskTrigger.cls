/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class test_deleteTaskTrigger {

    static testMethod void myUnitTest() {
        Account a = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
        a.BillingState = 'IL';
        a.BillingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
        a.BillingCountry = 'US';
        a.ShippingState = 'IL';
        a.ShippingCountry = 'US';
        a.ShippingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
        insert a;
        System.debug('Account - '+a);
        System.assert(a.Id!=null);
        
        User u = TestUtil.createUser();
        insert u;
        
        //share the account to user
        AccountTeamMember temp = new AccountTeamMember();
        temp.UserId = u.Id;
        temp.TeamMemberRole = 'Local Account Manager'; 
        temp.AccountId = a.Id;
        insert temp;
        // Create task
        Task tempTask = new Task();
        tempTask.ActivityDate = System.today();
        tempTask.Subject = 'call';
        tempTask.WhatId = a.Id;
        tempTask.Status = 'Not Started';
        tempTask.Priority = 'Normal';
        system.runAs(u) {
            try {
            insert tempTask;
            delete tempTask;
            } catch(DMLException e) {
               System.assert( e.getMessage().contains('first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Task can not be deleted: []'), e.getMessage() );
                    //Assert Status Code
                    System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' ,e.getDmlStatusCode(0) );   
            }
        }
        //delete tempTask;
    }
}