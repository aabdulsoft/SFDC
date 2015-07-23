public with sharing class oppSplitController {

    public Opportunity opp {get;set;}
    Account acc;
    map<integer, oppsplitwrapper> opp_splits;
    private integer x=0;

    //AAK 7/31/2012 Start to hold the values of iams showing in the error.
    list<string> iams = new list<string>();

    public oppSplitController (ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
        list<Opportunity> lopp = [select id, accountid, RecordTypeId, CurrencyIsoCode from Opportunity where id = :opp.id];
        if (lopp.size()>0){
            opp = lopp.get(0);
            if (opp.AccountId != null) {
                acc = [select Account_Classification__c from Account where id = :opp.accountid][0];
            }
        }
        populateSplits();
        System.debug('opp : '+opp);
            }
    
    private void populateSplits(){
        opp_splits = new map<integer, oppsplitwrapper>();
    
        for( opportunity_split__c os : [select id, Sales_Team_Member__c, Split_Percentage__c, Pipeline_split_Amount__c  from 
                        Opportunity_Split__c where Opportunity__r.id = :opp.id order by split_percentage__c desc] ){
            opp_splits.put(x, new oppsplitwrapper(os,x));
            x++;                   
        }
    }

    public pagereference refresh(){
        populateSplits();
        return null;
    }

    public pagereference save(){
        list<opportunity_split__c> los = new list<opportunity_split__c>();
        list<opportunity_split__c> ldos = new list<opportunity_split__c>();
        opportunity_split__c os = null;
    
        for ( oppsplitwrapper osw:opp_splits.values() ){
             os = osw.opp_split;
             if (os.Split_Percentage__c == null || os.Split_Percentage__c == 0){
                  if (os.id!=null)
                       ldos.add (os);
            }else
                  los.add( osw.opp_split );
        }
        system.debug('los = ' + los );
    
        if (!checkOppSplitList(los))
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.error, 'Split percentages must add up to 100%');
            ApexPages.addmessage(mymsg);            
            return null;
        }

        if (!checkOppSplitTeamMembers(los))
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.error, 'Invalid Sales Team Member');
            ApexPages.addmessage(mymsg);            
            return null;
        }
        
         if (!checkOppSplitTeamMemberDuplicate(los))
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.error, 'User already exists in split');
            ApexPages.addmessage(mymsg);            
            return null;
        }

        //AAK 07/31/2014 Start REQ520 Prevent Inside Sales from owning splits - Phase 1 - Validation Rule for IAM owned opportunities        
        if (checkOppSplitTeamMembersIAM(los))
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.error, 'Please update the split holder to a Field Sales Rep. An Inside Sales Rep(s) ' + iams + ' cannot be the split holder');
            ApexPages.addmessage(mymsg);
            return null;
        }
        //AAK 07/31/2014 End

        
        delete ldos;
        upsert los;
        populateSplits();

        return null;
    }


       /* AAK 08/01/2014 Start - Commented as the requested functionality part of REQ346 automatic pipeline refresh
       is not fully functional but restricting error msgs to show up.
    public pagereference refreshOppty(){
        system.debug(LoggingLevel.INFO, 'rendered command here...' + opp.id);
        OpportunityDSAndRSVO totalResult = DealSummaryRateSheetUtil.SyncDealSummaryAndRateSheetForOpportunity(opp.id);
        populateSplits();
        return null;
    }*/
    
    private boolean checkOppSplitList(List<Opportunity_split__c> los){
        decimal y=0;
        for (Opportunity_split__c os : los){
            if ( os.split_percentage__c != null)
                y += os.split_percentage__c;
        }
            
        system.debug('total perecentages: '+y);
        if (y ==100)
            return true;
        else 
            return false;
    }
    
    private boolean checkOppSplitTeamMembers(List<Opportunity_split__c> los){
        for (Opportunity_split__c os : los){
            if ( os.Sales_Team_Member__c == null)
                return false;
        }
        return true;
    }
    
    private boolean checkOppSplitTeamMemberDuplicate(List<Opportunity_split__c> los){
        List<String> losSorted = new List<String>();
        //Sort list to get duplicates
        for (Opportunity_split__c os : los){
            losSorted.add(os.Sales_Team_Member__c);
        }
        losSorted.sort(); 
        string previousValue = '';
        for (String os : losSorted){
            if (os == previousValue){return false;}
            previousValue = os;
        }
        return true;
    }

    //AAK 07/31/2014 Start REQ520 Prevent Inside Sales from owning splits - Phase 1 - Validation Rule for IAM owned opportunities
    //This function will look for the IAM 
    private boolean checkOppSplitTeamMembersIAM(List<Opportunity_split__c> los)
    {
        if(iams!=null)
            iams.clear();       
        for (Opportunity_split__c os : los){
            System.debug('Sales Team in the list' + os.Sales_Team_Member__c);
            list<User> tmprofile = [select ProfileId, Name FROM User WHERE Id = :os.Sales_Team_Member__c];
            System.debug('Sales Team Member Profile : ' + tmprofile.get(0).ProfileId);
            if(Label.IAMProfiles.Contains(tmprofile.get(0).ProfileId))
                iams.add(tmprofile.get(0).Name);
        }       
        System.debug('iams size : ' + iams.size());
        if (iams.size()>0)
            return true;
        
        return false;
    } 
    //AAK 07/31/2014 End   


    
    public pagereference newrec(){
        Opportunity_Split__c opp_split = new Opportunity_Split__c();
        opp_split.opportunity__c = opp.id;
    
        opp_splits.put(x, new oppsplitwrapper(opp_split,x));
        x++;
        return null;
    }
    
    public pagereference deleterec(){
        integer idd = integer.valueof(ApexPages.currentPage().getParameters().get('idx'));
        system.debug(idd);
        system.debug('opp_splits:' + opp_splits);
        
        if (idd != null){
        Opportunity_Split__c opp_split = opp_splits.get(idd).opp_split;
    
        list<Opportunity_Split__c> los = new list<Opportunity_Split__c>();
        Opportunity_Split__c os = null;
        for (oppsplitwrapper osw : opp_splits.values()){
            if (osw.mapkey!=idd)
                los.add(osw.opp_split);
        }
    
        if ( checkOppSplitList(los) ){
            if (opp_split.id != null)
                delete [select id from opportunity_split__c where id = :opp_split.id];
    
            opp_splits.remove(idd);
    
            }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.error, 'Split percentages for the remaining split(s) must add up to 100%');
            ApexPages.addmessage(mymsg);
            }
        }
        return null;
    }
    
    public List<oppsplitwrapper> getOpportunitySplits() {
             return opp_splits.values();
    }
        
    public class oppsplitwrapper {  
             public Opportunity_split__c opp_split {get; set;}  
             public integer mapkey {get; set;}
             public oppsplitwrapper(opportunity_split__c os, integer x) {  
                opp_split = os;
                mapkey = x;  
            }  
    }
    
    public boolean getShowNewButton(){
        if (acc != null && acc.Account_Classification__c == 'Local')
            return false;
        else
            return true;
    }
    
 static testmethod void test1(){
    profile pro = [select id from profile where name = 'National'][0];
    User u1 = new user();
    u1.username = 'opptest@ryder.com';
    u1.LastName = 'lastname';
    u1.Email = 'mherlihy@salesforce.com';
    u1.Alias = 'tuser';
    u1.CommunityNickname = 'tnick';
    u1.profileid = pro.id;
    u1.TimeZoneSidKey = 'America/New_York';
    u1.LocaleSidKey = 'en_US';
    u1.EmailEncodingKey = 'ISO-8859-1';
    u1.LanguageLocaleKey = 'en_US';
    insert u1;
    
    system.runas(u1){
    
    Account a = new account();
    a.name='oppsplittest';
    a.BillingState = 'IL'; 
    a.ShippingState = 'IL';
    //AAK 08/02/2014
    a.Account_Classification__c = 'National';
    insert a;
        
    //AAK 08/03/2014 Start - REQ520 Prevent Inside Sales from owning splits - Phase 1
    //Added for original decsion maker    
    Contact contact = new Contact();
    contact.FirstName = RyderGlobalVariables.TEST_FIRST_NAME;
    contact.LastName = RyderGlobalVariables.TEST_LAST_NAME;
    contact.Phone = null;
    contact.Email_does_not_exist__c = true;
    contact.Email_Does_Not_Exist_Reason__c = 'I will update it later';
    contact.AccountId = a.id;
    insert contact;        
    //AAK 08/03/2014 End
    
    Opportunity o = new opportunity();
    o.account = a;
    o.name = 'test opp';
    o.stagename = 'test';
    o.closedate = date.today();
    o.estimated_proposal_date__c = date.today();
    //AAK 08/03/2014 Start - REQ520 Prevent Inside Sales from owning splits - Phase 1
    o.Original_Decision_Maker__c = contact.Id;
    //AAK 08/03/2014 End
    insert o;
    
    oppsplitcontroller controller = new oppsplitcontroller(New ApexPages.StandardController(o));
    controller.refresh();
    controller.newrec();
    
    //AAK 08/02/2014
    boolean sbut = controller.getShowNewButton();
    
    List<oppsplitwrapper> losw = controller.getOpportunitySplits();
    oppsplitwrapper osw = losw.get(0);
    opportunity_split__c os = osw.opp_split;
    os.Split_Percentage__c = 0;
    os.Sales_Team_Member__c = u1.id;
    osw.mapkey = osw.mapkey;
    osw.opp_split = os;
    controller.save();
    os.Split_Percentage__c = 100;
    controller.save();
    os.Split_Percentage__c = 80;
    controller.newrec();
    losw = controller.getOpportunitySplits();
    oppsplitwrapper osw0 = losw.get(0);
    oppsplitwrapper osw1 = losw.get(1);
    opportunity_split__c os0 = osw0.opp_split;
    os0.Split_Percentage__c = 80;
    os0.Sales_Team_Member__c = u1.id;
    opportunity_split__c os1 = osw1.opp_split;
    os1.Split_Percentage__c = 20;
    os1.Sales_Team_Member__c = u1.id;
    controller.save();
    
    
    ApexPages.currentPage().getParameters().put('idx','4');
    //controller.deleterec();
    os0.Split_Percentage__c = 100;
    //controller.deleterec();
    os0.split_percentage__c=110;
    //controller.save();
    
    oppsplitcontroller.oppsplitwrapper contest = new oppsplitcontroller.oppsplitwrapper(os0, 0);

    }

    }
    

 static testmethod void test2(){
    profile pro = [select id from profile where name = 'Inside Sales Manager'][0];
    User u1 = new user();
    u1.username = 'opptest@ryder.com';
    u1.LastName = 'lastname';
    u1.Email = 'mherlihy@salesforce.com';
    u1.Alias = 'tuser';
    u1.CommunityNickname = 'tnick';
    u1.profileid = pro.id;
    u1.TimeZoneSidKey = 'America/New_York';
    u1.LocaleSidKey = 'en_US';
    u1.EmailEncodingKey = 'ISO-8859-1';
    u1.LanguageLocaleKey = 'en_US';
    insert u1;
    
    system.runas(u1){
    
    Account a = new account();
    a.name='oppsplittest';
    a.BillingState = 'IL'; 
    a.ShippingState = 'IL';
    //AAK 08/02/2014
    a.Account_Classification__c = 'Local';
    insert a;

    //AAK 08/03/2014 Start - REQ520 Prevent Inside Sales from owning splits - Phase 1
    //Added for original decsion maker    
    Contact contact = new Contact();
    contact.FirstName = RyderGlobalVariables.TEST_FIRST_NAME;
    contact.LastName = RyderGlobalVariables.TEST_LAST_NAME;
    contact.Phone = null;
    contact.Email_does_not_exist__c = true;
    contact.Email_Does_Not_Exist_Reason__c = 'I will update it later';
    contact.AccountId = a.id;
    insert contact;        
    //AAK 08/03/2014 End
        
        
    Opportunity o = new opportunity();
    o.account = a;
    o.name = 'test opp';
    o.stagename = 'test';
    o.closedate = date.today();
    o.estimated_proposal_date__c = date.today();
    //AAK 08/03/2014 Start - REQ520 Prevent Inside Sales from owning splits - Phase 1
    o.Original_Decision_Maker__c = contact.Id;
    //AAK 08/03/2014 End

    insert o;
    
    oppsplitcontroller controller = new oppsplitcontroller(New ApexPages.StandardController(o));
    controller.refresh();
    controller.newrec();
    
    boolean sbut = controller.getShowNewButton();
    
    List<oppsplitwrapper> losw = controller.getOpportunitySplits();
    oppsplitwrapper osw = losw.get(0);
    opportunity_split__c os = osw.opp_split;
    os.Split_Percentage__c = 0;
    os.Sales_Team_Member__c = u1.id;
    osw.mapkey = osw.mapkey;
    osw.opp_split = os;
    controller.save();
    os.Split_Percentage__c = 100;
    controller.save();
    os.Split_Percentage__c = 80;
    controller.newrec();
    losw = controller.getOpportunitySplits();
    oppsplitwrapper osw0 = losw.get(0);
    oppsplitwrapper osw1 = losw.get(1);
    opportunity_split__c os0 = osw0.opp_split;
    os0.Split_Percentage__c = 80;
    os0.Sales_Team_Member__c = u1.id;
    opportunity_split__c os1 = osw1.opp_split;
    os1.Split_Percentage__c = 20;
    os1.Sales_Team_Member__c = u1.id;
    controller.save();
  

    }

    }
    
    
    
         
}