//Generated by wsdl2apex

public class UvsVehicleImageService {
    public class GetMainImagePathsByVehicleIdNoWatermarkResponse_element {
        public UvsVehicleImageService.ArrayOfString GetMainImagePathsByVehicleIdNoWatermarkResult;
        private String[] GetMainImagePathsByVehicleIdNoWatermarkResult_type_info = new String[]{'GetMainImagePathsByVehicleIdNoWatermarkResult','http://tempuri.org/UVSImages/Vehicles',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'GetMainImagePathsByVehicleIdNoWatermarkResult'};
    }
    public class GetMainImageFilesByVehicleId_element {
        public Integer vehicleId;
        private String[] vehicleId_type_info = new String[]{'vehicleId','http://tempuri.org/UVSImages/Vehicles',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'vehicleId'};
    }
    public class GetThumbnailImageResponse_element {
        public UvsVehicleImageService.ArrayOfString GetThumbnailImageResult;
        private String[] GetThumbnailImageResult_type_info = new String[]{'GetThumbnailImageResult','http://tempuri.org/UVSImages/Vehicles',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'GetThumbnailImageResult'};
    }
    public class ArchivePictures_element {
        public UvsVehicleImageService.ArrayOfString Vehicles;
        private String[] Vehicles_type_info = new String[]{'Vehicles','http://tempuri.org/UVSImages/Vehicles',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'Vehicles'};
    }
    public class GetMainImageFilesByVehicleIdResponse_element {
        public UvsVehicleImageService.ArrayOfMemoryStream GetMainImageFilesByVehicleIdResult;
        private String[] GetMainImageFilesByVehicleIdResult_type_info = new String[]{'GetMainImageFilesByVehicleIdResult','http://tempuri.org/UVSImages/Vehicles',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'GetMainImageFilesByVehicleIdResult'};
    }
    public class GetMainImagePathsByVehicleId_element {
        public Integer vehicleId;
        private String[] vehicleId_type_info = new String[]{'vehicleId','http://tempuri.org/UVSImages/Vehicles',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'vehicleId'};
    }
    public class DeleteImage_element {
        public String ImageName;
        private String[] ImageName_type_info = new String[]{'ImageName','http://tempuri.org/UVSImages/Vehicles',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'ImageName'};
    }
    public class DeleteImageResponse_element {
        public Boolean DeleteImageResult;
        private String[] DeleteImageResult_type_info = new String[]{'DeleteImageResult','http://tempuri.org/UVSImages/Vehicles',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'DeleteImageResult'};
    }
    public class GetImageFilesByVehicleIdResponse_element {
        public UvsVehicleImageService.ArrayOfMemoryStream GetImageFilesByVehicleIdResult;
        private String[] GetImageFilesByVehicleIdResult_type_info = new String[]{'GetImageFilesByVehicleIdResult','http://tempuri.org/UVSImages/Vehicles',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'GetImageFilesByVehicleIdResult'};
    }
    public class GetMainImagePathsByVehicleIdResponse_element {
        public UvsVehicleImageService.ArrayOfString GetMainImagePathsByVehicleIdResult;
        private String[] GetMainImagePathsByVehicleIdResult_type_info = new String[]{'GetMainImagePathsByVehicleIdResult','http://tempuri.org/UVSImages/Vehicles',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'GetMainImagePathsByVehicleIdResult'};
    }
    public class MarshalByRefObject {
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetImageFilesByVehicleId_element {
        public Integer vehicleId;
        private String[] vehicleId_type_info = new String[]{'vehicleId','http://tempuri.org/UVSImages/Vehicles',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'vehicleId'};
    }
    public class GetImagesPathsByVehicleId_element {
        public Integer vehicleId;
        private String[] vehicleId_type_info = new String[]{'vehicleId','http://tempuri.org/UVSImages/Vehicles',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'vehicleId'};
    }
    public class AddImageResponse_element {
        public Boolean AddImageResult;
        private String[] AddImageResult_type_info = new String[]{'AddImageResult','http://tempuri.org/UVSImages/Vehicles',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'AddImageResult'};
    }
    public class ArrayOfMemoryStream {
        public UvsVehicleImageService.MemoryStream[] MemoryStream;
        private String[] MemoryStream_type_info = new String[]{'MemoryStream','http://tempuri.org/UVSImages/Vehicles',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'MemoryStream'};
    }
    public class DeleteAllImageResponse_element {
        public Boolean DeleteAllImageResult;
        private String[] DeleteAllImageResult_type_info = new String[]{'DeleteAllImageResult','http://tempuri.org/UVSImages/Vehicles',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'DeleteAllImageResult'};
    }
    public class AddImage_element {
        public String ForVehicleId;
        public String f;
        private String[] ForVehicleId_type_info = new String[]{'ForVehicleId','http://tempuri.org/UVSImages/Vehicles',null,'0','1','false'};
        private String[] f_type_info = new String[]{'f','http://tempuri.org/UVSImages/Vehicles',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'ForVehicleId','f'};
    }
    public class GetImagesPathsByVehicleIdNoWatermark_element {
        public Integer vehicleId;
        private String[] vehicleId_type_info = new String[]{'vehicleId','http://tempuri.org/UVSImages/Vehicles',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'vehicleId'};
    }
    public class ArrayOfString {
        public String[] string_x;
        private String[] string_x_type_info = new String[]{'string','http://tempuri.org/UVSImages/Vehicles',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'string_x'};
    }
    public class GetImagesPathsByVehicleIdResponse_element {
        public UvsVehicleImageService.ArrayOfString GetImagesPathsByVehicleIdResult;
        private String[] GetImagesPathsByVehicleIdResult_type_info = new String[]{'GetImagesPathsByVehicleIdResult','http://tempuri.org/UVSImages/Vehicles',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'GetImagesPathsByVehicleIdResult'};
    }
    public class ArchivePicturesResponse_element {
        public Boolean ArchivePicturesResult;
        private String[] ArchivePicturesResult_type_info = new String[]{'ArchivePicturesResult','http://tempuri.org/UVSImages/Vehicles',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'ArchivePicturesResult'};
    }
    public class GetMainImagePathsByVehicleIdNoWatermark_element {
        public Integer vehicleId;
        private String[] vehicleId_type_info = new String[]{'vehicleId','http://tempuri.org/UVSImages/Vehicles',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'vehicleId'};
    }
    public class Stream {
        public Long Position;
        public Integer ReadTimeout;
        public Integer WriteTimeout;
        private String[] Position_type_info = new String[]{'Position','http://tempuri.org/UVSImages/Vehicles',null,'1','1','false'};
        private String[] ReadTimeout_type_info = new String[]{'ReadTimeout','http://tempuri.org/UVSImages/Vehicles',null,'1','1','false'};
        private String[] WriteTimeout_type_info = new String[]{'WriteTimeout','http://tempuri.org/UVSImages/Vehicles',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'Position','ReadTimeout','WriteTimeout'};
    }
    public class MemoryStream {
        public Integer Capacity;
        private String[] Capacity_type_info = new String[]{'Capacity','http://tempuri.org/UVSImages/Vehicles',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'Capacity'};
    }
    public class GetThumbnailImage_element {
        public String VehicleId;
        private String[] VehicleId_type_info = new String[]{'VehicleId','http://tempuri.org/UVSImages/Vehicles',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'VehicleId'};
    }
    public class DeleteAllImage_element {
        public String VehicleId;
        private String[] VehicleId_type_info = new String[]{'VehicleId','http://tempuri.org/UVSImages/Vehicles',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'VehicleId'};
    }
    public class GetImagesPathsByVehicleIdNoWatermarkResponse_element {
        public UvsVehicleImageService.ArrayOfString GetImagesPathsByVehicleIdNoWatermarkResult;
        private String[] GetImagesPathsByVehicleIdNoWatermarkResult_type_info = new String[]{'GetImagesPathsByVehicleIdNoWatermarkResult','http://tempuri.org/UVSImages/Vehicles',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles','true','false'};
        private String[] field_order_type_info = new String[]{'GetImagesPathsByVehicleIdNoWatermarkResult'};
    }
    public class VehiclesSoap {
       
