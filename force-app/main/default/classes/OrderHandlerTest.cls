@isTest
public with sharing class OrderHandlerTest {
    @TestSetup
    static void makeData(){
        //Creating Account based on which Order will be created 
        Account acc = new Account();
        acc.Name = 'Mundari';
        acc.Phone = '94798798';
        insert acc;

        //creating associated order with account created
        Order__c odr = new Order__c ();
        odr.Customer_Name__c = acc.Id;
        odr.Order_Date__c = Date.today();
        odr.Total_Amount__c = 0;
        odr.Status__c = 'New';

        insert odr;
    }
    @isTest
    public static void createOrderTest(){

        //quering all the order available in the test setup 
        List<Order__c> odrList = [SELECT Id, Customer_Name__c FROM Order__c];
        Assert.areEqual(1, odrList.size());

        //test data getting form Lwc form
        Map<String, String> orderData = new Map<String, String>{
            'ProductName' => 'Samsung',
            'Price' => '100',
            'Quantity' => '4',
            'tAmount' => '400'
        };

        //checking by calling the method that order will create or not 
        OrderHandler.createOrder(orderData, odrList[0].Customer_Name__c );
        
        // quering all order record 
        List<Order__c> neworder = [SELECT Id, Customer_Name__c ,Total_Amount__c  FROM Order__c]; 

        //checking order is created or not as existing order is available with status new  
        Assert.areEqual(1, neworder.size());
        Assert.areEqual(400, neworder[0].Total_Amount__c);

        // quering all order items record 
        List<Order_Item__c> neworderitems = [SELECT Id, Order__c FROM Order_Item__c]; 

        //checking orderitem is created or not as for the order 
        Assert.areEqual(1, neworderitems.size()); 

        // checking the order item id is associated with existing order or not
        Assert.areEqual(neworder[0].Id, neworderitems[0].Order__c);

        //creating another account with no existing order related with it 
        Account acc1 = new Account();
        acc1.Name = 'Animesh Kumar';
        acc1.Phone = '79948989';
        insert acc1;

        //calling the method for order and orderItem record creation
        OrderHandler.createOrder(orderData, acc1.Id );

        //quering all order record with account id
        List<Order__c> odrList1 = [SELECT Id FROM Order__c WHERE Customer_Name__c = :acc1.Id];

        //checking the number of order created
        Assert.areEqual(1, odrList1.size());

        //quering all order items record with account id
        List<Order_Item__c> neworderitems1 = [SELECT Id, Order__c FROM Order_Item__c WHERE Order__c = : odrList1[0].Id ]; 
       
       // checking that associated order item is created or not
        Assert.areEqual(1, neworderitems1.size());  
       

    }
}