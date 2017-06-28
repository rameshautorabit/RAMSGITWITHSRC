/*****************************************************************/
/*                                                               */
/*  This Class syncs Quotes with the Quote Clone custom object.  */
/*                                                               */
/*****************************************************************/

public class SyncQuotes {
    
    // Declare Class variables
    String                                  alias {get; set;} // An alias/username generated for a new User
    Set<Id>                                 contactIds {get; set;} // A Set of Ids of source records
    private List<Contact>                   contacts {get; private set;} // The Contacts for which we will be creating portal users
    Set<Id>                                 contactsNeedingPortalUsers {get; set;} // A Set of IDs of Contacts needing Portal Users 
    private Map<Id, Id>                     contactUserMap {get; set;} // A Map of Contact Ids to their corresponding Portal User record Ids
    Database.DMLOptions                     dmo = new Database.DMLOptions(); // The options set for the new Portal Users to send an email upon creation
    private Set<Id>                         ids {get; set;} // A Set of Ids of Quotes corresponding to the Quote Clone Records
    User                                    newPortalUser {get; set;} // Holding variable for the new portal user
    List<User>                              newPortalUsers {get; set;} // The new Portal Users
    Set<Id>                                 ownerIds {get; set;} // A Set of IDs of 
    public Map<Id, Quote_Clone__c>          quoteCloneRecordMap {get; set;}
    public List<Quote_Clone__c>             quoteCloneRecords {get; set;} // The records to be created/updated/deleted
    private Map<Id, QuoteLineItem>          qlis {get; set;} // The QLIs for the Quotes that have been undeleted
    public Map<Id, Quote>                   quoteMap {get; set;} // A Map of the incoming records
    private String                          quoteStatus {get; private set;} // The status for which a Quote Clone needs a Portal User for the Contact
    public String                           triggerEvent {get; set;} // The event of the Trigger.
    private Set<Id>                         userIds {get; set;} // The IDs of the Portal Users taht were created
    private List<User>                      users {get; set;} // The Users corresponding to the Contacts
    private Map<Id, List<Id>>               contactId2quoteIds {get; set;} // A Map of Contact Id to Quote Ids
    private Boolean                         isCustomLoggingEnabled {get; set;}
    private Map<Id, Log__c>                 quoteId2customLog {get; set;}
    
