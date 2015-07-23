/**=====================================================================
 * Appirio, Inc
 * Name: BTRTriggerHandlerTest
 * Created Date: 10-15-2014
 * Created By: Jyotirmaya Rath
 =====================================================================*/
 @isTest(seeAllData = true)
private class BTRTriggerHandlerTest{

    Static BTR__c BTR ;
    static User uvsUser;
    Static Quote NewQuote = new Quote();
    static testMethod void testBTRTriggerHandler() {
        uvsUser = TestUtilUVS.createAdminUser(true);
        system.runAs(uvsUser) {
        	Test.startTest();
            // Insert New Quote
            NewQuote = TestUtilUVS.createQuote( 'UVS', True);
            // New QLI
            Product2 prod = new Product2();
            prod.Name = 'Standard Price Book UVS';
            prod.CurrencyIsoCode = 'USD';
            insert prod;
            PriceBookEntry pbe = [SELECT Id,Pricebook2Id
                                    FROM PriceBookEntry
                                    WHERE Product2Id = :prod.Id
                                    LIMIT 1];
            pbe.isActive = true;
            update pbe;
            NewQuote.Pricebook2Id = pbe.Pricebook2Id;
            Update NewQuote ;
            List<Vehicle__c> veh = TestUtilUVS.createVehList(true);

            list<QuoteLineItem> lstQuoteLineItem = new List <QuoteLineItem>();
            lstQuoteLineItem.add(new QuoteLineItem( Quantity = 1 ,PriceBookEntryId = pbe.Id, UnitPrice = 21951.0 , Vehicle__c = veh[0].Id,
                                                    QuoteId = newQuote.id,
                                                    Take_Price2__c = 18951 ,
                                                    Interest_Rate__c = '12',
													Term__c = '12'
                                                    ));


            if(lstQuoteLineItem <> NULL){
              insert lstQuoteLineItem;
            }
          //  NewQuote =
          	Test.stopTest();

			//Test.startTest();
            BTR = new BTR__c();
            BTR.Is_Conditional_Approval__c = false ;
            BTR.Quote__c = NewQuote.id;
            BTR.Status__c = 'Submitted - With VP AM';
            Insert BTR;

            BTR = [select Status__c from BTR__c where id = : BTR.id];
            BTR.Status__c = 'Approved';
            Update BTR;
			//Test.stopTest();

            Quote UpdatedQuote = [select id,status from Quote where id =: newQuote.id];
            System.assertequals( UpdatedQuote.status,'BTR Approved');



         }
    }

}