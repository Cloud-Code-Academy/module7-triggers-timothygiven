trigger AccountTrigger on Account (before insert, after insert) {
        // Before Insert Logic
    if(Trigger.isBefore && Trigger.isInsert){
        for(Account acc : Trigger.new){
        // Set the Account Type to 'Prospect' if it's null
        if(acc.Type == null){
            acc.Type = 'Prospect';
        }
        
 	    // Copy Shipping Address to Billing Address if Shipping fields are not empty
 	    if(acc.ShippingStreet != null || 
           acc.ShippingCity != null ||
           acc.ShippingState != null ||
           acc.ShippingPostalCode != null ||
           acc.ShippingCountry != null){
                acc.BillingStreet = acc.ShippingStreet;
                acc.BillingCity = acc.ShippingCity;
                acc.BillingState = acc.ShippingState;
                acc.BillingPostalCode = acc.ShippingPostalCode;
                acc.BillingCountry = acc.ShippingCountry;
        }
        
        //Update rating to 'Hot' if Fax, Website and Phone all have values.
        if(acc.Phone != null && acc.Fax != null && acc.Website != null){
            acc.Rating = 'Hot';
   		 }
      }
    }
       // After Insert Logic
    if(Trigger.isAfter && Trigger.isInsert){
        // List to store new Contacts
        List<Contact> contactsToInsert = new List<Contact>();
        for(Account acc : Trigger.new){
         // Create a default Contact for the Account
         contactsToInsert.add(new Contact(
         	LastName = 'DefaultContact',
 			Email = 'default@email.com',
            AccountId = acc.Id // Associate Contact with the Account
         ));
    }
        // Insert all collected Contacts after the loop
    	if(!contactsToInsert.isEmpty()){
        insert contactsToInsert;
    }
  }
}