    public void syncQuotes(String triggerEvent, Map<Id, Quote> recordMap)
    {
        this.contactIds = new Set<Id>();
        this.contactsNeedingPortalUsers = new Set<Id>();
        this.contactUserMap = new Map<Id, Id>();
        this.dmo.EmailHeader.triggerUserEmail = true;
        this.newPortalUsers = new List<User>();
        this.quoteCloneRecordMap = new Map<Id, Quote_Clone__c>();
        this.quoteCloneRecords = new List<Quote_Clone__c>();
        this.quoteMap = recordMap;
        System.debug('Set Quote Map to ' + this.quoteMap);
        this.triggerEvent = triggerEvent;
        System.debug('Set Trigger Event to ' + this.triggerEvent);
        this.userIds = new Set<Id>();
        
        Map<String, Application_Settings__c> appSettings = Application_Settings__c.getAll();
        this.isCustomLoggingEnabled = appSettings.get('EnableCustomLogging').Value_Text__c == 'True' ? true : false;
        if (isCustomLoggingEnabled) {
            this.contactId2quoteIds = new Map<Id, List<Id>>();
            this.quoteId2customLog = new Map<Id, Log__c>();
        }
        // Get/create the Portal User IDs
        getPortalUserIds();
        
        // If the Trigger is an Insert or Undelete, create the new records
        if (triggerEvent == 'Insert' || triggerEvent == 'Undelete')
        {
            this.createNewRecords();
            System.debug('The ' + quoteCloneRecords.size() + ' Quote Clone Records are: ' + quoteCloneRecords);
            this.upsertRecords();
            
            // If this is an undelete, we need to get all the undeleted QLIs and pass
            // them into their Class since the undelete event is not triggered for
            // QLIs when their Quote is undeleted
            if (triggerEvent == 'Undelete')
            {
                qlis = new Map<Id, QuoteLineItem>([
                    SELECT Id, Discount_Percent__c, ELC_Update__c,
                        Delivery_Date__c, Fulfillment_Method__c, ListPrice, MMU__c, Notes__c,
                        ProductId__c, Products_w_Shipping_Fees__c, Quantity, QuoteId,
                        Requires_Handling_Fees__c, UnitPrice, TotalPrice
                    FROM QuoteLineItem
                    WHERE QuoteId IN :this.QuoteMap.keySet()
                ]);
                
                SyncQuoteLineItems sqli = new SyncQuoteLineItems();
                System.debug('Calling SyncQuoteLineItems for ' + triggerEvent + ' with ' + qlis);
                sqli.syncQuoteLineItems(triggerEvent, qlis);
            }
        }
        
        // If the Trigger is an update or delete
        if (triggerEvent == 'Update' || triggerEvent == 'Delete')
        {
            
            // Get the IDs of the Quotes
            this.getIds();
            
            // Get the existing records
            this.quoteCloneRecords = new List<Quote_Clone__c>([SELECT BDL_Name__c, Bill_To_City__c,
                Bill_To_Country__c, Bill_To_Name__c, Bill_To_Postal_Code__c, Bill_To_State__c,
                Bill_To_Street__c, Blended_MMU__c, Contact__c, Contract_Total__c,Order_Total__c, Country_Shipping_To__c,
                Description__c, Expiration_Date__c, Freight_Fees__c, Handling_Fees__c, Handling_Fees_Y_N__c,
                Install_Date__c, Manual_Entry_of_S_H_Fees__c, Opportunity__c, Overall_Tax__c,
                Prepared_by__c, Products_With_Handling_Fees__c, Products_With_Shipping_Fees__c, Quoted_On__c,
                Quote_Status__c, Range_for_Handling_Fees__c, Shipping_City__c, Shipping_Contact__c, Shipping_Country__c,
                Shipping_Fees__c, Shipping_Postal_Code__c, Shipping_State__c, Shipping_Street_1__c,
                Shipping_Street_2__c, Ship_To_Name__c, Ship_To_Phone__c, Ship_To_State__c,
                Source_Record__c, Subtotal__c, Tax_Exempt__c, Tax_on_Handling__c, Tax_on_Merchandise__c,
                Tax_on_Shipping__c, Tax_Rate__c, Total__c, Total_Discount__c, Total_ELC__c, Total_List_Price__c, Total_Price__c, Quote_Name__c, Name
                FROM Quote_Clone__c WHERE Source_Record__c IN :ids]);
            
            // Write the records to the debug log
            System.debug('The ' + this.quoteCloneRecords.size() + ' selected Quote Clone Records are ' + quoteCloneRecords);
            
            // If the Trigger is an update then process the updates, otherwise process the deletes.
            if (this.triggerEvent == 'Update')
            {
                this.processUpdates();
            } else {
                this.deleteRecords();
            }
            
            // END IF the Trigger is an update then process the updates, otherwise process the deletes.
            
        } // END IF the Trigger is an update or delete
        if (this.isCustomLoggingEnabled && this.quoteId2customLog.size() > 0) {
            Database.insert(this.quoteId2customLog.values());
        }
    }

    public void createNewRecords()
    {
        for (Quote q : quoteMap.Values())
        {
            Quote_Clone__c qc = new Quote_Clone__c();
            qc = setQuoteCloneFields(true, q, qc);
            this.quoteCloneRecords.add(qc);
        }
    }
    
    public void deleteRecords()
    {        
        System.debug('Deleting records.');
        
        if (quoteCloneRecords.size() > 0)
        {
             //Only allow delete if payment has not already been made
             // // Loop through the Quote Clone records making a map keyed off of Source Record
            for (Quote_Clone__c qc : quoteCloneRecords)
            {
                Opportunity opp = [SELECT StageName from Opportunity WHERE id = :qc.Opportunity__c];        
                System.debug('Oppportunity Stage='+opp.StageName);
                
                if(opp.StageName == 'Closed Won'){
                    //Don't delete                    
                    //qc.addError('Quotes for which payment has been made cannot be deleted.');
                    system.debug(qc.id + ' was not deleted in SyncQuotes' );
                }
                else
                {
                    //Perform delete    
                    Database.DeleteResult dr = Database.Delete(qc, false);    
                    if (!dr.isSuccess())
                    {
                        System.debug('Delete failed for record ' + dr.getId());
                        System.debug('Errors: ' + dr.getErrors());
                    }
                     system.debug(qc.id + ' was deleted' );
                }
                
                this.quoteCloneRecordMap.put(qc.Source_Record__c, qc);
                
            } // END LOOP through the Quote Clone records making a map keyed off of Source Record
           
            
           /* System.debug('Deleting ' + quoteCloneRecords);
            Database.DeleteResult[] ldr = Database.Delete(quoteCloneRecords, false);
            for (Database.DeleteResult dr : ldr)
            {
                if (!dr.isSuccess())
                {
                    System.debug('Delete failed for record ' + dr.getId());
                    System.debug('Errors: ' + dr.getErrors());
                }
            }*/
        }
    }
    
