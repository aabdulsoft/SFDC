/******************************************************************************************
 *	Name    : ProductTrigger
 *  Purpose : Trigger on Product2 Object (T-317748)
 *  Author  : Manisha Gupta
 *  Date    : 2014-09-09
 *  Version : 1.0
 *
 *  Modification History
 *	Date	Who		Description
 *
 ********************************************************************************************/
trigger ProductTrigger on Product2 (after insert) {
    ProductTriggerHelper.productAfterInsert(trigger.New);
}