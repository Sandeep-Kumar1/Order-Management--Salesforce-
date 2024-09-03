import { api, LightningElement, wire } from 'lwc';
import getOrdersData from '@salesforce/apex/GetOrdersHistoryByDynamicSoql.getOrdersData';
import createReturnRecord from '@salesforce/apex/GetOrdersHistoryByDynamicSoql.createReturnRecord';


export default class ReturnPage extends LightningElement {

    @api recordId;
    SelectedItem ;
    Comments ;
    orderStatus = 'Delivered';
    recId ;
    amount;
    allData =[];
    orderItemList = [
        { label: 'Laptop', value: '3334343' }
    ];
    
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
    
    getInputData(event){
        const {name, value} = event.target;
        this[name] = value;
    }

    submitFrom(){
        for (let i = 0; i < this.allData.length; i++) {
            if (this.SelectedItem === this.allData[i].itemId) {
                // Store the recId and amount
                this.recId = this.allData[i].orderId;
                this.amount = this.allData[i].TotalPrice;
                break;  // Exit loop after finding the match
            }
        }
        createReturnRecord({orderId : this.recId, orderItemId : this.SelectedItem, totalAmount : this.amount, comment : this.Comments})
            .then(result =>{
                alert(result);
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            })
        this.clear();
    }

    clear(){
        this.SelectedItem = '' ;
        this.Comments = '' ;
    }
}