    public void getPortalUserIds()
    {
        // Get the Status for which a Quote Clone needs a Portal User
        this.quoteStatus = Application_Settings__c.getInstance('QuoteCloneStatusToCreatePortalUser').Value_Text__c;
        
        // Loop through the Quote records getting the Contact Ids and those that need Portal Users
        for (Quote q : this.quoteMap.values())
        {
            // If there is a Contact then add its ID to the Set
            if (q.ContactId != null)
            {
                contactIds.add(q.contactId);
                
                System.debug('Status: ' + q.Status);
                // If the Quote is in the Status for a Portal User, add the Contact ID to the Set.
                if (q.Status == this.quoteStatus)
                {
                    this.contactsNeedingPortalUsers.add(q.ContactId);
                    if (this.isCustomLoggingEnabled) {
                        if (this.contactId2quoteIds.containsKey(q.ContactId)) {
                            List<Id> tempList = this.contactId2quoteIds.get(q.ContactId);
                            tempList.add(q.Id);
                            this.contactId2quoteIds.put(q.ContactId, tempList);
                        } else {
                            this.contactId2quoteIds.put(q.ContactId, new List<Id>{q.Id});
                        }
                    }
                }
                // END IF the Quote is in the Status for a Portal User, add the Contact ID to the Set.
                
            } // END IF there is a Contact then add its ID to the Set
            
        } // END LOOP through the Quote records getting the Contact Ids
        
        // If there are Contacts IDs then get the Portal Users corresponding to the Contacts
        if (contactIds.size() > 0)
        {
            users = [
                SELECT ContactId, Id
                FROM User
                WHERE IsActive = true AND ContactId IN :contactIds
            ];
            
            // Loop through the Users, removing the Contacts from the list of Contacts needing Portal Users
            if (users.size() > 0)
            {
                for (User u : users)
                {
                    this.contactsNeedingPortalUsers.remove(u.ContactId);
                    if (this.isCustomLoggingEnabled) {
                        this.contactId2quoteIds.remove(u.ContactId);
                    }
                }
            }
            
            // Create Portal Users for those that do not exist
            this.createPortalUsers();
            
            // If there are Users then create a Map from the Contacts to the Users
            if (users.size() > 0)
            {
                for (user u : users)
                {
                    contactUserMap.put(u.ContactId, u.Id);
                }
                
            } // END IF there are Users then create a Map from the Contacts to the Users
            
        }
         // END IF there are Contacts IDs then get the Portal Users corresponding to the Contacts
    }
    
    public void getIds()
    {
        this.Ids = this.quoteMap.keySet();
        System.debug('IDs set to ' + this.Ids);
    }
    
    public void processUpdates()
    {
        // Declare local variables
        Boolean isNew; // Indicates whether the Quote Clone being created is new or not
        Quote_Clone__c quoteClone = new Quote_Clone__c();
        
        // Loop through the Quote Clone records making a map keyed off of Source Record
        for (Quote_Clone__c qc : quoteCloneRecords)
        {
            this.quoteCloneRecordMap.put(qc.Source_Record__c, qc);
            
        } // END LOOP through the Quote Clone records making a map keyed off of Source Record
        
        // Loop through the Quote records, updating the record if it exists
        for (Quote q : this.quoteMap.values())
        {
            // Reset the quoteClone variable
            quoteClone.clear();
            
            // If the QuoteClone Map contains a matching record then update it. If not, create it.
            if (quoteCloneRecordMap.containsKey(q.Id))
            {
                quoteClone = quoteCloneRecordMap.get(q.Id);
                isNew = false;
            } else {
                quoteClone = new Quote_Clone__c();
                isNew = true;
            }
            // END IF the QuoteClone Map contains a matching record then update it. If not, create it.
            
            // Synchronize the fields on the Quote
            quoteClone = setQuoteCloneFields(isNew, q, quoteClone);
            this.quoteCloneRecordMap.put(q.Id, quoteClone);
        }
        
        // Set the upsert variable to the updated records
        quoteCloneRecords = this.quoteCloneRecordMap.values();
        
        // Upsert the records
        this.upsertRecords();
    }
    
