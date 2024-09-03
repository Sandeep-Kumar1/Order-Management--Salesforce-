public with sharing class OpportunityTriggerHandler {
    public static void updateOrderStatus(List<Opportunity> oppList, Map<Id, Opportunity> oldOppList){
        Set<Id> orderItemIds = new Set<Id>();
        for(Opportunity opp : oppList){
            if (opp.StageName == 'Closed Won' && oldOppList.get(opp.Id).StageName != 'Closed Won'){
                orderItemIds.add(opp.Order_Item__c);
            }
        }
        system.debug(orderItemIds);
        List<Order_Item__c> allOrderList = [SELECT Order__r.Id FROM Order_Item__c WHERE Order__r.Id IN :orderItemIds];
        Set<Id> OrderIds = new Set<Id>();

        for(Order_Item__c order : allOrderList){
            OrderIds.add(order.Order__r.Id);
        }

        List<Order_Item__c> orderList = [SELECT Id, Order__r.Id, (Select Id, StageName FROM Opportunities__r WHERE StageName != 'Closed Won') FROM Order_Item__c WHERE Order__r.Id = : OrderIds];
        
        Map<Id, Integer> validOpp = new Map<Id, Integer>();

        for(Order_Item__c  order : orderList){
            if(validOpp.containsKey(order.Order__c)) {
                validOpp.put(order.Order__c, (validOpp.get(order.Order__c)+order.Opportunities__r.size()));
            } else {
                validOpp.put(order.Order__c, order.Opportunities__r.size());
            } 
        }

        List<Order__c> updatedOrderList = new List<Order__c>();

        for (Id oderId : validOpp.keySet()){
            if (validOpp.get(oderId) < 1){
                Order__c nOrder = new Order__c();
                nOrder.Id = oderId;
                nOrder.Status__c = 'Processing';

                updatedOrderList.add(nOrder);
            }  
        }
        update updatedOrderList;
    }
}