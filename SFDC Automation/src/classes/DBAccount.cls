public class DBAccount 
{
    public boolean selected{get;set;}
    public String Id {get; set;}
    public String DunsNumber {get; set;}
    public String Conf_cd {get; set;}
    public String Company_Name {get; set;}
    public String Address_Line {get; set;}
    public String CountryCode {get; set;}
    public String City {get; set;}
    public String State {get; set;}
    public String TLCM_Number {get; set;}
    public String ZipCode {get; set;}
    public String probabilityOfAccuracy {get; set;}
    public String CustomerType {get; set;}
    public Decimal ryderProbability {get; set;}
    public String locationType {get; set;}
    
    //AKK 06/20/2014 - Start
    //added to tag data.com datacloudcompany companyid
    public String DCCompanyId {get; set;}
    //AKK 06/20/2014 - End
    
    //AKK 07/17/2014 - Start
    //added to tag data.com datacloudcompany companyid
    public Double AnnualRevenue {get; set;}
    //AKK 07/17/2014 - End    
    
    
    //AAK 11/12/2014 Start - QC630 Change lead conversion process to use DUNSRIGHT API for matching and restore restricted functionality to create account without match
    public String matchGrade {get; set;}
    public Decimal matchConfidence {get; set;}
    public String tradeStyle {get; set;}    
    //AAK 11/12/2014 End
    
}