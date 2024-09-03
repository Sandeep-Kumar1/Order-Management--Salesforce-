public with sharing class shipmentsTriggerHandler {
    // this method will update the order status when a shipment is done
    public static void updateOrderStatus(List<Shipment__c> shipmentsList ) {
        //storing all orderIds 
        Set<Id> orderIds = new Set<Id>();
        for (Shipment__c shipment : shipmentsList) {
            orderIds.add(shipment.Order__c);
        }

        // querring aggregate Result goup by order Ids 
        List<AggregateResult> aggOrderList = [SELECT Id FROM Order__c WHERE Status__c ='Processing' 
            AND Id IN :orderIds GROUP BY Id];
        
        // storing ids to update records
        Set<Object> idsToUpdate = new Set<Object>();

        //iteraring on aggeregateResult list and adding order Ids to list
        for (AggregateResult ar : aggOrderList) {
            idsToUpdate.add(ar.Id);
        }

        //list of Order Records to be updated
        List<Order__c> toUpdateOrderList = new List<Order__c>();

        //iterating over the shipment list 
        for (Shipment__c shipment : shipmentsList) {
            //checking if shipment id is updated of not where payment id completed 
            if (idsToUpdate.contains(shipment.Order__c)) {

                //creating Order List 
                Order__c statusUpdate = new Order__c ();
                statusUpdate.Id = shipment.Order__c;
                statusUpdate.Status__c = 'Shipped';

                //adding records to orderList
                toUpdateOrderList.add(statusUpdate);
            }else{
                //sent error if payment is not done 
                shipment.addError('Order Payment is not Completed yet!');
            } 
        }
        
        //updating the orderlist
        update toUpdateOrderList;
    }
}