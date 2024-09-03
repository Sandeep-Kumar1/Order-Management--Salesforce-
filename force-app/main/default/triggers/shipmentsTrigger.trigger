trigger shipmentsTrigger on Shipment__c (before insert, after insert) {
    if (trigger.isBefore) {
        if (trigger.isInsert) {
            shipmentsTriggerHandler.updateOrderStatus(trigger.new);
        }
    }
}