    public Quote_Clone__c setQuoteCloneFields(Boolean isNew, Quote q, Quote_Clone__c qc)
    {
        String billToName;
        String billToStreet;
        
        billToName = (String.isBlank(q.Bill_To_First_Name__c)) ? '' : q.Bill_To_First_Name__c;
        if (String.isNotBlank(q.Bill_To_Last_Name__c)) {
        	if (String.isNotBlank(billToName)) {
        		billToName += ' ';
        	}
        	billToName += q.Bill_To_Last_Name__c;
        }
        
        billToStreet = (String.isBlank(q.Bill_To_Address_1__c)) ? '' : q.Bill_To_Address_1__c;
        if (String.isNotBlank(q.Bill_To_Address_2__c)) {
        	if (String.isNotBlank(billToStreet)) {
        		billToStreet += ', ';
        	}
        	billToStreet += q.Bill_To_Address_2__c;
        }
        
        // Set the Quote Clone fields
        qc.BDL_Name__c = q.BDL_Name__c;
        qc.Bill_To_City__c = q.Bill_To_City__c;
        qc.Bill_To_Country__c = q.Bill_To_Country_Code__c;
        qc.Bill_To_Name__c = billToName;
        qc.Bill_To_Postal_Code__c = q.Bill_To_Postal_Code__c;
        qc.Bill_To_State__c = q.Bill_To_State__c;
        qc.Bill_To_Street__c = billToStreet;
        qc.Blended_MMU__c = q.Blended_MMU__c;
        qc.Contact__c = q.ContactId;
        qc.Contract_Total__c = q.Order_Total__c;
        qc.Country_Shipping_To__c = q.Country__c;
        qc.Description__c = q.Description;
        qc.Expiration_Date__c = q.ExpirationDate;
        qc.Freight_Fees__c = q.Freight_Fees__c;
        qc.Handling_Fees__c = q.Handling_Fees__c;
        qc.Handling_Fees_Y_N__c = q.Handling_Fees_Y_N__c;
        qc.Install_Date__c = q.Install_Date__c;
        qc.Invoice__c = q.Invoice__c;//2014.08.02 Changed to populate with Invoice Number rather than Quote Number
        
        qc.Manual_Entry_of_S_H_Fees__c = q.Manual_Entry_of_S_H_fees__c;
        qc.Quote_Name__c = q.Name;
        qc.Name = q.Name.length() > 80 ? q.Name.substring(0, 79) : q.Name;
        
/*        // If the Trigger is an Insert then set the Opportunity Id, which is only writeable on Insert
        if (triggerEvent == 'Insert' || triggerEvent == 'Undelete')
        {
            qc.Opportunity__c = q.OpportunityId;
        } // END IF the Trigger is an Insert then set the Opportunity Id, which is only writeable on Insert
*/      

        // If the Quote Clone is new then set the Opportunity Id, which is only writeable on Insert
        if (isNew)
        {
            qc.Opportunity__c = q.OpportunityId;
            
        } // END IF the Quote Clone is new then set the Opportunity Id, which is only writeable on Insert
        
        qc.Opportunity_Name__c = q.Opportunity_Name__c;
        
        // Set the Owner for the Quote Clone, and email the Quote Owner
        // if there is no portal User
        if (q.contactId != null && q.Status == this.quoteStatus)
        {
            if (contactUserMap.containsKey(q.ContactId))
            {
                qc.OwnerId = contactUserMap.get(q.ContactId);
            } else {
                
                // The Contact does not have a Portal Account, so notify the Quote Creator 
                // That the Contact does not have a Portal Account if we have not already done so
                
                if (!Helper.getQuoteIds().contains(q.Id))
                {
                    // Populate the email message
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String body = 'The Contact for the ' + q.Name + ' Quote does not yet have a Portal account, and one failed to be created. \n\r';
                    body += 'Please notify your RH Salesforce administrator to create a Portal Account for the following Contact: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + q.ContactId;
                    mail.setHtmlBody(body);
                    mail.setPlainTextBody(body.remove('\n\r'));
                    mail.setCcAddresses(new List<String>{'marc.friedman@cadalys.com', 'tgibson@restorationhardware.com'});
                    mail.setSaveAsActivity(false);
                    mail.setSubject('ACTION REQUIRED: Portal Account Needed for Your Quote\'s Contact');
                    mail.setTargetObjectId(q.CreatedById);
                
                    // Send the email
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
                    // Add the Quote to the Helper class so that we do not resend an email in the same thread
                    Helper.addQuoteId(q.Id);
                }               
            }
            
        } // END IF - Set the Quote Clone owner or notify the Quote creator
          // that the Contact does not have a portal account
        
        qc.Overall_Tax__c = q.Total_Tax__c;
        qc.Prepared_by__c = q.Prepared_By__c;
        qc.Products_With_Handling_Fees__c = q.Products_with_Handling_Fees__c;
        qc.Products_With_Shipping_Fees__c = q.Products_with_Shipping_Fees__c;
        qc.Quoted_On__c = q.Quoted_On__c;
        qc.Quote_Status__c = q.Status;
        qc.Range_for_Handling_Fees__c = q.Range_for_Handling_Fees__c;
        qc.Shipping_City__c = q.Ship_City__c;
        qc.Shipping_Contact__c = q.Shipping_Contact__c;
        qc.Shipping_Country__c = q.Shipping_Country__c;
        qc.Shipping_Fees__c = q.Shipping_Fees__c;
        qc.Shipping_Postal_Code__c = q.Ship_Zip__c;
        qc.Shipping_State__c = q.Ship_State__c;
        qc.Shipping_Street_1__c = q.Ship_Street_1__c;
        qc.Shipping_Street_2__c = q.Ship_Street_2__c;
        qc.Ship_To_Name__c = q.ShippingName;
        qc.Ship_To_Phone__c = q.Shipping_Phone__c;
        qc.Ship_To_State__c = q.Ship_to_State__c;
        qc.Source_Record__c = q.Id;
        qc.Subtotal__c = q.Subtotal;
        qc.Tax_Exempt__c = q.Tax_Exempt__c;
        qc.Tax_on_Handling__c = q.Tax_on_Handling__c;
        qc.Tax_on_Merchandise__c = q.Tax_on_Merchandise__c;
        qc.Tax_on_Shipping__c = q.Tax_on_Shipping__c;
        qc.Tax_Rate__c = q.Tax_Rate__c;
        qc.Total__c = q.Total__c;
        qc.Total_Discount__c = q.Total_Discount__c;
        qc.Total_ELC__c = q.Total_ELC__c;
        qc.Total_List_Price__c = q.Total_List_Price__c;
        qc.Total_Price__c = q.TotalPrice;
        
        return qc;
    }
    
