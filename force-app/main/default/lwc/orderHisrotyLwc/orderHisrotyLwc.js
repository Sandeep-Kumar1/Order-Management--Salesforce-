import { LightningElement,api,track,wire } from 'lwc';
import getOrdersData from '@salesforce/apex/GetOrdersHistoryByDynamicSoql.getOrdersData';

export default class OrderHisrotyLwc extends LightningElement {

    @api recordId;

    //option for status picklist
    statusOptn=[
        { label: 'All', value: 'all' },
        { label: 'New', value: 'New' },
        { label: 'Processing', value: 'Processing' },
        { label: 'Shipped', value: 'Shipped' },
        { label: 'Delivered', value: 'Delivered' },
        { label: 'Returned', value: 'Returned' },
    ]
    //stores orderdat for datatable 
    orderdata ;

    //stores all the data of order
    wholeValues;

    //coloums for the data table defined 
    columns = [  
        { label: 'Order Id', fieldName: 'orderName', type: 'button',  typeAttributes: { label: { fieldName: 'orderName' }, name: 'Details', variant: 'base' } }, 
        { label: 'Status', fieldName: 'Status', type: 'text' },     
        { label: 'Order Date', fieldName: 'OrderDate', type: 'date' }
    ];
    
    //variable for storing the filter criteria
    startDate =null;
    endDate =null;
    status = 'all';
    selectedProductId ;
    comment = "";
    //getting the data based on the provided parameter form the getOrderData function through apex
    @wire (getOrdersData,{status : null , startDate : null, endDate : null, accId : '$recordId'})
        result({error, data}){
            if(data){

                //assgning all data to wholeValues vaiable 
                this.wholeValues = data;
                //creating map for storing unique data 
                const orderMap = new Map(); 

                //iterating over the data coming form the apex method as data 
                for (let i = 0; i < data.length; i++) {
                    const newlist = {
                        "orderId": data[i].orderId,
                        "orderName": data[i].orderName,
                        "Status": data[i].Status,
                        "OrderDate": data[i].OrderDate
                    };

                    //adding the data into map 
                    orderMap.set(data[i].orderId, newlist);
                }

                //converting the unique map to array so that this data can be displayed to datatable
                this.orderdata = Array.from(orderMap.values());

            }
            else{
                //if error comes as result then error will be logged in the console
                console.log(JSON.stringify(error));
            }
        }

    //whenever the vlaues of the filters change this method will be triggered 
    getDataHndler(event){

        // assigning the user input vlaues to variable declated eariler
        const {value, name} = event.target;
        this[name] = value;
        this.orderdata  = [];

        if (this.status === 'all'){
            this.status= null
        }

         //getting the data based on the provided parameter form the getOrderData function through apex
        getOrdersData({ status: this.status, startDate: this.startDate, endDate: this.endDate, accId: this.recordId })
            .then(result => {

                //assgning all data to wholeValues vaiable 
                this.wholeValues = result;

                //creating map for storing unique data 
                const orderMap = new Map(); 

                //iterating over the data coming form the apex method as data 
                for (let i = 0; i < result.length; i++) {
                    const newlist = {
                        "orderId": result[i].orderId,
                        "orderName": result[i].orderName,
                        "Status": result[i].Status,
                        "OrderDate": result[i].OrderDate
                    };

                    //adding the data into map 
                    orderMap.set(result[i].orderId, newlist);
                }

                 //converting the unique map to array so that this data can be displayed to datatable
                this.orderdata = Array.from(orderMap.values());
            })

            //if error comes as result then error will be logged in the console
            .catch(error => {
                console.error(error);
            });
    }
    

    @track visibledata = [];
    //varible for conditional rendering 
    @track isVisible = false;
    
    grandTotal = 0;

    //method triggerd when onrowAction in the datatable 
    openDetails(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        // checking for is actionName is eqal to detilas
        if (actionName === 'Details') {
            this.isVisible = true;
            this.visibledata = []; 
            this.grandTotal = 0;

            // iterating ovet the Whole values for geeting all the values 
            for (let i = 0; i < this.wholeValues.length; i++) {
                if (this.wholeValues[i].orderId === row.orderId) {
                    const nData = {
                        'itemId': this.wholeValues[i].itemId,
                        'orderName': this.wholeValues[i].orderName,
                        'Name': this.wholeValues[i].Name,
                        'Quantity': this.wholeValues[i].Quantity,
                        'Price': this.wholeValues[i].Price,
                        'totalPrice': this.wholeValues[i].TotalPrice,
                        'Status': this.wholeValues[i].Status,
                        'orderDate': this.wholeValues[i].OrderDate
                    };
                    this.grandTotal+= this.wholeValues[i].TotalPrice;

                    // adding the created data to list 
                    this.visibledata.push(nData); 
                }
            }
        }
    }

    // variable for open
    isReturnFormOpen = false;
    save(){
        for (let i = 0; i < this.wholeValues.length; i++) {
            if (this.wholeValues[i].orderId === this.selectedProductId) {
                if ( this.wholeValues[i].Status === 'Delivered'){
                    alert('sucessfully Returned');
                }else{
                    alert('this product can not be Returned');
                }
            }
        }
        this.isReturnFormOpen = false;
    }
    openForm(event){
        this.isReturnFormOpen = true;
        this.selectedProductId = event.target.dataset.id
    }

    closeFrom(){
        this.isReturnFormOpen = false;
    }
}