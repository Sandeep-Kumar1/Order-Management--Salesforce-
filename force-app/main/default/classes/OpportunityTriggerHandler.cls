public with sharing class OpportunityTriggerHandler {
    //this method will update the Order status as related opportunity stage name is updated to closed Won
    public static void updateOrderStatus(List<Opportunity> oppList, Map<Id, Opportunity> oldOppList){
        //set for storing unique orderitem ids 
        Set<Id> orderItemIds = new Set<Id>();
        //iterating over the opportunity list and adding those records where stageName is not closed Won
        for(Opportunity opp : oppList){
            if (opp.StageName == 'Closed Won' && oldOppList.get(opp.Id).StageName != 'Closed Won'){
                //adding orderItems to orderItemsids list
                orderItemIds.add(opp.Order_Item__c);
            }
        }
        // querring all the orderId records based on OrderItemIds
        List<Order_Item__c> allOrderList = [SELECT Order__r.Id FROM Order_Item__c WHERE Id IN :orderItemIds];
        
        //set for storing unique order ids 
        Set<Id> OrderIds = new Set<Id>();
        //iterating over the order items list for adding order ids
        for(Order_Item__c order : allOrderList){
            OrderIds.add(order.Order__r.Id);
        }

        //quering all the required fields form the order Ids where opp stage is closed Won based on orderids
        List<Order_Item__c> orderList = [SELECT Id, Order__r.Id, (Select Id, StageName FROM Opportunities__r WHERE StageName != 'Closed Won') FROM Order_Item__c WHERE Order__r.Id = : OrderIds];
        
        //storing id in map with counting the no of items in each order record with open opp 
        Map<Id, Integer> validOpp = new Map<Id, Integer>();

        //iteraring over the orderlist 
        for(Order_Item__c  order : orderList){
            //checking if orderid exists in map or not
            if(validOpp.containsKey(order.Order__c)) {
                //adding order record id with total items on that order with open opp
                validOpp.put(order.Order__c, (validOpp.get(order.Order__c)+order.Opportunities__r.size()));
            } else {
                // updating the values in map 
                validOpp.put(order.Order__c, order.Opportunities__r.size());
            } 
        }

        // list to order records to be created 
        List<Order__c> updatedOrderList = new List<Order__c>();

        //iterating over the mapids (keyset)
        for (Id oderId : validOpp.keySet()){
            //checing if the value is less than 1
            if (validOpp.get(oderId) < 1){
                //creating order record for updating 
                Order__c nOrder = new Order__c();
                nOrder.Id = oderId;
                nOrder.Status__c = 'Processing';

                //adding created record 
                updatedOrderList.add(nOrder);
            }  
        }
        //updating the order records with list 
        update updatedOrderList;
    }
}