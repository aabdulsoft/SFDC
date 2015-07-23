public with sharing class VehicleRateInformation {
  
    public List<VehicleRebillableRateInfoItem> rebillableRates {get; set;}
    
    public List<FuelRateInfoItem> fuelItems {get; set;}
    
    public List<FuelRateInformationItem> fuelRateInformationItems {get; set;}
    
    public final Vehicle__c vehicle {set; get;}
    
    public string vehicleNo {set; get;} 
    
    public FuelRateCode fuelRateCode {get; private set;}
        
    public List<Rental_Rates__c> rentalRateList {get; private set;}
    
    public VehicleRateInformation(ApexPages.StandardController stdController) {
        this.vehicle = (Vehicle__c)stdController.getRecord();        
        init();
    }
    
    public void init() {
             
        Vehicle__c veh = new Vehicle__c();        
        veh = [Select v.Id, v.unit__c From Vehicle__c v where v.Id =: this.vehicle.Id];
        vehicleNo = veh.Unit__c;
                        
        getRebillableRateItems();
        getFuelRateInformationItems(); 
        getRentalRateItems();
    }
      
    /*
    *   Get Fuel Rate Information
    */
    private void getFuelRateInformationItems() {
        
        System.debug(LoggingLevel.INFO, '+++++++++++++++ from FuelRates Vehicle: ' + this.vehicleNo);           
        fuelRateInformationItems = new List<FuelRateInformationItem>();
        List<Fuel_Rates__c> fuelRates = getFuelRatesListFromRyder(this.vehicleNo);
       
        for(Fuel_Rates__c fuelRate: fuelRates) {
            fuelRateInformationItems.add( new FuelRateInformationItem(System.Label.Lease, fuelRate.Lease_Markup_Cost_Per_Gallon__c, fuelRate.Lease_Outside_Markup_Rate__c, fuelRate.Lease_Floor_Amount__c, fuelRate.Lease_Ceiling_Amount__c));
            fuelRateInformationItems.add( new FuelRateInformationItem(System.Label.LeaseExtra, fuelRate.Lease_Extra_Outside_Markup_Rate__c, fuelRate.Lease_Extra_Outside_Markup_Rate__c, fuelRate.Lease_Extra_Floor_Amount__c, fuelRate.Lease_Extra_Ceiling_Amount__c));
            fuelRateInformationItems.add( new FuelRateInformationItem(System.Label.Rental, fuelRate.Rental_Markup_Cost_Per_Gallon__c, fuelRate.Rental_Outside_Markup_Rate__c, fuelRate.Rental_Floor_Amount__c, fuelRate.Rental_Ceiling_Amount__c));
            fuelRateCode = new FuelRateCode();
            fuelRateCode.fpsScore = fuelRate.Other_FPF_Score__c;
            fuelRateCode.usageCode = fuelRate.Other_Usage_Code__c;
            fuelRateCode.markUpRate = fuelRate.Other_Markup_Rate__c;
            fuelRateCode.algorithCode = fuelRate.Other_Algorithm_Code__c;
        }        
    } 

    private static List<Fuel_Rates__c> getFuelRatesListFromRyder(String vehicleNo) {
            
        GetFuelRates.FuelRateRequestCriteria requestCriteria = new GetFuelRates.FuelRateRequestCriteria();        
        requestCriteria.VehicleNo = vehicleNo;
        GetFuelRates.GetFuelRatesSoap FuelratesSoap = new GetFuelRates.GetFuelRatesSoap();
        GetFuelRates.CRMCredential credential = new GetFuelRates.CRMCredential();
             
        credential.UserName = '';        
        credential.Password = '';
        credential.SecurityToken = '';
        FuelratesSoap.timeout_x = RyderGlobalVariables.WS_TIMEOUT;
        FuelratesSoap.endpoint_x = RyderGlobalVariables.RYDER_WS_ENDPOINT + RyderGlobalVariables.GET_FUEL_RATES;
        
        List<Fuel_Rates__c> ratesList = new List<Fuel_Rates__c>();
        try
        {
            // Make a soap request            
            GetFuelRates.DCFuelRates rates = FuelratesSoap.ProcessRequest(credential, requestCriteria);
            if (rates != null)
            {
               System.debug(LoggingLevel.INFO, '+++++++++++++++ Fuel Rates returned from web service call: ' + rates);
               ratesList = parseFuelRatesResponse(rates);   
            }
            
            System.debug(LoggingLevel.INFO, '+++++++++++++++ Fuel Rates created: ' + ratesList);
            return ratesList;
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.ERROR, 'Error making Soap request for GetFuelRates exception: ' + ex.getMessage());
            throw ex;
        }
    }
    
        
    private static List<Fuel_Rates__c> parseFuelRatesResponse(GetFuelRates.DCFuelRates ws_Fuel_Rates)
    {
        Fuel_Rates__c result = new Fuel_Rates__c();
        List<Fuel_Rates__c>ratesList = new List<Fuel_Rates__c>();
        
        result.Lease_Markup_Cost_Per_Gallon__c = ws_Fuel_Rates.FuelRates_Lease_Markup_Cost_Per_Gallon;
        result.Lease_Outside_Markup_Rate__c = ws_Fuel_Rates.FuelRates_Lease_Outside_Markup_Rate;
        result.Lease_Floor_Amount__c = ws_Fuel_Rates.FuelRates_Lease_Floor_Amount;
        result.Lease_Ceiling_Amount__c = ws_Fuel_Rates.FuelRates_Lease_Ceiling_Amount;
        result.Lease_Extra_Outside_Markup_Rate__c = ws_Fuel_Rates.FuelRates_Lease_Extra_Outside_Markup_Rate;
        result.Lease_Extra_Floor_Amount__c = ws_Fuel_Rates.FuelRates_Lease_Floor_Amount;
        result.Lease_Extra_Ceiling_Amount__c = ws_Fuel_Rates.FuelRates_Lease_Extra_Ceiling_Amount;
        result.Rental_Markup_Cost_Per_Gallon__c = ws_Fuel_Rates.FuelRates_Rental_Markup_Cost_Per_Gallon;
        result.Rental_Outside_Markup_Rate__c = ws_Fuel_Rates.FuelRates_Rental_Outside_Markup_Rate;
        result.Rental_Floor_Amount__c = ws_Fuel_Rates.FuelRates_Rental_Floor_Amount;
        result.Rental_Ceiling_Amount__c = ws_Fuel_Rates.FuelRates_Rental_Ceiling_Amount;
        result.Other_FPF_Score__c = ws_Fuel_Rates.FuelRates_Other_FPF_Score;
        result.Other_Usage_Code__c = ws_Fuel_Rates.FuelRates_Other_Usage_Code;
        result.Other_Markup_Rate__c = ws_Fuel_Rates.FuelRates_Other_Markup_Rate;
        result.Other_Algorithm_Code__c = ws_Fuel_Rates.FuelRates_Other_Algorithm_Code;
        
        ratesList.add(result);      
        return ratesList;  
    }
    private string getListMinusType(boolean value)
    {
    	if(value)
    	return 'L';
    	else
    	return 'P';
    }
    private void getRebillableRateItems() {
        rebillableRates = new List<VehicleRebillableRateInfoItem>(); 
              
        List<Rebillable_Rates__c> rebillableRateList = getRebillableRatesListFromRyder(this.vehicleNo);               
         //List Minus flags added by Baskar.
		string repair_LMFlag = 'P';
		string accident_LMFlag = 'P';
		string accomodation_LMFlag = 'P';
		string abuse_LMFlag = 'P';
		string special_LMFlag = 'P';
		string miscellaneous_LMFlag = 'P';
        if (rebillableRateList != null && rebillableRateList.size() > 0) {
            for (Rebillable_Rates__c rebillableRate : rebillableRateList) {

                VehicleRebillableRateInfoItem labor = new VehicleRebillableRateInfoItem();
                labor.name = System.Label.Labor;

                labor.repairInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Repair,
                rebillableRate.Repair_Regular_Rate_Flag__c,  rebillableRate.Repair_Regular_Labour_Percent_MU__c,
                rebillableRate.Repair_Regular_Labour_Fixed_MU__c, rebillableRate.Repair_Regular_Labour_Set_MU__c);

                labor.accidentInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accident,
                rebillableRate.Accident_Regular_Rate_Flag__c,  rebillableRate.Accident_Regular_Labour_Percent_MU__c,
                rebillableRate.Accident_Regular_Labour_Fixed_MU__c, rebillableRate.Accident_Regular_Labour_Set_MU__c);
                
                labor.accomodationInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accomodation,
                rebillableRate.Accomodation_Regular_Rate_Flag__c,  rebillableRate.Accomodation_Regular_Labour_Percent_MU__c,
                rebillableRate.Accomodation_Regular_Labour_Fixed_MU__c, rebillableRate.Accomodation_Regular_Labour_Set_MU__c);
                
                labor.abuseInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Abuse,
                rebillableRate.Abuse_Regular_Rate_Flag__c,  rebillableRate.Abuse_Regular_Labour_Percent_MU__c,
                rebillableRate.Abuse_Regular_Labour_Fixed_MU__c, rebillableRate.Abuse_Regular_Labour_Set_MU__c);
                
                labor.specialInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Special,
                rebillableRate.Special_Regular_Rate_Flag__c,  rebillableRate.Special_Regular_Labour_Percent_MU__c,
                rebillableRate.Special_Regular_Labour_Fixed_MU__c, rebillableRate.Special_Regular_Labour_Set_MU__c);
                
                labor.miscellaneousInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Miscellaneous,
                rebillableRate.Miscellaneous_Regular_Rate_Flag__c,  rebillableRate.Miscellaneous_Regular_Labour_Percent_MU__c,
                rebillableRate.Miscellaneous_Regular_Labour_Fixed_MU__c, rebillableRate.Miscellaneous_Regular_Labour_Set_MU__c);
                rebillableRates.add(labor);

                VehicleRebillableRateInfoItem laborovertime = new VehicleRebillableRateInfoItem();
                laborovertime.name = System.Label.LaborOvertime;

                laborovertime.repairInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Repair,
                rebillableRate.Repair_Overtime_Rate_Flag__c,  rebillableRate.Repair_Overtime_Labour_Percent_MU__c,
                rebillableRate.Repair_Overtime_Labour_Fixed_MU__c, rebillableRate.Repair_Overtime_Labour_Set_MU__c);

                laborovertime.accidentInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accident,
                rebillableRate.Accident_Overtime_Rate_Flag__c,  rebillableRate.Accident_Overtime_Labour_Percent_MU__c,
                rebillableRate.Accident_Overtime_Labour_Fixed_MU__c, rebillableRate.Accident_Overtime_Labour_Set_MU__c);
                
                laborovertime.accomodationInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accomodation,
                rebillableRate.Accomodation_Overtime_Rate_Flag__c,  rebillableRate.Accomodation_Overtime_Labour_Percent_MU__c,
                rebillableRate.Accomodation_Overtime_Labour_Fixed_MU__c, rebillableRate.Accomodation_Overtime_Labour_Set_MU__c);
                
                laborovertime.abuseInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Abuse,
                rebillableRate.Abuse_Overtime_Rate_Flag__c,  rebillableRate.Abuse_Overtime_Labour_Percent_MU__c,
                rebillableRate.Abuse_Overtime_Labour_Fixed_MU__c, rebillableRate.Abuse_Overtime_Labour_Set_MU__c);
                
                laborovertime.specialInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Special,
                rebillableRate.Special_Overtime_Rate_Flag__c,  rebillableRate.Special_Overtime_Labour_Percent_MU__c,
                rebillableRate.Special_Overtime_Labour_Fixed_MU__c, rebillableRate.Special_Overtime_Labour_Set_MU__c);
                
                laborovertime.miscellaneousInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Miscellaneous,
                rebillableRate.Miscellaneous_Overtime_Rate_Flag__c,  rebillableRate.Miscellaneous_Overtime_Labour_Percent_MU__c,
                rebillableRate.Miscellaneous_Overtime_Labour_Fixed_MU__c, rebillableRate.Miscellaneous_Overtime_Labour_Set_MU__c);
                rebillableRates.add(laborovertime);
                
                VehicleRebillableRateInfoItem laborDblovertime = new VehicleRebillableRateInfoItem();
                laborDblovertime.name = System.Label.LaborDoubleOvertime;

                laborDblovertime.repairInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Repair,
                rebillableRate.Repair_Dbltime_Rate_Flag__c,  rebillableRate.Repair_Dbltime_Labour_Percent_MU__c,
                rebillableRate.Repair_Dbltime_Labour_Fixed_MU__c, rebillableRate.Repair_Dbltime_Labour_Set_MU__c);

                laborDblovertime.accidentInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accident,
                rebillableRate.Accident_Dbltime_Rate_Flag__c,  rebillableRate.Accident_Dbltime_Labour_Percent_MU__c,
                rebillableRate.Accident_Dbltime_Labour_Fixed_MU__c, rebillableRate.Accident_Dbltime_Labour_Set_MU__c);
                
                laborDblovertime.accomodationInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accomodation,
                rebillableRate.Accomodation_Dbltime_Rate_Flag__c,  rebillableRate.Accomodation_Dbltime_Labour_Percent_MU__c,
                rebillableRate.Accomodation_Dbltime_Labour_Fixed_MU__c, rebillableRate.Accomodation_Dbltime_Labour_Set_MU__c);
                
                laborDblovertime.abuseInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Abuse,
                rebillableRate.Abuse_Dbltime_Rate_Flag__c,  rebillableRate.Abuse_Dbltime_Labour_Percent_MU__c,
                rebillableRate.Abuse_Dbltime_Labour_Fixed_MU__c, rebillableRate.Abuse_Dbltime_Labour_Set_MU__c);
                
                laborDblovertime.specialInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Special,
                rebillableRate.Special_Dbltime_Rate_Flag__c,  rebillableRate.Special_Dbltime_Labour_Percent_MU__c,
                rebillableRate.Special_Dbltime_Labour_Fixed_MU__c, rebillableRate.Special_Dbltime_Labour_Set_MU__c);
                
                laborDblovertime.miscellaneousInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Miscellaneous,
                rebillableRate.Miscellaneous_Dbltime_Rate_Flag__c,  rebillableRate.Miscellaneous_Dbltime_Labour_Percent_MU__c,
                rebillableRate.Miscellaneous_Dbltime_Labour_Fixed_MU__c, rebillableRate.Miscellaneous_Dbltime_Labour_Set_MU__c);
                rebillableRates.add(laborDblovertime);

                VehicleRebillableRateInfoItem outsideAccident = new VehicleRebillableRateInfoItem();
                outsideAccident.name = System.Label.OutsideAccident;

                outsideAccident.repairInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Repair,
                rebillableRate.Repair_Outside_Misc_Flag__c,  rebillableRate.Repair_Outside_Misc_Percent_MU__c,
                rebillableRate.Repair_Outside_Misc_Fixed_MU__c, rebillableRate.Repair_Outside_Misc_Set_MU__c);

                outsideAccident.accidentInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accident,
                rebillableRate.Accident_Outside_Misc_Flag__c,  rebillableRate.Accident_Outside_Misc_Percent_MU__c,
                rebillableRate.Accident_Outside_Misc_Fixed_MU__c, rebillableRate.Accident_Outside_Misc_Set_MU__c);
                
                outsideAccident.accomodationInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accomodation,
                rebillableRate.Accomodation_Outside_Misc_Flag__c,  rebillableRate.Accomodation_Outside_Misc_Percent_MU__c,
                rebillableRate.Accomodation_Outside_Misc_Fixed_MU__c, rebillableRate.Accomodation_Outside_Misc_Set_MU__c);
                
                outsideAccident.abuseInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Abuse,
                rebillableRate.Abuse_Outside_Misc_Flag__c,  rebillableRate.Abuse_Outside_Misc_Percent_MU__c,
                rebillableRate.Abuse_Outside_Misc_Fixed_MU__c, rebillableRate.Abuse_Outside_Misc_Set_MU__c);
                
                outsideAccident.specialInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Special,
                rebillableRate.Special_Outside_Misc_Flag__c,  rebillableRate.Special_Outside_Misc_Percent_MU__c,
                rebillableRate.Special_Outside_Misc_Fixed_MU__c, rebillableRate.Special_Outside_Misc_Set_MU__c);
                
                outsideAccident.miscellaneousInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Miscellaneous,
                rebillableRate.Miscellaneous_Outside_Misc_Flag__c,  rebillableRate.Miscellaneous_Outside_Misc_Percent_MU__c,
                rebillableRate.Miscellaneous_Outside_Misc_Fixed_MU__c, rebillableRate.Miscellaneous_Outside_Misc_Set_MU__c);
                rebillableRates.add(outsideAccident);
                
                VehicleRebillableRateInfoItem partsPercentage = new VehicleRebillableRateInfoItem();
                partsPercentage.name = System.Label.PartsPercentage;
                
				abuse_LMFlag =getListMinusType(rebillableRate.Abuse_ListMinusFlag__c);
				accident_LMFlag = getListMinusType(rebillableRate.Accident_ListMinusFlag__c);
				accomodation_LMFlag = getListMinusType(rebillableRate.Accomodation_ListMinusFlag__c);
				miscellaneous_LMFlag = getListMinusType(rebillableRate.Miscellaneous_ListMinusFlag__c);
				repair_LMFlag = getListMinusType(rebillableRate.Repair_ListMinusFlag__c);
				special_LMFlag = getListMinusType(rebillableRate.Special_ListMinusFlag__c);
				system.debug('List Minus flags: abuse_LMFlag' + abuse_LMFlag);
				system.debug('List Minus flags: accident_LMFlag' + accident_LMFlag);
				system.debug('List Minus flags: accomodation_LMFlag' + accomodation_LMFlag);
				system.debug('List Minus flags: repair_LMFlag' + repair_LMFlag);
				system.debug('List Minus flags: miscellaneous_LMFlag' + miscellaneous_LMFlag);
				system.debug('List Minus flags: special_LMFlag' + special_LMFlag);
				
                partsPercentage.repairInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Repair,
                repair_LMFlag,  rebillableRate.Repair_Parts_Rate_Percent__c, 0, 0);
				  
                partsPercentage.accidentInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accident,
                accident_LMFlag,  rebillableRate.Accident_Parts_Rate_Percent__c, 0, 0);
                
                partsPercentage.accomodationInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accomodation,
                accomodation_LMFlag,  rebillableRate.Accomodation_Parts_Rate_Percent__c, 0, 0);
                
                partsPercentage.abuseInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Abuse,
                abuse_LMFlag,  rebillableRate.Abuse_Parts_Rate_Percent__c, 0, 0);
                
                partsPercentage.specialInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Special,
                special_LMFlag,  rebillableRate.Special_Parts_Rate_Percent__c, 0, 0);
                
                partsPercentage.miscellaneousInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Miscellaneous,
                miscellaneous_LMFlag,  rebillableRate.Miscellaneous_Parts_Rate_Percent__c, 0, 0);
                rebillableRates.add(partsPercentage);
                
                VehicleRebillableRateInfoItem tiresPercentage = new VehicleRebillableRateInfoItem();
                tiresPercentage.name = System.Label.TiresPercentage;

                tiresPercentage.repairInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Repair,
                repair_LMFlag,  rebillableRate.Repair_Tire_Rate_Percent_MU__c, 0, 0);

                tiresPercentage.accidentInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accident,
                accident_LMFlag,  rebillableRate.Accident_Tire_Rate_Percent_MU__c, 0, 0);
                
                tiresPercentage.accomodationInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accomodation,
                accomodation_LMFlag,  rebillableRate.Accomodation_Tire_Rate_Percent_MU__c, 0, 0);
                
                tiresPercentage.abuseInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Abuse,
                abuse_LMFlag,  rebillableRate.Abuse_Tire_Rate_Percent_MU__c, 0, 0);
                
                tiresPercentage.specialInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Special,
                special_LMFlag,  rebillableRate.Special_Tire_Rate_Percent_MU__c, 0, 0);
                
                tiresPercentage.miscellaneousInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Miscellaneous,
                miscellaneous_LMFlag,  rebillableRate.Miscellaneous_Tire_Rate_Percent_MU__c, 0, 0);
                rebillableRates.add(tiresPercentage);
               
                VehicleRebillableRateInfoItem wreckage = new VehicleRebillableRateInfoItem();
                wreckage.name = System.Label.Wreckage;

                wreckage.repairInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Repair,
                '',  rebillableRate.Repair_Wrecker_Rate__c, 0, 0);

                wreckage.accidentInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accident,
                '',  rebillableRate.Accident_Wrecker_Rate__c, 0, 0);
                
                wreckage.accomodationInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accomodation,
                '',  rebillableRate.Accomodation_Wrecker_Rate__c, 0, 0);
                
                wreckage.abuseInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Abuse,
                '',  rebillableRate.Abuse_Wrecker_Rate__c, 0, 0);
                
                wreckage.specialInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Special,
                '',  rebillableRate.Special_Wrecker_Rate__c, 0, 0);
                
                wreckage.miscellaneousInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Miscellaneous,
                '',  rebillableRate.Miscellaneous_Wrecker_Rate__c, 0, 0);
                rebillableRates.add(wreckage);    
                
                VehicleRebillableRateInfoItem serviceVehicle = new VehicleRebillableRateInfoItem();
                serviceVehicle.name = System.Label.ServiceVehicle;

                serviceVehicle.repairInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Repair,
                '',  rebillableRate.Repair_Service_Veh_Rate__c, 0, 0);

                serviceVehicle.accidentInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accident,
                '',  rebillableRate.Accident_Service_Veh_Rate__c, 0, 0);
                
                serviceVehicle.accomodationInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accomodation,
                '',  rebillableRate.Accomodation_Service_Veh_Rate__c, 0, 0);
                
                serviceVehicle.abuseInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Abuse,
                '',  rebillableRate.Abuse_Service_Veh_Rate__c, 0, 0);
                
                serviceVehicle.specialInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Special,
                '',  rebillableRate.Special_Service_Veh_Rate__c, 0, 0);
                
                serviceVehicle.miscellaneousInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Miscellaneous,
                '',  rebillableRate.Miscellaneous_Service_Veh_Rate__c, 0, 0);
                rebillableRates.add(serviceVehicle);
                
                fuelItems = new List<FuelRateInfoItem>();
                FuelRateInfoItem diselItem = new FuelRateInfoItem();
                diselItem.name = System.Label.Disel;
                diselItem.fuelInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Miscellaneous,
                rebillableRate.Diesel_MU_Method__c,  rebillableRate.Diesel_MU_Percent__c, rebillableRate.Diesel_Fixed_MU__c, 
                rebillableRate.Diesel_Set_Rate__c);
                fuelItems.add(diselItem);
                FuelRateInfoItem oilItem = new FuelRateInfoItem();
                oilItem.name = System.Label.Oil;
                oilItem.fuelInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Miscellaneous,
                rebillableRate.Oil_MU_Method__c,  rebillableRate.Oil_MU_Percent__c, rebillableRate.Oil_Fixed_MU__c, 
                rebillableRate.Oil_Set_Rate__c);
                fuelItems.add(oilItem);
            }
        } else {
            // insert blank rows
            rebillableRates.add(getBlankVehicleRebillableRateInfoItem(System.Label.Labor));
            rebillableRates.add(getBlankVehicleRebillableRateInfoItem(System.Label.LaborOvertime));
            rebillableRates.add(getBlankVehicleRebillableRateInfoItem(System.Label.LaborDoubleOvertime));
            rebillableRates.add(getBlankVehicleRebillableRateInfoItem(System.Label.OutsideAccident));
            rebillableRates.add(getBlankVehicleRebillableRateInfoItem(System.Label.PartsPercentage));
            rebillableRates.add(getBlankVehicleRebillableRateInfoItem(System.Label.TiresPercentage));
            rebillableRates.add(getBlankVehicleRebillableRateInfoItem(System.Label.Wreckage));
            rebillableRates.add(getBlankVehicleRebillableRateInfoItem(System.Label.ServiceVehicle));
        }
    }
    
        private static List<Rebillable_Rates__c> getRebillableRatesListFromRyder(String vehicleNo) {
            
        GetRebillableRates.RebillableRateRequestCriteria requestCriteria = new GetRebillableRates.RebillableRateRequestCriteria();        
        requestCriteria.VehicleNo = vehicleNo;
        GetRebillableRates.GetRebillableRatesSoap rebillableratesSoap = new GetRebillableRates.GetRebillableRatesSoap();
        GetRebillableRates.CRMCredential credential = new GetRebillableRates.CRMCredential();
             
        credential.UserName = '';        
        credential.Password = '';
        credential.SecurityToken = '';
        rebillableratesSoap.timeout_x = RyderGlobalVariables.WS_TIMEOUT;
        rebillableratesSoap.endpoint_x = RyderGlobalVariables.RYDER_WS_ENDPOINT + RyderGlobalVariables.GET_REBILLABLE_RATES;
        system.debug('SOAP EndPoint' + rebillableratesSoap.endpoint_x);
        List<Rebillable_Rates__c> ratesList = new List<Rebillable_Rates__c>();
        try
        {
            // Make a soap request            
            
            System.debug(LoggingLevel.INFO, '+++++++++++++++ Before Rebillable Rates returned from web service call: ');
            
            
            GetRebillableRates.DCRebillableRate rates = rebillableratesSoap.ProcessRequest(credential, requestCriteria);
            if (rates != null)
            {
               System.debug(LoggingLevel.INFO, '+++++++++++++++ Rebillable Rates returned from web service call: ' + rates);
               ratesList = parseRebillableRatesResponse(rates); 
            }
            
            System.debug(LoggingLevel.INFO, '+++++++++++++++ Rebillable Rates created: ' + ratesList);
            return ratesList;
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.ERROR, 'Error making Soap request for GetRebillableRates exception: ' + ex.getMessage());
            throw ex;
        }
    }
    
        
    private static List<Rebillable_Rates__c> parseRebillableRatesResponse(GetRebillableRates.DCRebillableRate ws_Rebillable_Rates)
    {
        Rebillable_Rates__c result = new Rebillable_Rates__c();
        List<Rebillable_Rates__c>ratesList = new List<Rebillable_Rates__c>();
               
        
        System.debug(LoggingLevel.INFO, '+++++++++++++++ wsresult: ' + result);       
        
        result.Special_Wrecker_Rate__c = ws_Rebillable_Rates.Special_Wrecker_Rate_Resp;                       
        result.Special_Tire_Rate_Percent_MU__c = ws_Rebillable_Rates.Special_Tire_Rate_Percent_MU_Resp;
        result.Special_Service_Veh_Rate__c = ws_Rebillable_Rates.Special_Service_Veh_Rate_Resp;
        result.Special_Regular_Rate_Flag__c = ws_Rebillable_Rates.Special_Regular_Rate_Flag_Resp;
        result.Special_Regular_Labour_Set_MU__c = ws_Rebillable_Rates.Special_Regular_Labour_Set_MU_Resp; 
        result.Special_Regular_Labour_Percent_MU__c = ws_Rebillable_Rates.Special_Regular_Labour_Percent_MU_Resp;
        result.Special_Regular_Labour_Fixed_MU__c = ws_Rebillable_Rates.Special_Regular_Labour_Fixed_MU_Resp;
        result.Special_Parts_Rate_Percent__c = ws_Rebillable_Rates.Special_Parts_Rate_Percent_Resp; 
        result.Special_Overtime_Rate_Flag__c = ws_Rebillable_Rates.Special_Overtime_Rate_Flag_Resp; 
        result.Special_Overtime_Labour_Set_MU__c = ws_Rebillable_Rates.Special_Overtime_Labour_Set_MU_Resp; 
        result.Special_Overtime_Labour_Percent_MU__c = ws_Rebillable_Rates.Special_Overtime_Labour_Percent_MU_Resp;
        result.Special_Overtime_Labour_Fixed_MU__c = ws_Rebillable_Rates.Special_Overtime_Labour_Fixed_MU_Resp; 
        result.Special_Outside_Misc_Set_MU__c = ws_Rebillable_Rates.Special_Outside_Misc_Set_MU_Resp;
        result.Special_Outside_Misc_Percent_MU__c = ws_Rebillable_Rates.Special_Outside_Misc_Percent_MU_Resp; 
        result.Special_Outside_Misc_Flag__c = ws_Rebillable_Rates.Special_Outside_Misc_Flag_Resp;
        result.Special_Outside_Misc_Fixed_MU__c = ws_Rebillable_Rates.Special_Outside_Misc_Fixed_MU_Resp; 
        result.Special_Dbltime_Rate_Flag__c = ws_Rebillable_Rates.Special_Dbltime_Rate_Flag_Resp; 
        result.Special_Dbltime_Labour_Set_MU__c = ws_Rebillable_Rates.Special_Dbltime_Labour_Set_MU_Resp; 
        result.Special_Dbltime_Labour_Percent_MU__c = ws_Rebillable_Rates.Special_Dbltime_Labour_Percent_MU_Resp; 
        result.Special_Dbltime_Labour_Fixed_MU__c = ws_Rebillable_Rates.Special_Dbltime_Labour_Fixed_MU_Resp; 
        result.Repair_Wrecker_Rate__c = ws_Rebillable_Rates.Repair_Wrecker_Rate_Resp; 
        result.Repair_Tire_Rate_Percent_MU__c = ws_Rebillable_Rates.Repair_Tire_Rate_Percent_MU_Resp; 
        result.Repair_Service_Veh_Rate__c = ws_Rebillable_Rates.Repair_Service_Veh_Rate_Resp; 
        result.Repair_Regular_Rate_Flag__c = ws_Rebillable_Rates.Repair_Regular_Rate_Flag_Resp; 
        result.Repair_Regular_Labour_Set_MU__c = ws_Rebillable_Rates.Repair_Regular_Labour_Set_MU_Resp;
        result.Repair_Regular_Labour_Percent_MU__c = ws_Rebillable_Rates.Repair_Regular_Labour_Percent_MU_Resp; 
        result.Repair_Regular_Labour_Fixed_MU__c = ws_Rebillable_Rates.Repair_Regular_Labour_Fixed_MU_Resp; 
        result.Repair_Parts_Rate_Percent__c = ws_Rebillable_Rates.Repair_Parts_Rate_Percent_Resp; 
        result.Repair_Overtime_Rate_Flag__c = ws_Rebillable_Rates.Repair_Overtime_Rate_Flag_Resp; 
        result.Repair_Overtime_Labour_Set_MU__c = ws_Rebillable_Rates.Repair_Overtime_Labour_Set_MU_Resp; 
        result.Repair_Overtime_Labour_Percent_MU__c = ws_Rebillable_Rates.Repair_Overtime_Labour_Percent_MU_Resp; 
        result.Repair_Overtime_Labour_Fixed_MU__c = ws_Rebillable_Rates.Repair_Overtime_Labour_Fixed_MU_Resp;
        result.Repair_Outside_Misc_Set_MU__c = ws_Rebillable_Rates.Repair_Outside_Misc_Set_MU_Resp; 
        result.Repair_Outside_Misc_Percent_MU__c = ws_Rebillable_Rates.Repair_Outside_Misc_Percent_MU_Resp; 
        result.Repair_Outside_Misc_Flag__c = ws_Rebillable_Rates.Repair_Outside_Misc_Flag_Resp;
        result.Repair_Outside_Misc_Fixed_MU__c = ws_Rebillable_Rates.Repair_Outside_Misc_Fixed_MU_Resp; 
        result.Repair_Dbltime_Rate_Flag__c = ws_Rebillable_Rates.Repair_Dbltime_Rate_Flag_Resp; 
        result.Repair_Dbltime_Labour_Set_MU__c = ws_Rebillable_Rates.Repair_Dbltime_Labour_Set_MU_Resp; 
        result.Repair_Dbltime_Labour_Percent_MU__c = ws_Rebillable_Rates.Repair_Dbltime_Labour_Percent_MU_Resp; 
        result.Repair_Dbltime_Labour_Fixed_MU__c = ws_Rebillable_Rates.Repair_Dbltime_Labour_Fixed_MU_Resp; 
        result.Rebill_Rate_Flag__c = ws_Rebillable_Rates.Rebill_Rate_Flag_Resp; 
        result.Oil_Set_Rate__c = ws_Rebillable_Rates.Oil_Set_Rate_Resp; 
        result.Oil_MU_Percent__c = ws_Rebillable_Rates.Oil_MU_Percent_Resp;
        result.Oil_MU_Method__c = ws_Rebillable_Rates.Oil_MU_Method_Resp; 
        result.Oil_Fixed_MU__c = ws_Rebillable_Rates.Oil_Fixed_MU_Resp; 
        //result.Name = ws_Rebillable_Rates.Name, 
        result.Miscellaneous_Wrecker_Rate__c = ws_Rebillable_Rates.Miscellaneous_Wrecker_Rate_Resp; 
        result.Miscellaneous_Tire_Rate_Percent_MU__c = ws_Rebillable_Rates.Miscellaneous_Tire_Rate_Percent_MU_Resp;
        result.Miscellaneous_Service_Veh_Rate__c = ws_Rebillable_Rates.Miscellaneous_Service_Veh_Rate_Resp; 
        result.Miscellaneous_Regular_Rate_Flag__c = ws_Rebillable_Rates.Miscellaneous_Regular_Rate_Flag_Resp; 
        result.Miscellaneous_Regular_Labour_Set_MU__c = ws_Rebillable_Rates.Miscellaneous_Regular_Labour_Set_MU_Resp;
        result.Miscellaneous_Regular_Labour_Percent_MU__c = ws_Rebillable_Rates.Miscellaneous_Regular_Labour_Percent_MU_Resp; 
        result.Miscellaneous_Regular_Labour_Fixed_MU__c = ws_Rebillable_Rates.Miscellaneous_Regular_Labour_Fixed_MU_Resp; 
        result.Miscellaneous_Parts_Rate_Percent__c = ws_Rebillable_Rates.Miscellaneous_Parts_Rate_Percent_Resp; 
        result.Miscellaneous_Overtime_Rate_Flag__c = ws_Rebillable_Rates.Miscellaneous_Overtime_Rate_Flag_Resp;                
        result.Miscellaneous_Overtime_Labour_Percent_MU__c = ws_Rebillable_Rates.Miscellaneous_Overtime_Labour_Percent_MU_Resp; 
        result.Miscellaneous_Overtime_Labour_Set_MU__c = ws_Rebillable_Rates.Miscellaneous_Overtime_Labour_Set_MU_Resp; 
        result.Miscellaneous_Overtime_Labour_Fixed_MU__c = ws_Rebillable_Rates.Miscellaneous_Overtime_Labour_Fixed_MU_Resp;
        result.Miscellaneous_Outside_Misc_Set_MU__c = ws_Rebillable_Rates.Miscellaneous_Outside_Misc_Set_MU_Resp; 
        result.Miscellaneous_Outside_Misc_Percent_MU__c = ws_Rebillable_Rates.Miscellaneous_Outside_Misc_Percent_MU_Resp; 
        result.Miscellaneous_Outside_Misc_Flag__c = ws_Rebillable_Rates.Miscellaneous_Outside_Misc_Flag_Resp;
        result.Miscellaneous_Outside_Misc_Fixed_MU__c = ws_Rebillable_Rates.Miscellaneous_Outside_Misc_Fixed_MU_Resp; 
        result.Miscellaneous_Dbltime_Rate_Flag__c = ws_Rebillable_Rates.Miscellaneous_Dbltime_Rate_Flag_Resp; 
        result.Miscellaneous_Dbltime_Labour_Set_MU__c = ws_Rebillable_Rates.Miscellaneous_Dbltime_Labour_Set_MU_Resp; 
        result.Miscellaneous_Dbltime_Labour_Percent_MU__c = ws_Rebillable_Rates.Miscellaneous_Dbltime_Labour_Percent_MU_Resp;
        result.Miscellaneous_Dbltime_Labour_Fixed_MU__c = ws_Rebillable_Rates.Miscellaneous_Dbltime_Labour_Fixed_MU_Resp; 
        result.Misc_Overtime_Labour_Percent_MU__c = ws_Rebillable_Rates.Misc_Overtime_Labour_Percent_MU_Resp; 
        result.Location_RO_Rate__c = ws_Rebillable_Rates.Location_RO_Rate_Resp;        
        result.Location_LBU__c = ws_Rebillable_Rates.Location_LBU_Resp; 
        result.LesseeNo__c = ws_Rebillable_Rates.LesseeNo_Resp;        
        result.Domicile_Branch_Code__c = ws_Rebillable_Rates.Domicile_Branch_Code_Resp;
        result.District_Code__c = ws_Rebillable_Rates.District_Code_Resp; 
        result.Diesel_Set_Rate__c = ws_Rebillable_Rates.Diesel_Set_Rate_Resp; 
        result.Diesel_MU_Percent__c = ws_Rebillable_Rates.Diesel_MU_Percent_Resp; 
        result.Diesel_MU_Method__c = ws_Rebillable_Rates.Diesel_MU_Method_Resp; 
        result.Diesel_Fixed_MU__c = ws_Rebillable_Rates.Diesel_Fixed_MU_Resp; 
        result.Customer_No__c = ws_Rebillable_Rates.Customer_No_Resp; 
        result.CurrencyIsoCode = ws_Rebillable_Rates.CurrencyIsoCode; 
        result.Accomodation_Wrecker_Rate__c = ws_Rebillable_Rates.Accomodation_Wrecker_Rate_Resp; 
        result.Accomodation_Tire_Rate_Percent_MU__c = ws_Rebillable_Rates.Accomodation_Tire_Rate_Percent_MU_Resp; 
        result.Accomodation_Service_Veh_Rate__c = ws_Rebillable_Rates.Accomodation_Service_Veh_Rate_Resp; 
        result.Accomodation_Regular_Rate_Flag__c = ws_Rebillable_Rates.Accomodation_Regular_Rate_Flag_Resp; 
        result.Accomodation_Regular_Labour_Set_MU__c = ws_Rebillable_Rates.Accomodation_Regular_Labour_Set_MU_Resp; 
        result.Accomodation_Regular_Labour_Percent_MU__c = ws_Rebillable_Rates.Accomodation_Regular_Labour_Percent_MU_Resp; 
        result.Accomodation_Regular_Labour_Fixed_MU__c = ws_Rebillable_Rates.Accomodation_Regular_Labour_Fixed_MU_Resp; 
        result.Accomodation_Parts_Rate_Percent__c = ws_Rebillable_Rates.Accomodation_Parts_Rate_Percent_Resp; 
        result.Accomodation_Overtime_Rate_Flag__c = ws_Rebillable_Rates.Accomodation_Overtime_Rate_Flag_Resp; 
        result.Accomodation_Overtime_Labour_Set_MU__c = ws_Rebillable_Rates.Accomodation_Overtime_Labour_Set_MU_Resp; 
        result.Accomodation_Overtime_Labour_Percent_MU__c = ws_Rebillable_Rates.Accomodation_Overtime_Labour_Percent_MU_Resp;
        result.Accomodation_Overtime_Labour_Fixed_MU__c = ws_Rebillable_Rates.Accomodation_Overtime_Labour_Fixed_MU_Resp; 
        result.Accomodation_Outside_Misc_Set_MU__c = ws_Rebillable_Rates.Accomodation_Outside_Misc_Set_MU_Resp; 
        result.Accomodation_Outside_Misc_Percent_MU__c = ws_Rebillable_Rates.Accomodation_Outside_Misc_Percent_MU_Resp;
        result.Accomodation_Outside_Misc_Flag__c = ws_Rebillable_Rates.Accomodation_Outside_Misc_Flag_Resp; 
        result.Accomodation_Outside_Misc_Fixed_MU__c = ws_Rebillable_Rates.Accomodation_Outside_Misc_Fixed_MU_Resp;
        result.Accomodation_Dbltime_Rate_Flag__c = ws_Rebillable_Rates.Accomodation_Dbltime_Rate_Flag_Resp; 
        result.Accomodation_Dbltime_Labour_Set_MU__c = ws_Rebillable_Rates.Accomodation_Dbltime_Labour_Set_MU_Resp; 
        result.Accomodation_Dbltime_Labour_Percent_MU__c = ws_Rebillable_Rates.Accomodation_Dbltime_Labour_Percent_MU_Resp;
        result.Accomodation_Dbltime_Labour_Fixed_MU__c = ws_Rebillable_Rates.Accomodation_Dbltime_Labour_Fixed_MU_Resp;
        result.Accident_Wrecker_Rate__c = ws_Rebillable_Rates.Accident_Wrecker_Rate_Resp; 
        result.Accident_Tire_Rate_Percent_MU__c = ws_Rebillable_Rates.Accident_Tire_Rate_Percent_MU_Resp;
        result.Accident_Service_Veh_Rate__c = ws_Rebillable_Rates.Accident_Service_Veh_Rate_Resp;
        result.Accident_Regular_Rate_Flag__c = ws_Rebillable_Rates.Accident_Regular_Rate_Flag_Resp;         
        result.Accident_Regular_Labour_Set_MU__c = ws_Rebillable_Rates.Accident_Regular_Labour_Set_MU_Resp;        
        result.Accident_Regular_Labour_Percent_MU__c = ws_Rebillable_Rates.Accident_Regular_Labour_Percent_MU_Resp; 
        result.Accident_Regular_Labour_Fixed_MU__c = ws_Rebillable_Rates.Accident_Regular_Labour_Fixed_MU_Resp;
        result.Accident_Parts_Rate_Percent__c = ws_Rebillable_Rates.Accident_Parts_Rate_Percent_Resp; 
        result.Accident_Overtime_Rate_Flag__c = ws_Rebillable_Rates.Accident_Overtime_Rate_Flag_Resp; 
        result.Accident_Overtime_Labour_Set_MU__c = ws_Rebillable_Rates.Accident_Overtime_Labour_Set_MU_Resp; 
        result.Accident_Overtime_Labour_Percent_MU__c = ws_Rebillable_Rates.Accident_Overtime_Labour_Percent_MU_Resp; 
        result.Accident_Overtime_Labour_Fixed_MU__c = ws_Rebillable_Rates.Accident_Overtime_Labour_Fixed_MU_Resp;
        result.Accident_Outside_Misc_Set_MU__c = ws_Rebillable_Rates.Accident_Outside_Misc_Set_MU_Resp; 
        result.Accident_Outside_Misc_Percent_MU__c = ws_Rebillable_Rates.Accident_Outside_Misc_Percent_MU_Resp; 
        result.Accident_Outside_Misc_Flag__c = ws_Rebillable_Rates.Accident_Outside_Misc_Flag_Resp; 
        result.Accident_Outside_Misc_Fixed_MU__c = ws_Rebillable_Rates.Accident_Outside_Misc_Fixed_MU_Resp; 
        result.Accident_Dbltime_Rate_Flag__c = ws_Rebillable_Rates.Accident_Dbltime_Rate_Flag_Resp; 
        result.Accident_Dbltime_Labour_Set_MU__c = ws_Rebillable_Rates.Accident_Dbltime_Labour_Set_MU_Resp; 
        result.Accident_Dbltime_Labour_Percent_MU__c = ws_Rebillable_Rates.Accident_Dbltime_Labour_Percent_MU_Resp;
        result.Accident_Dbltime_Labour_Fixed_MU__c = ws_Rebillable_Rates.Accident_Dbltime_Labour_Fixed_MU_Resp; 
        result.Abuse_Wrecker_Rate__c = ws_Rebillable_Rates.Abuse_Wrecker_Rate_Resp;
        result.Abuse_Tire_Rate_Percent_MU__c = ws_Rebillable_Rates.Abuse_Tire_Rate_Percent_MU_Resp;        
        result.Abuse_Service_Veh_Rate__c = ws_Rebillable_Rates.Abuse_Service_Veh_Rate_Resp; 
        result.Abuse_Regular_Rate_Flag__c = ws_Rebillable_Rates.Abuse_Regular_Rate_Flag_Resp; 
        result.Abuse_Regular_Labour_Set_MU__c = ws_Rebillable_Rates.Abuse_Regular_Labour_Set_MU_Resp; 
        result.Abuse_Regular_Labour_Percent_MU__c = ws_Rebillable_Rates.Abuse_Regular_Labour_Percent_MU_Resp; 
        result.Abuse_Regular_Labour_Fixed_MU__c = ws_Rebillable_Rates.Abuse_Regular_Labour_Fixed_MU_Resp; 
        result.Abuse_Parts_Rate_Percent__c = ws_Rebillable_Rates.Abuse_Parts_Rate_Percent_Resp; 
        result.Abuse_Overtime_Rate_Flag__c = ws_Rebillable_Rates.Abuse_Overtime_Rate_Flag_Resp; 
        result.Abuse_Overtime_Labour_Set_MU__c = ws_Rebillable_Rates.Abuse_Overtime_Labour_Set_MU_Resp; 
        result.Abuse_Overtime_Labour_Percent_MU__c = ws_Rebillable_Rates.Abuse_Overtime_Labour_Percent_MU_Resp; 
        result.Abuse_Overtime_Labour_Fixed_MU__c = ws_Rebillable_Rates.Abuse_Overtime_Labour_Fixed_MU_Resp;
        result.Abuse_Outside_Misc_Set_MU__c = ws_Rebillable_Rates.Abuse_Outside_Misc_Set_MU_Resp; 
        result.Abuse_Outside_Misc_Percent_MU__c = ws_Rebillable_Rates.Abuse_Outside_Misc_Percent_MU_Resp; 
        result.Abuse_Outside_Misc_Flag__c = ws_Rebillable_Rates.Abuse_Outside_Misc_Flag_Resp; 
        result.Abuse_Outside_Misc_Fixed_MU__c = ws_Rebillable_Rates.Abuse_Outside_Misc_Fixed_MU_Resp; 
        result.Abuse_Dbltime_Rate_Flag__c = ws_Rebillable_Rates.Abuse_Dbltime_Rate_Flag_Resp; 
        result.Abuse_Dbltime_Labour_Set_MU__c = ws_Rebillable_Rates.Abuse_Dbltime_Labour_Set_MU_Resp; 
        result.Abuse_Dbltime_Labour_Percent_MU__c = ws_Rebillable_Rates.Abuse_Dbltime_Labour_Percent_MU_Resp;
        result.Abuse_Dbltime_Labour_Fixed_MU__c = ws_Rebillable_Rates.Abuse_Dbltime_Labour_Fixed_MU_Resp;
         //List Minus Flags
        result.Abuse_ListMinusFlag__c =ws_Rebillable_Rates.Abuse_ListMinusFlag;
        result.Accident_ListMinusFlag__c =ws_Rebillable_Rates.Accident_ListMinusFlag;
        result.Accomodation_ListMinusFlag__c =ws_Rebillable_Rates.Accomodation_ListMinusFlag;
        result.Miscellaneous_ListMinusFlag__c =ws_Rebillable_Rates.Miscellaneous_ListMinusFlag;
        result.Repair_ListMinusFlag__c = ws_Rebillable_Rates.Repair_ListMinusFlag;
        result.Special_ListMinusFlag__c = ws_Rebillable_Rates.Special_ListMinusFlag;
        system.debug('List Minus flags: abuse_LMFlag' + ws_Rebillable_Rates.Abuse_ListMinusFlag);
		system.debug('List Minus flags: accident_LMFlag' + ws_Rebillable_Rates.Accident_ListMinusFlag);
		system.debug('List Minus flags: accomodation_LMFlag' + ws_Rebillable_Rates.Accomodation_ListMinusFlag);
		system.debug('List Minus flags: repair_LMFlag' + ws_Rebillable_Rates.Repair_ListMinusFlag);
		system.debug('List Minus flags: miscellaneous_LMFlag' + ws_Rebillable_Rates.Miscellaneous_ListMinusFlag);
		system.debug('List Minus flags: special_LMFlag' + ws_Rebillable_Rates.Special_ListMinusFlag);
        ratesList.add(result);      
        return ratesList;  
    }
    
    /*
    *   Get all rebillable rate for vehicle.
    */
    private void getRyderRebillableRateItems() {    
        
        //string vehicleno = [Select unit__c from Vehicle__c where Id =: vehicle.Id limit 1];        
        string vehicleno = '202412';
        System.debug(LoggingLevel.INFO, '+++++++++++++++ from Ryder: vehicle ' + vehicleno);
                
        List<Fuel_Rates__c> rebillableRatesList = getFuelRatesListFromRyder(vehicleno);                
        System.debug(LoggingLevel.INFO, '+++++++++++++++ result from Ryder: ' + rebillableRatesList);
    }
    
    private VehicleRebillableRateInfoItem getBlankVehicleRebillableRateInfoItem(String name) {
        VehicleRebillableRateInfoItem item1 = new VehicleRebillableRateInfoItem();
        item1.name = name;
        item1.repairInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Repair,
            '', 0.00, 0.00, 0.00);
        item1.accidentInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accident,
            '', 0.00, 0.00, 0.00);
        item1.accomodationInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Accomodation,
            '', 0.00, 0.00, 0.00);
        item1.abuseInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Abuse,
            '', 0.00, 0.00, 0.00);
        item1.specialInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Special,
            '', 0.00, 0.00, 0.00);
        item1.miscellaneousInfo = getVehicleRateInfoVO(RyderGlobalVariables.InfoType.Miscellaneous,
            '', 0.00, 0.00, 0.00);
        return item1;
    }
    private VehicleRateInfoVO getVehicleRateInfoVO(RyderGlobalVariables.InfoType infoType, String amountType, Decimal percentValue, Decimal fixedValue, Decimal setValue) {
        VehicleRateInfoVO result = new VehicleRateInfoVO();
        result.infoType = infoType;
        result.amountType = amountType;
        result.amount = percentValue;
        if (amountType == RyderGlobalVariables.AMOUNT_TYPE_PERCENTAGE) {
            result.amount = percentValue;
        }
        if (amountType == RyderGlobalVariables.AMOUNT_TYPE_FIXED) {
            result.amount = fixedValue;
        }
        if (amountType == RyderGlobalVariables.AMOUNT_TYPE_SET) {
            result.amount = setValue;
        }
        return result;
    }
     
    public with sharing class FuelRateCode {
        public String fpsScore {get; set;}
        public Decimal markUpRate {get; set;}
        public String usageCode {get; set;}
        public String algorithCode {get; set;}
    }
    
    /*
    *   Get Rental Rates for the vehicle
    */
    private void getRentalRateItems() {
        
        this.rentalRateList = getRentalRatesListFromRyder(this.vehicleNo);
        
        //this.rentalRateList = [Select r.Weekly_Rate__c, r.Standby_Rate__c, r.Refer_Rate__c, r.Monthly_Rate__c, r.Mileage_Rate__c, r.Daily_Rate__c, 
        //r.Class_Description__c From Rental_Rates__c r
        //where r.Vehicle__c =: vehicle.Id ];
    }
    
    
    private static List<Rental_Rates__c> getRentalRatesListFromRyder(String vehicleNo) {
            
        GetRentalRates.RentalRateRequestCriteria requestCriteria = new GetRentalRates.RentalRateRequestCriteria();        
        requestCriteria.VehicleNo = vehicleNo;
        GetRentalRates.GetRentalRatesSoap RentalratesSoap = new GetRentalRates.GetRentalRatesSoap();
        GetRentalRates.CRMCredential credential = new GetRentalRates.CRMCredential();
             
        credential.UserName = '';        
        credential.Password = '';
        credential.SecurityToken = '';
        RentalratesSoap.timeout_x = RyderGlobalVariables.WS_TIMEOUT;
        RentalratesSoap.endpoint_x = RyderGlobalVariables.RYDER_WS_ENDPOINT + RyderGlobalVariables.GET_RENTAL_RATES;
        
        List<Rental_Rates__c> ratesList = new List<Rental_Rates__c>();
        try
        {
            // Make a soap request
            System.debug(LoggingLevel.INFO, '+++++++++++++++ Before Rental Rates returned from web service call: ');            
            
            GetRentalRates.DCRentalRates rates = RentalratesSoap.ProcessRequest(credential, requestCriteria);
            if (rates != null)
            {
               System.debug(LoggingLevel.INFO, '+++++++++++++++ Rental Rates returned from web service call: ' + rates);
               ratesList = parseRentalRatesResponse(rates.RentalRates.DCRentalRate);    
               
            }
            
            System.debug(LoggingLevel.INFO, '+++++++++++++++ Rental Rates created: ' + ratesList);
            return ratesList;
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.ERROR, 'Error making Soap request for GetRentalRates exception: ' + ex.getMessage());
            throw ex;
        }
    }
    
    private static List<Rental_Rates__c> parseRentalRatesResponse(List<GetRentalRates.DCRentalRate> ws_Rental_Rates)
    {
        List<Rental_Rates__c>ratesList = new List<Rental_Rates__c>();
        
        for (GetRentalRates.DCRentalRate rr : ws_Rental_Rates)
        {
            Rental_Rates__c result = new Rental_Rates__c();
        
            result.Weekly_Rate__c  = rr.RentalRates_Weekly_Rate; 
            result.Standby_Rate__c = rr.RentalRates_Standby_Rate;
            result.Refer_Rate__c = rr.RentalRates_Refer_Rate;
            result.Monthly_Rate__c = rr.RentalRates_Monthly_Rate;
            result.Mileage_Rate__c = rr.RentalRates_Mileage_Rate;
            result.Daily_Rate__c = rr.RentalRates_Daily_Rate; 
            result.Class_Description__c = rr.RentalRates_Class_Description;
            
            ratesList.add(result);
        }
                
        return ratesList;  
    }
    
    public static testMethod void test_vechiclerateinfo(){
         Account acct = TestUtil.createAccount('Ryder FMS Parent Account', 'Customer');
        insert acct;
        Customer_Branch__c cb = new Customer_Branch__c();
        cb.Name = 'test branch';
        cb.Ryder_HQ_Account__c = acct.Id;
        insert cb;
        Vehicle__c veh = new Vehicle__c();
        veh.Account__c = acct.Id;
        veh.CUSTOMER_BRANCH__c = cb.id;
        insert veh;
        GetFuelRates.FuelRateRequestCriteria rsrc = new GetFuelRates.FuelRateRequestCriteria();
        rsrc.VehicleNo = '12345';  
        
        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(veh); 
        VehicleRateInformation vri = new VehicleRateInformation(controller);
        
          vri.getFuelRateInformationItems();
         VehicleRateInformation.getFuelRatesListFromRyder('12345');
        //vri.parseFuelRatesResponse();
        //vri.parseRebillableRatesResponse();
    }
        
    
}