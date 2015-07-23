public with sharing class RSM_NonLeaseContract_Controller
{
	public RSM_Contract__c RSM_Contract {get; set;}
	public String StatusName {get; set;}
	public String DocumentTypeName {get; set;}
	public String CreatedBy {get; set;}
	public Boolean bShowAll {get; set;}
	public List<InnerClass> InnerClassObj {get; set;}
	
	Map<String, String> StatusId = new Map<String, String>();
	Map<String, String> DocumentTypeId = new Map<String, String>();
	Map<String, String> ServiceId = new Map<String, String>();
	Map<String, String> ActionId = new Map<String, String>();
	Account Acc = null;
	Set<String> sVehicleRecordTypeId = new Set<String>();
	public String sAccId {get; set;}
 	public RSM_NonLeaseContract_Controller()
	{
		// Assign default values
		if(ApexPages.CurrentPage().getParameters().get('acid') != null)
			sAccId = String.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().get('acid').replaceFirst('/',''));
		RSM_Contract = new RSM_Contract__c(Contract_Number__c = GenerateRandomNumber(6), 
											Status_Date__c = System.now(), 
											CreatedDate__c = System.now(), 
											Effective_Date__c = System.now(), 
											CreatedBy__c = UserInfo.getName());
		RSM_Contract.Name = RSM_Contract.Contract_Number__c + '';
		InnerClassObj = new List<InnerClass>();
		Init();
		AddRows();
		QueryRecordType();
		if(sAccId != null && sAccId != '' && sAccId.startsWith('001'))
		{
			RSM_Contract.Account__c = sAccId;
			QueryVehicleData();
		}
	}
	public PageReference Cancel()
	{
		if(sAccId != null && sAccId != '' && sAccId.startsWith('001'))
		{
			PageReference PageObj = new PageReference('/' + sAccId);			
			PageObj.setRedirect(true);
			return PageObj;
		}
		return null;
	}
	public void Init()
	{
		StatusName = 'Approved';
		DocumentTypeName = 'RPM';
		bShowAll = true;
		DocumentTypeName = '';
		// Put default values in maps
		StatusId.put('Approved','1');
		StatusId.put('Deleted','2');
		StatusId.put('Draft','3');
		StatusId.put('Printed','4');
		StatusId.put('Rejected by SSC','5');
		StatusId.put('Submitted to SSC','7');
		
		DocumentTypeId.put('NRV','340');
		DocumentTypeId.put('Rental','350');
		system.debug('------>'+StatusId);
		
		// Put default values in maps
		ServiceId.put('STD','1');
		ServiceId.put('Plus','2');
		ServiceId.put('Plus 1','3');		
		ActionId.put('Add','1');
		ActionId.put('Edit','2');
		ActionId.put('Cancel','3');
		
	}
	public void QueryRecordType()
	{
		// Set the Vehicle Record Type Ids
		Global_Settings__c VehicleRydeSmartRecordType = Global_Settings__c.getValues('7');
		// if the custom settings is not null then get the value from settings and out in a local variable
		if(VehicleRydeSmartRecordType != null && VehicleRydeSmartRecordType.IsActive__c)
			sVehicleRecordTypeId.add(VehicleRydeSmartRecordType.Value__c);
		VehicleRydeSmartRecordType = Global_Settings__c.getValues('8');
		// if the custom settings is not null then get the value from settings and out in a local variable
		if(VehicleRydeSmartRecordType != null && VehicleRydeSmartRecordType.IsActive__c)
			sVehicleRecordTypeId.add(VehicleRydeSmartRecordType.Value__c);
		
	}
	public void AddRows()
	{
		if(InnerClassObj.size() > 600)
		{
			apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Adding rows limit exceeding!');
			apexpages.addmessage(msg);
		}
		else
		{
			List<SelectOption> options = Vehicles();
			for(Integer i = 1; i <= 5; i++)
			{
				InnerClass Obj = new InnerClass();
				RSM_ContractDetail__c ContractDetailObj = new RSM_ContractDetail__c(EffectiveDate__c = System.now());
				Obj.RSM_ContractDetail = ContractDetailObj;
				Obj.ActionNames = ActionNames();
				Obj.ServiceNames = ServiceName();
				Obj.ActionName = 'Add';
				Obj.ServiceName = 'STD';
				Obj.RowNo = String.ValueOf(InnerClassObj.size());
				Obj.Vehicles = options;
				InnerClassObj.add(Obj);
			}
		}
	}
	public PageReference SaveData()
	{
		Set<String> sUniqueVehicles = new Set<String>();
		List<RSM_ContractDetail__c> lContractDetail = new List<RSM_ContractDetail__c>();
		List<InnerClass> lInnerClass = new List<InnerClass>();
		for(InnerClass Obj : InnerClassObj)
		{
			if(Obj.RSM_ContractDetail != null && Obj.Vehicle != '--None--')
			{
				Obj.RSM_ContractDetail.Unit_Number__c = Obj.Vehicle;
				if(Obj.RSM_ContractDetail.Rate__c == null)
				{
					apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'Rate is a required field if Unit Number is selected!');
					apexpages.addmessage(msg);
					return null;
				}
				else if(Obj.RSM_ContractDetail.EffectiveDate__c == null)
				{
					apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'Effective Date is a required field if Unit Number is selected!');
					apexpages.addmessage(msg);
					return null;
				}
				else
				{
					lInnerClass.add(Obj);
					sUniqueVehicles.add(Obj.Vehicle);
				}
			}				
		}
		if(lInnerClass.size() == 0)
		{
			apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'Please add at-least one Contract Details!');
			apexpages.addmessage(msg);
			return null;
		}
		if(sUniqueVehicles.size() != lInnerClass.size())
		{
			apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'Duplicate Vehicles have been selected!');
			apexpages.addmessage(msg);
			return null;
		}
		System.debug('----->'+RSM_Contract);
		Savepoint sp1 = Database.setSavepoint();
		try
		{
			List<Vehicle__c> lVehicle = new List<Vehicle__c>();
			if(RSM_Contract.Account__c != null && Acc == null)
				Acc = [select LesseeNo__c, Id from Account where Id =: RSM_Contract.Account__c];
			RSM_Contract.DocumentTypeID__c = Decimal.valueOf(DocumentTypeId.get(DocumentTypeName));
			RSM_Contract.Document_Type_Name__c = DocumentTypeName;
			RSM_Contract.Status__c = Decimal.valueOf(StatusId.get(StatusName));
			RSM_Contract.Status_Name__c = StatusName;
			RSM_Contract.Lessee__c = Acc.LesseeNo__c;
			if(RSM_Contract.id == null)
				insert RSM_Contract;
			else
				update RSM_Contract;
			Integer iNumber = GenerateRandomNumber(8);
			for(InnerClass Obj : lInnerClass)
			{
				System.debug('----Obj.ActionName->'+Obj.ActionName);
				System.debug('----ActionId->'+ActionId);
				System.debug('----Obj.ServiceName->'+Obj.ServiceName);
				System.debug('----ServiceId->'+ServiceId);
				System.debug('----ServiceId.get(Obj.ServiceName)->'+ServiceId.get(Obj.ServiceName));
				System.debug('----ActionId.get(Obj.ActionName)->'+ActionId.get(Obj.ActionName));
				Obj.RSM_ContractDetail.Name = iNumber + '';
				Obj.RSM_ContractDetail.Contract_Detail_ID__c = iNumber;
				Obj.RSM_ContractDetail.Action_ID__c = Decimal.valueOf(ActionId.get(Obj.ActionName));
				Obj.RSM_ContractDetail.Action_Name__c = Obj.ActionName;
				Obj.RSM_ContractDetail.Service_ID__c = Decimal.valueOf(ServiceId.get(Obj.ServiceName));
				Obj.RSM_ContractDetail.Service_Name__c = Obj.ServiceName;
				Obj.RSM_ContractDetail.Contract_Number__c = RSM_Contract.Id;
				lContractDetail.add(Obj.RSM_ContractDetail);
				iNumber++;
			}
			if(lContractDetail.size() > 0)
			{
				insert lContractDetail;
				bShowAll = false;
				for(RSM_ContractDetail__c ContractDetailObj : lContractDetail)
		        {
			        if(ContractDetailObj.Is_Current__c)
			        {
				        Vehicle__c Vehicle = new Vehicle__c(Id=ContractDetailObj.Unit_Number__c);
				        Vehicle.RSM_Customer__c = true;
				        Vehicle.RSM_Service_Level__c = ContractDetailObj.Service_Name__c;
				        Vehicle.RSM__c = RSM_Contract.Status_Name__c;
		                lVehicle.add(Vehicle);
			        }
		        }
		        if(lVehicle.size() > 0)
		        	update lVehicle;
		        // Execute the Batches as we need to show the real time data chage
				RSMServiceLevelChangeStatus RSMServiceLevelChangeClass = new RSMServiceLevelChangeStatus(); 
				RSMServiceLevelChangeClass.query='select r.Unit_Number__r.RSM__c, r.Action_Name__c, '
												+'r.Unit_Number__r.RSM_Add_Service_current_count__c, '
												+'r.Unit_Number__r.RSM_Addition_Service_prior_count__c, '
												+'r.Unit_Number__r.RSM_Service_Level__c, '
												+'r.Unit_Number__r.RSM_Service_Level_Prior_value__c, '
												+'r.Contract_Number__r.Account__c, r.Unit_Number__c, '
												+'r.Unit_Number__r.Account__c from RSM_ContractDetail__c r '
												+'where Contract_Number__c = \'' + RSM_Contract.Id + '\' and r.Is_Current__c = true';							
				database.executebatch(RSMServiceLevelChangeClass,500);
			}
		}
		catch(Exception Ex)
		{
			System.debug('----->'+Ex.getMessage());
			Database.rollback(sp1);
			return null;			
		}
		System.debug('----->'+RSM_Contract);
		apexpages.Message msg = 
			new Apexpages.Message(ApexPages.Severity.Info,'Data is Saved successfully! <a href="/' + RSM_Contract.Id + '" target="_Blank"><font size="2" color="red">'+ RSM_Contract.Contract_Number__c +'</font></a>');
		apexpages.addmessage(msg);
		return null;
	}
	public void QueryVehicleData()
	{
		List<SelectOption> options = Vehicles();
		System.debug('-------options->'+options);
		for(InnerClass Obj : InnerClassObj)
		{
			Obj.Vehicles = options;
		}
	}
	public Integer GenerateRandomNumber(Integer iLen)
	{
		String chars = '0123456789';
	    String randStr = '';
	    if(iLen == 6)
	    {
		    List<RSM_Contract__c> lRSM_Contract = [select Contract_Number__c from 
		    										RSM_Contract__c order by 
		    										Contract_Number__c Desc limit 1];
	    	if(lRSM_Contract != null && lRSM_Contract.size() > 0 && 
	    		lRSM_Contract[0].Contract_Number__c > 700000 && 
	    		String.ValueOf(lRSM_Contract[0].Contract_Number__c).length() == 6)
	    	{
	    		randStr = String.ValueOf(lRSM_Contract[0].Contract_Number__c + 1);
	    	}
	    	if(randStr == '')
	    	{
	    		randStr = '700001';
	    	}
	    }
	    else if(iLen == 8)
	    {
	    	List<RSM_ContractDetail__c> lRSM_ContractDetail = [select Contract_Detail_ID__c 
	    														from RSM_ContractDetail__c 
	    														order by Contract_Detail_ID__c 
	    														Desc limit 1];
	    	if(lRSM_ContractDetail != null && lRSM_ContractDetail.size() > 0 && 
				lRSM_ContractDetail[0].Contract_Detail_ID__c > 700000 && 
				String.ValueOf(lRSM_ContractDetail[0].Contract_Detail_ID__c).length() == 8)
	    	{
	    		randStr = String.ValueOf(lRSM_ContractDetail[0].Contract_Detail_ID__c + 1);
	    	}
	    	if(randStr == '')
	    	{
	    		randStr = '70000001';
	    	}
	    }
	    return Integer.valueOf(randStr); 
	}
	public void DeleteRow()
	{
		String sRow = ApexPages.currentPage().getParameters().get('rowno');
		InnerClassObj.remove(Integer.valueOf(sRow));
		List<InnerClass> InnerClassTemp = InnerClassObj;
		InnerClassObj = new List<InnerClass>();
		for(InnerClass Obj : InnerClassTemp)
		{
			Obj.RowNo = String.ValueOf(InnerClassObj.size());
			InnerClassObj.add(Obj);
		} 
	}
	public PageReference ResetData()
	{
		String sParam = ApexPages.currentPage().getParameters().get('sfdc.tabName');
		PageReference PageObj = new PageReference('/apex/RSM_AutoRegContractDetails');
		if(sParam != null && sParam.trim().length() > 0)
			PageObj.getParameters().put('sfdc.tabName',sParam);
		PageObj.setRedirect(true);
		return PageObj;
	}
	public List<SelectOption> ServiceName()
	{
 	 	List<SelectOption> options = new List<SelectOption>();
 	 	options.add(new SelectOption('STD','STD'));
 	 	options.add(new SelectOption('Plus','Plus'));
 	 	options.add(new SelectOption('Plus 1','Plus 1'));
 	 	return options;
  	}
	public List<SelectOption> ActionNames()
	{
 	 	List<SelectOption> options = new List<SelectOption>();
 	 	options.add(new SelectOption('Add','Add'));
 	 	options.add(new SelectOption('Edit','Edit'));
 	 	options.add(new SelectOption('Cancel','Cancel'));
 	 	return options;
  	}
  	
	public List<SelectOption> getStatusNames()
	{
 	 	List<SelectOption> options = new List<SelectOption>();
 	 	options.add(new SelectOption('Approved','Approved'));
 	 	options.add(new SelectOption('Deleted','Deleted'));
 	 	options.add(new SelectOption('Draft','Draft'));
 	 	options.add(new SelectOption('Printed','Printed'));
 	 	options.add(new SelectOption('Rejected by SSC','Rejected by SSC'));
 	 	options.add(new SelectOption('Submitted to SSC','Submitted to SSC'));
 	 	return options;
  	}
  	public List<SelectOption> Vehicles()
	{
		List<SelectOption> options = new List<SelectOption>();
 	 	System.debug('-------->'+RSM_Contract.Account__c);
 	 	options.add(new SelectOption('--None--','--None--'));
 	 	if(RSM_Contract.Account__c != null)
 	 	{
 	 		List<Vehicle__c> lVehicle = [Select v.Unit__c, v.Id, v.Account__c 
 	 									From Vehicle__c v where 
 	 									Account__c =: RSM_Contract.Account__c and 
 	 									RecordTypeId in: sVehicleRecordTypeId 
 	 									order by Unit__c limit 999];
 	 		for(Vehicle__c Vehicle : lVehicle)
 	 		{
 	 			options.add(new SelectOption(Vehicle.Id,Vehicle.Unit__c));
 	 		}
 	 	}
 	 	System.debug('--------options>'+options);
 	 	return options;
  	}
  	public List<SelectOption> getDocumentTypeNames()
	{
 	 	List<SelectOption> options = new List<SelectOption>();
 	 	options.add(new SelectOption('NRV','NRV'));
 	 	options.add(new SelectOption('Rental','Rental'));
 	 	return options;
  	}
  	public Class InnerClass
  	{
  		public RSM_ContractDetail__c RSM_ContractDetail {get; set;}
  		public String RowNo {get; set;}
  		public String ServiceName {get; set;}
		public String ActionName {get; set;}		
		public String Vehicle {get; set;}
		public List<SelectOption> ServiceNames {get; set;}
		public List<SelectOption> ActionNames {get; set;}
		public List<SelectOption> Vehicles {get; set;}
  	}
}