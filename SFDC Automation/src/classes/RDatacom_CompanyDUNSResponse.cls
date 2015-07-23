public class RDatacom_CompanyDUNSResponse
{
    public List<RDatacom_Errors> Errors { get; set; }
    public String matchEngine;
    public List<RDatacom_DUNSMatchRecords> matchRecords { get; set; }
    public String rule;
    public Integer size;
    public Boolean success;
}