/*****************************************************************/
/*                                                               */
/*  This Class syncs Quote Line Items with the Quote Line Item   */
/*  Clone custom object.                                         */
/*                                                               */
/*****************************************************************/

public class SyncQuoteLineItems {

// Declare Class variables
	Set<Id>										ids {get; set;} // A Set of Ids of source records
	public Map<Id, Id>							quoteCloneMap {get; set;} // A Map of Quotes to their Quote Clone records
	public List<Quote_Clone__c>					quoteClones {get; set;} // A List of Quote Clone objects for the Quote Line Items' Quotes
	public Set<Id>								quoteIds {get; set;} // The IDs of the Quotes for the line items
	public Map<Id, Quote_Line_Item_Clone__c>	quoteLineItemCloneRecordMap {get; set;}
	public List<Quote_Line_Item_Clone__c>		quoteLineItemCloneRecords {get; set;} // The records to be created/updated/deleted
	public Map<Id, QuoteLineItem>				quoteLineItemMap {get; set;} // A Map of the incoming records
	public String								triggerEvent {get; set;} // The event of the Trigger.
	
	public void syncQuoteLineItems(String triggerEvent, Map<Id, QuoteLineItem> recordMap)
	{
		this.quoteCloneMap = new Map<Id, Id>();
		this.quoteIds = new Set<Id>();
		this.quoteLineItemCloneRecordMap = new Map<Id, Quote_Line_Item_Clone__c>();
		this.quoteLineItemCloneRecords = new List<Quote_Line_Item_Clone__c>();
		this.quoteLineItemMap = recordMap;
		this.triggerEvent = triggerEvent;
		
		// Create a Set of Quote IDs
		for (QuoteLineItem qli : this.QuoteLineItemMap.values())
		{
			quoteIds.add(qli.QuoteId);
		}
		
		// Get the Quote Clone Records
		quoteClones = [SELECT Id, Source_Record__c FROM Quote_Clone__c WHERE Source_Record__c IN :quoteIds];
		
		// Create a Map of Quote Ids to their Quote Clone Ids
		for (Quote_Clone__c qc : quoteClones)
		{
			quoteCloneMap.put(qc.Source_Record__c, qc.Id);
		}
				
		// If the Trigger is an Insert or Undelete, create the new records
		if (triggerEvent == 'Insert' || triggerEvent == 'Undelete')
		{
			this.createNewRecords();
			System.debug('The ' + quoteLineItemCloneRecords.size() + ' Quote Line Item Clone Records are: ' + quoteLineItemCloneRecords);
			this.upsertRecords();
		}
		
		// If the Trigger is an update or delete
		if (triggerEvent == 'Update' || triggerEvent == 'Delete')
		{
			
			// Get the IDs of the Quote Line Items
			this.getIds();
System.debug('The IDs are ' + ids);
System.debug('The Quote Clone Line Items are ' + [SELECT Source_Record__c FROM Quote_Line_Item_Clone__c]);
			
			// Get the existing records
			this.quoteLineItemCloneRecords = new List<Quote_Line_Item_Clone__c>([SELECT Discount__c,
				ELC_Update__c, Expected_Delivery_Date__c, Fulfillment_Method__c, List_Price__c,
				MMU__c, Notes__c, Product__c, Products_w_Shipping_Fees__c, Quantity__c, Quote_Clone__c,
				Requires_Handling_Fees__c, Sales_Price__c, Source_Record__c, Total_Price__c 
				FROM Quote_Line_Item_Clone__c WHERE Source_Record__c IN :ids]);
			
			// If the Trigger is an update then process the updates, otherwise process the deletes.
			if (this.triggerEvent == 'Update')
			{
				this.processUpdates();
			} else {
				this.deleteRecords();
			}
			// END IF the Trigger is an update then process the updates, otherwise process the deletes.
			
		} // END IF the Trigger is an update or delete
	
	}

	public void createNewRecords()
	{
		for (QuoteLineItem qli : quoteLineItemMap.Values())
		{
			Quote_Line_Item_Clone__c qlic = new Quote_Line_Item_Clone__c();
			qlic = setQuoteLineItemCloneFields(qli, qlic);
			this.quoteLineItemCloneRecords.add(qlic);
		}
	}
	
