/**=====================================================================
 * Appirio, Inc
 * Name         : ParsingUtility
 * Description  : Used to Parse XML used in Start Bill Of Sale on Quote
 * Created Date : [09/19/2014]
 * Created By   : [Manisha Gupta]
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]     [Short description for changes]
 =====================================================================*/
public with sharing class ParsingUtility {

    /* Use custom setting "XML_Structure__c" to retrieve the mapping of XML tags
    *  to class fields and then push data from XML to class object
    */
    public static void mapClassFields(Dom.XMLNode currentNode , SAMResponse responseObj) {
        if(currentNode == null ||currentNode.getName() == null) {
            return;
        }

        String currentObjectName = responseObj.getClassName();
        String mappingKey = currentNode.getName() + PARSE_RESUME_MAPPING_SEPRATOR + currentObjectName;
        //system.debug('mappingKey'+mappingKey);
        XML_Structure__c resumeHierarchy = getMapping(mappingKey);
                       //XML_Structure__c.getInstance(currentNode.getName());
        if(resumeHierarchy == null) {
            return;
        }

        system.debug('================' + resumeHierarchy);
        Map<String,String> fieldMapping = new Map<String,String>();
        List<String> lstTags = resumeHierarchy.SubTags__c.split(',');
        List<String> lstMappedField = resumeHierarchy.Mapped_To_Contact_Field__c.split(',');
        // Important notice : resumeHierarchy custom setting must have mapping for all the tags
        // In case field is not present for any tag use "NotMapped" for that tag
        // Number of child tags must be equal to number of mapped fields.
        for(integer i = 0 ; i < lstTags.size() ; i++) {
            //fieldMapping.put(lstTags[i],lstMappedField[i]);
            system.debug(lstTags[i] + '=================' + lstMappedField[i]);
            fieldMapping.put(trimString(lstTags[i]),trimString(lstMappedField[i]));
        }
        system.debug('=====MANISHA fieldMapping========' + fieldMapping);
        // Loop through the tags and retrieve corresponding mapped fields and populate mapped
        // field with data in the XML for that tag
        for(String tag : fieldMapping.keySet()) {
            if( currentNode.getChildElement(tag, null) != NULL ) {
              System.debug(tag+' - - tag ::  check Child Nodes' + currentNode.getChildElement(tag, null).getChildElements().size());
              if(fieldMapping.get(tag) != XML_TAG_MAPPING_STATUS_NOTMAPPED) {
                 system.debug('================MANISHA NOT MAPPED=======' + fieldMapping.get(tag));

                 system.debug('================MANISHA NOT MAPPED=======' + currentNode.getChildElement(tag, null).getText());
                 responseObj.put(fieldMapping.get(tag), currentNode.getChildElement(tag, null).getText());
              } else { // Parse childs of currentNode
                // In case mapping of a child node is "NotMapped" then called this method again
                // to check if current node is parent node and childs of current node are parsed
                // Manisha Gupta : If a node has multiple childre of same type, then below code will parse them as well
                if(resumeHierarchy.multiple_Children__c){
                    for(dom.Xmlnode childNode : currentNode.getChildElements()){
                        mapClassFields(childNode, responseObj);
                    }
                }else{
                    mapClassFields(currentNode.getChildElement(tag, null),responseObj);
                }

            }
          }
        }
    }

    public static String trimString(String str){
        return str != null ? str.trim() : null;
    }

    public static Map<String,XML_Structure__c> mapResumeHierarchy =
                           new Map<String,XML_Structure__c>();

    /* Methods will return the Datatype of the field mapped to xml tag
    */
    public static XML_Structure__c getMapping(String tags) {
        if(!mapResumeHierarchy.containsKey(tags)) {
            for(XML_Structure__c hierarchy : XML_Structure__c.getall().values()) {
                mapResumeHierarchy.put(hierarchy.ParentTag__c,hierarchy);
            }
        }
        return mapResumeHierarchy.get(tags);
    }



    // ParseResume Constants
    public static final String REFERENCE_PLACEHOLDER = 'X';
    public static final String PARSE_RESUME_MAPPING_SEPRATOR = '-TAGFOR-';
    public static final String PARSE_RESUME_MAPPING_SEPRATOR_FOR_ATTRIBUTE = '-ATTRFOR-';
    public static final String PARSE_RESUME_PROCESSCV_ACCOUNT = 'pd54pPL1C4n77r4CK1N9p4r537Hat';
    public static final String XML_TAG_STRUCTUREDXMLRESUME = 'StructuredXMLResume';
    public static final String XML_TAG_CONTACTINFO = 'ContactInfo';
    public static final String XML_TAG_EMPLOYMENTHISTORY = 'EmploymentHistory';
    public static final String XML_TAG_EDUCATIONHISTORY = 'EducationHistory';
    public static final String XML_TAG_COMPETENCY = 'Competency';
    public static final String XML_TAG_NAME = 'name';
    public static final String XML_TAG_MAPPING_STATUS_NOTMAPPED = 'NotMapped';
    public static final String XML_TAG_MAPPING_STATUS_SELFMAPPED = 'SelfMapped';
    public static final String XML_TAG_MAPPING_STATUS_CHILDMAPPED = 'ChildMapped';
    public static final String XML_TAG_DATA_TYPE_STRING = 'STRING';
    public static final String XML_TAG_DATA_TYPE_INTEGER = 'INTEGER';
    public static final String XML_TAG_DATA_TYPE_DOUBLE = 'DOUBLE';
    public static final String XML_TAG_DATA_TYPE_DATETIME = 'DATETIME';
    public static final String XML_TAG_DATA_TYPE_DATE = 'DATE';
    public static final String XML_TAG_DATE_FILED_TEXT_NOTAPPLICABLE = 'notApplicable';
    public static final String XML_TAG_YEARMONTH = 'YearMonth';
    public static final String XML_TAG_YEAR = 'Year';
    public static final String XML_TAG_ERROR = 'CSERROR';
    public static final String XML_TAG_REFERENCES = 'References';
    public static final String XML_TAG_COMPETENCYEVIDENCE = 'CompetencyEvidence';
    public static final String XML_TAG_DESCRIPTION = 'description';
    public static final String CANDIDATE_DEFAULT_STATUS = 'Prospect';
}