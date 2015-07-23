/******************************************************************************************
 *	Name    : ProductTriggerHelper
 *  Purpose : Helper class for Trigger on Product2 Object (T-317748)
 *  Author  : Manisha Gupta
 *  Date    : 2014-09-09
 *  Version : 1.0
 *
 *  Modification History
 *	Date	Who		Description
 *
 ********************************************************************************************/
public with sharing class ProductTriggerHelper {
    public static void productAfterInsert(List<Product2> newListProduct){

		PriceBook2 standardPriceBook;
        if (Test.isRunningtest()) {
       		standardPriceBook = new PriceBook2(Id=Test.getStandardPriceBookId());
        }
        else{
         standardPriceBook = [Select Id from PriceBook2
                               where isStandard = true limit 1];
        }                                
        
                                        
                                        
        system.debug('==============Samarth Mathur==============' + standardPriceBook + '=========');
        List<PriceBookEntry> listStandardPriceBookEntries = new list<PriceBookEntry>();
        for(Product2 newProd : newListProduct){
            // Create a standard price book enrty for product if the product belongs to UVS
            if(newProd.Name.contains('UVS')){
                listStandardPriceBookEntries.add(new PriceBookEntry(Pricebook2Id = standardPriceBook.Id,
                                                                Product2Id = newProd.Id,
                                                                UnitPrice = 0.00,
                                                                isActive = false));
            }

        }

        if(!listStandardPriceBookEntries.isEmpty()){
            insert listStandardPriceBookEntries;
        }

    }
}