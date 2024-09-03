import { api, LightningElement, wire } from 'lwc';
import getOrdersData from '@salesforce/apex/GetOrdersHistoryByDynamicSoql.getOrdersData';
import createReturnRecord from '@salesforce/apex/GetOrdersHistoryByDynamicSoql.createReturnRecord';


export default class ReturnPage extends LightningElement {
    
    //all the variable are listed here 
    @api recordId;
    SelectedItem ;
    Comments ;
    orderStatus = 'Delivered';
    recId ;
    amount;
    allData =[];
    orderItemList = [ ];
   
    //this method is auto called once component is rendered 
    connectedCallback(){
        getOrdersData({status : this.orderStatus , startDate : null, endDate : null, accId : this.recordId})
            .then(result =>{
                this.orderItemList =[];
                const itemList=[]; 
                this.allData =result;

                //iterating over the data coming form the apex method as data 
                for (let i = 0; i < result.length; i++) {
                    const newlist = {
                        "label": result[i].Name,
                        "value": result[i].itemId,
                    };
                    itemList.push(newlist);   
                }
                this.orderItemList = itemList;
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            })   
    }
    
    //this mehtod called on when oncahnge event , and it assignes the vlaues to the vlariable with the name 
    getInputData(event){
        const {name, value} = event.target;
        this[name] = value;
    }

    //method is called when form is submited 
    submitFrom(){
        //iteraring over all data and fiding data based on itemId 
        for (let i = 0; i < this.allData.length; i++) {
            if (this.SelectedItem === this.allData[i].itemId) {
                // Store the recId and amount
                this.recId = this.allData[i].orderId;
                this.amount = this.allData[i].TotalPrice;
                break;  // Exit loop after finding the match
            }
        }
        //calling apex method for recrod creation 
        createReturnRecord({orderId : this.recId, orderItemId : this.SelectedItem, totalAmount : this.amount, comment : this.Comments})
            .then(result =>{
                alert(result);
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            })
        //this mehtod will clear the form data 
        this.clear();
    }
    // method for clearing the form data 
    clear(){
        this.SelectedItem = '' ;
        this.Comments = '' ;
    }
}