    public void upsertRecords()
    {   
        if (quoteCloneRecords.size() > 0)
        {
            if (this.isCustomLoggingEnabled) {
                for ( Quote_Clone__c qc : quoteCloneRecords) {
                    if (qc.Quote_Status__c == this.quoteStatus ) {
                        Log__c tempLog = new Log__c();
                        if (this.quoteId2customLog.containsKey(qc.Source_Record__c)) {
                            tempLog = this.quoteId2customLog.get(qc.Source_Record__c);
                            tempLog.Log_Message__c += '; ';
                            tempLog.Script_Event__c += '; SyncQuotes.upsertRecords';
                        } else {
                            tempLog.Log_Message__c = '';
                            tempLog.Target_Record_Id__c = qc.Source_Record__c;
                            tempLog.Script_Event__c = 'SyncQuotes.upsertRecords';
                        }
                        
                        if (this.triggerEvent == 'Undelete') {
                            tempLog.Log_Message__c += 'Attempt to send Email using workflow to User: ' + qc.OwnerId + '. Quote was undeleted.';
                        } else if (this.triggerEvent == 'Update') {
                            tempLog.Log_Message__c += 'Attempt to send Email using workflow to User: ' + qc.OwnerId + '. Quote was updated. (Only if Quote Status is changed.)';
                        } else if (this.triggerEvent == 'Insert') {
                            tempLog.Log_Message__c += 'Attempt to send Email using workflow to User: ' + qc.OwnerId + '. Quote was created';
                        }
                        this.quoteId2customLog.put(qc.Source_Record__c, tempLog);
                    }
                }
            }
            Database.UpsertResult[] lur = Database.Upsert(quoteCloneRecords, false);
//            for (Database.UpsertResult ur : lur)
            for (integer i = 0; i < lur.size(); i++)
            {
                if (!lur[i].isSuccess())
                {
                    System.debug('Upsert failed for record ' + quoteCloneRecords[i].Id);
                    System.debug('Errors: ' + lur[i].getErrors());
                    
                    Log__c tempLog = new Log__c();
                        
                    if (this.quoteId2customLog.containsKey(quoteCloneRecords[i].Source_Record__c)) {
                        tempLog = this.quoteId2customLog.get(quoteCloneRecords[i].Source_Record__c);
                        tempLog.Log_Message__c += 'Errors: ' + lur[i].getErrors();
                        tempLog.Script_Event__c += '; SyncQuotes.upsertRecords';
                    } else {
                        tempLog.Log_Message__c = 'Errors: ' + lur[i].getErrors();
                        tempLog.Target_Record_Id__c = quoteCloneRecords[i].Source_Record__c;
                        tempLog.Script_Event__c = 'SyncQuotes.upsertRecords';
                    }
                    
                    this.quoteId2customLog.put(quoteCloneRecords[i].Source_Record__c, tempLog);
                }
            }
        }
    }
    
