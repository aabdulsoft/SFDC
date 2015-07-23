/**
 *
 */
@isTest(seeAllData=true)
private class SearchMasterInventoryControllerTest {

      static List<Vehicle__c> vehList;

    static testMethod void myUnitTest_Truck() {
        createTestData();
      SearchMasterInventoryController controller = new SearchMasterInventoryController();
      controller.daysAtUTCStartTruck = '2';
      controller.getDescribeSObject();
      controller.getDescribeSearchInput();
      controller.selectedTab = 'Truck';
      controller.searchVehicleInventory_Truck();
      controller.exportToExcel();
      controller.selectTab();
      controller.sortData();
      controller.populateFieldMapping();
      String sortDir =  controller.sortDir;
      controller.getDescribeSObject();
      controller.getDescribeSearchInput();
    }

    static testMethod void myUnitTest_Tractor() {
      createTestData();
      SearchMasterInventoryController controller = new SearchMasterInventoryController();
      controller.daysAtUTCStartTractor = '2';
      controller.getDescribeSObject();
      //controller.customPageSize = '5';
      controller.selectedTab = 'Tractor';
      controller.searchVehicleInventory_Tractor();
      controller.exportToExcel();
      controller.selectTab();
     // controller.setPagination();
      controller.sortData();
    }

    static testMethod void myUnitTest_Trailer() {
      createTestData();
      SearchMasterInventoryController controller = new SearchMasterInventoryController();
      controller.daysAtUTCStartTrailer = '2';
      controller.getDescribeSObject();
      //controller.customPageSize = '5';
      controller.selectedTab = 'Trailer';
      controller.searchVehicleInventory_Trailer();
      controller.exportToExcel();
      controller.selectTab();
      //controller.setPagination();
      controller.sortData();
      //controller.paginateList(vehList);
      List<sObject> searchResultTractors = controller.searchResultTractors;
      List<sObject> searchResultTtucks = controller.searchResultTrucks;
      List<sObject> searchResultTrailers = controller.searchResultTrailers;
      controller.resetTractor();
      controller.resetTrailer();
      controller.resetTruck();

      try {
        controller.getResultFieldSet('VehicleMasterInventorySearchResult_Field');
      }
      catch ( exception ex) {

      }
      ApexPages.StandardController sc = new ApexPages.StandardController(vehlist[0]);
      SearchMasterInventoryController controller1 = new SearchMasterInventoryController(sc);
    }

    static void createTestData () {
        //TestUtilUVS.createCustomSettingData();
      Profile p = [select p.id from Profile p where p.Name = 'System Administrator' LIMIT 1];
      //Creating the user
      User u = new User( Username = 'standarduser@rydertest.com',
                                    Alias = 'standt', FirstName = 'Ryder', LastName = 'Tester', Email = 'standarduser@rydertest.com',
                                    EmailEncodingKey = TestUtil.USER_EMAIL_ENCODING, LanguageLocaleKey = 'en_US',
                                    LocalesIdKey = 'en_US', ProfileId = p.Id, TimeZonesIdKey = TestUtil.USER_TIMEZONE,
                                    isActive = true);
      insert u;
        system.runAs(u) {
            vehList = new List<Vehicle__c>();
            Account acc = TestUtilUVS.createAccount('Vendor', 'FMS', true);
        Vehicle__c veh1 = new Vehicle__c();
        veh1.Name = 'test1';
        veh1.Account__c = acc.Id;
        veh1.Ask_Price__c = 11;
        veh1.Take_Price__c = 11;
        veh1.NBV__c = 11;
        veh1.SAM_CLASS__c = '51 -Truck [No Body] >16K <=26K GVW';
        veh1.Is_Available_For_Sale__c = true;
        veh1.Sold_Flag__c = false;
        veh1.Ask_Price__c = 20000.0;
        vehList.add(veh1);
        Vehicle__c veh6 = new Vehicle__c();
        veh6.Name = 'test1';
        veh6.Account__c = acc.Id;
        veh6.Ask_Price__c = 11;
        veh6.Take_Price__c = 11;
        veh6.NBV__c = 11;
        veh6.SAM_CLASS__c = '51 -Truck [No Body] >16K <=26K GVW';
        veh6.Is_Available_For_Sale__c = true;
        veh6.Sold_Flag__c = false;
        veh6.Availability__c = 'OS in Process';
        veh6.Ask_Price__c = 20000.0;
        vehList.add(veh6);
        Vehicle__c veh2 = new Vehicle__c();
        veh2.Name = 'test2';
        veh2.Account__c = acc.Id;
        veh2.Ask_Price__c = 22;
        veh2.Take_Price__c = 22;
        veh2.NBV__c = 22;
        veh2.SAM_CLASS__c = '130 - S/A Tractor';
        veh2.Is_Available_For_Sale__c = true;
        veh2.Sold_Flag__c = false;
        veh2.Ask_Price__c = 20000.0;
        vehList.add(veh2);
        Vehicle__c veh3 = new Vehicle__c();
        veh3.Name = 'test3';
        veh3.Account__c = acc.Id;
        veh3.Ask_Price__c = 33;
        veh3.Take_Price__c = 33;
        veh3.NBV__c = 33;
        veh3.SAM_CLASS__c = '190 - Flatbed Trailer';
        veh3.Is_Available_For_Sale__c = true;
        veh3.Sold_Flag__c = false;
        veh3.Availability__c = 'Available for Sale';
        veh3.Ask_Price__c = 20000.0;
        vehList.add(veh3);
        Vehicle__c veh4 = new Vehicle__c();
        veh4.Name = 'test4';
        veh4.Account__c = acc.Id;
        veh4.Ask_Price__c = 44;
        veh4.Take_Price__c = 44;
        veh4.NBV__c = 44;
        veh4.SAM_CLASS__c = '190 - Flatbed Trailer';
        veh4.Is_Available_For_Sale__c = true;
        veh4.Sold_Flag__c = false;
        veh4.Availability__c = 'OS in Process';
        veh4.Ask_Price__c = 20000.0;
        vehList.add(veh4);

            insert vehList;

        //  List<Vehicle_List__c> vehicleList = TestUtilUVS.createVehicleList(true);
        }
    }
}