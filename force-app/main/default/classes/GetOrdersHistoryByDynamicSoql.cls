public with sharing class GetOrdersHistoryByDynamicSoql {

    @AuraEnabled(Cacheable = true)
    public static List<Map<String, Object>> getOrdersData(String status, Date startDate, Date endDate, Id accId){
        
        String query = 'SELECT Id ,Name, Status__c, Order_Date__c, (SELECT Id, Price__c, Name, Quantity__c,' + 
            ' Total_Price__c FROM Order_Items__r) FROM Order__c WHERE Customer_Name__c = :accId ';
        
        if (accId != Null && status == Null && startDate == Null && endDate == Null){

            List<Order__c> orderList = new List<Order__c> ();
            orderList = Database.query(query);

            List<Map<String, Object>> allOrderData = new List<Map<String, Object>>();

                for (Order__c order : orderList ){
                    for (Order_Item__c odr : order.Order_Items__r){
                        Map<String, Object> orderData = new Map<String, Object>{
                            'itemId'=> odr.Id,
                            'orderId'=> order.Id,
                            'orderName'=> order.Name,
                            'Name'=> odr.Name,
                            'Quantity'=> odr.Quantity__c,
                            'Price'=> odr.Price__c,
                            'TotalPrice' => odr.Total_Price__c,
                            'Status'=> order.Status__c,
                            'OrderDate' => order.Order_Date__c
                        }; 
                        allOrderData.add(orderData);
                    }  
                }
            return allOrderData;
        }
    
        query += ' AND ';

        List<String> toAppend = new List<String>();
       
        if (status != Null){
            toAppend.Add('Status__c = :status') ;
        }
        if (startDate != Null){
            toAppend.Add('Order_Date__c >= :startDate');
        }
        if(endDate != Null){
            toAppend.Add('Order_Date__c <= :endDate');
        }
        query+= String.join(toAppend, ' AND ');
        
        List<Order__c> orderList = new List<Order__c> ();
        orderList = Database.query(query);

        List<Map<String, Object>> allOrderData = new List<Map<String, Object>>();

        for (Order__c order : orderList ){
            for (Order_Item__c odr : order.Order_Items__r){
                Map<String, Object> orderData = new Map<String, Object>{
                    'itemId'=> odr.Id,
                    'orderId'=> order.Id,
                    'orderName'=> order.Name,
                    'Name'=> odr.Name,
                    'Quantity'=> odr.Quantity__c,
                    'Price'=> odr.Price__c,
                    'TotalPrice' => odr.Total_Price__c,
                    'Status'=> order.Status__c,
                    'OrderDate' => order.Order_Date__c
                }; 
                allOrderData.add(orderData);
            }  
        }
        return allOrderData;
    }

    @AuraEnabled
    public static String createReturnRecord(Id orderId , Id orderItemId, Decimal totalAmount, String comment){

        List<Return__c> returnList= [SELECT Id, Order_Item__r.Id FROM Return__c WHERE Order_Item__r.Id = :orderItemId];
        if(returnList.size() == 0){
            Return__c returObj = new Return__c();
            returObj.Order__c=orderId;
            returObj.Order_Item__c = orderItemId;
            returObj.Refund_Amount__c = totalAmount;
            returObj.Return_Status__c = 'Pending';
            returObj.Return_Reason__c = comment;
            returObj.Return_Date__c= Date.today();

            insert returObj;

            Refund__c refundObj = new Refund__c();
            refundObj.Refund_Amount__c = totalAmount;
            refundObj.Status__c = 'Pending';
            refundObj.Return__c = returObj.Id;

            insert refundObj;
            return 'Return request is Accepted';
        }else {
            return 'Return Already Processed';
        }
        
    }
}