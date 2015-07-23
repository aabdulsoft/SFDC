/*************************************************************************************************
Created By:    Jyotirmaya.Rath
Date:          October 14, 2014
Description  : Test class for BTRViewController class
**************************************************************************************************/
@isTest(seeAllData = true)
private class BTRViewControllerTest {
    static User uvsUser;
    Static BTRViewController BTRView ;
    Static Quote NewQuote ;
    Static list< BTR__C> BTRList;
     static testMethod void testBTRViewControllerAsVSR() {
       //Creating the VSR user
        uvsUser = TestUtilUVS.createUser(true);
        System.runAs(uvsUser ){
             InsertBTR()   ;
            BTRView = new  BTRViewController ();
            System.assert(BTRView.getItems() != null);
            BTRView.selectView();
        }
     }
      // FAM User
    static testMethod void TestBTRViewControllerAsFAM() {
         uvsUser = TestUtilUVS.createUser(true);
         Profile fAMProfile = [select p.id from Profile p where p.Name in ('FAM') LIMIT 1];
        uvsUser.profileid = FamProfile .id;
        update uvsUser ;


        System.runAs(uvsUser ){


            BTRView = new  BTRViewController ();
            InsertBTR();
            //System.assert(BTRView.isApprovers);
            BTRView.currentUserType = 'FAM';
            Test.startTest();
            BTRView.selectView();
            System.assert(BTRView.getItems() != null);
            BTRView.currentUserType = 'DAM';
            System.assert(BTRView.getItems() != null);

            BTRView.selectView();
            BTRView.currentUserType = 'VP';
            System.assert(BTRView.getItems() != null);

            BTRView.selectView();
            Test.stopTest();
        }
     }
     // ADmin User
     static testMethod void TestBTRViewControllerAsAdmin() {
        uvsUser = TestUtilUVS.createUser(true);
        Profile AdminProfile = [select p.id from Profile p where p.Name in ('System Administrator') LIMIT 1];
        uvsUser.profileid = AdminProfile .id;
        update uvsUser ;

        System.runAs(uvsUser ){
            Test.startTest();
            BTRView = new  BTRViewController ();
            InsertBTR();
        //  System.assert(BTRView.isApprovers);
            BTRView.selectView();
            Test.stopTest();
        }
     }
     private static Void InsertBTR(){
         NewQuote = TestUtilUVS.createQuote( 'UVS', True);
        BTRList = new List<BTR__c>();
        BTRList.add(new BTR__c(Is_Conditional_Approval__c = false,Quote__c =NewQuote.id,Status__c = 'Submitted - With FAM')) ;
        BTRList.add( new BTR__c(Is_Conditional_Approval__c = false,Quote__c =NewQuote.id,Status__c = 'Submitted - With DAM'));
        BTRList.add(new BTR__c(Is_Conditional_Approval__c = false,Quote__c =NewQuote.id,Status__c = 'Submitted - With VP AM'));

        Insert BTRList;
     }
}