public class AddSurveyActivityController {
     // Constructor - this only really matters if the autoRun function doesn't work right
        private final Survey_Assignment__c sa;
    public AddSurveyActivityController(ApexPages.StandardController stdController) {
        this.sa = (Survey_Assignment__c)stdController.getRecord();
    }

public PageReference execute() {

        String theId = ApexPages.currentPage().getParameters().get('id');
 
        BatchAutoSurveyActivity basa  = new BatchAutoSurveyActivity(); 
        database.executebatch(basa); 
        if (theId == null) {
            // Display the Visualforce page's content if no Id is passed over
            return null;
        } else
        {     
         // Redirect the user back to the original page
        PageReference pageRef = new PageReference('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;
        }
     }
 
}