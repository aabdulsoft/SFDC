/***********************************************************************
 Class          : SAMResponse
 Author         : Manisha Gupta
 Created Date   : Sept 9, 2014
 Descritption   : Wrapper class to hold the formatted response returned from web service

 Date       Modified By         Description

 ************************************************************************/
public class SAMResponse{

  // Mandatory field for class
  public List<PotentialDuplicate> listPotentialDuplicates{get;set;}
  public List<ResponseError> lstError{get;set;}
  public String newAccountBSNP{get;set;}

  public String getClassName() {
    return SAMResponse.Class.getName();
  }

  public SAMResponse(){
    lstError = new list<ResponseError>();
    listPotentialDuplicates = new list<PotentialDuplicate>();
  }


  public void put(String fieldName , String value) {
	  if(fieldName == 'NEW_ACCOUNT_BSNP'){
	  	newAccountBSNP = value;
	  }else if(fieldName == 'BSNP_ID') {
	    if(!listPotentialDuplicates.isEmpty() && listPotentialDuplicates[listPotentialDuplicates.size()-1].BSNP_ID == null){
	      system.debug('======MANISHA LIST NOT EMPTY========');
	      listPotentialDuplicates[listPotentialDuplicates.size()-1].BSNP_ID = value;
	    }else{
	    	system.debug('======MANISHA LIST EMPTY========');
	      listPotentialDuplicates.add(new PotentialDuplicate(value, null, null, null, null, null, null));
	    }
	  }else if(fieldName == 'CUST_NO') {
    	if(!listPotentialDuplicates.isEmpty() && listPotentialDuplicates[listPotentialDuplicates.size()-1].CUST_NO == null){
        system.debug('======MANISHA LIST NOT EMPTY========');
        listPotentialDuplicates[listPotentialDuplicates.size()-1].CUST_NO = value;
      }else{
        system.debug('======MANISHA LIST EMPTY========');
        listPotentialDuplicates.add(new PotentialDuplicate(null, value, null, null, null, null, null));
      }
    }else if(fieldName == 'Name') {
    	system.debug('============NAME================' + listPotentialDuplicates);
    	if(!listPotentialDuplicates.isEmpty() && listPotentialDuplicates[listPotentialDuplicates.size()-1].Name == null){
        system.debug('======MANISHA LIST NOT EMPTY========' + value );
        listPotentialDuplicates[listPotentialDuplicates.size()-1].Name = value;
      }else{
        system.debug('======MANISHA LIST EMPTY========' + value);
        listPotentialDuplicates.add(new PotentialDuplicate(null, null, value, null, null, null, null));
        system.debug('============NAME================' + listPotentialDuplicates);
      }
	  }else if(fieldName == 'Location') {
	  	if(!listPotentialDuplicates.isEmpty() && listPotentialDuplicates[listPotentialDuplicates.size()-1].Location == null){
        system.debug('======MANISHA LIST NOT EMPTY========');
        listPotentialDuplicates[listPotentialDuplicates.size()-1].Location = value;
      }else{
        system.debug('======MANISHA LIST EMPTY========');
        listPotentialDuplicates.add(new PotentialDuplicate(null, null, null, value, null, null, null));
      }
	  }else if(fieldName == 'Phone') {
	  	if(!listPotentialDuplicates.isEmpty() && listPotentialDuplicates[listPotentialDuplicates.size()-1].Phone == null){
        system.debug('======MANISHA LIST NOT EMPTY========');
        listPotentialDuplicates[listPotentialDuplicates.size()-1].Phone = value;
      }else{
        system.debug('======MANISHA LIST EMPTY========');
        listPotentialDuplicates.add(new PotentialDuplicate(null, null, null, null, value, null, null));
      }
	  }else if(fieldName == 'EmailAddress') {
    	if(!listPotentialDuplicates.isEmpty() && listPotentialDuplicates[listPotentialDuplicates.size()-1].EmailAddress == null){
        system.debug('======MANISHA LIST NOT EMPTY========');
        listPotentialDuplicates[listPotentialDuplicates.size()-1].EmailAddress = value;
      }else{
        system.debug('======MANISHA LIST EMPTY========');
        listPotentialDuplicates.add(new PotentialDuplicate(null, null, null, null, null, value, null));
      }
	  }else if(fieldName == 'ContactName') {
	    if(!listPotentialDuplicates.isEmpty() && listPotentialDuplicates[listPotentialDuplicates.size()-1].ContactName == null){
        system.debug('======MANISHA LIST NOT EMPTY========');
        listPotentialDuplicates[listPotentialDuplicates.size()-1].ContactName = value;
      }else{
        system.debug('======MANISHA LIST EMPTY========');
        listPotentialDuplicates.add(new PotentialDuplicate(null, null, null, null, null, null, value));
      }
	  }else if(fieldName == 'errorCode'){
	    if(!lstError.isEmpty() && lstError[lstError.size()-1].code == null){
	      lstError[lstError.size()-1].code = value;
	    }else{
	    	lstError.add(new ResponseError(value, null));
	    }
	  } else if(fieldName == 'errorMessage'){
	    if(!lstError.isEmpty() && lstError[lstError.size()-1].message == null){
	      lstError[lstError.size()-1].message = value;
	    }else{
	       lstError.add(new ResponseError(null, value));
	    }
	  }
	  system.debug('===================listPotentialDuplicates==========' + listPotentialDuplicates);

	}


  public class ResponseError{
    public String code {get;set;}
    public String message {get;set;}

    public ResponseError(String code, String message){
      this.code = code;
      this.message = message;
    }
  }

  public class PotentialDuplicate{
  	public boolean isSelected{get;set;}
    public string BSNP_ID{get;set;}
    public string CUST_NO{get;set;}
    public string Name{get;set;}
    public string Location{get;set;}
    public string Phone{get;set;}
    public string EmailAddress{get;set;}
    public string ContactName{get;set;}

    public PotentialDuplicate(String BSNP_ID, String CUST_NO, String Name, String Location, String Phone, String EmailAddress, String ContactName){
      this.isSelected = false;
      this.BSNP_ID = BSNP_ID;
	    this.CUST_NO = CUST_NO;
	    this.Name = Name;
	    this.Location = Location;
	    this.Phone = Phone;
	    this.EmailAddress = EmailAddress;
	    this.ContactName = ContactName;

    }
  }
}