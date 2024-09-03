trigger ReturnTrigger on Return__c (after update, before update) {
    if (trigger.isAfter){
        if(trigger.isUpdate){
            RefundTriggerHandler.updateOrderAndRefundStatus(trigger.new , trigger.oldMap);
        }
    }
}