@isTest(SeeAllData=true)
private class SolutionInterestsDuplicateCheckTest {

    //This test is to test the existing Solution Interest record for Lead
    static testmethod void LeadSIDupTest()
    {
        System.debug('enter test');
        Solutions_Interest__c dup1 = new Solutions_Interest__c(Lead_Id__c ='00Q6000000g3JSLEA2',Contact_Id__c=null,Original_Source__c = 'Corporate Marketing',Latest_Source__c='Corporate Marketing',Product_Detail__c='Standard',Product_Line__c='Lease',Stage__c='Pre Inquiry' );
        System.debug('pass insert');
        try {
             System.debug('duplead : ' + dup1);
             insert dup1;
             System.debug('done');
             System.assert(true);
          } catch (DmlException e) {
                System.debug('fail ' + e.getDmlMessage(0));
                System.assert(e.getDmlMessage(0).indexOf('A Solution Interest for with this Details already exists.') > -1);
          }                   
    }

    //This is to test the new Solution Interest record for Lead
    static testmethod void LeadSINewTest()
    {
        System.debug('enter test 2');
        Solutions_Interest__c dup1 = new Solutions_Interest__c(Lead_Id__c ='00Q6000000g3JSLEA2',Contact_Id__c=null,Original_Source__c = 'Corporate Marketing',Latest_Source__c='Corporate Marketing',Product_Detail__c='Flex',Product_Line__c='Lease',Stage__c='Pre Inquiry' );
        System.debug('pass insert 2');
        try {
             System.debug('duplead : ' + dup1);
             insert dup1;
             System.debug('done 2');
             System.assert(true);
          } catch (DmlException e) {
                System.debug('fail 2 : ' + e.getDmlMessage(0));
                System.assert(e.getDmlMessage(0).indexOf('A Solution Interest for with this Details already exists.') > -1);
          }                   
    }

    //This test is to test the existing Solution Interest record for Contact
    static testmethod void ContactSIDupTest()
    {
        System.debug('enter test 3');
        Solutions_Interest__c dup1 = new Solutions_Interest__c(Lead_Id__c =null,Contact_Id__c='0036000001Hukg1AAB',Original_Source__c = 'Corporate Marketing',Latest_Source__c='Corporate Marketing',Product_Detail__c='VOSA',Product_Line__c='Lease',Stage__c='Pre Inquiry' );
        System.debug('pass insert 3');
        try {
             System.debug('dupcont 3 : ' + dup1);
             insert dup1;
             System.debug('done 3');
             System.assert(true);
          } catch (DmlException e) {
                System.debug('fail 3' + e.getDmlMessage(0));
                System.assert(e.getDmlMessage(0).indexOf('A Solution Interest for with this Details already exists.') > -1);
          }                   
    }

    //This is to test the new Solution Interest record for Contact
    static testmethod void ContactSINewTest()
    {
        System.debug('enter test 4');
        Solutions_Interest__c dup1 = new Solutions_Interest__c(Lead_Id__c =null,Contact_Id__c='0036000001Hukg1AAB',Original_Source__c = 'Corporate Marketing',Latest_Source__c='Corporate Marketing',Product_Detail__c='Flex',Product_Line__c='Lease',Stage__c='Pre Inquiry' );
        System.debug('pass insert 4');
        try {
             System.debug('duplead : ' + dup1);
             insert dup1;
             System.debug('done 4');
             System.assert(true);
          } catch (DmlException e) {
                System.debug('fail 4 : ' + e.getDmlMessage(0));
                System.assert(e.getDmlMessage(0).indexOf('A Solution Interest for with this Details already exists.') > -1);
          }                   
    }
    
}