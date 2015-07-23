/*************************************************************************************************
Created By:    Manisha Gupta
Date:          September 27, 2014
Description:   Get Latest Customer Need for Account(T-323089)
**************************************************************************************************/
public class UVSAccountLatestCustomerNeedController {
  public List<Solution_Interest_Detail__c> custNeed{get;set;}
  public UVSAccountLatestCustomerNeedController(ApexPages.StandardController sc){
    custNeed = new List<Solution_Interest_Detail__c>();
    Id latestContactId;
    for(Contact c : [Select Id from Contact where AccountId=:sc.getId() order by LastModifiedDate DESC LIMIT 1]){
      latestContactId = c.Id;
    }
    if(latestContactId == null){
      ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'No Contact exists.'));
      return;
    }
    for(Solution_Interest_Detail__c sID : [Select Id, Name, Vehicle_Name__c, Vehicle_Type__c, Solutions_Interest__r.Contact_Id__c,
                                           Solutions_Interest__c, Solutions_Interest__r.Name, Solutions_Interest__r.Contact_Id__r.Name
                                           from Solution_Interest_Detail__c
                                           where Solutions_Interest__r.Contact_Id__c = :latestContactId
                                           order by Id desc]){
      custNeed.add(sId);
    }
    system.debug('===================' + custNeed);
    if(custNeed.isEmpty()){
      ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'No Customer Need exists.'));
    }

  }
}