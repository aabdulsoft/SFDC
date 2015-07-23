/**=============================================================================
 * Created By: Gaurav Gupta (Appirio, Inc)
 * Created Date: [15/10/2014]
 * Description: Test class for QuoteTriggerHandler

==============================================================================*/
@isTest(seeAllData = true)
private class QuoteTriggerHandlerTest {

     static User uvsAdminUser ;
     static testMethod void testSyncOLIQLISyncTest() {
       uvsAdminUser = TestUtilUVS.createAdminUser(true);
       system.runAs(uvsAdminUser) {
       Vehicle__c veh = new Vehicle__c();
       list<QuoteLineItem> quotelineItemList = new list<QuoteLineItem>();
            
            Account acc = TestUtilUVS.createAccount('Ryder FMS Parent Account', 'FMS', true);
            Contact con = TestUtilUVS.createContact(acc.Id,True);
            
            Product2 prod = new Product2();
            prod.Name = 'testUVS123';
            prod.CurrencyIsoCode = 'USD';
            prod.IsActive = true;
            prod.family = 'UVS';
            insert prod;


        	 PriceBookEntry pbe = [Select Name ,Product2.Family,Product2.Id, Pricebook2Id , Pricebook2.name , CurrencyIsoCode
        	                       From PricebookEntry where Pricebook2.name= 'UVS' and Product2.Family='UVS' LIMIT 1];
            pbe.isActive = true;
            update pbe;
            
            system.debug('::PBE :::'+pbe);
            String productFamily = pbe.Product2.Family;
test.startTest();
            Opportunity opp = TestUtilUVS.createOpportunity('UVS Opportunity', acc, false, con);
            opp.Original_Decision_Maker__c = con.Id;
            opp.Pricebook2Id = pbe.Pricebook2Id;
            opp.CurrencyIsoCode = pbe.CurrencyIsoCode;
            insert opp;
            Test.stopTest();
            Quote quote = new Quote();
            quote.Name = 'test-Quote UVS';
            quote.OpportunityId = opp.Id;
            quote.Pricebook2Id = pbe.Pricebook2Id;

          //quote.IsSyncing = true;
            insert quote;

            

            veh.Name = 'test1';
            veh.Account__c = acc.Id;
            veh.Ask_Price__c = 11;
            veh.Take_Price__c = 11;
            veh.NBV__c = 11;
            insert Veh ;
         //   veh = TestUtilUVS.createUVSVehicle(acc, true);
			
			 OpportunityLineItem oLI = new OpportunityLineItem();
            oLI.OpportunityId=opp.Id;
            oLI.Unit_Number__c=veh.Id;
            oLI.PricebookEntryId=pbe.Id;
            oLI.Quantity=1;
            oLI.UnitPrice=123;
            oLI.Transaction_Type__c='NewCustomer';
            oLI.Product_Line__c= productFamily;
            oLI.Product_Detail__c='VOSA';
            //oLi.IsTestRunning__c = true;
            insert oLI;
            
            QuoteLineItem quoteLI =new QuoteLineItem();
            quoteLI.PriceBookEntryId=pbe.Id;
            quoteLI.Quantity=1;
            quoteLI.Quantity__c=1;
            quoteLI.UnitPrice=123;
            quoteLI.Vehicle__c = veh.Id;
            quoteLI.QuoteId=quote.Id;
            quoteLI.Interest_Rate__c = '12';
			quoteLI.Term__c = '12';


            quotelineItemList.add(quoteLI);

            try{
	            if(!quotelineItemList.isEmpty()) {
	                insert quotelineItemList;
	            }
            }catch(Exception ex){
            	system.debug(':: >>>Exception ex ::'+ex);
            }
            
           
			oLI.Product_Detail__c='Standard';
			update oLI;
          

            opp.SyncedQuoteId = quote.Id;
            update opp;
            system.debug(':::Opportunity Updated :::'+opp);
            
            ManageStartSync.copyValuesToQLI(quoteLI,oLI);
            ManageStartSync.copyValuesToOLI(quoteLI,oLI);
           
          }

    }
   

}