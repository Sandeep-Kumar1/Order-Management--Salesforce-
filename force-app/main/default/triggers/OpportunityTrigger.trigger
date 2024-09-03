trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update) {
    if ( trigger.isAfter){
        if (trigger.isUpdate){
            OpportunityTriggerHandler.updateOrderStatus(trigger.new, trigger.oldMap);
        }
    }
}