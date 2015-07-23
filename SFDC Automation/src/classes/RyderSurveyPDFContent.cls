/* RyderSurveyPDFContent class */
global class RyderSurveyPDFContent
{
    webservice static string GetSurveyContentByActivityId(string activityId)
    {
        PageReference pdf = Page.RyderSurveyPDF;
        
        //pass in activityId to the PDF page
        pdf.getParameters().put('id',activityId);
  
        //system.debug('*****activityId = ' + activityId);
        
        Blob body;
    
        try {
    
            // returns the output of the page as a PDF
            body = pdf.getContent();
            system.debug ('***body blobbed'); 
            system.debug ('***body = ' + body); 
        } catch (VisualforceException e) {
            body = Blob.valueOf('Page not generated');
            system.debug ('***body not blobbed');
        }
      
        return body.toString();
    }
}