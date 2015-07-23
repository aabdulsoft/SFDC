public with sharing class KeyContactVO {
    public string Name {get; set; }
    public Id id {get; set;}
    public String customerBranch {get; set;}
    public String customerBranchId {get; set;}
    public String contactName {get; set;}
    public String contactId {get; set;}
    public String contactType {get; set;}
    public String contactRole {get; set;}
    public String availableTo {set; get; }
    public String availableFrom {set; get; }
    public String available247 {set; get; }
    // neelima boppana- added for key contact rewrite 06/29/11
    public boolean allBranch {set; get; }
    public boolean contactStatus {set; get;}
    public boolean contactDoNotCall {set; get;}
    public boolean contactSurveyOptOut {set; get;}
}