public with sharing class ServicesProvided {
    public boolean substitution {get; set;}
    public String subsDuringPM {get; set;}
    public boolean pickupAndDelivery {get; set;}
    public boolean fuel {get; set;}
    public boolean reeferService {get; set;}
    public boolean parking {get; set;}
    public boolean onsiteMaintenance {get; set;}
    public Integer numberOfWashesProvided {get; set;}
    public String safetyProgram {get; set;}
    public boolean pegged {get; set;}
    
    static testMethod void test_ServicesProvided(){
    	ServicesProvided sp = new ServicesProvided();
    	sp.substitution = false;
    	sp.subsDuringPM = '';
    	sp.pickupAndDelivery = false;
    	sp.fuel = false;
    	sp.reeferService = false;
    	sp.parking = false;
    	sp.onsiteMaintenance = false;
    	sp.numberOfWashesProvided = 0;
    	sp.safetyProgram = '';
    	sp.pegged = false;
    	
    	system.assertequals(sp.substitution, false);
    	system.assertequals(sp.subsDuringPM, '');
    	system.assertequals(sp.pickupAndDelivery, false);
    	system.assertequals(sp.fuel, false);
    	system.assertequals(sp.reeferService, false);
    	system.assertequals(sp.parking, false);
    	system.assertequals(sp.onsiteMaintenance, false);
    	system.assertequals(sp.numberOfWashesProvided, 0);
    	system.assertequals(sp.safetyProgram, '');
    	system.assertequals(sp.pegged, false);
    }
    
}