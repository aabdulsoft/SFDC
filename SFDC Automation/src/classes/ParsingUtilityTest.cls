/*******************************************************************
Name  : ParsingUtilityTest
Author: Jytirmaya Rath (Appirio)
Date  : October 16, 2014
Discription: Test Class for  ParsingUtility
*************************************************************************/
@isTest(seealldata = true)
private class ParsingUtilityTest {
    static testMethod void TestParsingUtility() {
        User sysAdmin = TestUtilUvs.createAdminUser(True);
        System.runAs (sysAdmin) {
              
                generateResumeHierarchyData();
                Test.startTest();
                parseXMLToClass();
                System.assert(ParsingUtility.PARSE_RESUME_PROCESSCV_ACCOUNT != NULL);
                System.assert(ParsingUtility.XML_TAG_YEAR != NULL);
                System.assert(ParsingUtility.XML_TAG_ERROR != NULL);
                System.assert(ParsingUtility.XML_TAG_COMPETENCYEVIDENCE != NULL);
                System.assert(ParsingUtility.CANDIDATE_DEFAULT_STATUS != NULL);
                System.assert(ParsingUtility.XML_TAG_DATA_TYPE_STRING != NULL);
                
                //System.assert(ParsingUtility.isNotNullOrBlank('test'));
                Test.stopTest();

        }
    }
    public static void parseXMLToClass() {
        String xmlFile = '';
        xmlFile += '<DxResponse>';
        xmlFile += '<Status>';
        xmlFile += '<Code>200</Code>';
        xmlFile += '<Description>OK</Description>';
        xmlFile += '</Status>';
        xmlFile += '<Results>';
        xmlFile += '<Result>';
        xmlFile += '<CandidateId>cId000001</CandidateId>';
        xmlFile += '<Score>100</Score>';
        xmlFile += '</Result>';
        xmlFile += '<Result>';
        xmlFile += '<CandidateId>cId000002</CandidateId>';
        xmlFile += '<Score>90</Score>';
        xmlFile += '</Result>';
        xmlFile += '</Results>';
        xmlFile += '</DxResponse>';
        Dom.Document domDoc = new Dom.Document();
           domDoc.load(xmlFile);
           Dom.XMLNode rootNode = domDoc.getRootElement();
        /* Can be any custom object ,mapping must be sepecified in XML_Structure__c custom setting*/
        SAMResponse classObj = new SAMResponse();
        ParsingUtility.mapClassFields(rootNode, classObj);
        System.debug(classObj);
    }
     public static List<XML_Structure__c> generateResumeHierarchyData() {
        List<XML_Structure__c> lstXMLStructure = new List<XML_Structure__c>();
        lstXMLStructure.add(getXMLStructure('21','DxResponse-TAGFOR-SAMResponse','Status,Candidate,Results',
                                                                                            'NotMapped,NotMapped,NotMapped', false, false));
        lstXMLStructure.add(getXMLStructure('22','Status-TAGFOR-SAMResponse','Code,Description',
                                                                                            'Code,Description', false, false));
        lstXMLStructure.add(getXMLStructure('23','Candidate-TAGFOR-SAMResponse','CandidateId',
                                                                                            'CandidateId', false, false));
        lstXMLStructure.add(getXMLStructure('24','Results-TAGFOR-SAMResponse','Result',
                                                                                     'NotMapped', false, true));
        lstXMLStructure.add(getXMLStructure('35','Result-TAGFOR-SAMResponse','CandidateId,Score',
                                                                               'Candidate_Id,Score', false, false));

        insert lstXMLStructure;
        return lstXMLStructure;
    }

  public static XML_Structure__c getXMLStructure(String name,String parentTag,String tags,String mappedToContact,boolean isInsert, boolean multiChildren) {
    XML_Structure__c XMLStructure = new XML_Structure__c(Name = name, ParentTag__c = parentTag,
                                                         Mapped_To_Contact_Field__c = mappedToContact , SubTags__c = tags,
                                                         Multiple_Children__c = multiChildren);
    if(isInsert) {
        insert XMLStructure;
    }
    return XMLStructure;
  }
}