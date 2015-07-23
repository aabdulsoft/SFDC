@isTest
public with sharing class test_GetRentalRates {
    
     static testMethod void validateRentalRates() {
        
        GetRentalRates.ProcessRequestResponse_element prr = new GetRentalRates.ProcessRequestResponse_element();
        GetRentalRates.DCRentalRate rr = new GetRentalRates.DCRentalRate();
        GetRentalRates.DCRentalRates rrs = new GetRentalRates.DCRentalRates(); 
        GetRentalRates.ArrayOfDCRentalRate arr = new GetRentalRates.ArrayOfDCRentalRate();
        arr.DCRentalRate = new GetRentalRates.DCRentalRate[1];
        rr.RentalRates_Customer_No = 'test';
        rr.RentalRates_Vehicle = '25637';
       
        GetRentalRates.CRMCredential cc = new GetRentalRates.CRMCredential();
        cc.Password = '';
        cc.SecurityToken = '';
        cc.UserName = '';
        
        GetRentalRates.RentalRateRequestCriteria rsrc = new GetRentalRates.RentalRateRequestCriteria();
        rsrc.VehicleNo = '12345';       
     }
}