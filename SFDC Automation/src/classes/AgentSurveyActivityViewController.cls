public class AgentSurveyActivityViewController{
     
    public String taskid{get; set;}
    
    public AgentSurveyActivityViewController(ApexPages.StandardController controller) {
        this.controller = controller;
        taskid= ApexPages.currentPage().getParameters().get('id');
        if (taskid == null){
            taskid = '00TR000000CLNntMAH';
        }
    }
 
    public PageReference getRedir() {
    	//08-17-2011 updated by Neelima to get the record type dynamically instead of a hard coded value.
        RecordType recordType= [Select r.Id  from RecordType r where r.SobjectType='Task' and developerName='Survey'];
        List<Task> t = [Select id, recordtypeid From Task Where Id = :taskid];
        PageReference newPage;
  
     if(t.size() > 0){
        Task t_co = t.get(0);
       // if (t_co.recordtypeid == '012R00000000XuzIAE') {
       if (t_co.recordtypeid == recordType.Id) {
            newPage = Page.SurveyActivities;
        } else {
            newPage = new PageReference('/' + t_co.id);
            newPage.getParameters().put('nooverride', '1');
        }
        newPage.getParameters().put('id', t_co.id);        
     }
      else {
          newPage = new PageReference('/500/e');
     }
     return newPage.setRedirect(true);
    }
      public static testMethod void testAgentSurveyActivityViewController() {
      	
             	//08-17-2011 updated by Neelima to get the record type dynamically instead of a hard coded value.
            RecordType recordType= [Select r.Id  from RecordType r where r.SobjectType='Task' and developerName='Survey'];
        
          //  Task testTask = new Task( Subject = 'Customer Sat Survey', Type = 'Survey', Priority = 'Low', RecordTypeId = '012R00000000XuzIAE', ActivityDate = System.today() );
            Task testTask = new Task( Subject = 'Customer Sat Survey', Type = 'Survey', Priority = 'Low', RecordTypeId = recordType.Id, ActivityDate = System.today() );
            insert testTask; 
            
            // Find a Task
             Task t = [Select id, recordtypeid From Task Where Subject = 'Customer Sat Survey' AND Type = 'Survey' LIMIT 1][0]; // Not sure if it is needed, but setup a page and load it 
             PageReference pageRef = Page.SurveyActivities; 
             pageRef.getParameters().put('nooverride','1'); 
             //pageRef.getParameters().put('id','http://'+ t.id + '/'); 
             pageRef.getParameters().put('id', '/' + t.id);
             Test.setCurrentPage(pageRef);
             
            
            // Instantiate a new controller with all parameters in the page 
            Test.startTest(); 
            Apexpages.StandardController stdController = new Apexpages.StandardController(t); 
            AgentSurveyActivityViewController controller = new AgentSurveyActivityViewController (stdController); 
            PageReference nextPage= controller.getRedir(); 
            Test.stopTest();         
        }   

    private final ApexPages.StandardController controller;
 
}