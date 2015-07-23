global with sharing class EditTester{

 webservice static String[] testObject(String objectName, Id[] ida){
    Map<String, String> ids_map = new Map<String, String>();
    String []editableIds = null;
    List<ID> lid = new List<ID>();

    String ids = '';
    
    for (integer x=0;x<ida.size() && x<200; x++){
        ids = ids + ' \'' + ida[x] + '\', ';
        ids_map.put(ida[x], ida[x]);
    }
    ids = ids.substring(0, ids.length()-2);
    
    String soql = 'select id from ' + objectName + ' where id in (' + ids + ')';
    system.debug(soql);
    
    sobject []so = database.query(soql);
  
    Savepoint sp = Database.setSavepoint();

    database.saveresult []sr = null;
    try{
    sr = database.update(so, false);
    system.debug(sr);
    }catch(exception e){
    system.debug(sr);
    }
    
    if (sr!= null){
        for(integer x=0;x<sr.size();x++){
            if (sr[x].isSuccess())
                lid.add(sr[x].getId());
        }
        
    editableIds = new string[lid.size()];
    for(integer x=0;x<editableIds.size();x++)
        editableIds[x] = lid.get(x);
    }

    Database.rollback(sp);
    return editableIds; 
 }
 
 static testMethod void tm1(){
    profile p = [select id from profile where name = 'National'][0];
    User u1 = new user();
    u1.username='edittm1@ryder.com';
    u1.LastName = 'lastname';
    u1.Email = 'mherlihy@salesforce.com';
    u1.Alias = 'tus';
    u1.CommunityNickname = 'tnick';
    u1.profileid = p.id;
    u1.TimeZoneSidKey = 'America/New_York';
    u1.LocaleSidKey = 'en_US';
    u1.EmailEncodingKey = 'ISO-8859-1';
    u1.LanguageLocaleKey = 'en_US';
    insert u1;

    system.debug(u1);
    
    User u2 = new user();
    u2.username='edittm2@ryder.com';
    u2.LastName = 'lastname';
    u2.Email = 'mherlihy@salesforce.com';
    u2.Alias = 'tus2';
    u2.CommunityNickname = 'tnick2';
    u2.profileid = p.id;
    u2.TimeZoneSidKey = 'America/New_York';
    u2.LocaleSidKey = 'en_US';
    u2.EmailEncodingKey = 'ISO-8859-1';
    u2.LanguageLocaleKey = 'en_US';
    insert u2;
    
    opportunity a = null;
    System.RunAs(u1){
        Account ac = new Account();
        ac.shippingstate = 'IL';
        ac.BillingState = 'IL';
        ac.BillingCountry = 'US';
        ac.BillingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
        ac.name = 'test account';
        ac.Account_Classification__c = 'National';
        insert ac;
        
        Contact c1 = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = ac.Id);
    	insert c1;
    
        a = new opportunity();
        a.accountid = ac.id;
        a.name = 'test acct1';
        a.stagename='test';
        a.Original_Decision_Maker__c = c1.id;
        a.closedate=date.today()+1;
        a.estimated_proposal_date__c = date.today();
        a.recordtypeid = [select id from recordtype where name = 'Standard Opportunity'][0].id;
        insert a;
    }
 
    System.RunAs(u2){

    Account ac2 = new Account();
    ac2.BillingState = 'IL';
    ac2.shippingstate = 'IL';
    ac2.BillingCountry = 'US';
    ac2.BillingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
    ac2.name = 'test account';
    ac2.Account_Classification__c = 'National';
    insert ac2;

	Contact c2 = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = ac2.Id);
    insert c2;

    opportunity a2 = new opportunity();
    a2.accountid = a2.id;
    a2.name = 'test acct2';
    a2.stagename='test';
    a2.Original_Decision_Maker__c = c2.id;
    a2.closedate=date.today()+1;
    a2.estimated_proposal_date__c = date.today();
    a2.recordtypeid = [select id from recordtype where name = 'Standard Opportunity'][0].id;
    insert a2;
    
    List<OpportunityContactRole> allContactRoles = [Select o.ContactId, o.Id, o.IsPrimary, o.OpportunityId, o.Role from OpportunityContactRole o where OpportunityId =: a2.Id];
    
    for (OpportunityContactRole ocr :allContactRoles)
    {
    System.AssertEquals(ocr.ContactId, c2.id);
    System.AssertEquals(ocr.Role, 'Decision Maker');
    System.AssertEquals(ocr.IsPrimary, true);
    }
     
    string [] inids = new string[2];
    inids[0] = a2.id;
    //inids[1] = [select id from account where name = 'test acct1'][0].id;
    inids[1] = a.id;

    string [] res = EditTester.testObject('opportunity', inids);
    system.debug('editable: ' + res);
    }
 }

}