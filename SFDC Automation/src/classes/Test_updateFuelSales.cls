/**
 * This class tests  affects the "updateFuelSales" trigger.
 */
@isTest
public class Test_updateFuelSales {

    private static Account createAccount(){
        Account a = new Account();
        a.BillingState = 'IL';
        a.BillingCountry = 'US';
        a.BillingPostalCode = '33178';
        a.name = 'test account';
        a.Account_Classification__c = 'Local';
        insert a;
        
        return a;
    }

    static testMethod void updateFuleSales(){  
    //It is needed to an Account be created for the master relationship.
    // create the test data

    //Account acctNew = createAccount();
    
    System.debug('aaaaaaaaa Test Started!!');
    
    Fuel_Sales__c fuelSales = new Fuel_Sales__c();
    fuelSales.Ryder_full_service_fuel__c = '25';
    fuelSales.Truck_stop_self_service_fuel__c = '25' ;  
    fuelSales.Bulk_tank_on_yard__c = '25'; 
    fuelSales.Wet_hosing_on_yard__c = '25';
    fuelSales.Account_Name__c = '0016000000YgYI8AAN';//acctNew.Name;
    insert fuelSales;
    
    System.debug('aaaaaaaaa fuelSales: ' + fuelSales);
        
    Task t1 = new Task ();
    t1.Status = 'Not Started';   
    t1.WhatId = fuelSales.Id;   
    insert t1;     
    
    System.debug('aaaaaaaaa fuelSales: ' + t1);
     
     Test.startTest();
     System.debug('aaaaaaaaa Inside begining of Test');
     Fuel_Sales__c fuelSalesOut = [SELECT Id, Name, Full_service_fuel__c  FROM Fuel_Sales__c where Id =: fuelSales.id];
     
     System.debug('aaaaaaaaa fuelSalesOut : ' + fuelSalesOut );
     
     Fuel_Sales__c fuelSales1 = new Fuel_Sales__c();
     fuelSales1.Ryder_full_service_fuel__c = '25';
     fuelSales1.Id = fuelSalesOut.Id;
     update fuelSales1;
     System.debug('aaaaaaaaa fuelSales1: ' + fuelSales1);

     Test.stopTest(); 
    
   }
   

    
}