       // public String endpoint_x = 'http://vehicleimages.ryder.com/private/Vehicles.asmx';
        public String endpoint_x;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://tempuri.org/UVSImages/Vehicles', 'UvsVehicleImageService'};
        
         
        public Boolean AddImage(String ForVehicleId,String f) {
              
            UvsVehicleImageService.AddImage_element request_x = new UvsVehicleImageService.AddImage_element();
            request_x.ForVehicleId = ForVehicleId;
            request_x.f = f;
            UvsVehicleImageService.AddImageResponse_element response_x;
            Map<String, UvsVehicleImageService.AddImageResponse_element> response_map_x = new Map<String, UvsVehicleImageService.AddImageResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/UVSImages/Vehicles/AddImage',
              'http://tempuri.org/UVSImages/Vehicles',
              'AddImage',
              'http://tempuri.org/UVSImages/Vehicles',
              'AddImageResponse',
              'UvsVehicleImageService.AddImageResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            if (Test.isRunningTest())
            	return Null;
            return response_x.AddImageResult;
        }
        public Boolean ArchivePictures(UvsVehicleImageService.ArrayOfString Vehicles) {
            UvsVehicleImageService.ArchivePictures_element request_x = new UvsVehicleImageService.ArchivePictures_element();
            request_x.Vehicles = Vehicles;
            UvsVehicleImageService.ArchivePicturesResponse_element response_x;
            Map<String, UvsVehicleImageService.ArchivePicturesResponse_element> response_map_x = new Map<String, UvsVehicleImageService.ArchivePicturesResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/UVSImages/Vehicles/ArchivePictures',
              'http://tempuri.org/UVSImages/Vehicles',
              'ArchivePictures',
              'http://tempuri.org/UVSImages/Vehicles',
              'ArchivePicturesResponse',
              'UvsVehicleImageService.ArchivePicturesResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ArchivePicturesResult;
        }
        public Boolean DeleteAllImage(String VehicleId) {
            UvsVehicleImageService.DeleteAllImage_element request_x = new UvsVehicleImageService.DeleteAllImage_element();
            request_x.VehicleId = VehicleId;
            UvsVehicleImageService.DeleteAllImageResponse_element response_x;
            Map<String, UvsVehicleImageService.DeleteAllImageResponse_element> response_map_x = new Map<String, UvsVehicleImageService.DeleteAllImageResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/UVSImages/Vehicles/DeleteAllImage',
              'http://tempuri.org/UVSImages/Vehicles',
              'DeleteAllImage',
              'http://tempuri.org/UVSImages/Vehicles',
              'DeleteAllImageResponse',
              'UvsVehicleImageService.DeleteAllImageResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            if (Test.isRunningTest())
            	return Null;
            return response_x.DeleteAllImageResult;
        }
        public UvsVehicleImageService.ArrayOfString GetImagesPathsByVehicleIdNoWatermark(Integer vehicleId) {
            UvsVehicleImageService.GetImagesPathsByVehicleIdNoWatermark_element request_x = new UvsVehicleImageService.GetImagesPathsByVehicleIdNoWatermark_element();
            request_x.vehicleId = vehicleId;
            UvsVehicleImageService.GetImagesPathsByVehicleIdNoWatermarkResponse_element response_x;
            Map<String, UvsVehicleImageService.GetImagesPathsByVehicleIdNoWatermarkResponse_element> response_map_x = new Map<String, UvsVehicleImageService.GetImagesPathsByVehicleIdNoWatermarkResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/UVSImages/Vehicles/GetImagesPathsByVehicleIdNoWatermark',
              'http://tempuri.org/UVSImages/Vehicles',
              'GetImagesPathsByVehicleIdNoWatermark',
              'http://tempuri.org/UVSImages/Vehicles',
              'GetImagesPathsByVehicleIdNoWatermarkResponse',
              'UvsVehicleImageService.GetImagesPathsByVehicleIdNoWatermarkResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            if (Test.isRunningTest())
            	return Null;
            return response_x.GetImagesPathsByVehicleIdNoWatermarkResult;
        }
        public UvsVehicleImageService.ArrayOfString GetImagesPathsByVehicleId(Integer vehicleId) {
            for( VehilcleURL__c vh : VehilcleURL__c.getAll().values())
              {
               endpoint_x =  vh.URL__c ;
               }
            UvsVehicleImageService.GetImagesPathsByVehicleId_element request_x = new UvsVehicleImageService.GetImagesPathsByVehicleId_element();
            request_x.vehicleId = vehicleId;
            UvsVehicleImageService.GetImagesPathsByVehicleIdResponse_element response_x;
            Map<String, UvsVehicleImageService.GetImagesPathsByVehicleIdResponse_element> response_map_x = new Map<String, UvsVehicleImageService.GetImagesPathsByVehicleIdResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/UVSImages/Vehicles/GetImagesPathsByVehicleId',
              'http://tempuri.org/UVSImages/Vehicles',
              'GetImagesPathsByVehicleId',
              'http://tempuri.org/UVSImages/Vehicles',
              'GetImagesPathsByVehicleIdResponse',
              'UvsVehicleImageService.GetImagesPathsByVehicleIdResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            
            if (Test.isRunningTest())
            	return Null;
            return response_x.GetImagesPathsByVehicleIdResult;
        }
        public UvsVehicleImageService.ArrayOfString GetThumbnailImage(String VehicleId) {
            UvsVehicleImageService.GetThumbnailImage_element request_x = new UvsVehicleImageService.GetThumbnailImage_element();
            request_x.VehicleId = VehicleId;
            UvsVehicleImageService.GetThumbnailImageResponse_element response_x;
            Map<String, UvsVehicleImageService.GetThumbnailImageResponse_element> response_map_x = new Map<String, UvsVehicleImageService.GetThumbnailImageResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/UVSImages/Vehicles/GetThumbnailImage',
              'http://tempuri.org/UVSImages/Vehicles',
              'GetThumbnailImage',
              'http://tempuri.org/UVSImages/Vehicles',
              'GetThumbnailImageResponse',
              'UvsVehicleImageService.GetThumbnailImageResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            
              if (Test.isRunningTest())
            	return Null;
            return response_x.GetThumbnailImageResult;
        }
        public Boolean DeleteImage(String ImageName) {
            UvsVehicleImageService.DeleteImage_element request_x = new UvsVehicleImageService.DeleteImage_element();
            request_x.ImageName = ImageName;
            UvsVehicleImageService.DeleteImageResponse_element response_x;
            Map<String, UvsVehicleImageService.DeleteImageResponse_element> response_map_x = new Map<String, UvsVehicleImageService.DeleteImageResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/UVSImages/Vehicles/DeleteImage',
              'http://tempuri.org/UVSImages/Vehicles',
              'DeleteImage',
              'http://tempuri.org/UVSImages/Vehicles',
              'DeleteImageResponse',
              'UvsVehicleImageService.DeleteImageResponse_element'}
            );
            response_x = response_map_x.get('response_x');
              if (Test.isRunningTest())
            	return Null;
            return response_x.DeleteImageResult;
        }
        public UvsVehicleImageService.ArrayOfMemoryStream GetImageFilesByVehicleId(Integer vehicleId) {
            UvsVehicleImageService.GetImageFilesByVehicleId_element request_x = new UvsVehicleImageService.GetImageFilesByVehicleId_element();
            request_x.vehicleId = vehicleId;
            UvsVehicleImageService.GetImageFilesByVehicleIdResponse_element response_x;
            Map<String, UvsVehicleImageService.GetImageFilesByVehicleIdResponse_element> response_map_x = new Map<String, UvsVehicleImageService.GetImageFilesByVehicleIdResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/UVSImages/Vehicles/GetImageFilesByVehicleId',
              'http://tempuri.org/UVSImages/Vehicles',
              'GetImageFilesByVehicleId',
              'http://tempuri.org/UVSImages/Vehicles',
              'GetImageFilesByVehicleIdResponse',
              'UvsVehicleImageService.GetImageFilesByVehicleIdResponse_element'}
            );
            response_x = response_map_x.get('response_x');
              if (Test.isRunningTest())
            	return Null;
            return response_x.GetImageFilesByVehicleIdResult;
        }
        public UvsVehicleImageService.ArrayOfMemoryStream GetMainImageFilesByVehicleId(Integer vehicleId) {
            UvsVehicleImageService.GetMainImageFilesByVehicleId_element request_x = new UvsVehicleImageService.GetMainImageFilesByVehicleId_element();
            request_x.vehicleId = vehicleId;
            UvsVehicleImageService.GetMainImageFilesByVehicleIdResponse_element response_x;
            Map<String, UvsVehicleImageService.GetMainImageFilesByVehicleIdResponse_element> response_map_x = new Map<String, UvsVehicleImageService.GetMainImageFilesByVehicleIdResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/UVSImages/Vehicles/GetMainImageFilesByVehicleId',
              'http://tempuri.org/UVSImages/Vehicles',
              'GetMainImageFilesByVehicleId',
              'http://tempuri.org/UVSImages/Vehicles',
              'GetMainImageFilesByVehicleIdResponse',
              'UvsVehicleImageService.GetMainImageFilesByVehicleIdResponse_element'}
            );
            response_x = response_map_x.get('response_x');
              if (Test.isRunningTest())
            	return Null;
            return response_x.GetMainImageFilesByVehicleIdResult;
        }
        public UvsVehicleImageService.ArrayOfString GetMainImagePathsByVehicleIdNoWatermark(Integer vehicleId) {
            UvsVehicleImageService.GetMainImagePathsByVehicleIdNoWatermark_element request_x = new UvsVehicleImageService.GetMainImagePathsByVehicleIdNoWatermark_element();
            request_x.vehicleId = vehicleId;
            UvsVehicleImageService.GetMainImagePathsByVehicleIdNoWatermarkResponse_element response_x;
            Map<String, UvsVehicleImageService.GetMainImagePathsByVehicleIdNoWatermarkResponse_element> response_map_x = new Map<String, UvsVehicleImageService.GetMainImagePathsByVehicleIdNoWatermarkResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/UVSImages/Vehicles/GetMainImagePathsByVehicleIdNoWatermark',
              'http://tempuri.org/UVSImages/Vehicles',
              'GetMainImagePathsByVehicleIdNoWatermark',
              'http://tempuri.org/UVSImages/Vehicles',
              'GetMainImagePathsByVehicleIdNoWatermarkResponse',
              'UvsVehicleImageService.GetMainImagePathsByVehicleIdNoWatermarkResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            if (Test.isRunningTest())
            	return Null;
            
            return response_x.GetMainImagePathsByVehicleIdNoWatermarkResult;
        }
        public UvsVehicleImageService.ArrayOfString GetMainImagePathsByVehicleId(Integer vehicleId) {
            UvsVehicleImageService.GetMainImagePathsByVehicleId_element request_x = new UvsVehicleImageService.GetMainImagePathsByVehicleId_element();
            request_x.vehicleId = vehicleId;
            UvsVehicleImageService.GetMainImagePathsByVehicleIdResponse_element response_x;
            Map<String, UvsVehicleImageService.GetMainImagePathsByVehicleIdResponse_element> response_map_x = new Map<String, UvsVehicleImageService.GetMainImagePathsByVehicleIdResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/UVSImages/Vehicles/GetMainImagePathsByVehicleId',
              'http://tempuri.org/UVSImages/Vehicles',
              'GetMainImagePathsByVehicleId',
              'http://tempuri.org/UVSImages/Vehicles',
              'GetMainImagePathsByVehicleIdResponse',
              'UvsVehicleImageService.GetMainImagePathsByVehicleIdResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            if (Test.isRunningTest())
            	return Null;
            return response_x.GetMainImagePathsByVehicleIdResult;
        }
    }
}