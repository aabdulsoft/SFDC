/***********************************************************************
 Class      : SmartContactSearchExtension
 Author     : Appirio
 Created Date   : 4 march 2014
 Descritption   : Provide functionality to contact search.
 ************************************************************************/

public without sharing class SmartContactSearchExtension {

	//Search criteria fields
	public String contactFirstNameToSearch {set;get;}
	public String contactLastNameToSearch {set;get;}
	public String contactEmail {set;get;}
	public String contactPhone {set;get;}
	public STring contactAccount {get;set;}
	public String resetTextBoxName {set; get;}
	public String filterCriteria {get;set;}
	public String contactFieldCsv {get;set;}

	//Constructor
	public SmartContactSearchExtension(ApexPages.StandardController controller) {
    init();
	}

	//Constructor
	public SmartContactSearchExtension() {
    init();
	}

	private void init(){
	  resetSearchStatus();
    createContactFieldCsv();
	}

	// Method for create csv of field from fieldset of Contact
	private void createContactFieldCsv(){
	  contactFieldCsv = SmartSearchUtility.createFieldCsv('Contact','Contact_Search_Result');
	}

	//set to default status of page
	public void resetSearchStatus(){
    //Reset Contact fields

    if(resetTextBoxName != ''){
	    if(resetTextBoxName=='1'){
        contactFirstNameToSearch = '';
	    }
	    else if(resetTextBoxName=='2'){
        contactLastNameToSearch = '';
	    }
	    else if(resetTextBoxName=='3'){
        contactEmail = '';
	    }
	    else if(resetTextBoxName=='4'){
        contactPhone = '';
	    } else if(resetTextBoxName=='5'){
        contactAccount = '';
	    }
	    performSearch();
    }else{
	    contactFirstNameToSearch = '';
	    contactLastNameToSearch = '';
	    contactEmail = '';
	    contactPhone = '';
	    contactAccount = '';
	    filterCriteria = '';
    }
  }

	// Method to create filter criteria string for contact search
	public String findSearchCondition(){

    String query = '';

	  if(String.isNotBlank(contactFirstNameToSearch)){
      contactFirstNameToSearch = contactFirstNameToSearch.replace('*','');
    }

	  if(String.isNotBlank(contactAccount)){
	      contactAccount = contactAccount.replace('*','');
	      contactAccount = String.escapeSingleQuotes(contactAccount);
	      query += ' Account.Name like \'%' + contactAccount.Trim() + '%\' OR';
	  }

	  if(String.isNotBlank(contactLastNameToSearch)){
	      contactLastNameToSearch = contactLastNameToSearch.replace('*','');
	      contactLastNameToSearch = String.escapeSingleQuotes(contactLastNameToSearch);
	      query += ' LastName like \'%' + contactLastNameToSearch.Trim() + '%\' OR';
	  }
	  if(String.isNotBlank(contactEmail)){
	      contactEmail = contactEmail.replace('*','');
	      contactEmail = String.escapeSingleQuotes(contactEmail);
	      query += ' Email like \'%' + contactEmail.Trim() + '%\' OR';
	  }
    system.debug('===contactPhone========' + contactPhone);
	  if(String.isNotBlank(contactPhone)){
	      system.debug('===========' + contactPhone);
	      contactPhone = contactPhone.replace('*','');
	      contactPhone = String.escapeSingleQuotes(contactPhone);
	      query += ' Phone like \'%' + contactPhone.Trim() + '%\' OR';
	  }
	  if(String.isNotBlank(query)){
	    query = query.substring(0,query.lastindexof('OR'));
	  }
    system.debug('@@@@@@@@@@@@@@@@@@@@@@ ' + query);
    return query;
  }

  // method to search for contacts
  public void performSearch() {
    filterCriteria = findSearchCondition();
  }

  //method to create new contact if user clicks on new contact button
  public pagereference createNewContact(){
    String recordType = ApexPages.currentPage().getParameters().get('RecordType');
    Pagereference pg = new Pagereference('/' + SmartSearchUtility.getPrefix('Contact') +
                                          '/e?retURL=/apex/SmartContactSearch&nooverride=1&name_firstcon2=' +
                                          contactFirstNameToSearch + '&name_lastcon2=' +
                                          contactLastNameToSearch + '&con15=' + contactEmail +
                                          '&con4=' + contactAccount +
                                          (String.isEmpty(recordType) ? '' : '&RecordType=' + recordType ));
    pg.setRedirect(true);
    return pg;
  }

  // method to check the source of the page. If it is account then navigate to standard new contact page else navigate to smart contact search
  public Pagereference checkSource(){
    String accId = ApexPages.CurrentPage().getParameters().get('accid');
    String recordType = ApexPages.CurrentPage().getParameters().get('RecordType');
    if(accId <> null){
    	return new Pagereference('/003/e?retURL=%2F'+accId +
    	                         '&accid='+accId +
    	                         (recordType <> null ? '&RecordType='+recordType : '') +
    	                         '&ent=Contact&nooverride=1');
    }
    return null;
  }

}