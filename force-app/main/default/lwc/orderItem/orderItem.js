import { api, LightningElement, track } from 'lwc';
import createOrder from "@salesforce/apex/OrderHandler.createOrder"

export default class OrderItem extends LightningElement {
    //getting account Id 
    @api recordId ;

    //storing all the input data form user
    @track OrderData ={
        ProductName :"",
        Price :"",
        Quantity : "",
        tAmount : "",
        SelectedItem : ""
    }
    // option for the combobox used to select the product category
    orderCategoryList =[   
        { label: 'Electronics & Gadgets', value: 'Electronics & Gadgets' },
        { label: 'Clothing & Apparel', value: 'Clothing & Apparel' },
        { label: 'Home Appliances', value: 'Home Appliances' },
        { label: 'Furniture', value: 'Furniture' },
        { label: 'Health & Beauty Products', value: 'Health & Beauty Products' },
        { label: 'Toys & Games', value: 'Toys & Games' },
        { label: 'Books & Media', value: 'Books & Media' },
        { label: 'Sports & Outdoor Equipment', value: 'Sports & Outdoor Equipment' },
        { label: 'Groceries & Perishables', value: 'Groceries & Perishables' },
        { label: 'Automotive Parts & Accessories', value: 'Automotive Parts & Accessories' }
    ]
    //this method is called in input field onChange event
    getFromData(event){
        const { name, value} = event.target;
        this.OrderData[name] = value;
    }

    // for reseting all the fields values in the form 
    reset(){
        this.OrderData.ProductName = "";
        this.OrderData.Price = "";
        this.OrderData.Quantity = "";
        this.OrderData.SelectedItem = "";
    }

    // on click of submit button this method will be executed 
    fromData(){
        let Amount = parseInt(this.OrderData.Price) * parseInt(this.OrderData.Quantity);
        this.OrderData.tAmount= Amount;
        // apex createOrder mthod is calling 
        createOrder({allData : this.OrderData, AccountId : this.recordId})
            .then(result => {
                alert (result );
            })
            .catch(error =>{
                alert ('Error');
                console.log(JSON.stringify(error));
            })
        // for refreshing all window 
        window.location.reload();
        this.reset();
    }
}