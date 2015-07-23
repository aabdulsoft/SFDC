/*
*   Class represneting response received from calling DnB Business Verification web services
*/
/*
<GDPResponse>
            <DGX>
               <SIGNONMSGSRSV1>
                  <SONRS>
                     <STATUS>
                        <CODE>0</CODE>
                        <SEVERITY>INFO</SEVERITY>
                     </STATUS>
                     <DTSERVER>20101130072742</DTSERVER>
                     <LANGUAGE>EN</LANGUAGE>
                  </SONRS>
               </SIGNONMSGSRSV1>
               <CREDITMSGSRSV2>
                  <DATATRNRS>
                     <TRNUID>8a9c05a0d39898ad12cf5902796</TRNUID>
                     <STATUS>
                        <CODE>0</CODE>
                        <SEVERITY>INFO</SEVERITY>
                     </STATUS>
                     <DATARS>
                        <SRVRTID>ABFCEEEC-294E-478F-B886-DA3335C6875B</SRVRTID>
                        <CACHE_IND>N</CACHE_IND>
                        <DUNS_NBR>610796604</DUNS_NBR>
                        <PRIM_NME>US Test Company 1</PRIM_NME>
                        <ADR_LINE>
                           <ArrayOfstringItem>899 Eaton Ave</ArrayOfstringItem>
                        </ADR_LINE>
                        <POST_TOWN>Bethlehem</POST_TOWN>
                        <PRIM_GEO_AREA>PA</PRIM_GEO_AREA>
                        <POST_CODE>18025</POST_CODE>
                        <CTRY_CD>US</CTRY_CD>
                        <BR_IND>N</BR_IND>
                        <INTL_DLNG_CD>1</INTL_DLNG_CD>
                        <OUT_BUS_IND>Y</OUT_BUS_IND>
                        <PRIM_SIC>0119</PRIM_SIC>
                        <PRIM_SIC_TYPE_CD>1987</PRIM_SIC_TYPE_CD>
                        <TLCM_NBR>DISCONNECTED</TLCM_NBR>
                        <TRDG_STYL>
                           <ArrayOfstringItem>US Fictitious Company 1</ArrayOfstringItem>
                        </TRDG_STYL>
                        <ENQ_DUNS>610796604</ENQ_DUNS>
                     </DATARS>
                  </DATATRNRS>
               </CREDITMSGSRSV2>
            </DGX>
         </GDPResponse>
         */
public with sharing class BusinessVerification 
{
	
	public String dunsNumber {get; set;}
	public String primaryName {get; set;}
	public String addressLine {get; set;}
	public String postalTown {get; set;}
	public String stateProvince {get; set;}
	public String postalCode {get; set;}
	public String countryCode {get; set;}
	public String branchIndicator {get; set;}
	public String businessStructure {get; set;}
	
	public String locationStatus {get; set;}
    public String siteName {get; set;}
    public String siteDUNS {get; set;}
    public String siteCountry {get; set;}
    public String domesticUltimateName {get; set;}
    public String domesticUltimateDUNS {get; set;}
    public String domesticUltimateCountry {get; set;}
    public String globalUltimateName {get; set;}
    public String globalUltimateDUNS {get; set;}
    public String globalUltimateCountry {get; set;}
    public String hqDUNSName {get; set;}
    public String hqDUNS {get; set;}
    public String hqDUNSCountry {get; set;}
    
    public String sicCode {get; set;}
	public String sicTypeCode {get; set;}
	public Boolean hasBusinessVerication {get; set;}
	public String outOfBusiness {get; set;}

}