/**=====================================================================
 * Appirio, Inc
 * Name: ImageSelectorController_V1Test
 * Description: Test class for controller class ImageSelectorController_V1
 * Created Date: [12/26/2014]
 * Created By: [Rajeev Arya] (Appirio)
 * Date Modified                Modified By                  Description of the update
 
 =====================================================================*/
@isTest
private class ImageSelectorController_V1Test {

    static Quote quo = new Quote();
    
    private static void createTestData(){
        
        RyderConfig__c rdc = TestUtilUVS.createRyderConfig(true);
        
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
        
        quo = TestUtilUVS.createQuote('UVS', false);
        quo.Selected_Image1__c = 'http://vehicleimages.ryder.com//images/300294.jpg';
        quo.Selected_Image2__c = 'http://vehicleimages.ryder.com//images/300294-1.jpg';
        quo.Selected_Image3__c = 'http://vehicleimages.ryder.com//images/300294-2.jpg';
        quo.Selected_Image4__c = 'http://vehicleimages.ryder.com//images/300294-3.jpg';
        quo.Selected_Image5__c = 'http://vehicleimages.ryder.com//images/300044.jpg';
        quo.Pricebook2Id = pbe.Pricebook2Id;
        insert quo;
        
        
        list < Vehicle__c > veh1 = TestUtilUVS.createVehList(false);
        //veh1[0].Account__c = acc.id;
        veh1[0].Overstock__c = false;
        veh1[0].SpecialPrice__c = null;
        veh1[0].Display_Code__c = false;
        insert veh1[0];
        
        QuoteLineItem q = new QuoteLineItem();
        q.Interest_Rate__c = '12';
        q.Term__c = '12';
        q.PriceBookEntryId = pbe.Id;
        q.Quantity = 1;
        q.UnitPrice = 123;
        q.Vehicle__c = veh1[0].Id;
        q.Approval_Level__c = 3;
        q.QuoteId = quo.Id;
        q.VehicleImage1__c = 'http://vehicleimages.ryder.com//images/300294-4.jpg';
        q.VehicleImage2__c = 'http://vehicleimages.ryder.com//images/300294-5.jpg';
        q.VehicleImage3__c = 'http://vehicleimages.ryder.com//images/300294-6.jpg';
        insert q;
    }
    
    static testMethod void ControllerTest(){
       
        createTestData();
        Test.startTest();
                    
        RyderGlobalVariables.IS_TEST = true;
       
        PageReference quotePage = Page.QuoteVehicleImages_V1;
        Test.setCurrentPage(quotePage);
                    
        // Set the model action
        ApexPages.currentPage().getParameters().put('quoteId', quo.Id);

        // Create a standard controller 
        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(quo); 
        
        //create instance of pages controller
        ImageSelectorController_V1 ImageSelector = new ImageSelectorController_V1(controller);
        //ImageSelectorController_V1.init();
        Test.stopTest();
        
        ImageSelectorController_V1.VehImageWrapper wrap=new ImageSelectorController_V1.VehImageWrapper();
        wrap.imageSelect=true;
        ImageSelector.getorderOptions();
        ImageSelector.removeOpt();
        ImageSelector.validateImageUrl();
        ImageSelector.saveImageUrl();
        ImageSelector.vehMap.put('Test1','1');
        List<String> vehPaths = new List<String>();
        vehPaths.add('Test1');
        ImageSelector.allVehPaths.addall(vehPaths);
        ImageSelector.vehPathsMap.put('1',vehPaths);
        wrap.imageSelect = false;
        wrap.imageURL = 'Test1';
        wrap.vehNo = 'Test1';
        ImageSelector.vehImageWrap.add(wrap);
        ImageSelector.saveImageUrl();
        ImageSelector.closePopup();
        ImageSelector.showPopup();
        ImageSelector.cancel();
          
        ImageSelector.vehiclePaths();
    
    }
}