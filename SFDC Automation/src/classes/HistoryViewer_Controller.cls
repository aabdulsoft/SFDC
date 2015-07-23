public with sharing class HistoryViewer_Controller
{
	public String VehicleName {get; set;}
	public String ObjectName {get; set;}
	public String FieldName {get; set;}
	public Account Acc {get; set;}
	// Below AccDate object of Account is being used as a place holder to display date fields on VF page
	public Account AccDate {get; set;}
	public List<Vehicle__c> lVehicle;
	public Boolean bShowVehicles {get; set;}
	public String Action {get; set;}
	public List<InnerClass> InnerClassObj {get; set;}
	
	Map<String, String> mVehicleInfo = new Map<String, String>();
	Map<String, String> mVehicleObject = new Map<String, String>();
	String sAccID;
	Map<String, String> mFields = new Map<String, String>();
	Map<String, String> mFieldToUse = new Map<String, String>();
	Map<String, String> mFieldType = new Map<String, String>();
	Map<String, String> mObjectMapping = new Map<String, String>();
	String retURL;
	public HistoryViewer_Controller(ApexPages.StandardController Control)
	{
		InnerClassObj = new List<InnerClass>();
		sAccID = Control.getId();
		// Below AccDate object of Account is being used as a place holder to display date fields on VF page
		// dates are default populdated as end date today and start date as  3 months back
		AccDate = new Account(addr_verified_date__c = system.today().addDays(-90), BAD_ADDR_DATE__c = system.today());
		Init();		
	}
	public void Init()
	{
		VehicleName = '';
		Acc = [Select Id, Name, CustProspectID__c  from Account where Id =: sAccID];
		lVehicle = [select Id, Unit__c from Vehicle__c 
					where Account__c =: sAccID 
					order by Unit__c Desc];
		ObjectName = 'None';
		bShowVehicles = true;
		
		mVehicleObject.put('Vehicle__c', 'Vehicle__History');
		mVehicleObject.put('RSM_Contract__c', 'RSM_Contract__History');
		mVehicleObject.put('Account', 'AccountHistory');
		mVehicleObject.put('RSM_PO__c', 'RSM_PO__History');
		mVehicleObject.put('RSM_Component__c', 'RSM_Component__History');
		
		mObjectMapping.put('a0W', 'Vehicle__c');
		mObjectMapping.put('a1R', 'RSM_Contract__c');
		mObjectMapping.put('001', 'Account');
		mObjectMapping.put('a1S', 'RSM_PO__c');
		mObjectMapping.put('a1O', 'RSM_Component__c');
		if(ApexPages.currentPage().getParameters().get('extid') != null)
		{
			retURL = (ID)ApexPages.currentPage().getParameters().get('extid');
			if(mObjectMapping.get(retURL.subString(0,3)) != null)
			{
				System.debug('-----------1->'+retURL.subString(0,3));
				System.debug('-----------2->'+mObjectMapping.get(retURL.subString(0,3)));
				ObjectName = mObjectMapping.get(retURL.subString(0,3));
				System.debug('-----------3->'+(ID)ApexPages.currentPage().getParameters().get('vn'));
				if(ApexPages.currentPage().getParameters().get('vn') != null)
					VehicleName = (Id)ApexPages.currentPage().getParameters().get('vn');				
				bShowVehicles = false;
				System.debug('-----------4->'+ObjectName);
				System.debug('-----------5->'+VehicleName);
			}
		}
	}
	public PageReference ReturnBack()
	{
		PageReference PageObj = null;
		if(retURL != null)
			PageObj = new PageReference('/'+retURL);
		else
			PageObj = new PageReference('/'+sAccId);
		PageObj.setRedirect(true);
		return PageObj;
	}
	public PageReference SearchHistory()
	{
		System.debug('-----------5->'+VehicleName);
		InnerClassObj = new List<InnerClass>();
		// Show error on Page if the user didn't selected Object and Field
		// Basic validations
		if(ObjectName == 'None' || FieldName == 'None')
		{
			apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please fill all required columns!');
			apexpages.addmessage(msg);
			return null;
		}
		if(ObjectName != 'None' && ObjectName != 'Account' && VehicleName == 'None' && getVehicleNames().size() > 1)
		{
			apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please select vehicle Name!');
			apexpages.addmessage(msg);
			return null;
		}
		if(ObjectName != 'None' && ObjectName == 'Vehicle__c' && VehicleName == 'None' && getVehicleNames().size() == 1)
		{
			apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'There are no Vehicle in this Account!');
			apexpages.addmessage(msg);
			return null;
		}
		
		if(ObjectName != 'None' && ObjectName != 'Account' && ObjectName != 'Vehicle__c' && VehicleName == 'All' && getVehicleNames().size() > 1)
		{
			apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please select a Vehicle Number!');
			apexpages.addmessage(msg);
			return null;
		}
		
		// Below Account Date fields are used as place holder on the VF page to take user input. Based on these dates history is queried
		if(AccDate.addr_verified_date__c == null || AccDate.BAD_ADDR_DATE__c == null)
		{
			apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Start Date and End Date are required!');
			apexpages.addmessage(msg);
			return null;
		}
		// If no errors then based on User selection process the request
		if(ObjectName != 'None' && ObjectName == 'Account' )
		{
			Set<Id> sAccIds = new Set<Id>();
			sAccIds.add(sAccId);
			QueryHistoryData(sAccIds);
		}
		else if(ObjectName != 'None' && ObjectName == 'Vehicle__c')
		{
			Set<Id> sVehicleIds = new Set<Id>();
			if(VehicleName == 'All')
			{
				for(String sVehicleName : mVehicleInfo.keySet())
					sVehicleIds.add(sVehicleName);
			}
			else
				sVehicleIds.add(VehicleName);
			QueryHistoryData(sVehicleIds);
		}		
		else if(ObjectName != 'None' && ObjectName == 'RSM_Contract__c')
		{
			Set<Id> sContractIds = new Set<Id>();
			List<RSM_ContractDetail__c> lRSM_ContractDetail = [Select r.Unit_Number__c, r.Id, 
																r.Contract_Number__c From RSM_ContractDetail__c r 
																where Unit_Number__c = : VehicleName 
																and Contract_Number__r.Account__c = : sAccID];
			for(RSM_ContractDetail__c ObjContractD : lRSM_ContractDetail)
			{
				sContractIds.add(ObjContractD.Contract_Number__c);
			}
			if(sContractIds.size() > 0)
			{
				QueryHistoryData(sContractIds);
			}
		}
		else if(ObjectName != 'None' && ObjectName == 'RSM_Component__c')
		{
			Set<Id> sComponentIds = new Set<Id>();
			List<RSM_Component__c> lRSM_Component = [Select r.Unit_Number__c, r.Id, r.Account_Number__c From RSM_Component__c r 
										where Unit_Number__c = : VehicleName];
			for(RSM_Component__c ObjComponent : lRSM_Component)
			{
				sComponentIds.add(ObjComponent.Id);
			}
			if(sComponentIds.size() > 0)
			{
				QueryHistoryData(sComponentIds);
			}
		}
		else if(ObjectName != 'None' && ObjectName == 'RSM_PO__c')
		{
			Set<Id> sPOIds = new Set<Id>();
			List<RSM_PO__c> lRSM_PO = [Select r.Unit_Number__c, r.Id From RSM_PO__c r 
										where Unit_Number__c = : VehicleName and Account__c = : sAccID];
			for(RSM_PO__c ObjPO : lRSM_PO)
			{
				sPOIds.add(ObjPO.Id);
			}
			if(sPOIds.size() > 0)
			{
				QueryHistoryData(sPOIds);
			}
		}		
		if(Action != null && Action.trim().length() > 0)
		{
			FilterData();
		}
		if(InnerClassObj.size() == 0)
		{
			apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'No History Record found!');
			apexpages.addmessage(msg);
		}
		return null;
	}
	// Quering the History Object
	public void QueryHistoryData(Set<Id> sParentIds)
	{
		// Query String
		String sQuery = 'Select a.OldValue, a.NewValue, a.Id, '
								+ 'a.Field, a.CreatedDate, a.CreatedById, ';
		if(ObjectName == 'Account')
			sQuery += 'a.AccountId ';
		else
			sQuery += 'a.ParentId ';
		sQuery += 'From ' + mVehicleObject.get(ObjectName) + ' a where Field =: FieldName ';
		
		// Below Account Date fields are used as place holder on the VF page to take user input. Based on these dates history is queried
		// Convert Date in date time and in query format
		Date dt = AccDate.addr_verified_date__c;
		DateTime dateStr = DateTime.newInstance(dt.year(),dt.month(),dt.day(),0,0,0);
		Date dt1 = AccDate.BAD_ADDR_DATE__c.addDays(1);
		DateTime dateStr1 = DateTime.newInstance(dt1.year(),dt1.month(),dt1.day(),0,0,0);
		sQuery += 'AND CreatedDate >=' + dateStr.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
		sQuery += ' AND CreatedDate <=' + dateStr1.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');		
		if(ObjectName == 'Account')
			sQuery += ' AND AccountId in : sParentIds order by CreatedDate desc';
		else
			sQuery += ' AND ParentId in : sParentIds order by Parent.Name desc, CreatedDate desc';
		//sQuery += ' limit 500';
		system.debug('-------------FieldName---->'+FieldName);
		system.debug('----------------->'+sQuery);
		// Query the data
		List<sObject> lHistory = database.query(sQuery);
		system.debug('----------------->'+lHistory);
		
		// Collect all the Users Id which came in History records
		Set<Id> sUserIds = new Set<Id>();
		Set<Id> setParentIds = new Set<Id>();
		for(sObject Obj : lHistory)
		{
			sUserIds.add(String.valueOf(Obj.get('CreatedById')));
			if(ObjectName != 'Account' && ObjectName != 'Vehicle__c')
				setParentIds.add(String.valueOf(Obj.get('ParentId')));
		}
		
		// Query the Name of the Users
		Map<Id, RSM_Contract__c> mContract = new Map<Id, RSM_Contract__c>();
		Map<Id, RSM_Component__c> mComponent = new Map<Id, RSM_Component__c>();
		Map<Id, RSM_PO__c> mPO = new Map<Id, RSM_PO__c>();
		
		Map<Id, User> mUser = null;
		if(sUserIds.size() > 0)
			mUser = new Map<Id, User>([select Id, Name from User where Id in : sUserIds]);
		if(setParentIds.size() > 0)
		{
			if(ObjectName == 'RSM_Contract__c')
			{
				mContract = new Map<Id, RSM_Contract__c>([select Id, Name from RSM_Contract__c where Id in: setParentIds]);
			}
			else if(ObjectName == 'RSM_Component__c')
			{
				mComponent = new Map<Id, RSM_Component__c>([select Id, Name from RSM_Component__c where Id in: setParentIds]);
			}
			else if(ObjectName == 'RSM_PO__c')
			{
				mPO = new Map<Id, RSM_PO__c>([select Id, Name from RSM_PO__c where Id in: setParentIds]);
			}
		}
		system.debug('---------mContract-------->'+mContract);
		system.debug('---------mComponent-------->'+mComponent);
		system.debug('---------mPO-------->'+mPO);
		// Bind the History records with the Class properties
		for(sObject Obj : lHistory)
		{
			InnerClass InnerClassO = new InnerClass();
			InnerClassO.sDate = DateTime.valueOf(Obj.get('CreatedDate')).format();
			if(mUser.get(String.valueOf(Obj.get('CreatedById'))) != null)
				InnerClassO.sUser = mUser.get(String.valueOf(Obj.get('CreatedById'))).Name;
			String sFieldType = '';
			if(mFieldType.get(String.valueOf(Obj.get('Field'))) != null)
			{
				sFieldType = mFieldType.get(String.valueOf(Obj.get('Field')));
			}
			//REFERENCE
			system.debug('---------sFieldType-------->'+sFieldType);
			if(sFieldType.toUpperCase() == 'DATE')
			{
				if(Obj.get('OldValue') != null)
					InnerClassO.sOldValue = String.valueOf(Date.valueOf(Obj.get('OldValue')).format());
				if(Obj.get('NewValue') != null)
					InnerClassO.sNewValue = String.valueOf(Date.valueOf(Obj.get('NewValue')).format());
			}			
			else if(sFieldType.toUpperCase() == 'DATETIME')
			{
				if(Obj.get('OldValue') != null)
					InnerClassO.sOldValue = String.valueOf(DateTime.valueOf(Obj.get('OldValue')).format());
				if(Obj.get('NewValue') != null)
					InnerClassO.sNewValue = String.valueOf(DateTime.valueOf(Obj.get('NewValue')).format());
			}			
			else
			{
				InnerClassO.sOldValue = String.valueOf(Obj.get('OldValue'));
				InnerClassO.sNewValue = String.valueOf(Obj.get('NewValue'));
			}
			if(InnerClassO.sOldValue == null)
			{
				InnerClassO.sAction = 'Changed <b>' + mFieldToUse.get(String.valueOf(Obj.get('Field'))) + ' to <b>' + InnerClassO.sNewValue + '</b>';
			}
			else if(InnerClassO.sNewValue == null)
			{
				InnerClassO.sAction = 'Deleted '+ InnerClassO.sOldValue + ' in <b>' + mFieldToUse.get(String.valueOf(Obj.get('Field'))) + '</b>';
			}
			else
			{
				InnerClassO.sAction = 'Changed <b>' + mFieldToUse.get(String.valueOf(Obj.get('Field'))) + '</b> from ' 
									+ InnerClassO.sOldValue + ' to <b>' + InnerClassO.sNewValue + '</b>';
			}
			if(ObjectName == 'Vehicle__c')
			{
				InnerClassO.sVehicle = mVehicleInfo.get(String.valueOf(Obj.get('ParentId')));
				InnerClassO.sVehicleId = String.valueOf(Obj.get('ParentId'));
			}
			else if(ObjectName == 'Account')
			{
				InnerClassO.sVehicle = Acc.Name;
				InnerClassO.sVehicleId = Acc.Id;
			}
			else
			{
				system.debug('---------ObjectName--283------>'+ObjectName);
				system.debug('---------Obj.get(ParentId)--284------>'+Obj.get('ParentId'));
				if(ObjectName == 'RSM_Contract__c')
				{
					InnerClassO.sVehicle = mContract.get(String.valueOf(Obj.get('ParentId'))).Name;
					InnerClassO.sVehicleId = String.valueOf(Obj.get('ParentId'));
				}
				else if(ObjectName == 'RSM_Component__c')
				{
					InnerClassO.sVehicle = mComponent.get(String.valueOf(Obj.get('ParentId'))).Name;
					InnerClassO.sVehicleId = String.valueOf(Obj.get('ParentId'));
				}
				else if(ObjectName == 'RSM_PO__c')
				{
					InnerClassO.sVehicle = mPO.get(String.valueOf(Obj.get('ParentId'))).Name;
					InnerClassO.sVehicleId = String.valueOf(Obj.get('ParentId'));
				}
			}
			Boolean bAdd = true;
			if(sFieldType.toUpperCase() == 'REFERENCE')
			{
				if(InnerClassO.sOldValue != null)
				{
					if(!InnerClassO.sOldValue.contains(' ') && InnerClassO.sOldValue.length() == 18)
						bAdd = false;
				}
				else if(InnerClassO.sNewValue != null)
				{
					if(!InnerClassO.sNewValue.contains(' ') && InnerClassO.sNewValue.length() == 18)
						bAdd = false;
				}				
			}
			if(bAdd)
			{
				InnerClassObj.add(InnerClassO);
			}
		}
	}
	// If the Action text box is populated then below method filter the queried data based on searched Action
	public void FilterData()
	{
		if(InnerClassObj.size() > 0)
		{
			Action = Action.trim();
			List<InnerClass> ObjTemp = InnerClassObj;
			InnerClassObj = new List<InnerClass>();
			for(InnerClass Obj : ObjTemp)
			{
				if(Obj.sOldValue != null && Obj.sOldValue.toUpperCase().contains(Action.toUpperCase()))
					InnerClassObj.add(Obj);
				else if(Obj.sNewValue != null && Obj.sNewValue.toUpperCase().contains(Action.toUpperCase()))
					InnerClassObj.add(Obj);
			}
		}
	}
	// Method called from Page when user changes / select the Object Name
	public void ObjectSelected()
	{
		bShowVehicles = true;
		if(ObjectName != 'None' && ObjectName != 'Account')
		{
			bShowVehicles = false;
		}
	}
	// Property to show all the Object Names in a drop down on Page
	public List<SelectOption> getObjectNames()
	{
 	 	List<SelectOption> options = new List<SelectOption>();
 	 	options.add(new SelectOption('None','--None--'));
 	 	options.add(new SelectOption('Account','Account'));
 	 	options.add(new SelectOption('Vehicle__c','Vehicle'));
 	 	options.add(new SelectOption('RSM_Component__c','Vehicle Component'));
 	 	options.add(new SelectOption('RSM_Contract__c','Vehicle Contract'));
 	 	options.add(new SelectOption('RSM_PO__c','Vehicle PO'));
 	 	
 	 	return options;
  	}
  	// Property to show all the History Ttracking fields on Page
  	public List<SelectOption> getFieldNames()
	{
		FetchFieldSet(ObjectName);
		system.debug('----------------->'+mFields);
		Set<String> sFields = mFields.keySet();
 	 	List<String> lFields = new List<String>();
 	 	lFields.addAll(sFields);
 	 	lFields.sort();
 	 	system.debug('--------------lFields--->'+lFields);
 	 	List<SelectOption> options = new List<SelectOption>();
 	 	options.add(new SelectOption('None','--None--'));
 	 	for(String sField : lFields)
 	 	{
 	 		options.add(new SelectOption(mFields.get(sField), sField));
 	 	}
 	 	return options;
  	}
  	// Proprty to show all Vehicles in selected Account 
	public List<SelectOption> getVehicleNames()
	{
 	 	List<SelectOption> options = new List<SelectOption>();
 	 	if(ObjectName == 'Vehicle__c')
 	 		options.add(new SelectOption('All','--All--'));
 	 	else
 	 		options.add(new SelectOption('None','--Select One--'));
 	 	for(Vehicle__c Obj : lVehicle)
 	 	{
 	 		options.add(new SelectOption(Obj.Id,Obj.Unit__c));
 	 		mVehicleInfo.put(Obj.Id,Obj.Unit__c);
 	 	}
 	 	return options;
  	}
  	// Property to call Global Description
  	private Map<String, Schema.SObjectType> schemaMap{
        get{
            if(schemaMap == null){
                schemaMap = Schema.getGlobalDescribe();
            }
            return schemaMap;
        }private set{}
    }
    // Method to fetch Field Set information from Meta data
  	public void FetchFieldSet(String sObjectName)
  	{
  		mFields = new Map<String, String>();
  		if(sObjectName != 'None')
  		{
	  		Schema.DescribeSObjectResult d = schemaMap.get(sObjectName).getDescribe();
	  		Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
	  		List<Schema.FieldSetMember> trackedFields = null;
	  		if(FsMap != null && FsMap.get('HistoryTracking') != null)
				trackedFields = FsMap.get('HistoryTracking').getFields();
			for(Schema.FieldSetMember fsm : trackedFields)
			{
				String fieldName  = fsm.getFieldPath();
				String fieldLabel = fsm.getLabel();
				if(sObjectName == 'Account')
				{
					if(fieldName == 'OwnerId')
						fieldName = 'Owner';
					else if(fieldName == 'Name')
						fieldName = 'TextName';
				}
				mFields.put(fieldLabel, fieldName);
				mFieldToUse.put(fieldName, fieldLabel);
				mFieldType.put(fieldName, String.valueOf(fsm.getType()));
			}
  		}
  	}
  	// Inner Class to show information on Page
  	public class InnerClass
  	{
  		public String sVehicle {get; set;}
  		public String sVehicleId {get; set;}
  		public String sDate {get; set;}
		public String sUser {get; set;}
		public String sOldValue {get; set;}
		public String sNewValue {get; set;}
		public String sAction {get; set;}
  	}
}