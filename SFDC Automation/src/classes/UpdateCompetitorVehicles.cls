public with sharing class UpdateCompetitorVehicles {

    public static void updateCompetitorVehiclesOnLeads(Database.Leadconvertresult lc){
        Database.Leadconvertresult []alc = new Database.Leadconvertresult[1];
        alc[0] = lc;
        UpdateCompetitorVehicles.updateCompetitorVehiclesOnLeads( alc );
    }

    public static void updateCompetitorVehiclesOnLeads(Database.Leadconvertresult []alc){
		System.debug('***** Start updateCompetitorVehiclesOnLeads *****');
        recordtype rt = [select id from recordtype where name = 'Account Competitor Vehicle']; 
		System.debug('recordtype' + rt);
        map<id, id> leadtoaccount = new map<id, id>();
        for (database.Leadconvertresult lc : alc){
            leadtoaccount.put(lc.getleadid(), lc.getaccountid());
        }
        
        list<Competitor_Vehicle__c> lcv = new list<Competitor_Vehicle__c>();
        
        for (Competitor_Vehicle__c cv : [select account__c, lead__c from competitor_vehicle__c where lead__c in :leadtoaccount.keyset()]){
            cv.account__c = leadtoaccount.get(cv.lead__c);
            if (rt != null){
                cv.recordtypeid = rt.id;
            }
            lcv.add(cv);
        }
        update lcv;
        System.debug('***** End updateCompetitorVehiclesOnLeads *****');
    }
    
    static testMethod void test_updateCompetitorVehiclesOnLeads() {
		Lead l = new lead();
		l.FirstName = 'firstTest';
		l.LastName = 'test';
		l.State = 'IL';
		l.PostalCode = RyderGlobalVariables.TEST_POST_CODE;
		l.Country = 'US';
		l.Company = 'Test Company';
		l.Email = 'jkdsgfj@ryder.com';
		l.Status = 'Accepted';
		insert l;
		Competitor_Vehicle__c cv = new Competitor_Vehicle__c();
		cv.Lead__r = l;
		cv.Vehicle_Count__c = 10;
		insert cv;
		database.Leadconvert lc = new database.Leadconvert();
		lc.setLeadId(l.id);
		lc.setDoNotCreateOpportunity(true);
		LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
		lc.setConvertedStatus(convertStatus.MasterLabel);
		
		database.Leadconvertresult lcr = database.convertlead(lc);
		UpdateCompetitorVehicles.updateCompetitorVehiclesOnLeads(lcr);
		list<Competitor_Vehicle__c> lcv = [select id, account__c, lead__c from competitor_vehicle__c where account__r.id = :lcr.getaccountid()];
		//system.assertequals(lcv.size(),1);
    }
    
}