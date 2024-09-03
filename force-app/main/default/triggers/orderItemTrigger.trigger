trigger orderItemTrigger on Order_Item__c (before insert, after insert) {
    if (trigger.isAfter) {
        if (trigger.isInsert) {
            orderItemTriggerHandler.createOpp(trigger.new);
        }
    }
}