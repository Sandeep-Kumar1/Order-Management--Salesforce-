public with sharing class RefundTriggerHandler {
    public static void updateOrderAndRefundStatus(List<Return__c> returnList, Map<Id, Return__c> oldReturnList ) {
        Set<Id> returnIds = new Set<Id>();
        Set<Id> emailUpdateIds = new Set<Id>();
        for( Return__c retrn : returnList){
            if (retrn.Return_Status__c == 'Approved' && oldReturnList.get(retrn.Id).Return_Status__c != 'Approved'){
                returnIds.add(retrn.Id);
            }
            if (retrn.Return_Status__c == 'Rejected' && oldReturnList.get(retrn.Id).Return_Status__c != 'Rejected'){
                emailUpdateIds.add(retrn.Id);
            }
        }
        if (!returnIds.isEmpty()){
            List<Return__C> orderList = [SELECT Id, Order__r.Id, Order__r.Status__c,(SELECT Id FROM Refunds__r) FROM Return__c WHERE Id = : returnIds ];
            List<Refund__c> toUpdateRefundList = new List<Refund__c>();
            List<Order__c> toUpdateOrderList = new List<Order__c>();
            for (Return__c retrn : orderList ){
                Order__c rtn = new Order__c();
                rtn.Status__c = 'Returned';
                rtn.Id = retrn.Order__r.Id;

                toUpdateOrderList.add(rtn);

                for (Refund__c refund : retrn.Refunds__r ){
                    Refund__c rfnd = new Refund__c();
                    rfnd.Id = refund.Id;
                    rfnd.Status__c = 'Processed';

                    toUpdateRefundList.add(rfnd);
                }
            }
            update toUpdateRefundList;
            update toUpdateOrderList;
        }

        if (!emailUpdateIds.isEmpty()){

            List <Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

            List<Return__c> toSendEmailList = [SELECT Id, Owner.Email, Order__r.Customer_Name__r.Name FROM Return__c WHERE Id = :returnIds];       
            
            for (Return__c rtn : toSendEmailList){
                mailList.add(sendEmailToOwner(rtn.Order__r.Customer_Name__r.Name, rtn.Owner.Email));
            }
            Messaging.sendEmail(mailList);
        }
    }    

    // Method to send email which require there parameter name, email and term(Months)
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