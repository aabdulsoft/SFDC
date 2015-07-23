/**=============================================================================
 * Created By: Rahul Aeran (Appirio, Inc)
 * Created Date: [10/10/2014]
 * Description: Test class for BTRVehicleHistoryController

==============================================================================*/
@isTest(SeeAllData=True)
private class BTRVehicleHistoryControllerTest {
    
    Static BTR__c BTR ;
    static User uvsUser;
    Static Quote NewQuote = new Quote();
    static testMethod void testBTRTriggerHandler() {
        uvsUser = TestUtilUVS.createAdminUser(true);
        system.runAs(uvsUser) {
            test.starttest();
            NewQuote = TestUtilUVS.createQuote( 'UVS', True);
            // New QLI
            Product2 prod = new Product2();
            prod.Name = 'Standard Price Book UVS';
            prod.CurrencyIsoCode = 'CAD';
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
            test.stoptest();
          //  NewQuote = 
            BTR = new BTR__c();
            BTR.Is_Conditional_Approval__c = false ;
            BTR.Quote__c = NewQuote.id;
            BTR.Status__c = 'Submitted - With VP AM';
            Insert BTR;
            
            NewQuote = TestUtilUVS.createQuote( 'UVS', True);
            // New QLI

            NewQuote.Pricebook2Id = pbe.Pricebook2Id;
            Update NewQuote ;
            
            
            
            BTR_History__c btrHis = new BTR_History__c();
            btrHis.BTR_Number__c= btr.id;
            btrHis.Vehicle_Number__c = 'test1';
            btrHis.Request_Date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);

            insert btrHis;
            
            System.currentPageReference().getParameters().put('BTRId', BTR.Id);
            System.currentPageReference().getParameters().put('vehNumber', 'test1');
 
            
            BTRVehicleHistoryController controller = new BTRVehicleHistoryController();

    }
}
}