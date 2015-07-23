/**=============================================================================
 * Created By: Gaurav Gupta (Appirio, Inc)
 * Created Date: [15/10/2014]
 * Description: Test class for BTRDetailController

==============================================================================*/
@
isTest(seealldata = true)
private class BTRDetailControllerTest
{
    //* Group with deveoper name UVS_DAM is mandatory to be there in the org


    static testMethod void myUnitTest()
        {
            Group testGroup = [select id, DeveloperName from group where developername = 'UVS_DAM'];
            UserRole userRoleId = [select Id from UserRole where name = 'VSM/VSR Calgary'];
            User sysAdmin = TestUtilUvs.createAdminUser(false);
            sysAdmin.UserRoleId = userRoleId.id;
            insert sysAdmin;
			
			/*
            UserRole userRoleId_fam = [select Id from UserRole where name = 'FAM Canada'];
            User sysAdmin_fam = TestUtilUvs.createAdminUser(false);
            sysAdmin_fam.UserRoleId = userRoleId_fam.id;
            sysAdmin_fam.Username = 'uvs@rydertest_fam.com';
            insert sysAdmin_fam;
			*/
			
            UserRole userRoleId_dam = [select Id from UserRole where name = 'DAM Canada'];
            User sysAdmin_dam = TestUtilUvs.createAdminUser(false);
            sysAdmin_dam.UserRoleId = userRoleId_dam.id;
            sysAdmin_dam.Username = 'uvs@rydertest_dam.com';
            insert sysAdmin_dam;

            UserRole userRoleId_vam = [select Id from UserRole where name = 'VP Asset Management'];
            User sysAdmin_vam = TestUtilUvs.createAdminUser(false);
            sysAdmin_vam.UserRoleId = userRoleId_vam.id;
            sysAdmin_vam.Username = 'uvs@rydertest_vam.com';
            insert sysAdmin_vam;

            GroupMember gm = new GroupMember();
            gm.GroupId = testGroup.id;
            gm.UserOrGroupId = sysAdmin.id;
            insert gm;
            Group testGroup1 = [select id, DeveloperName from group where developername = 'UVS_VP_AM'];
            GroupMember gm1 = new GroupMember();
            gm1.GroupId = testGroup1.id;
            gm1.UserOrGroupId = sysAdmin.id;
            insert gm1;


            System.runAs(sysAdmin)
            {

                PageReference pgRef = Page.BTRDetail; //Create Page Reference - 'Appt_New' is the name of Page

                Test.setCurrentPage(pgRef); //Set the page for Test Method

                //RyderConfig__c rydConf = new RyderConfig__c();
                //rydConf = TestUtilUVS.createRyderConfig(true);

                //Create Quote
                Account acc = TestUtilUVS.createAccount('Vendor', 'FMS', false);
                acc.SAM_Cust_ID__c = 'abc';
                insert acc;

                Contact newCon = TestUtilUVS.createContact(acc.Id, false);
                newCon.Additional_Comments__c = 'Test1';
                newCon.Email = 'test1@rydertest.com';
                newCon.OwnerId = UserInfo.getUserId();
                newCon.fax = '123456789';
                insert newCon;




                Product2 prod = new Product2();
                prod.Name = 'testUVS123';
                prod.CurrencyIsoCode = 'USD';
                prod.IsActive = true;
                insert prod;

                PriceBookEntry pbe = [SELECT Id, Pricebook2Id
                    FROM PriceBookEntry
                    WHERE Product2Id = : prod.Id
                    LIMIT 1
                ];
                pbe.isActive = true;
                update pbe;

                list < Vehicle__c > veh1 = TestUtilUVS.createVehList(false);
                veh1[0].Account__c = acc.id;
                veh1[0].Overstock__c = false;
                veh1[0].SpecialPrice__c = null;
                veh1[0].Display_Code__c = false;
                //veh1.meq_sale_prc_am__c = true;
                insert veh1[0];
                Opportunity opp = TestUtilUVS.createOpportunity('UVS Opportunity', acc, true, newCon);


                Quote quo = new Quote();
                quo.Name = 'test-Quote UVS';
                quo.Pricebook2Id = pbe.Pricebook2Id;
                quo.OpportunityId = opp.id;
                insert quo;

                QuoteLineItem q = new QuoteLineItem();
                q.Interest_Rate__c = '12';
                q.Term__c = '12';
                q.PriceBookEntryId = pbe.Id;
                q.Quantity = 1;
                q.UnitPrice = 123;
                q.Vehicle__c = veh1[0].Id;
                q.Approval_Level__c = 2;
                q.QuoteId = quo.Id;
                insert q;
                //quo = [select Max_Approval_Level__c  from Quote where id = :quo.id];
                //system.assert(false , quo);
                BTR__c btr = new BTR__c();
                btr.Status__c = 'Submitted - With DAM';
                btr.quote__c = quo.id;
                //btr.Third_Approver__c = sysAdmin_vam.id;
                btr.First_Approver__c= sysAdmin_dam.id;
                btr.Second_Approver__c= sysAdmin_vam.id;
                insert btr;

                // Create an approval request for the btr

                Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
                app.setComments('Pending');

                app.setObjectId(btr.Id);

                // Submit the approval request for the btr

                Approval.ProcessResult result = Approval.process(app);
                // Verify the result
                System.assert(result.isSuccess());
                System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status' + result.getInstanceStatus());

                ApexPages.currentPage().getParameters().put('id', btr.id); //Pass Id to page

                ApexPages.StandardController sc = new ApexPages.standardController(btr);


                BTRDetailController BbtrDetailControllerObj = new BTRDetailController(sc);
                BbtrDetailControllerObj.reject();
                btr = [select Status__c from BTR__c where id = : btr.id];
                system.assertequals(btr.status__c, 'Rejected');
                BbtrDetailControllerObj.cancel();

                BTR__c btr1 = new BTR__c();
                btr1.Status__c = 'Submitted - With VP AM';
                //btr1.Third_Approver__c = sysAdmin_vam.id;
                btr1.First_Approver__c= sysAdmin_dam.id;
                btr1.Second_Approver__c= sysAdmin_vam.id;
                btr1.quote__c = quo.id;
                insert btr1;
                
                BTR__c btr3 = new BTR__c();
                btr3.Status__c = 'Approved';
                //btr3.Third_Approver__c = sysAdmin_vam.id;
		        btr3.First_Approver__c= sysAdmin_dam.id;
		        btr3.Second_Approver__c= sysAdmin_vam.id;
		        btr3.quote__c = quo.id;
                insert btr3;
                
                // Create an approval request for the btr

                Approval.ProcessSubmitRequest app1 = new Approval.ProcessSubmitrequest();
                app1.setComments('Pending');

                app1.setObjectId(btr1.Id);

                // Submit the approval request for the btr

                Approval.ProcessResult result1 = Approval.process(app1);
                // Verify the result
                System.assert(result1.isSuccess());
                System.assertEquals('Pending', result1.getInstanceStatus(), 'Instance Status' + result1.getInstanceStatus());

                ApexPages.currentPage().getParameters().put('id', btr1.id); //Pass Id to page

                ApexPages.StandardController sc1 = new ApexPages.standardController(btr1);


                BTRDetailController BbtrDetailControllerObj1 = new BTRDetailController(sc1);
                BbtrDetailControllerObj1.getIsPageMesssage();
                BbtrDetailControllerObj1.currentUserType = 'DAM';
                BbtrDetailControllerObj1.approve();
                //BbtrDetailControllerObj1.reject();
                //btr1 = [select Status__c from BTR__c where id = : btr1.id];
                //system.assertequals(btr1.status__c, 'Submitted - With VP AM');




            }
        }
         static testMethod void nonSystemAdminRun()
        {


            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Product2 prod = new Product2();
            prod.Name = 'testUVS123';
            prod.CurrencyIsoCode = 'USD';
            prod.IsActive = true;
            insert prod;

            PriceBookEntry pbe = [SELECT Id, Pricebook2Id
                FROM PriceBookEntry
                WHERE Product2Id = : prod.Id
                LIMIT 1
            ];
            pbe.isActive = true;
            update pbe;

            User sysAdmin = TestUtilUvs.createAdminUser(True);



            Account acc = TestUtilUVS.createAccount('Vendor', 'FMS', false);
            acc.SAM_Cust_ID__c = 'abc';
            acc.OwnerId = sysAdmin.Id;
            insert acc;
            Contact newCon = TestUtilUVS.createContact(acc.Id, false);
            newCon.Additional_Comments__c = 'Test1';
            newCon.Email = 'test1@rydertest.com';
            newCon.OwnerId = UserInfo.getUserId();
            newCon.fax = '123456789';
            insert newCon;

            Opportunity opp = new Opportunity();
            opp.Name = 'test Opp';
            opp.Original_Decision_Maker__c = newCon.Id;
            opp.AccountId = acc.Id;
            opp.Estimated_Proposal_Date__c = system.today();
            opp.CloseDate = system.today().addDays(10);
            opp.StageName = 'Solution Hypothesis';
            opp.Purchase_Reason__c = 'End of Lease Sale';
            opp.CurrencyIsoCode = 'USD';
            opp.OwnerId = sysAdmin.Id;
            insert opp;
            Quote quo1 = new Quote();
            quo1.Name = 'test-Quote UVS abc';
            quo1.Pricebook2Id = pbe.Pricebook2Id;
            quo1.OpportunityId = opp.id;
            quo1.Status = 'In Review';
            insert quo1;
         Vehicle__c veh1 = new Vehicle__c();
        veh1.Name = 'test1';
        veh1.Ask_Price__c = 11;
        veh1.Take_Price__c = 11;
        veh1.NBV__c = 11;
              veh1.Account__c = acc.id;
              veh1.Overstock__c = false;
              veh1.SpecialPrice__c = null;
              veh1.Display_Code__c = false;
              insert veh1;


                QuoteLineItem q1 = new QuoteLineItem();
                q1.PriceBookEntryId = pbe.Id;
                q1.Quantity = 1;
                q1.UnitPrice = 123;
                q1.Vehicle__c = veh1.Id;
                q1.Approval_Level__c = 2;
                q1.QuoteId = quo1.Id;
                insert q1;

            BTR__c btr2 = new BTR__c();
            btr2.Status__c = 'Submitted - With FAM';
            btr2.quote__c = quo1.id;
            insert btr2;

            // Create an approval request for the btr
            /*
            Approval.ProcessSubmitRequest app2 = new Approval.ProcessSubmitrequest();
            app2.setComments('Pending');

            app2.setObjectId(btr2.Id);
            

            // Submit the approval request for the btr
            Approval.ProcessResult result1 = Approval.process(app2);
            */
            ApexPages.currentPage().getParameters().put('id', btr2.id); //Pass Id to page

            ApexPages.StandardController sc1 = new ApexPages.standardController(btr2);


            BTRDetailController BbtrDetailControllerObj1 = new BTRDetailController(sc1);
            //BbtrDetailControllerObj1.approve();
            //q1.SpecialPrice__c = 1.0;
            //q1.Display_Code__c = true;
            //q1.Meq_sale_prc_am__c = 1.0;
            //q1.BankOfAmerica__c = true;
            //q1.NonCompliantCAUnits__c = true;
            BTRDetailController.QLIWrapper obj = new BTRDetailController.QLIWrapper(q1,false);
        }
        }
}