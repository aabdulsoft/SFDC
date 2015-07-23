/**=====================================================================
 * Appirio, Inc
 * Created Date: 10-2-2014
 * Created By: Swathy (Appirio)
 =====================================================================*/
 @isTest
public class ImageSelectorController_Test{

  Public class MainClientMock implements WebServiceMock {
        Vehicle__c veh1;
        public void m1(){
        User sysAdmin = TestUtilUVS.createAdminUser(true);
        System.runAs(sysAdmin){
            RyderConfig__c rdc = TestUtilUVS.createRyderConfig(true);
            Account acc = TestUtilUVS.createAccount('Vendor', 'FMS', true);
            veh1 = TestUtilUVS.createUVSVehicle(acc, true);
        }
        }
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
        ) {
            List<String> resstr=new List<String>();
            resstr.add('test');
            resstr.add('test1');
            UvsVehicleImageService.VehiclesSoap testmock=new UvsVehicleImageService.VehiclesSoap();
            Integer vehicleId = Integer.valueOf(veh1.id);
            UvsVehicleImageService.ArrayOfString arrayofstring = new UvsVehicleImageService.ArrayOfString();
            arrayofstring.string_x = resstr;
        }
    }

  static testMethod void testImageSelectorController(){
    User sysAdmin = TestUtilUVS.createAdminUser(true);
    System.runAs(sysAdmin){
    
      RyderConfig__c rdc = TestUtilUVS.createRyderConfig(true);
      
      Product2 prod = new Product2();
      prod.Name = 'Standard Price Book UVS';
      prod.CurrencyIsoCode = 'CAD';
      insert prod;
      
      Pricebook2 pb = new pricebook2(name='test');
      insert pb;

      PricebookEntry pbe = new PricebookEntry(pricebook2id=pb.id, product2id=prod.id,unitprice=1.0, isActive=true);
      insert pbe;
      
      Account acc = TestUtilUVS.createAccount('Vendor', 'FMS', true);
      Vehicle__c veh = TestUtilUVS.createUVSVehicle(acc, true);
      
      Quote q1 = TestUtilUVS.createQuote('UVS',true);
      q1.pricebook2id=pb.id;
      update q1;
      
      list <QuoteLineItem> lstQuoteLineItem = new List< QuoteLineItem>();
      lstQuoteLineItem.add(new QuoteLineItem( Quantity = 1.0 ,Vehicle__c = veh.id,  quoteid= q1.id,
                                            UnitPrice = 21951.0 , Take_Price2__c = 18951.0,Product2id=prod.id,PricebookEntryId=pbe.id,
                                            Interest_Rate__c = '12',
                                            Term__c = '12'
                                            ));
      insert lstQuoteLineItem;   
        
      PageReference pageRef = Page.QuoteVehicleImages;
      pageRef.getParameters().put('quoteId', q1.id);
      Test.setcurrentpage(pageRef);
      
      ApexPages.StandardController sc = new ApexPages.StandardController(q1);
      ImageSelectorController imgc = new ImageSelectorController(sc);
      ImageSelectorController.VehImageWrapper wrap=new ImageSelectorController.VehImageWrapper();
      //imgc.selectOptionsFromSet();
      imgc.getorderOptions();
      imgc.removeOpt();
      imgc.saveImageUrl();
      imgc.vehMap.put('Test1','1');
      List<String> vehPaths = new List<String>();
      vehPaths.add('Test1');
      imgc.allVehPaths.addall(vehPaths);
      imgc.vehPathsMap.put('1',vehPaths);
      wrap.imageSelect = false;
      wrap.imageURL = 'Test1';
      wrap.vehNo = 'Test1';
      imgc.vehImageWrap.add(wrap);
      imgc.saveImageUrl();
      imgc.closePopup();
      imgc.showPopup();
      imgc.cancel();
      wrap.imageSelect=true;
      
      system.debug('testvehName>>>'+imgc.vehName);
      
      Test.setMock(WebServiceMock.class, new MainClientMock());  
      Test.starttest();
      imgc.vehiclePaths();
      Test.stoptest();
      //ImageSelectorController imgc1 = new ImageSelectorController(sc);
      
    }
  }

}