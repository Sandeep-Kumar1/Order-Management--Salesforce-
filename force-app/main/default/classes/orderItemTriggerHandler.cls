public with sharing class orderItemTriggerHandler {
    public static void createOpp(List<Order_Item__c> orderItemList){

        //List of Opportunity for sotirng all Opportunity
        List<Opportunity> OppList = new List<Opportunity>();

        for (Order_Item__c odrItem : orderItemList){

            //creating new opp instance for storing all data 
            Opportunity opp = new Opportunity();
            opp.Name = odrItem.Name + ' opp';
            opp.StageName = 'Prospecting';
            opp.CloseDate = Date.today().addDays(4);
            opp.Amount = odrItem.Total_Price__c;
            opp.Order_Item__c = odrItem.Id;

            //adding new created opp into oppList
            OppList.add(opp);
        }
        //inserting Opp
        insert OppList;
    }
}