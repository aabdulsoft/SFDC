@isTest
public with sharing class test_GetFuelRates {
	
	 static testMethod void validateFuelRates() {
	 	
	 	GetFuelRates.ProcessRequestResponse_element prr = new GetFuelRates.ProcessRequestResponse_element();
        GetFuelRates.DCFuelRates fr = new GetFuelRates.DCFuelRates();
       // GetFuelRates.ArrayOfDCRateSheet ars = new GetRateSheets.ArrayOfDCRateSheet();
       // ars.DCRateSheet = new GetRateSheets.DCRateSheet[1];
       fr.FuelRates_Customer_No = 'test';
       fr.FuelRates_Vehicle = '25637';
       
    
        GetFuelRates.CRMCredential cc = new GetFuelRates.CRMCredential();
        cc.Password = '';
        cc.SecurityToken = '';
        cc.UserName = '';
        
        GetFuelRates.FuelRateRequestCriteria rsrc = new GetFuelRates.FuelRateRequestCriteria();
        rsrc.VehicleNo = '12345';       
	 }
}