    public void createPortalUsers()
    {
        
        // Custom Logging. Create Logs for creating new Portal Users
        if (this.isCustomLoggingEnabled) {
            for (Id contactId : contactId2quoteIds.keyset()) {
                for (Id quoteId : contactId2quoteIds.get(contactId)) {
                    this.quoteId2customLog.put(quoteId, new Log__c(Target_Record_Id__c = quoteId, Log_Message__c = 'Attempt to create new Portal User for Contact: ' + contactId, Script_Event__c = 'SyncQuotes.createPortalUsers'));
                }
            }
        }

        // Get the Contact Fields that we need to create portal users
        contacts = new List<Contact>([SELECT Email, FirstName, Id, LastName FROM Contact WHERE Id IN :this.contactsNeedingPortalUsers]);
        
        // Loop through the Contacts creating new Portal Users
        for (Contact c : contacts)
        {
            // Generate an alias/username for the user that is likely to be unique
            alias = (c.FirstName == null ? '' : c.FirstName.left(1)) + (c.LastName.length() < 4 ? c.LastName : c.LastName.left(4)) + String.valueOf(Math.round(Math.random() * 999));
            alias = alias.deleteWhitespace();
            
            // Add a new User to the list
            newPortalUser = PrepareData.createPortalUser(
                alias,
                c.id, 
                c.firstName,
                c.lastName,
                alias+'@rhportal.com');
            newPortalUser.Email = c.Email;
            
            newPortalUsers.add(newPortalUser.clone(false, true));
        }
        
        // Loop through the new Users setting the DMLOptions to send an email to the new Users
        for (User u : newPortalUsers)
        {
            u.setOptions(dmo);
        } 
        
        // Create the portal users
        List<Database.Saveresult> databaseInsert = UtilityFunctions.databaseInsert(newPortalUsers, false, 'SyncQuotes.createPortalUsers');
        System.debug('Created new Portal Users: ' + databaseInsert);
        
        // Clear the New Portsl Users array
        newPortalUsers.clear();
        
        // Loop through the Saveresult creating a set of IDs of the new Users
        for (Database.Saveresult sr : databaseInsert)
        {
            // If the record was successfully inserted then add the ID
            if (sr.isSuccess())
            {
                userIds.add(sr.getId());
                
            } // END IF the record was successfully inserted then add the ID
            
        } // END LOOP through the Saveresult creating a set of IDs of the new Users
        
        // Reselect the New Portal Users
        newPortalUsers = [
            SELECT ContactId, Id
            FROM User
            WHERE IsActive = true AND Id IN :userIds
        ];
        
        // Add the newPortalUsers to the User List
        users.addAll(newPortalUsers);
    }
}