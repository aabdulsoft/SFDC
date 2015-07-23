public with sharing class OppRedirectController {

  public OppRedirectController(Apexpages.StandardController Controller)
   {
     this.controller = controller;
   }

   public PageReference doRedir()
    {
      Opportunity opp = [Select id, recordtypeid From Opportunity Where Id = :ApexPages.currentPage().getParameters().get('id')];
       Id rtId = UVS_Util.UVSRecordType_Opp;


        PageReference newPage;

        if (opp.recordtypeid != rtId ) {
            newPage = Page.OpptyDetail2;
            newPage.getParameters().put('id', opp.id);
        } else {
            newPage = new PageReference('/'+opp.id );
            newPage.getParameters().put('nooverride', '1');
        }

        return newPage.setRedirect(true);

    }

    private final ApexPages.StandardController controller;
}