/**=============================================================================
 * Created By: Gaurav Gupta (Appirio, Inc)
 * Created Date: [16/10/2014]
 * Description: Test class for UVS_VehicleStatsController

==============================================================================*/
@isTest
Public class UvsVehicleImageServiceTest {

    Public class MainClientMock implements WebServiceMock {
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
            UvsVehicleImageService.VehiclesSoap testmock=new UvsVehicleImageService.VehiclesSoap();
        }
    }
      
    
    static testMethod void myUnitTest() {
     
     string f;
     User sysAdmin = TestUtilUVS.createAdminUser(true);
     System.runAs(sysAdmin){
     
      RyderConfig__c rdc = TestUtilUVS.createRyderConfig(true);
      
      Product2 prod = new Product2();
      prod.Name = 'Standard Price Book UVS';
      prod.CurrencyIsoCode = 'CAD';
      insert prod;
      
     Account acc = TestUtilUVS.createAccount('Vendor', 'FMS', true);
     Vehicle__c veh = TestUtilUVS.createUVSVehicle(acc, true);
     
     Quote q1 = TestUtilUVS.createQuote('UVS',true);

      
     UvsVehicleImageService uvs=new UvsVehicleImageService();
     UvsVehicleImageService.GetMainImagePathsByVehicleIdNoWatermarkResponse_element test1=new UvsVehicleImageService.GetMainImagePathsByVehicleIdNoWatermarkResponse_element();
     UvsVehicleImageService.GetMainImageFilesByVehicleId_element test2=new UvsVehicleImageService.GetMainImageFilesByVehicleId_element();
     UvsVehicleImageService.GetThumbnailImageResponse_element test3=new UvsVehicleImageService.GetThumbnailImageResponse_element();
     UvsVehicleImageService.ArchivePictures_element test4=new UvsVehicleImageService.ArchivePictures_element();
     UvsVehicleImageService.GetMainImageFilesByVehicleIdResponse_element test5=new UvsVehicleImageService.GetMainImageFilesByVehicleIdResponse_element();
     UvsVehicleImageService.GetMainImagePathsByVehicleId_element test6=new UvsVehicleImageService.GetMainImagePathsByVehicleId_element();
     UvsVehicleImageService.DeleteImage_element test7=new UvsVehicleImageService.DeleteImage_element();
     UvsVehicleImageService.DeleteImageResponse_element test8=new UvsVehicleImageService.DeleteImageResponse_element();
     UvsVehicleImageService.GetImageFilesByVehicleIdResponse_element test9=new UvsVehicleImageService.GetImageFilesByVehicleIdResponse_element();
     UvsVehicleImageService.GetMainImagePathsByVehicleIdResponse_element test10=new UvsVehicleImageService.GetMainImagePathsByVehicleIdResponse_element();
     UvsVehicleImageService.MarshalByRefObject test11=new UvsVehicleImageService.MarshalByRefObject();
     UvsVehicleImageService.GetImageFilesByVehicleId_element test12=new UvsVehicleImageService.GetImageFilesByVehicleId_element();
     UvsVehicleImageService.GetImagesPathsByVehicleId_element test13=new UvsVehicleImageService.GetImagesPathsByVehicleId_element();
     UvsVehicleImageService.AddImageResponse_element test14=new UvsVehicleImageService.AddImageResponse_element();
     UvsVehicleImageService.ArrayOfMemoryStream test15=new UvsVehicleImageService.ArrayOfMemoryStream();
     UvsVehicleImageService.DeleteAllImageResponse_element test16=new UvsVehicleImageService.DeleteAllImageResponse_element(); 
     UvsVehicleImageService.AddImage_element test17=new UvsVehicleImageService.AddImage_element(); 
     UvsVehicleImageService.GetImagesPathsByVehicleIdNoWatermark_element test18=new UvsVehicleImageService.GetImagesPathsByVehicleIdNoWatermark_element(); 
     UvsVehicleImageService.ArrayOfString test19=new UvsVehicleImageService.ArrayOfString(); 
     UvsVehicleImageService.GetImagesPathsByVehicleIdResponse_element test20=new UvsVehicleImageService.GetImagesPathsByVehicleIdResponse_element(); 
     UvsVehicleImageService.ArchivePicturesResponse_element test21=new UvsVehicleImageService.ArchivePicturesResponse_element(); 
     UvsVehicleImageService.GetMainImagePathsByVehicleIdNoWatermark_element test22=new UvsVehicleImageService.GetMainImagePathsByVehicleIdNoWatermark_element(); 
     UvsVehicleImageService.Stream test23=new UvsVehicleImageService.Stream();
     UvsVehicleImageService.MemoryStream test24=new UvsVehicleImageService.MemoryStream();
     UvsVehicleImageService.GetThumbnailImage_element test25=new UvsVehicleImageService.GetThumbnailImage_element();
     UvsVehicleImageService.DeleteAllImage_element test26=new UvsVehicleImageService.DeleteAllImage_element();
     UvsVehicleImageService.GetImagesPathsByVehicleIdNoWatermarkResponse_element test27=new UvsVehicleImageService.GetImagesPathsByVehicleIdNoWatermarkResponse_element();
     UvsVehicleImageService.VehiclesSoap test28=new UvsVehicleImageService.VehiclesSoap ();
     
     Test.setMock(WebServiceMock.class, new MainClientMock());  
     
     Test.startTest();
     test28.GetImagesPathsByVehicleIdNoWatermark(123);
     test28.GetImagesPathsByVehicleId(123);
     test28.GetThumbnailImage('popular');
     test28.DeleteImage('popular');
     test28.GetImageFilesByVehicleId(123);
     test28.GetMainImageFilesByVehicleId(123);
     
     test28.AddImage('popular','popular');
     test28.DeleteAllImage('popular');
     
     
     
     test28.GetMainImagePathsByVehicleIdNoWatermark(123);
     test28.GetMainImagePathsByVehicleId(123);
     
     Test.stopTest();
          
    }
    
  }
}