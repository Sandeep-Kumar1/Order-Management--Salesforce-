public with sharing class GetOrdersHistoryByDynamicSoql {
    //method for getting recdords to js 
    @AuraEnabled(Cacheable = true)
    public static List<Map<String, Object>> getOrdersData(String status, Date startDate, Date endDate, Id accId){
        //dynamic Soql for which will accomodate as per given parameter 
        String query = 'SELECT Id ,Name, Status__c, Order_Date__c, (SELECT Id, Price__c, Name, Quantity__c,' + 
            ' Total_Price__c FROM Order_Items__r) FROM Order__c WHERE Customer_Name__c = :accId ';
        
        // checing if only acc id is given as parameter 
        if (accId != Null && status == Null && startDate == Null && endDate == Null){

            //list of Order for sotirng the queried data 
            List<Order__c> orderList = new List<Order__c> ();
            orderList = Database.query(query);

            //list of map in which will be returned as result 
            List<Map<String, Object>> allOrderData = new List<Map<String, Object>>();
                //iteraring over the orders list 
                for (Order__c order : orderList ){
                    //iteraring over the orderItems List related to Order
                    for (Order_Item__c odr : order.Order_Items__r){
                        //creating map for storing the required data 
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
                        //adding map to the list 
                        allOrderData.add(orderData);
                    }  
                }
            //returning the list of map data 
            return allOrderData;
        }
        //if any of patatmeter is given along with accid then these code will be executing 

        query += ' AND ';

        //list of parameter to be apended on to the querry 
        List<String> toAppend = new List<String>();
       
        // checking for status is not null 
        if (status != Null){
            toAppend.Add('Status__c = :status') ;
        }
        // checking for startDate is not null 
        if (startDate != Null){
            toAppend.Add('Order_Date__c >= :startDate');
        }
        // checking for endDate is not null 
        if(endDate != Null){
            toAppend.Add('Order_Date__c <= :endDate');
        }

        //appending all the stored parameter to querry 
        query+= String.join(toAppend, ' AND ');
        
        //list of Order for sotirng the queried data 
        List<Order__c> orderList = new List<Order__c> ();
        orderList = Database.query(query);

        //list of map in which will be returned as result 
        List<Map<String, Object>> allOrderData = new List<Map<String, Object>>();
        //iteraring over the orders list
        for (Order__c order : orderList ){
            //iteraring over the orderItems List related to Order
            for (Order_Item__c odr : order.Order_Items__r){
                //creating map for storing the required data 
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
                 //adding map to the list 
                allOrderData.add(orderData);
            }  
        }
        //returning the list of map data
        return allOrderData;
    }

    // this method will create return record and associated refund record 
    @AuraEnabled
    public static String createReturnRecord(Id orderId , Id orderItemId, Decimal totalAmount, String comment){
        //list of Return record for storing all the queried data 
        List<Return__c> returnList= [SELECT Id, Order_Item__r.Id FROM Return__c WHERE Order_Item__r.Id = :orderItemId];
        //checking if size is equal to 0
        if(returnList.size() == 0){
            // create a return record
            Return__c returObj = new Return__c();
            //specififiying all the fields that are required
            returObj.Order__c=orderId;
            returObj.Order_Item__c = orderItemId;
            returObj.Refund_Amount__c = totalAmount;
            returObj.Return_Status__c = 'Pending';
            returObj.Return_Reason__c = comment;
            returObj.Return_Date__c= Date.today();

            //inserting the record created 
            insert returObj;

            // refund record is created related ot return record 
            Refund__c refundObj = new Refund__c();
            refundObj.Refund_Amount__c = totalAmount;
            refundObj.Status__c = 'Pending';
            refundObj.Return__c = returObj.Id;

            //inserting the record created 
            insert refundObj;
            //return a message that return record is created 
            return 'Return request is Accepted';
        }else {
            //returning message if return is already in process 
            return 'Return Already Processed';
        }
        
    }
}