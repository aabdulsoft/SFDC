public class RyderSurveyReport
{
    public ApexPages.StandardSetController setSurveyCon {
        get {
            if(setSurveyCon == null) {
                setSurveyCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [SELECT rs.Id,rs.Survey_Submission_Date__c, rs.Contact__r.Account.Name, rs.Contact__r.Name, rs.Contact__r.Title,
                      rs.Contact__r.Fax, rs.Activity_Id__c, Contact__r.Account.CustProspectID__c, rs.Contact__r.Account.LesseeNo__c,
                      rs.Customer_Branch__r.Customer_Branch_Owner__r.Name, rs.Customer_Branch__r.Name, rs.Customer_Branch__r.Area_Name__c,
                      rs.Customer_Sat_Likelihood_to_Renew__c, rs.Customer_Sat_Overall_Satisfaction_FSL__c, rs.Customer_Sat_Overall_Satisfaction_RPM__c,
                      rs.Customer_Sat_Willingness_to_Refer__c, rs.Customer_Sat_Maintenance_Satisfaction__c, rs.Customer_Sat_Shop_Communications__c,
                      rs.Customer_Sat_Acct_Mgr_Satisfaction__c, Customer_Satisfaction_Survey__c
                      FROM Ryder_Surveys__c rs WHERE rs.Activity_ID__c = :activityId]));
            }
            return setSurveyCon;
        }
        set;
    }

    private string DONT_KNOW = 'Don\'t Know';
    
    public List<Task> tasklist;

    public List<Task> TaskList() {
        if (tasklist == null)
        {           
            List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
            
            System.Debug('**** rs[0].Activity_Id__c = ' + rs[0].Activity_Id__c);
                        
            tasklist = [SELECT t.Call_Attempts__c, t.Id, t.Subject, t.Type, t.WhatId FROM Task t where t.Id = :rs[0].Activity_Id__c];
        }
        return tasklist;
    }
    
    String ClosedLoop = '';
    public string getClosedLoop()
    {
        List<Task> t = TaskList();
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        List<Customer_Branch__c> cb = [Select c.Id, c.Name from Customer_Branch__c c where c.Id = :t[0].WhatId];
        //System.debug('****t[0].WhatId = ' + t[0].WhatId);
        List<Case> c = [Select c.Customer_Branch__c, c.Customer_Branch__r.Id, c.Customer_Branch__r.Name, c.Origin from Case c  where c.Customer_Branch__r.Id = :cb[0].Id and c.Activity_ID__c = :activityId];
        //System.debug('****c.size() = ' + c.size());
        if(c.size() > 0)
        {
            if(rs[0].Customer_Branch__r.Name == cb[0].Name && (c[0].Origin.contains('CSI Closed Loop') || (c[0].Origin.contains('Customer Sat Survey')) || (c[0].Origin.contains('Phone'))))
            {
                ClosedLoop = 'Closed Loop';
            }
        }
        return ClosedLoop;
    }

    public List<Ryder_Survey_Response__c> rydersurveyresponse;

    public List<Ryder_Survey_Response__c> RyderSurveyResponse() {
        if (rydersurveyresponse== null)
        {
            List<Ryder_Surveys__c> rs = setSurveyCon.getRecords(); 
           // rydersurveyresponse = [SELECT r.Question_Number__c, r.Question_Response__c FROM Ryder_Survey_Response__c r WHERE r.CT_Survey_ID__c = :rs[0].Customer_Satisfaction_Survey__c];
           // neelima- 24Feb2012- updated the soql to get the responses by survey id rather than the clickTools view link.
           rydersurveyresponse = [SELECT r.Question_Number__c, r.Question_Response__c FROM Ryder_Survey_Response__c r WHERE r.surveyid__c = :rs[0].Id];
        }
        return rydersurveyresponse;
    }

    public string activityId{
        get{
            if(activityId == null)
            {
                //return '00TR000000CSMllMAH';
                return ApexPages.currentPage().getParameters().get('Id');
            }
            else
            {
               return activityId;
            }
        } 
        set{
            if (value == null)
            {
                //activityId = '00TR000000CSMllMAH';
                activityId = ApexPages.currentPage().getParameters().get('Id');
            }
            else
            {
                activityId = value;
            }
        }
    }
    

    String SurveySubmissionDate = '';

    public String getSurveySubmissionDate() {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        SurveySubmissionDate = rs[0].Survey_Submission_Date__c.format('MMM dd, yyyy');
        return SurveySubmissionDate;
    }

    public String getCallAttempts() {
        List<Task> t = TaskList();
        return t[0].Call_Attempts__c.toPlainString();
    }
    
    public String getMethod() {
        List<Task> t = TaskList();
        String method = '';
        if(t[0].Subject == 'Customer Sat Survey' && t[0].Type == 'Survey')
        {
            method = 'Phone';
        }
        else if (t[0].Subject == 'Rental Customer Sat Survey' && t[0].Type == 'Survey')
        {
            method = 'Email';
        }
        return method;
    }

    public String getCompanyName() {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        return rs[0].Contact__r.Account.Name;
    }
    
    public String getContactName() {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        return rs[0].Contact__r.Name;
    }

    public String getContactTitle () {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        return rs[0].Contact__r.Title;
    }

    public String getFleetType () {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        string type = '';
        if(rs[0].Customer_Sat_Overall_Satisfaction_FSL__c != null)
        {
            type = 'FSL';
        }
        //Changed By: Saad Wali Jaan 
      //Changed Dt: 09/25/2012
      //Change Des: In case if the user selects the Fleet type as FSL & RPM, then the FSL type was not 
      //displaying both on the PDF due to conditional logic.
        if(rs[0].Customer_Sat_Overall_Satisfaction_RPM__c != null)
        type= (type !='') ? type+ ', RPM' : 'RPM';
        return type;
    }

    public String getContactFax () {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        return rs[0].Contact__r.Fax;
    }

    public String getCSICustomerId () {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        return rs[0].Contact__r.Account.CustProspectID__c;
    }

    public String getLesseeNo () {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        return rs[0].Contact__r.Account.LesseeNo__c;
    }

    public String getManager () {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        return rs[0].Customer_Branch__r.Customer_Branch_Owner__r.Name;
    }

    public String getBranch () {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        return rs[0].Customer_Branch__r.Name;
    }
    
    public String getRegion () {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        return rs[0].Customer_Branch__r.Area_Name__c;
    }
    
    //Changed By: Saad Wali Jaan 
    //Changed Dt: 05/07/2012
    //Requested By: Holly 
    //Change Des: The CSI score should be the average of overall satisfaction and intent to renew.
    //The overall satisfaction is the average of FSL & RPM
    public String getOverallRyderRelationship () {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        Integer count = 0;
        Decimal overallSat = 0;
        Decimal csiScore = 0;
        Decimal num1 = 0;
        Decimal num2 = 0;
        Decimal num3 = 0;
        if(rs[0].Customer_Sat_Overall_Satisfaction_RPM__c != null)
        {
            if(rs[0].Customer_Sat_Overall_Satisfaction_RPM__c != DONT_KNOW)
            {
                num1 = Decimal.valueof(rs[0].Customer_Sat_Overall_Satisfaction_RPM__c);
                count++;
            }
        }
        if(rs[0].Customer_Sat_Overall_Satisfaction_FSL__c != null)
        {
            if(rs[0].Customer_Sat_Overall_Satisfaction_FSL__c  != DONT_KNOW)
            {
                num2 = Decimal.valueof(rs[0].Customer_Sat_Overall_Satisfaction_FSL__c);
                count++;
            }
        }
        //Change Start
        if(count == 0)
        {
          csiScore = 0;
        }
        else if (count > 0)
        {
          overallSat = ((num1 + num2)/count);
          
          if(rs[0].Customer_Sat_Likelihood_to_Renew__c != null)
          {
              if(rs[0].Customer_Sat_Likelihood_to_Renew__c != DONT_KNOW)
              {
                  num3 = Decimal.valueof(rs[0].Customer_Sat_Likelihood_to_Renew__c);
                  count++;
              }
          } 
            if(num3 > 0)
            {
              csiScore = ((num3 + overallSat)/2)*10;
            }
            else
            {
              csiScore = 0;
            }
        }
        if (csiScore == 0)
        {
          return null;
        }
        else
        {
          return csiScore.format();
        }
        //Change Ends
    }

    public String getWillingnessToRefer () {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        Integer num = 0;
        Integer total = 0;
        if(rs[0].Customer_Sat_Willingness_to_Refer__c != null)
        {
            if(rs[0].Customer_Sat_Willingness_to_Refer__c == DONT_KNOW)
            {
                return DONT_KNOW;
            }
            else
            {
                num = integer.valueOf(rs[0].Customer_Sat_Willingness_to_Refer__c);
            }
        }
        String promoter = '';
        total = num * 10;
        if(num < 7)
        {
            promoter = total.format() + ' Detractor';
        }
        else if (num > 8)
        {
            promoter = total.format() + ' Promoter';
        }
        else
        {
            promoter = total.format() + ' Passive';
        }
        
        return promoter;
    }

  //Changed By: Saad Wali Jaan 
    //Changed Dt: 09/25/2012
    //Change Des: In case if the user selects the Fleet type as FSL & RPM, then the overall satisfaction  
    //score was not getting displayed correctly on the PDF due to conditional logic.
    public String getOverallSatisfaction () {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        Integer count = 0;
        Decimal overallSat = 0;
        Decimal num1 = 0;
        Decimal num2 = 0;
        if(rs[0].Customer_Sat_Overall_Satisfaction_FSL__c != null)
        {
            if(rs[0].Customer_Sat_Overall_Satisfaction_FSL__c != DONT_KNOW)
            {
                num1 = integer.valueof(rs[0].Customer_Sat_Overall_Satisfaction_FSL__c);
                count++;
            }
        }
        if(rs[0].Customer_Sat_Overall_Satisfaction_RPM__c != null)
        {
            if(rs[0].Customer_Sat_Overall_Satisfaction_RPM__c != DONT_KNOW)
            {
        num2 = integer.valueof(rs[0].Customer_Sat_Overall_Satisfaction_RPM__c);
                count++;
            }
        }
        if (count == 0) return null;       
        else
        {
          overallSat = (num1 + num2)/count;
          return overallSat.format();
        }
    }
    
    public String getLikelihoodToRenew () {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        Integer num = 0;
        if(rs[0].Customer_Sat_Likelihood_to_Renew__c != null)
        {
            if(rs[0].Customer_Sat_Likelihood_to_Renew__c == DONT_KNOW)
            {
                return DONT_KNOW;
            }
            else
            {
                num = integer.valueof(rs[0].Customer_Sat_Likelihood_to_Renew__c);           
            }
        }
        if (num == 0)
        {
          return null;
        }
        else
        {
          return num.format();
        }
    }

    public String getMaintenanceSatisfaction () {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        Integer num = 0;
        if(rs[0].Customer_Sat_Maintenance_Satisfaction__c != null)
        {
           if(rs[0].Customer_Sat_Maintenance_Satisfaction__c == DONT_KNOW)
           {
               return DONT_KNOW;
           }
           else
           {
               num = integer.valueof(rs[0].Customer_Sat_Maintenance_Satisfaction__c);
           }
        }

        if(num > 0)
        {    
            return num.format();
        }
        else
        {
            return '';
        }
    }

    public String getShopCommunications () {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        Integer num = 0;
        if(rs[0].Customer_Sat_Shop_Communications__c != null)
        {
            if(rs[0].Customer_Sat_Shop_Communications__c == DONT_KNOW)
            {
                return DONT_KNOW;
            }
            else
            {
                num = integer.valueof(rs[0].Customer_Sat_Shop_Communications__c);
            }
        }

        if(num > 0)
        {    
            return num.format();
        }
        else
        {
            return '';
        }
    }

    public String getAccountManagerSatisfaction () {
        List<Ryder_Surveys__c> rs = setSurveyCon.getRecords();
        Integer num = 0;
        if(rs[0].Customer_Sat_Acct_Mgr_Satisfaction__c != null)
        {
            if(rs[0].Customer_Sat_Acct_Mgr_Satisfaction__c == DONT_KNOW)
            {
                return DONT_KNOW;
            }
            else
            {
                num = integer.valueof(rs[0].Customer_Sat_Acct_Mgr_Satisfaction__c);
            }
        }

        if(num > 0)
        {    
            return num.format();
        }
        else
        {
            return '';
        }
    }
    
    /////////////////////////////
    /////question properties/////
    ////////////////////////////

    public String getQ22_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 22.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ24_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 24.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }

    public String getQ27_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 27.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ29_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 29.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ35_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 35.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ36_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 36.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ36_10() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 36.10)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ36_20() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 36.20)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ36_30() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 36.30)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ36_40() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 36.40)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ36_50() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 36.50)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ36_60() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 36.60)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ36_70() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 36.70)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ37_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 37.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }

    public String getQ38_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 38.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ40_20() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 40.20)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ40_30() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 40.30)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ40_40() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 40.40)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ40_60() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 40.60)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }

    public String getQ40_70() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 40.70)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }

    public String getQ41_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 41.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ42_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 42.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ45_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 45.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ46_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 46.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ46_70() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 46.70)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }

    public String getQ47_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 47.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ48_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 48.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    public String getQ48_10() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 48.10)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ49_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 49.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ52_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 52.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
        
    public String getQ52_10() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 52.10)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
        
    public String getQ52_20() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 52.20)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
        
    public String getQ52_30() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 52.30)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
        
    public String getQ52_40() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 52.40)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
        
    public String getQ52_50() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 52.50)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
        
    public String getQ52_60() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 52.60)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
        
    public String getQ52_70() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 52.70)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ53_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 53.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }

    public String getQ55_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 55.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ58_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 58.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }

  public String getQ59_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 59.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }
    
    public String getQ61_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 61.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }

    public String getQ63_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 63.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }

    public String getQ64_00() {
        string question = '';
        List<Ryder_Survey_Response__c> rsr = RyderSurveyResponse();
        for(Ryder_Survey_Response__c response : rsr)
        {
            if(response.Question_Number__c == 64.00)
            {
                question = response.Question_Response__c;
            }
        }
        return question;
    }

    public RyderSurveyReport()
    {
        
        //system.debug ('***pageRef = ' + pageRef.getUrl());
    }
}