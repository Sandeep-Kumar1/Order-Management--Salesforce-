public with sharing class shipmentsTriggerHandler {
   public static void updateOrderStatus(List<Shipment__c> shipmentsList ) {
        Set<Id> orderIds = new Set<Id>();
        for (Shipment__c shipment : shipmentsList) {
            orderIds.add(shipment.Order__c);
        }

        List<AggregateResult> aggOrderList = [SELECT Id FROM Order__c WHERE Status__c ='Processing' 
            AND Id IN :orderIds GROUP BY Id];
        
        Set<Object> idsToUpdate = new Set<Object>();

        for (AggregateResult ar : aggOrderList) {
            idsToUpdate.add(ar.Id);
        }

        List<Order__c> toUpdateOrderList = new List<Order__c>();

        for (Shipment__c shipment : shipmentsList) {
            if (idsToUpdate.contains(shipment.Order__c)) {
                Order__c statusUpdate = new Order__c ();
                statusUpdate.Id = shipment.Order__c;
                statusUpdate.Status__c = 'Shipped';

                toUpdateOrderList.add(statusUpdate);
            }else{
                shipment.addError('Order Payment is not Completed yet!');
            } 
        }
        
        update toUpdateOrderList;
    }
}