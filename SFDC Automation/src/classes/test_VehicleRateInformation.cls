/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class test_VehicleRateInformation {

    static testMethod void testVehicleRateInfo_1() {
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
        
        
        // Fuel_Rates__c
        FIS_Account__c fis = createFISAccount(cb.Id);
        insert fis;
        // Rebillable_Rates__c
        Rental_Rates__c rentalRate = createRentalRate(veh.Id, fis.id);
        insert rentalRate ;
        Fuel_Rates__c fuleRate = createFuleRates(veh.Id, fis.id);
        insert fuleRate;
        Rebillable_Rates__c reBillableRate = createRebillableRate(veh.Id, fis.id);
        insert reBillableRate;
        // Start the test
        Test.startTest();
                    
        RyderGlobalVariables.IS_TEST = true;
        RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
        // Set the Page Reference
        PageReference vehiclePage = Page.VehicleRateInformation;
        Test.setCurrentPage(vehiclePage);
                    
        // Set the model action
        // Create a standard controller
        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(veh); 

        //create instance of pages controller
        VehicleRateInformation vehicleRateController = new VehicleRateInformation(controller);

        // check that list of items retrieved from vehicle is same
        // System.assert(leadToCheck.ConvertedContactId != null);
        
        // Stop the test
        Test.stopTest();
    }
    
    static testMethod void testVehicleRateInfo_2() {
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
        
        
        // Fuel_Rates__c
        FIS_Account__c fis = createFISAccount(cb.Id);
        insert fis;
        // Rebillable_Rates__c
        Rental_Rates__c rentalRate = createRentalRate(veh.Id, fis.id);
        insert rentalRate ;
        Fuel_Rates__c fuleRate = createFuleRates(veh.Id, fis.id);
        insert fuleRate;
        
        // Start the test
        Test.startTest();
                    
        RyderGlobalVariables.IS_TEST = true;
        RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
        // Set the Page Reference
        PageReference vehiclePage = Page.VehicleRateInformation;
        Test.setCurrentPage(vehiclePage);
                    
        // Set the model action
        // Create a standard controller
        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(veh); 

        //create instance of pages controller
        VehicleRateInformation vehicleRateController = new VehicleRateInformation(controller);

        // check that list of items retrieved from vehicle is same
        // System.assert(leadToCheck.ConvertedContactId != null);
        
        // Stop the test
        Test.stopTest();
    }
    
    //create FIS account
    public static FIS_Account__c createFISAccount(ID custBranchID) {
    	FIS_Account__c result = new FIS_Account__c();
    	result.name = 'FISACCOUNT123';
    	result.Customer_Branch__c = custBranchID;
    	return result;
    }

    //create Fuel_Rates__c
    public static Fuel_Rates__c createFuleRates(Id vehicleID, ID fisID) {
    	Fuel_Rates__c result = new Fuel_Rates__c();
    	result.FIS_Account__c=fisID;
    	result.Lease_Extra_Markup_Cost_Per_Gallon__c=0.00000;
    	result.Customer_No__c='015659';
    	result.Rental_Floor_Amount__c=0.00000;
    	result.ext_rates__c='408716_015659_03027_02743';
        result.Lease_Extra_Ceiling_Amount__c=9.99990;
        result.Domicile_Location_Code__c='02743';
        result.Rental_Outside_Markup_Rate__c=0.00000;
        result.Lease_Extra_Outside_Markup_Rate__c=0.00000;
        result.District_Code__c='03027';
        result.Lease_Extra_Floor_Amount__c=0.00000;
        result.Vehicle__c=vehicleId;
        result.Lease_Ceiling_Amount__c=9.99990;
        result.Effective_Date__c= System.today();
        result.LesseeNo__c='0015659';
        result.Rental_Ceiling_Amount__c=9.99990;
        result.Rental_Markup_Cost_Per_Gallon__c=0.00000;
        result.Lease_Markup_Cost_Per_Gallon__c=0.00000;
        result.Lease_Floor_Amount__c=0.00000;
        result.Lease_Outside_Markup_Rate__c=0.00000;
    	return result;
    }
    
    // create rental rate
    public static Rental_Rates__c createRentalRate(ID vehicleID, ID fisId) {
        Rental_Rates__c rentalRate = new Rental_Rates__c();
        rentalRate.Refer_Rate__c=0;
        rentalRate.Vehicle__c = vehicleID;
        rentalRate.FIS_Account__c = fisId;
        rentalRate.Customer_No__c='088903';
        rentalRate.ext_rates__c='417055_088903_03001_00558_14114';
        rentalRate.Mileage_Rate__c= 0.16;
        rentalRate.Rate_Type__c='S';
        rentalRate.Branch_Code__c= '00558';
        rentalRate.District_Code__c='03001';
        rentalRate.Standby_Rate__c=0;
        rentalRate.Special_Rate_Flag__c='N';
        rentalRate.Weekly_Rate__c=259.75;
        rentalRate.LesseeNo__c='0009303';
        rentalRate.Daily_Rate__c=51.95;
        rentalRate.Class_Category_Code__c='City Van / Parcel Van';
        rentalRate.Rate_Frequency__c='W';
        rentalRate.Class_Description__c='14\' Gas Parcel Van';
        rentalRate.Class_Code__c='14114';
        rentalRate.Monthly_Rate__c=0;
        return rentalRate;		            	
    }
    
    // 
    public static Rebillable_Rates__c createRebillableRate(ID vehicleID, ID fisId) {
        Rebillable_Rates__c result = new Rebillable_Rates__c();
        result.Accomodation_Regular_Labour_Fixed_MU__c=0.00000;
        result.Miscellaneous_Dbltime_Labour_Percent_MU__c=0.0000;
        result.Abuse_Overtime_Labour_Set_MU__c=99.99000;
        result.ext_rates__c='390961_024771_03050_01680';
        result.Accident_Dbltime_Labour_Fixed_MU__c=0.00000;
        result.Repair_Regular_Labour_Set_MU__c=95.00000;
        result.Miscellaneous_Regular_Labour_Fixed_MU__c=0.00000;
        result.Accomodation_Outside_Misc_Fixed_MU__c=0.00000;
        result.Abuse_Overtime_Labour_Percent_MU__c=0.0000;
        result.Accident_Dbltime_Labour_Percent_MU__c=0.0000;
        result.Diesel_Set_Rate__c=0.002;
        result.Special_Overtime_Labour_Fixed_MU__c=0.00000;
        result.Accident_Regular_Labour_Set_MU__c=95.00000;
        result.Special_Dbltime_Rate_Flag__c='S';
        result.Accident_Regular_Rate_Flag__c='S';
        result.Abuse_Outside_Misc_Percent_MU__c=25.0000;
        result.Miscellaneous_Wrecker_Rate__c=2.5000;
        result.Miscellaneous_Outside_Misc_Flag__c='P';
        result.Abuse_Overtime_Labour_Fixed_MU__c=0.00000;
        result.Accident_Wrecker_Rate__c=2.5000;
        result.Accident_Outside_Misc_Percent_MU__c=25.0000;
        result.Oil_MU_Method__c='P';
        result.Repair_Tire_Rate_Percent_MU__c=75.0000;
        result.Accomodation_Parts_Rate_Percent__c=110.0000;
        result.Diesel_MU_Percent__c=18.0000000;
        result.Accident_Parts_Rate_Percent__c=110.0000;
        result.Special_Dbltime_Labour_Percent_MU__c=0.0000;
        result.Accident_Service_Veh_Rate__c=2.5000;
        result.Abuse_Dbltime_Labour_Percent_MU__c=0.0000;
        result.Accomodation_Dbltime_Labour_Fixed_MU__c=0.00000;
        result.Repair_Wrecker_Rate__c=2.5000;
        result.Oil_Fixed_MU__c=0.345;
        result.Accomodation_Tire_Rate_Percent_MU__c=75.0000;
        result.Accomodation_Outside_Misc_Flag__c='P';
        result.Accident_Outside_Misc_Set_MU__c=0.00000;
        result.Repair_Dbltime_Labour_Percent_MU__c=0.0000;
        result.Special_Overtime_Rate_Flag__c='S';
        result.Special_Tire_Rate_Percent_MU__c=75.0000;
        result.Miscellaneous_Service_Veh_Rate__c=2.5000;
        result.Accident_Dbltime_Labour_Set_MU__c=99.99000;
        result.Miscellaneous_Overtime_Labour_Set_MU__c=99.99000;
        result.District_Code__c='03050';
        result.Accident_Regular_Labour_Percent_MU__c=0.0000;
        result.Accomodation_Outside_Misc_Percent_MU__c=25.0000;
        result.Repair_Parts_Rate_Percent__c=110.0000;
        result.Special_Regular_Labour_Fixed_MU__c=0.00000;
        result.Special_Overtime_Labour_Percent_MU__c=0.0000;
        result.Abuse_Regular_Labour_Set_MU__c=95.00000;
        result.Repair_Overtime_Labour_Percent_MU__c=0.0000;
        result.Repair_Dbltime_Labour_Fixed_MU__c=0.00000;
        result.Repair_Regular_Rate_Flag__c='S';
        result.Abuse_Overtime_Rate_Flag__c='S';
        result.Domicile_Branch_Code__c='01680';
        result.Abuse_Regular_Labour_Percent_MU__c=0.0000;
        result.Accomodation_Wrecker_Rate__c=2.5000;
        result.Abuse_Service_Veh_Rate__c=2.5000;
        result.Special_Overtime_Labour_Set_MU__c=99.99000;
        result.Miscellaneous_Outside_Misc_Percent_MU__c=25.0000;
        result.Accomodation_Dbltime_Labour_Percent_MU__c=0.0000;
        result.Accomodation_Dbltime_Labour_Set_MU__c=99.99000;
        result.Abuse_Dbltime_Labour_Set_MU__c=99.99000;
        result.Special_Regular_Labour_Percent_MU__c=0.0000;
        result.Miscellaneous_Outside_Misc_Set_MU__c=0.00000;
        result.Special_Dbltime_Labour_Fixed_MU__c=0.00000;
        result.Repair_Overtime_Labour_Fixed_MU__c=0.00000;
        result.Miscellaneous_Overtime_Rate_Flag__c='S';
        result.Accomodation_Regular_Rate_Flag__c='S';
        result.Accident_Overtime_Labour_Fixed_MU__c=0.00000;
        result.Oil_MU_Percent__c=100.0000000;
        result.Customer_No__c='024771';
        result.Miscellaneous_Regular_Labour_Set_MU__c=95.00000;
        result.Oil_Set_Rate__c=0.07;
        result.Miscellaneous_Tire_Rate_Percent_MU__c=75.0000;
        result.Special_Service_Veh_Rate__c=2.5000;
        result.Abuse_Outside_Misc_Fixed_MU__c=0.00000;
        result.Abuse_Outside_Misc_Flag__c='P';
        result.Special_Parts_Rate_Percent__c=110.0000;
        result.Vehicle__c=vehicleId;
        result.Repair_Regular_Labour_Fixed_MU__c=0.00000;
        result.Special_Outside_Misc_Set_MU__c=0.00000;
        result.Repair_Outside_Misc_Fixed_MU__c=0.00000;
        result.Special_Regular_Rate_Flag__c='S';
        result.Special_Dbltime_Labour_Set_MU__c=99.99000;
        result.Repair_Outside_Misc_Flag__c='P';
        result.Repair_Outside_Misc_Set_MU__c=0.00000;
        result.Abuse_Wrecker_Rate__c=2.5000;
        result.Special_Outside_Misc_Flag__c='P';
        result.Accomodation_Overtime_Rate_Flag__c='S';
        result.Abuse_Parts_Rate_Percent__c=110.0000;
        result.Accident_Dbltime_Rate_Flag__c='S';
        result.Accomodation_Overtime_Labour_Set_MU__c=99.99000;
        result.Accident_Regular_Labour_Fixed_MU__c=0.00000;
        result.Accomodation_Outside_Misc_Set_MU__c=0.00000;
        result.Repair_Outside_Misc_Percent_MU__c=25.0000;
        result.Diesel_Fixed_MU__c=0.089;
        result.Accident_Outside_Misc_Fixed_MU__c=0.00000;
        result.Abuse_Outside_Misc_Set_MU__c=0.00000;
        result.Special_Outside_Misc_Percent_MU__c=25.0000;
        result.Accident_Overtime_Labour_Percent_MU__c=0.0000;
        result.Miscellaneous_Dbltime_Labour_Set_MU__c=99.99000;
        result.Abuse_Dbltime_Labour_Fixed_MU__c=0.00000;
        result.Accident_Overtime_Labour_Set_MU__c=99.99000;
        result.FIS_Account__c=fisId;
        result.Special_Regular_Labour_Set_MU__c=95.00000;
        result.Accomodation_Service_Veh_Rate__c=2.5000;
        result.Special_Outside_Misc_Fixed_MU__c=0.00000;
        result.Accident_Overtime_Rate_Flag__c='S';
        result.Repair_Overtime_Labour_Set_MU__c=99.99000;
        result.Repair_Regular_Labour_Percent_MU__c=0.0000;
        result.Miscellaneous_Overtime_Labour_Percent_MU__c=0.0000;
        result.Accomodation_Overtime_Labour_Percent_MU__c=0.0000;
        result.Repair_Service_Veh_Rate__c=2.5000;
        result.Miscellaneous_Overtime_Labour_Fixed_MU__c=0.00000;
        result.Repair_Dbltime_Labour_Set_MU__c=99.99000;
        result.Miscellaneous_Outside_Misc_Fixed_MU__c=0.00000;
        result.Accident_Tire_Rate_Percent_MU__c=75.0000;
        result.Miscellaneous_Regular_Labour_Percent_MU__c=0.0000;
        result.Accomodation_Regular_Labour_Set_MU__c=95.00000;
        result.Accomodation_Regular_Labour_Percent_MU__c=0.0000;
        result.Accomodation_Overtime_Labour_Fixed_MU__c=0.00000;
        result.Miscellaneous_Dbltime_Labour_Fixed_MU__c=0.00000;
        result.Abuse_Tire_Rate_Percent_MU__c=75.0000;
        result.Miscellaneous_Regular_Rate_Flag__c='S';
        result.Abuse_Dbltime_Rate_Flag__c='S';
        result.Special_Wrecker_Rate__c=2.5000;
        result.LesseeNo__c='0024771';
        result.Repair_Dbltime_Rate_Flag__c='S';
        result.Diesel_MU_Method__c='P';
        result.Accident_Outside_Misc_Flag__c='P';
        result.Accomodation_Dbltime_Rate_Flag__c='S';
        result.Abuse_Regular_Rate_Flag__c='S';
        result.Abuse_Regular_Labour_Fixed_MU__c=0.00000;
        result.Miscellaneous_Dbltime_Rate_Flag__c='S';
        result.Repair_Overtime_Rate_Flag__c='S';
        result.Miscellaneous_Parts_Rate_Percent__c=110.0000;	
        return result;
    }
}