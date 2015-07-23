/**=====================================================================
 * Appirio, Inc
 * Created Date: 10-2-2014
 * Created By: Swathy (Appirio)
 =====================================================================*/

public with sharing class ImageSelectorController {
   
   public Quote quote {get; set;}
   public Id quoteId;
   public boolean isError{get;set;}
   public List<QuoteLineItem> qlItem;
   public List<String> vehName;
   public Map<string,List<string>> vehPathsMap;
   public Map<Id,string> qliIds;
   public List<string> allVehPaths;
   public Boolean isImagesNull{get;set;}
   public Map<string,string> vehMap;
   public boolean checkVal{get;set;}
   public string orderRem{get;set;}
   public List<string> checkedURLs{get;set;}
   
   public ImageSelectorController(ApexPages.StandardController stdController)
    {
       quoteId = ApexPages.currentPage().getParameters().get('quoteId');
       this.quote = (Quote)stdController.getRecord();
         this.quote = [select Id,Selected_Image1__c,
                        Selected_Image2__c,Selected_Image3__c,Selected_Image4__c,Selected_Image5__c
                         from Quote where Id = : quoteId ];
       isImagesNull = false;
       allVehPaths = new List<string>();
       vehName = new List<string>();
       qliIds = new Map<Id,string>();
       qlItem = new List<QuoteLineItem>();
       vehPathsMap = new Map<string,List<string>>();
       vehImageWrap = new List<VehImageWrapper>();
       vehMap = new Map<string,string>();
       numMap = new Map<string,boolean>();
       vehicleNames();
       vehiclePaths();    
       if(vehMap.size() > 0)
       {
       for(string vehUrl : allVehPaths)
         { 
           VehImageWrapper vIWrap = new VehImageWrapper();
           vIWrap.imageSelect = false;
           vIWrap.imageURL = vehUrl;
           vIWrap.vehNo = vehmap.get(vehUrl);
           vehImageWrap.add(vIWrap);
         }  
        }
        else        
          isImagesNull = true;       
    }
    
    public void vehicleNames()
    {
      for(QuoteLineItem qli : [SELECT Id,VehicleImage1__c,VehicleImage2__c,VehicleImage3__c,
                               VehicleImage4__c,VehicleImage5__c,VehicleImage6__c,VehicleImage7__c,VehicleImage8__c,
                               VehicleImage9__c, Vehicle__c,Vehicle__r.name 
                                    FROM QuoteLineItem WHERE QuoteId = : quoteId])
           {
             if(qli.Vehicle__r.name!=null)
             {
              vehName.add(qli.Vehicle__r.name);
              system.debug('vehName>>>'+vehName);
              qliIds.put(qli.Id,qli.Vehicle__r.name);
               for(integer i=1;i<10;i++)
               {
                qli.put('VehicleImage'+i+'__c', ' ');
                }
              qlItem.add(qli);
              }
           }     
    }
     
     
     public List<SelectOption> getorderOptions() { 
        return selectOptionsFromSet();
       }
       
      private List<SelectOption> selectOptionsFromSet() {
        //List<String> optionsList = new List<String>(opts);
       // optionsList.sort();
        List<SelectOption> options = new List<SelectOption>();
        for (integer i=1;i<6;i++) {
           if(numMap.containskey(string.valueof(i)))
            options.add(new 
                SelectOption(string.valueof(i),string.valueof(i),numMap.get(string.valueof(i))));
                else
                 options.add(new 
                SelectOption(string.valueof(i),string.valueof(i)));
        }
        return options;
    }
   
    public Map<string,boolean> numMap;
    public void removeOpt()
     {
         
          system.debug('*****test****'+ checkVal);
          system.debug('*****test****'+ orderRem);
          numMap.put(orderRem,checkVal);
     }
    public void vehiclePaths()
     {
       if(vehName.size() > 0 && vehName.size() < 11)
        {
          for(string vehiName : vehName)
           {
             try{
             UvsVehicleImageService.VehiclesSoap  VehicleImageServiceSoap = new UvsVehicleImageService.VehiclesSoap();
             Integer vehicleId = Integer.valueOf(vehiName);             
             
             UvsVehicleImageService.ArrayOfString arrayofstring = VehicleImageServiceSoap.GetImagesPathsByVehicleId(vehicleId);
             if(arrayofstring.string_x <> null)
             {
             List<String> vehPaths = new List<String>();
              vehPaths = arrayofstring.string_x ;
              IF(!vehPaths.isEmpty())
              { 
               for(string s : vehPaths)
                {
                 vehMap.put(s,vehiName);
                }             
              allVehPaths.addall(vehPaths);
              vehPathsMap.put(vehiName,vehPaths);  }
              }
              }
              
              catch(exception e)
              {
                system.debug('*****exceptionoccured**'+e);
              }
              
          }
        }
     }
     
     public void Cancel()
     {
     
     }
     
     public PageReference saveImageUrl()
      {
         checkedURLs= new List<string>(); 
         Set<string> unCheckedURLs= new Set<string>(); 
         List<QuoteLineItem> qliList = new List<QuoteLineItem>();
         for(VehImageWrapper VIW : vehImageWrap)
          {
             if(VIW.imageSelect == true)
               checkedURLs.add(VIW.imageURL);
             else
               unCheckedURLs.add(VIW.imageURL);
          }
        Integer error=0;
         if(checkedURLs.size()>5) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Please select only 5 Images'));
             error = 1;
             }
            if(error==1){
              isError = true;
              displayPopup = false;
              return null;
               }
          else{
            isError = false;
             displayPopup = true;
            if(checkedURLs.size()>0)
            {
              for(integer j=1;j<=5-checkedURLs.size(); j++)
               {
                checkedURLs.add(' ');
               }
              for(integer i=1 ;i<=checkedURLs.size(); i++)
               {
               quote.put('Selected_Image'+i+'__c', checkedURLs[i-1]);
               }
            }     
            System.debug('...........quote............'+quote);       
           update quote;  
           
            for(QuoteLineItem qli : qlItem)
             {
               string vName = qliIds.get(qli.id);
               if(vehPathsMap.containskey(vName))
                {
                  List<string> vehUrlPaths = vehPathsMap.get(vName);
                   integer j=1;
                   
                  for(integer i=1 ;i<=vehUrlPaths.size()&& j<10 ; i++)
                   {
                     if(unCheckedURLs.contains(vehUrlPaths[i-1]))
                      {
                         qli.put('VehicleImage'+j+'__c', vehUrlPaths[i-1]);
                         j++;
                      }
                   }
                  qliList.add(qli);
                 }
             } 
             update qliList;         
           
        //  PageReference quotePage = new ApexPages.StandardController(quote).view();
        //  quotePage.setRedirect(true);
          return null;
          }
      }
     public boolean displayPopup {get; set;}   
     public void closePopup() {        
        displayPopup = false;    
      }     
     public void showPopup() {        
        displayPopup = true;    
       }   
     public List<VehImageWrapper> vehImageWrap{get;set;}
     public class VehImageWrapper
      {
        public Boolean imageSelect{get;set;}
        public String  imageURL{get;set;}
        public String  vehNo{get;set;}
        public String selectedOrder{get;set;}
      }    
  }