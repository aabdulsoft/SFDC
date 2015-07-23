/*************************************************************************************************
Created By:    Jyotirmaya Rath
Date:          October 14, 2014
Description  : Test class for QLIOLISyncManager class
**************************************************************************************************/
@isTest(seeAllData = true)
private class QLIOLISyncManagerTest
{
    static User uvsAdminUser ;
    
    static testMethod void TestOpportunitySyncMultipleUnits()
    {
        uvsAdminUser = TestUtilUVS.createAdminUser(true);
        system.runAs(uvsAdminUser)
        {
        	test.startTest();
        	
        	list<QuoteLineItem> quotelineItemList = new list<QuoteLineItem>();
            Account acc = TestUtilUVS.createAccount('Ryder FMS Parent Account', 'FMS', true);
            Contact con = TestUtilUVS.createContact(acc.Id,True);
                        
            Product2 prod = new Product2();
	        prod.Name = 'Standard Price Book UVS';
	        prod.CurrencyIsoCode = 'CAD';
	        prod.family = 'FSL';
	        insert prod;
	       	
	       	PriceBookEntry pbe = [Select Name ,Product2.Family,Product2.Id, Pricebook2Id , Pricebook2.name , CurrencyIsoCode From PricebookEntry where Pricebook2.name= 'UVS' LIMIT 1];
            pbe.isActive = true;
            update pbe;
            
            String productFamily = pbe.Product2.Family;
            Opportunity opp = TestUtilUVS.createOpportunity('UVS Opportunity', acc, false, con);
            opp.Original_Decision_Maker__c = con.Id;
            opp.Pricebook2Id = pbe.Pricebook2Id;
            opp.CurrencyIsoCode = pbe.CurrencyIsoCode;            
            insert opp;
			
			Quote quote = new Quote();
            quote.Name = 'test-Quote UVS';
            quote.OpportunityId = opp.Id;
            quote.Pricebook2Id = pbe.Pricebook2Id;
            insert quote;
			test.stopTest();
			
			opp = [Select Id, SyncedQuoteId from Opportunity where id= : opp.id limit 1];
            opp.SyncedQuoteId =  Quote.id;
			update opp;
			
			List<QuoteLineItem> lquotelineItem = [Select Id from QuoteLineItem where QuoteId = : quote.Id];
			System.debug('----------QLI Size--1.0->' + lquotelineItem.size());
						
            Vehicle__c veh = new Vehicle__c();
            veh.Name = 'test1';
            veh.Account__c = acc.Id;
            veh.Take_Price__c = 11;
            veh.NBV__c = 11;
            veh.Ask_Price__c = 20000.0;
            insert Veh;
            
            Vehicle__c veh1 = new Vehicle__c();
            veh1.Name = 'test2';
            veh1.Account__c = acc.Id;
            veh1.Take_Price__c = 11;
            veh1.NBV__c = 11;
            veh1.Ask_Price__c = 20000.0;
            insert veh1;
						
            OpportunityLineItem oLI = new OpportunityLineItem();
            oLI.OpportunityId=opp.Id;
            oLI.Unit_Number__c=veh.Id;
            oLI.PricebookEntryId=pbe.Id;
            oLI.Quantity=1;
            oLI.UnitPrice=123;
            oLI.Transaction_Type__c='NewCustomer';
            oLI.Product_Line__c= productFamily;
            oLI.Product_Detail__c='VOSA';
            insert oLI;
            lquotelineItem = [Select Id from QuoteLineItem where QuoteId = : quote.Id];
			System.debug('----------QLI Size--1.1->' + lquotelineItem.size());
			
            OpportunityLineItem oLI1 = new OpportunityLineItem();
            oLI1.OpportunityId=opp.Id;
            oLI1.Unit_Number__c=veh1.Id;
            oLI1.PricebookEntryId=pbe.Id;
            oLI1.Quantity=1;
            oLI1.UnitPrice=123;
            oLI1.Transaction_Type__c='NewCustomer';
            oLI1.Product_Line__c= productFamily;
            oLI1.Product_Detail__c='VOSA';
            insert oLI1;
            
			lquotelineItem = [Select Id from QuoteLineItem where QuoteId = : quote.Id];
			System.debug('----------QLI Size--1.2->' + lquotelineItem.size());
			System.assertEquals(2, lquotelineItem.size());			
		}
    }
    
    
    static testMethod void testSyncQLIOLISyncManager()
    {
        uvsAdminUser = TestUtilUVS.createAdminUser(true);
        system.runAs(uvsAdminUser)
        {
        	test.startTest();
        	list<QuoteLineItem> quotelineItemList = new list<QuoteLineItem>();
            Account acc = TestUtilUVS.createAccount('Ryder FMS Parent Account', 'FMS', true);
            Contact con = TestUtilUVS.createContact(acc.Id,True);
                        
            Product2 prod = new Product2();
	        prod.Name = 'Standard Price Book UVS';
	        prod.CurrencyIsoCode = 'CAD';
	        prod.family = 'FSL';
	        insert prod;
	       	
	       	PriceBookEntry pbe = [Select Name ,Product2.Family,Product2.Id, Pricebook2Id , Pricebook2.name , CurrencyIsoCode From PricebookEntry where Pricebook2.name= 'UVS' LIMIT 1];
            pbe.isActive = true;
            update pbe;
            
            String productFamily = pbe.Product2.Family;
            Opportunity opp = TestUtilUVS.createOpportunity('UVS Opportunity', acc, false, con);
            opp.Original_Decision_Maker__c = con.Id;
            opp.Pricebook2Id = pbe.Pricebook2Id;
            opp.CurrencyIsoCode = pbe.CurrencyIsoCode;            
            insert opp;
			
			Quote quote = new Quote();
            quote.Name = 'test-Quote UVS';
            quote.OpportunityId = opp.Id;
            quote.Pricebook2Id = pbe.Pricebook2Id;
            insert quote;
            
            opp = [Select id,SyncedQuoteId from Opportunity where id=:opp.id limit 1];
            opp.SyncedQuoteId =  Quote.id;
			update opp;

            Vehicle__c veh = new Vehicle__c();
            veh.Name = 'test1';
            veh.Account__c = acc.Id;
            veh.Ask_Price__c = 11;
            veh.Take_Price__c = 11;
            veh.NBV__c = 11;
            veh.Ask_Price__c = 20000.0;
            insert Veh;
            
            Vehicle__c veh1 = new Vehicle__c();
            veh1.Name = 'test1';
            veh1.Account__c = acc.Id;
            veh1.Ask_Price__c = 11;
            veh1.Take_Price__c = 11;
            veh1.NBV__c = 11;
            veh1.Ask_Price__c = 20000.0;
            insert veh1;
			test.stopTest();
            OpportunityLineItem oLI = new OpportunityLineItem();
            oLI.OpportunityId=opp.Id;
            oLI.Unit_Number__c=veh.Id;
            oLI.PricebookEntryId=pbe.Id;
            oLI.Quantity=1;
            oLI.UnitPrice=123;
            oLI.Transaction_Type__c='NewCustomer';
            oLI.Product_Line__c= productFamily;
            oLI.Product_Detail__c='VOSA';
            insert oLI;
            
            OpportunityLineItem oLI1 = new OpportunityLineItem();
            oLI1.OpportunityId=opp.Id;
            oLI1.Unit_Number__c=veh1.Id;
            oLI1.PricebookEntryId=pbe.Id;
            oLI1.Quantity=1;
            oLI1.UnitPrice=123;
            oLI1.Transaction_Type__c='NewCustomer';
            oLI1.Product_Line__c= productFamily;
            oLI1.Product_Detail__c='VOSA';
            insert oLI1;
			
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
			
			QuoteLineItem quoteLI1 =new QuoteLineItem();
            quoteLI1.PriceBookEntryId=pbe.Id;
            quoteLI1.Quantity=1;
            quoteLI1.Quantity__c=1;
            quoteLI1.UnitPrice=123;
            quoteLI1.Vehicle__c = veh1.Id;
            quoteLI1.QuoteId = quote.Id;
			quoteLI1.Interest_Rate__c = '12';
			quoteLI1.Term__c = '12';
            quotelineItemList.add(quoteLI1);
            
            
            try
            {
	        	if(!quotelineItemList.isEmpty())
	        	{
	            	insert quotelineItemList;
	        	}
            }
            catch(Exception ex)
            {
            	system.debug('::test Exception :::'+ex);
            }    
            quoteLI.Quantity=2;
            quoteLI.Quantity__c=2;
            quoteLI.UnitPrice=124;
            try
            {
                Update quoteLI;
            }
            catch(exception e)
            {
              system.debug('=============EXCEPTION===========' + e.getMessage());
            }
            
			Map<Id, OpportunityLineItem> mOLI = new Map<Id, OpportunityLineItem>();
			mOLI.put(oLI.Id, oLI);
			QLIOLISyncManager.syncQuoteLineItems(mOLI, mOLI);
			
			System.assertequals(oLI.Description, quoteLI.Description);
      }

    }
    
