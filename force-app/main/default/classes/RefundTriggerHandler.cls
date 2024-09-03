public with sharing class RefundTriggerHandler {
    public static void updateOrderAndRefundStatus(List<Return__c> returnList, Map<Id, Return__c> oldReturnList ) {
        //stroing ids in set for field update and email alerts 
        Set<Id> returnIds = new Set<Id>();
        Set<Id> emailUpdateIds = new Set<Id>();

        //iterating over the returnList  
        for( Return__c retrn : returnList){
            //checking if the status is approved 
            if (retrn.Return_Status__c == 'Approved' && oldReturnList.get(retrn.Id).Return_Status__c != 'Approved'){
                returnIds.add(retrn.Id);
            }
            //checking if the status is Rejected 
            if (retrn.Return_Status__c == 'Rejected' && oldReturnList.get(retrn.Id).Return_Status__c != 'Rejected'){
                emailUpdateIds.add(retrn.Id);
            }
        }
        //checking returnIds set is not empty or not 
        if (!returnIds.isEmpty()){
            //quering all the data form return object and quring refunds and the Order object data 
            List<Return__C> orderList = [SELECT Id, Order__r.Id, Order__r.Status__c,(SELECT Id FROM Refunds__r) FROM Return__c WHERE Id = : returnIds ];
            //list for storing all the all the refund object record to update
            List<Refund__c> toUpdateRefundList = new List<Refund__c>();
            //list for storing all the all the order object record to update
            List<Order__c> toUpdateOrderList = new List<Order__c>();

            //itereting over the orderList
            for (Return__c retrn : orderList ){
                //creating order record with same id to update
                Order__c rtn = new Order__c();
                rtn.Status__c = 'Returned';
                rtn.Id = retrn.Order__r.Id;

                //adding record to list
                toUpdateOrderList.add(rtn);

                for (Refund__c refund : retrn.Refunds__r ){
                    //creating refund record with same id to update
                    Refund__c rfnd = new Refund__c();
                    rfnd.Id = refund.Id;
                    rfnd.Status__c = 'Processed';

                    //adding record to list
                    toUpdateRefundList.add(rfnd);
                }
            }
            //udating the Refund and Order records status fields 
            update toUpdateRefundList;
            update toUpdateOrderList;
        }

        //checking emailUpdateIds set is not empty or not 
        if (!emailUpdateIds.isEmpty()){

            //Storing all the list of messages 
            List <Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            //querring all the data required for the seding email form return object 
            List<Return__c> toSendEmailList = [SELECT Id, Owner.Email, Order__r.Customer_Name__r.Name FROM Return__c WHERE Id = :returnIds];       
            
            //iterarting ovet the list of return data 
            for (Return__c rtn : toSendEmailList){
                mailList.add(sendEmailToOwner(rtn.Order__r.Customer_Name__r.Name, rtn.Owner.Email));
            }
            //sending messages in list
            Messaging.sendEmail(mailList);
        }
    }    

    // Method to send email which require there parameter name, email 
    public static Messaging.SingleEmailMessage sendEmailToOwner (String name , String email){

        // creating new instance of mail type and adding all the required fields of that instance
        Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();

        newMail.setToAddresses(new List<String> {email,'sandeep.ttps@gmail.com'});
        //newMail.setSubject('Regarding Renewal of your Contract');
        String body = 'Hi, '+ name;
        body += ' Your Order Return is rejeted';    
        newMail.setHtmlBody(body);
        //newMail.setTemplateId('00XdM000003hZ9lUAE');
        
        //returining the generated mail 
        Return newMail;
    } 
}