	public void deleteRecords()
	{
		if (quoteLineItemCloneRecords.size() > 0)
		{
			Database.DeleteResult[] ldr = Database.Delete(quoteLineItemCloneRecords, false);
			for (Database.DeleteResult dr : ldr)
			{
				if (!dr.isSuccess())
				{
 					System.debug('Delete failed for record ' + dr.getId());
 					System.debug('Errors: ' + dr.getErrors());
				}
			}
		}
	}
	
	public void getIds()
	{
		this.Ids = this.quoteLineItemMap.keySet();
	}
	
	public void processUpdates()
	{
		// Declare local variables
		Quote_Line_Item_Clone__c quoteLineItemClone = new Quote_Line_Item_Clone__c();
		
		// Loop through the Quote Line Item Clone records making a map keyed off of Source Record
		for (Quote_Line_Item_Clone__c qlic : quoteLineItemCloneRecords)
		{
			this.quoteLineItemCloneRecordMap.put(qlic.Source_Record__c, qlic);
			
		} // END LOOP through the Quote Line Item Clone records making a map keyed off of Source Record
		
		// Loop through the Quote Line Item records, updating the cloned record if it exists
		for (QuoteLineItem qli : this.quoteLineItemMap.values())
		{
			// Reset the quoteLineItemClone variable
			quoteLineItemClone.clear();
			
			// If the QuoteLineItemClone Map contains a matching record then update it. If not, create it.
			if (quoteLineItemCloneRecordMap.containsKey(qli.Id))
			{
				quoteLineItemClone = quoteLineItemCloneRecordMap.get(qli.Id);
			} else {
				quoteLineItemClone = new Quote_Line_Item_Clone__c();
			}
			// END IF the QuoteLineItemClone Map contains a matching record then update it. If not, create it.
			
			// Synchronize the fields on the Quote
			quoteLineItemClone = setQuoteLineItemCloneFields(qli, quoteLineItemClone);
//			this.quoteLineItemCloneRecords.add(quoteLineItemClone.clone(true,true));
			quoteLineItemCloneRecordMap.put(qli.Id, quoteLineItemClone.clone(true,true));
		}
		
		// Get the updated records from the Map
		quoteLineItemCloneRecords = quoteLineItemCloneRecordMap.values();
		
		// Upsert the records
		this.upsertRecords();
	}
	
	public Quote_Line_Item_Clone__c setQuoteLineItemCloneFields(QuoteLineItem qli, Quote_Line_Item_Clone__c qlic)
	{
		// Set the Quote Line Item Clone fields
		qlic.Discount__c = qli.Discount_Percent__c;
		qlic.ELC_Update__c = qli.ELC_Update__c;
		qlic.Expected_Delivery_Date__c = qli.Delivery_Date__c;
		qlic.Fulfillment_Method__c = qli.Fulfillment_Method__c;
		qlic.List_Price__c = qli.ListPrice;
		qlic.MMU__c = qli.MMU__c;
		qlic.Notes__c = qli.Notes__c;
		qlic.Product__c = qli.ProductId__c;
		qlic.Products_w_Shipping_Fees__c = qli.Products_w_Shipping_Fees__c;
		qlic.Quantity__c = qli.Quantity;
		if (triggerEvent == 'Insert' || triggerEvent == 'Undelete')
		{
			qlic.Quote_Clone__c = quoteCloneMap.get(qli.QuoteId);
		}
		qlic.Requires_Handling_Fees__c = qli.Requires_Handling_Fees__c;
		qlic.Sales_Price__c = qli.UnitPrice;
		qlic.Source_Record__c = qli.id;
		qlic.Total_Price__c = qli.TotalPrice;
		
		return qlic;
	}
	
	public void upsertRecords()
	{
		if (quoteLineItemCloneRecords.size() > 0)
		{
			Database.UpsertResult[] lur = Database.Upsert(quoteLineItemCloneRecords, false);
			for (integer i = 0; i < lur.size(); i++)
			{
				if (!lur[i].isSuccess())
				{
 					System.debug('Upsert failed for Quote Line Item Clone record ' + quoteLineItemCloneRecords[i].Id);
 					System.debug('Errors: ' + lur[i].getErrors());
				}
			}
		}
	}
}