   static testMethod void testSyncOLIQLISyncManager() {
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
            prod.family = 'FSL';
            insert prod;


        	 PriceBookEntry pbe = [Select Name ,Product2.Family,Product2.Id, Pricebook2Id , Pricebook2.name , CurrencyIsoCode From PricebookEntry where Pricebook2.name= 'UVS' LIMIT 1];
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

            //opp.SyncedQuoteId = quote.Id;
            //update opp;
            //System.assert([select IsSyncing from Quote where id =:quote.id].IsSyncing);


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
            	system.debug('::Exception ex ::'+ex);
            }

            OpportunityLineItem SyncOLI = [select  id,
                                                    Transaction_Type__c,
                                                    Quantity,
                                                    UnitPrice,
                                                    Unit_Number__c
                                            from OpportunityLineItem
                                            WHERE id =: OLI.id ];
           SyncOLI.Quantity  = 2;
           SyncOLI.Quantity__C = 2;
            SyncOLI.UnitPrice = 124 ;
           // SyncOLI.IsTestRunning__c = true;
            Try {
                Update SyncOLI;
             }
             Catch (Exception e){
                system.debug('::Exception :::'+e);
             }
        }

    }
    
   static testMethod void testSyncQuoteLineItemsOnInsert() {
   	  User uvsUser;
	  Account acc;
	  Contact con;
	  Vehicle__c veh;
	  Product2 prod;
	  Opportunity opp;
	  OpportunityLineItem oli;
	  Quote quote;
	  list<QuoteLineItem> qliList = new list<QuoteLineItem>();
    uvsUser = TestUtilUVS.createUser(true);
    system.runAs(uvsUser) {
    	test.startTest();
    	acc = TestUtilUVS.createAccount('Ryder FMS Parent Account', 'FMS', true);
    	con = TestUtilUVS.createContact(acc.Id,false);
      con.Additional_Comments__c = 'Test1';
      con.Email = 'test2@rydertest.com';
      con.OwnerId = UserInfo.getUserId();
      insert con;
      Test.stopTest();
      prod = new Product2();
	    prod.Name = 'testUVS123';
	    prod.CurrencyIsoCode = 'USD';
	    prod.IsActive = true;

	    insert prod;

	  

		PriceBookEntry pbe = [Select Name , Pricebook2Id , Pricebook2.name , CurrencyIsoCode From PricebookEntry where Pricebook2.name= 'UVS' LIMIT 1];
        pbe.isActive = true;
        update pbe;
      opp = TestUtilUVS.createOpportunity('UVS Opportunity', acc, false, con);
      opp.Original_Decision_Maker__c = con.Id;
      opp.Pricebook2Id = pbe.Pricebook2Id;
      opp.CurrencyIsoCode = pbe.CurrencyIsoCode;
      insert opp;
      veh = TestUtilUVS.createUVSVehicle(acc, true);

      quote = new Quote();
      quote.Name = 'test-Quote UVS';
      quote.OpportunityId = opp.Id;
      quote.Pricebook2Id = pbe.Pricebook2Id;
      //quote.IsSyncing = true;
      insert quote;

      oLI = new OpportunityLineItem();
      oLI.OpportunityId = opp.Id;
      oLI.Unit_Number__c = veh.Id;
      oLI.PricebookEntryId = pbe.Id;
      oLI.Quantity = 1;
      oLI.UnitPrice = 123;
      //oLI.Take_Price__c = 12;
      oLI.Transaction_Type__c = 'New Location';
      oLI.Product_Line__c = 'FSL';
      oLI.Product_Detail__c = 'VOSA';

      
      //insert oLI;


      QuoteLineItem qLI = new QuoteLineItem();
      qLI.PriceBookEntryId = pbe.Id;
      qLI.Quantity = 1;
      qLI.UnitPrice = 123;
      qLI.Vehicle__c = veh.Id;
      qLI.QuoteId = quote.Id;
	  qLI.Interest_Rate__c = '12';
	  qLI.Term__c = '12';
      qliList.add(qLI);

      if(!qliList.isEmpty()) {
      	insert qliList;
      }

      //opp = [Select Id, SyncedQuoteId from Opportunity where Id = :opp.Id limit 1];
      //opp.SyncedQuoteId = quote.Id;

      //update opp;



      //qLI = [select Id, UnitPrice from QuoteLineItem where Id in :qliList].get(0);

      qLI.Approved_Price__c = 1234;
      qLI.Interest_Rate__c = '12';
	  qLI.Term__c = '12';
	  qLI.UnitPrice = 12;
      update qLI;



    }
  }
}