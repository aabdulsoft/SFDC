/******************************************************************************************
 *  Name    : VehicleUtilClass
 *  Purpose : Contains utility methods for vehicle.
 *  Author  : Hari Krishnan
 *  Date    : 2014-10-09
 *  Version : 1.0
 *
 *  Modification History
 *  Date  Who   Description
 *
 ********************************************************************************************/
public with sharing class VehicleUtilClass {

    /**
    * @author Hari Krishnan
    * @date 2014/10/09
    * @description This method returns a list of SAM Class.
    * @return List<SelectOption> A list of SelectOption that contains all applicable SAM Class codes.
    */
    public static List<SelectOption> getSAMClassList(boolean enableNoneOption) {
        List<SelectOption> options = new List<SelectOption>();
        if(enableNoneOption == true)
            options.add(new SelectOption('--None--', '--None--'));
        Schema.DescribeFieldResult fieldResult = VehicleSearchSetting__c.SAM_Truck__c.getDescribe();
        List<Schema.PicklistEntry> listPicklistEntry = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : listPicklistEntry)
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        return options;
    }
    
    /**
    * @author Hari Krishnan
    * @date 2014/10/09
    * @description This method returns a list of 'availability' values.
    * @return List<SelectOption> A list of SelectOption that contains all applicable 'availability' values.
    */
    public static List<SelectOption> getAvailabilityList(boolean enableNoneOption) {
        List<SelectOption> options = new List<SelectOption>();
        if(enableNoneOption == true)
            options.add(new SelectOption('--None--', '--None--'));
        Schema.DescribeFieldResult fieldResult = VehicleSearchSetting__c.Availability__c.getDescribe();
        List<Schema.PicklistEntry> listPicklistEntry = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : listPicklistEntry)
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        return options;
    }
    
    /**
    * @author Hari Krishnan
    * @date 2014/10/09
    * @description This method returns a list of body height values.
    * @return List<SelectOption> A list of SelectOption that contains all applicable body height values.
    */
    public static List<SelectOption> getBodyHeightList(boolean enableNoneOption) {
        List<SelectOption> options = new List<SelectOption>();
        if(enableNoneOption == true)
            options.add(new SelectOption('--None--', '--None--'));
        Schema.DescribeFieldResult fieldResult = VehicleSearchSetting__c.Body_Height__c.getDescribe();
        List<Schema.PicklistEntry> listPicklistEntry = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : listPicklistEntry)
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        return options;
    }
    
    /**
    * @author Hari Krishnan
    * @date 2014/10/09
    * @description This method returns a list of body length values.
    * @return List<SelectOption> A list of SelectOption that contains all applicable body length values.
    */
    public static List<SelectOption> getBodyLengthList(boolean enableNoneOption) {
        List<SelectOption> options = new List<SelectOption>();
        if(enableNoneOption == true)
            options.add(new SelectOption('--None--', '--None--'));
        Schema.DescribeFieldResult fieldResult = VehicleSearchSetting__c.Body_Length__c.getDescribe();
        List<Schema.PicklistEntry> listPicklistEntry = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : listPicklistEntry)
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        return options;
    }
    
    /**
    * @author Hari Krishnan
    * @date 2014/10/09
    * @description This method returns a list of body width values.
    * @return List<SelectOption> A list of SelectOption that contains all applicable body width values.
    */
    public static List<SelectOption> getBodyWidthList(boolean enableNoneOption) {
        List<SelectOption> options = new List<SelectOption>();
        if(enableNoneOption == true)
            options.add(new SelectOption('--None--', '--None--'));
        Schema.DescribeFieldResult fieldResult = VehicleSearchSetting__c.Body_Width__c.getDescribe();
        List<Schema.PicklistEntry> listPicklistEntry = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : listPicklistEntry)
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        return options;
    }
      
    /**
    * @author Hari Krishnan
    * @date 2014/10/09
    * @description This method returns a list of vehicle models.
    * @return List<SelectOption> A list of SelectOption that contains all applicable vehicle model values.
    */
    public static List<SelectOption> getVehicleModelList(boolean enableNoneOption) {
        List<SelectOption> options = new List<SelectOption>();
        if(enableNoneOption == true)
            options.add(new SelectOption('--None--', '--None--'));
        Schema.DescribeFieldResult fieldResult = VehicleSearchSetting__c.Model__c.getDescribe();
        List<Schema.PicklistEntry> listPicklistEntry = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : listPicklistEntry)
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        return options;
    }

}