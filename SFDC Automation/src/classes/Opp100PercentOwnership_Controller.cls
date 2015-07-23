public with sharing class Opp100PercentOwnership_Controller
{
	public List<InnerClass> InnerClassObj {get; set;}
	Map<Id, Task> mTask = new Map<Id, Task>();
	public Opp100PercentOwnership_Controller(ApexPages.StandardController stdController)
	{
		Map<String,String> mOppIds = new Map<String,String>();
		InnerClassObj = new List<InnerClass>();
		mTask = new Map<Id, Task>([Select t.WhatId, t.Subject, t.Id From Task t 
							where Subject = 'Ownership Validation' 
							and Status != 'Completed' and 
							OwnerId = : UserInfo.getUserId() and WhatId != null]);
		if(mTask != null && mTask.size() > 0)
		{
			for(Task TaskObj : mTask.Values())
			{
				if(String.valueOf(TaskObj.WhatId).startsWith('006'))
					mOppIds.put(TaskObj.Id, TaskObj.WhatId);
			}
		}
		if(mOppIds.size() > 0)
		{
			Map<Id,Opportunity> mOpp = new Map<Id,Opportunity>([Select o.Owner.Name, o.OwnerId, 
																o.Name, o.CloseDate, o.Amount, o.StageName, 
																o.Account.Name, o.AccountId, o.Customer_100_Ownership__c 
																From Opportunity o where Id in : mOppIds.values()]);
			for(String sTaskId : mOppIds.keySet())
			{
				String OppId = mOppIds.get(sTaskId);
				Opportunity Opp = mOpp.get(OppId);
				if(Opp != null)
				{
					InnerClass Obj = new InnerClass();
					Obj.Opp = Opp;
					Obj.OppId = OppId;
					Obj.TaskId = sTaskId;
					if(Opp.Customer_100_Ownership__c != null)
						Obj.Ownership100Selected = Opp.Customer_100_Ownership__c;				
					InnerClassObj.add(Obj);
				}
			}
		}
		if(InnerClassObj.size() == 0)
		{
			apexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No more Opportunities available for your action!'));
		}
	}
	public PageReference SubmitData()
	{
		List<Opportunity> lOpp = new List<Opportunity>();
		List<Task> lTask = new List<Task>();
		for(InnerClass Obj : InnerClassObj)
		{
			if(Obj.IsSelected)
			{
				Opportunity Opp = Obj.Opp;
				Opp.Customer_100_Ownership__c = Obj.Ownership100Selected;
				lOpp.add(Opp);
				Task TaskObj = mTask.get(Obj.TaskId);
				TaskObj.Status = 'Completed';
				TaskObj.Description = 'Manager has submitted this Opportunity Ownership 100% as:' + Opp.Customer_100_Ownership__c;
				if(Obj.sComment != null && Obj.sComment.length() > 0)
					TaskObj.Description += '\n\n\nManager Comment: ' + Obj.sComment;								
				lTask.add(TaskObj);
			}
		}
		if(lOpp.size() > 0)
			update lOpp;
		if(lTask.size() > 0)
			update lTask;
		PageReference PageObj = apexPages.currentPage();
		PageObj.setRedirect(true);
		return PageObj;
	}
	public List<SelectOption> getOwnership100()
	{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Yes','Yes'));
            options.add(new SelectOption('No','No'));
            return options;
    }
	public class InnerClass
	{
		public Opportunity Opp {get; set;}
		public String OppId {get; set;}
		public String TaskId {get; set;}
		public Boolean IsSelected {get; set;}
		public String Ownership100Selected {get; set;}
		public String sComment {get; set;}
		public InnerClass()
		{
			Opp = new Opportunity();
			OppId = '';
			TaskId = '';
			IsSelected = false;
			Ownership100Selected = '';
			sComment = '';
		}
	}
}