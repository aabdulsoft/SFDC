global with sharing class RSM_VehicleActiveReportGT60FR087_Batch implements Database.Batchable<SObject>
{
	/* 
		Query the RSM_VehicleValidationDetails__c object where the Validation Id is:
		As this Id is always there which is matching the FR087 condition
	*/ 
	public String query = 'Select r.Validation_Rule_Id__c, r.Unit_Number__c, r.Status_Date__c, '
							+'r.Rule_Description__c, r.Name, r.Id, r.Unit_Number__r.Account__c, r.Unit_Number__r.Account__r.OwnerId '
							+'From RSM_VehicleValidationDetails__c r where Validation_Rule_Id__c = \'40\'';
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		/* 
			Return the Query Data
		*/ 
		return Database.getQueryLocator(query);
	}
	global void execute(Database.BatchableContext BC, List<RSM_VehicleValidationDetails__c> lVehicleValidate)
	{
		Set<String> sVehicleIds = new Set<String>();
		/* 
			Iterate the Query data and create a set of Vehicle IDs
		*/
		for(RSM_VehicleValidationDetails__c VehicleValidate : lVehicleValidate)
		{   
			sVehicleIds.add(VehicleValidate.Unit_Number__c);
		}
		List<Messaging.SingleEmailMessage> lSingleEmail = new List<Messaging.SingleEmailMessage>();
		String sMsg = '';
		String sHost = URL.getSalesforceBaseUrl().toExternalForm();
		System.debug('------------------sVehicleIds-->'+sVehicleIds);
		if(sVehicleIds.size() > 0)
		{
			/*
				Create a HTML to send to Billing
			*/
			sMsg = '<html>';
			sMsg += '<style>';
		    sMsg += 'table.t01 {';
		    sMsg += 'width:100%;';
		    sMsg += '}';
		    sMsg += 'table.t01, table.t01 th, table.t01 td {';
		    sMsg += 'border: 1px solid black;';
		    sMsg += 'border-collapse: collapse;';
		    sMsg += '}';
		    sMsg += 'table.t01 th, table.t01 td {';
		    sMsg += 'padding: 5px;';
		    sMsg += 'text-align: center;';
		    sMsg += '}';
		    sMsg += 'table.t01 tr:nth-child(even) {';
		    sMsg += 'background-color: #eee;';
		    sMsg += '}';
		    sMsg += 'table.t01 tr:nth-child(odd) {';
		    sMsg += 'background-color:#fff;';
		    sMsg += '}';
		    sMsg += 'table.t01 th    {';
		    sMsg += 'background-color: #08088A;';
		    sMsg += 'color: white;';
		    sMsg += '}';
		    sMsg += '</style>';
			sMsg += '<form>';
			sMsg += '<body>';
			sMsg += '<p>';
			sMsg += 'RS Units reporting and last FSL billed date > 60 calendar days?';
			sMsg += '</p>';
		    sMsg += '<table border="1" class="t01">';
		    sMsg += '<tr>';
		    sMsg += '<th><b>Unit Number</b></th>';
		    sMsg += '<th><b>Account Name</b></th>';
		    sMsg += '</tr>';
			/* 
				Iterate all vehicle and add those in the Table Row
			*/
			String sBillingEmailAddress = RyderGlobalVariables.RyderSmart_Billing;
			for(Vehicle__c Vehicle : [Select v.Unit__c, v.Id, v.Account__r.Name, 
										v.Account__c, v.Account__r.Id  
										From Vehicle__c v where Id in : sVehicleIds])
			{
		    	sMsg += '<tr>';
			    sMsg += '<td><a href="' + sHost +'/' + Vehicle.Id + '" target="_Blank">'+ Vehicle.Unit__c +'</a>';
			    sMsg += '</td>';
			    sMsg += '<td><a href="' + sHost +'/' + Vehicle.Account__r.Id + '" target="_Blank">'+ Vehicle.Account__r.Name +'</a>';
			    sMsg += '</td>';
			    sMsg += '</tr>';
			}
			sMsg += '</table>';
			sMsg += '</body>';
			sMsg += '</html>';
			/* 
				Add the paramters in Email object
			*/
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setHtmlBody(sMsg);
            mail.setToAddresses(new List<String>{sBillingEmailAddress});
            mail.setSubject('Daily Email to Billing');
            lSingleEmail.add(mail);
            System.debug('------------------sMsg-->'+sMsg);
		}
		/* 
			If the Email object contains any record then send the email
		*/
		System.debug('------------------lSingleEmail-->'+lSingleEmail);
		if(lSingleEmail.size() > 0)
			Messaging.sendEmail(lSingleEmail);
	}
	global void finish(Database.BatchableContext BC){
   }   
}