/******************************************************************/
/*                                                                */
/*  This serves as a helper class for the organization.           */
/*                                                                */
/******************************************************************/

public without sharing class Helper {
	
	// Declare local variables
	private static Set<Id>	quoteIds = new Set<Id>();
	
	// Getter for the Quote Ids
	public static Set<Id> getQuoteIds()
	{
		return quoteIds;
	}
	
	// Setter for the Quote Ids
	public static void addQuoteId(id quoteId)
	{
		quoteIds.add(quoteId);
	}
	
	// Resetter for the Quote IDs for unit tests
	public static void resetQuoteIds()
	{
		quoteIds.clear();
	}

}