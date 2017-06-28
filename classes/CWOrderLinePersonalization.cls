global class CWOrderLinePersonalization {
	
	public String PersonalizationSequenceNumber {get; set;}
	public String PersonalizationStandardText {get;set;}
	public String PersonalizationType {get;set;}
	public String PersonalizationText {get;set;}
	
	public List<CWOrderLinePersonalization> CWOrderLinePersonalizations(Dom.XMLNode OrderLinePersonalizationItems){
   		
   		List<CWOrderLinePersonalization> orderLinePersonalizations = new List<CWOrderLinePersonalization>();
   		
   		if(OrderLinePersonalizationItems.getChildElement('Personalizations', null)!= null){
 
	   		Dom.XMLNode OrderLinePersonalizationElements = OrderLinePersonalizationItems.getChildElement('Personalizations', null);
	 
	   		for(Dom.XMLNode OrderLinePersonalizationElement : OrderLinePersonalizationElements.getChildElements()){
		   		if(OrderLinePersonalizationElement.getName() =='Personalization'){
		   			
		   			CWOrderLinePersonalization olp = new CWOrderLinePersonalization();
				
					olp.PersonalizationSequenceNumber = OrderLinePersonalizationElement.getChildElement('SequenceNumber',null).getText();
					System.debug('Personalization Sequence Number: ' + olp.PersonalizationSequenceNumber);
					olp.PersonalizationStandardText = OrderLinePersonalizationElement.getChildElement('StandardText', null).getText();
					System.debug('Personalization Standard Text: ' + olp.PersonalizationStandardText);
					olp.PersonalizationType = OrderLinePersonalizationElement.getChildElement('PersonalizationType', null).getText();
					System.debug('Personalization Type: ' + olp.PersonalizationType);
					olp.PersonalizationText = OrderLinePersonalizationElement.getChildElement('PersonalizationText', null).getText();
					System.debug('Personalization Text: ' + olp.PersonalizationText);
						
					orderLinePersonalizations.add(olp);
		   		}
	   		}
   		}
	return orderLinePersonalizations;
	}
}