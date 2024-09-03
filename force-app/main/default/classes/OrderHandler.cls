public with sharing class OrderHandler {
    //this funtion will create a order record based on accountn Id and total amount as parameter
    @AuraEnabled
    public static String createOrder(Map<String, String> allData, Id AccountId){

        //quering the associated order with this account where Status is New
        List<Order__c> odrList = [SELECT Id, Status__c, Total_Amount__c FROM Order__c WHERE Customer_Name__c= :AccountId AND Status__c = 'New' LIMIT 1];
        
        //checking if there any asscociated order with this account where status is new 
        if(odrList.size()>0) {

             //creating new orderItem with given data by user associated with existing order
            Order_Item__c odrItem = new Order_Item__c ();
            odrItem.Order__c= odrList[0].Id;
            odrItem.Price__c = Decimal.valueOf(allData.get('Price'));
            odrItem.Name = allData.get('ProductName');
            odrItem.Quantity__c = Integer.valueOf(allData.get('Quantity')) ;

            //inserting oderItem record
            insert odrItem;

            //calculating the total_amount if new order item is added to that order
            Order__c cloneOrder = odrList[0].clone(true, false, false, false);
            cloneOrder.Total_Amount__c = odrList[0].Total_Amount__c + Decimal.valueOf(allData.get('tAmount'));

            update cloneOrder;

            return 'Record Created Sucessfully';
    }
        else {
            //creating new Order record 
            Order__c odr = new Order__c ();
            odr.Customer_Name__c = AccountId;
            odr.Total_Amount__c = Decimal.valueOf(allData.get('tAmount'));
            odr.Order_Date__c = Date.today();
            odr.Status__c = 'New';
            odr.Product_Category__c = allData.get('SelectedItem');
            //inserting order record 
            insert odr;

            //creating new orderItem with given data by user associated with created order
            Order_Item__c odrItem = new Order_Item__c ();
            odrItem.Order__c= odr.Id;
            odrItem.Price__c = Decimal.valueOf(allData.get('Price'));
            odrItem.Name = allData.get('ProductName');
            odrItem.Quantity__c = Integer.valueOf(allData.get('Quantity')) ;

            //inserting oderItem record
            insert odrItem;
            
            return 'Record Created Sucessfully';
        }     
    }

    //this method will send email if order status is shipped or delivered 
    public static void sendEmail(List<Order__c> orderList , Map<Id, Order__c> oldOrderList ){

        List<Order__c> toSendEmail = [SELECT Id, Owner.Email, Name, Customer_Name__r.Name FROM Order__c WHERE Id = :oldOrderList.keySet()];

        //list of Email to store all the emails for shipped status 
        List <Messaging.SingleEmailMessage> shippedMailList = new List<Messaging.SingleEmailMessage>();
        //list of Email to store all the emails for Delivered status 
        List <Messaging.SingleEmailMessage> deliveredMailList = new List<Messaging.SingleEmailMessage>();
        
        //iteraring over the list of Order records 
        for (Order__c  order : toSendEmail ){
            if (order.status__c == 'Shipped' && oldOrderList.get(order.Id).status__c !='Shipped'){
                //adding mails to shiped mail list
                shippedMailList.add(sendEmailToOwner(order.Customer_Name__r.Name, order.Owner.Email, 'Shipped'));
            }
            if (order.status__c == 'Delivered' && oldOrderList.get(order.Id).status__c !='Delivered'){
                //adding mails to delivered mail list
                deliveredMailList.add(sendEmailToOwner(order.Customer_Name__r.Name, order.Owner.Email, 'Delivered'));
            }
        }
        if (!shippedMailList.isEmpty()){
            //seding emails in list
            Messaging.sendEmail(shippedMailList);
        }
        if (!deliveredMailList.isEmpty()){
            //seding emails in list
            Messaging.sendEmail(deliveredMailList);
        }
    }

    // Method to send email which require there parameter name, email 
    public static Messaging.SingleEmailMessage sendEmailToOwner (String name , String email, String value){

        // creating new instance of mail type and adding all the required fields of that instance
        Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
        newMail.setToAddresses(new List<String> {email,'sandeep.ttps@gmail.com'});
        //newMail.setSubject('Regarding Renewal of your Contract');
        String body = 'Hi, '+ name;
        body += ' Your Order has be sucessfully' + value;    
        newMail.setHtmlBody(body);
        //newMail.setTemplateId('00XdM000003hZ9lUAE');
        
        //returining the generated mail 
        Return newMail;
    } 
}