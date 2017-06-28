public with sharing class QuoteCreditCardEntryPageController {

	public  ApexPages.StandardController	con{get; set;}
	public String 							errorMessage {get; set;}
	public string							firstAmountToBeApplied {get; set;}
	public Boolean 							hasErrors {get; set;}
	public Quote_Clone__c					q {get; set;}
	public string							secondAmountToBeApplied {get; set;}
	public DateTime 						Today { get { return DateTime.now(); }}
	public decimal							totalAmountToBeApplied {get; set;} // A variable storing the total amount to be applied
	

	public QuoteCreditCardEntryPageController (ApexPages.StandardController stdController) {
		con = stdController;
		this.q = (Quote_Clone__c)stdController.getRecord();
		
		// Prepopulate the Amount to be applied
		firstAmountToBeApplied = String.valueOf(q.Contract_Total__c);
		secondAmountToBeApplied = '0';
		
		errorMessage = '';
		recalculateTotalAmount();
	}

	public void cancel() {

	}
	
	public void recalculateTotalAmount()
	{
		System.debug('Recalculating Total Amount.');
		try
		{
			Decimal d = Decimal.valueOf(firstAmountToBeApplied);
			this.totalAmountToBeApplied = (firstAmountToBeApplied == null ? 0 : Decimal.valueOf(firstAmountToBeApplied).setScale(2,System.RoundingMode.HALF_UP)) + (secondAmountToBeApplied == null ? 0 : Decimal.valueOf(secondAmountToBeApplied).setScale(2,System.RoundingMode.HALF_UP));
		} catch (Exception e) {
			hasErrors = true;
			errorMessage = e.getMessage();
			this.totalAmountToBeApplied = 0;
		}
		
		System.debug('Total Amount to be Applied = ' + this.totalAmountToBeApplied);
	}
	
	public PageReference ok()
	{
		return new PageReference('http://www.restorationhardware.com/contract-sales/index.jsp');
	}
	
	public void save() {
		System.debug('Saving the record.');
		System.debug('The record is ' + q);
		errorMessage = '';
		hasErrors = false;
		recalculateTotalAmount();
		if (q.Card_Holder_Name__c == NULL || q.Card_Holder_Name__c == '') {
				hasErrors = true;
				errorMessage += 'Card holder name is required.';
		}
		
		if (q.Card_Billing_Street__c == NULL || q.Card_Billing_Street__c == '') {
				hasErrors = true;
				errorMessage += '<br>Card billing street is required.';
		}

		if (q.Card_Billing_City__c == NULL || q.Card_Billing_City__c == '') {
				hasErrors = true;
				errorMessage += '<br>Card billing city is required.';
		} 

		if (q.Card_Billing_State__c == NULL || q.Card_Billing_State__c == '') {
				hasErrors = true;
				errorMessage += '<br>Card billing state is required.';
		}

		if (q.Card_Billing_Postal_Code__c == NULL || q.Card_Billing_Postal_Code__c == '') {
				hasErrors = true;
				errorMessage += '<br>Card billing zip/postal code is required.';
		}

		if (q.Card_Billing_Country__c == NULL || q.Card_Billing_Country__c == '') {
				hasErrors = true;
				errorMessage += '<br>Card billing country is required.';
		}

		if (q.Card_Number__c == NULL || q.Card_Number__c == '') {
				hasErrors = true;
				errorMessage += '<br>M/C, Visa, AMEX # is required.';
		}
		
		// If the card does not pass the Luhn Algorith or is the wrong number of digits
		// for the card type then add an error
		if (q.Card_Number__c != null && q.Card_Number__c != '')
		{
			if (!pattern.matches('[0-9]+',q.Card_Number__c) || (!isLuhnValid(q.Card_Number__c) || ((q.Card_Number__c.startsWith('4') || q.Card_Number__c.startsWith('5')) && q.Card_Number__c.length() != 16 && q.Card_Number__c.length() != 13)
				|| (q.Card_Number__c.startsWith('3') && q.Card_Number__c.length() != 15)) 
				&& q.Card_Number__c != NULL && q.Card_Number__c != '')
			{
				hasErrors = true;
				errorMessage += '<br>The credit card number is invalid.';
			}	
		} // END IF the card does not pass the Luhn Algorith or is the wrong number of digits
		// for the card type

		if (q.Card_Expiration_Month__c == NULL || q.Card_Expiration_Month__c == '') {
				hasErrors = true;
				errorMessage += '<br>Expiration month is required.';
		}

		if (q.Card_Expiration_Month__c != null && q.Card_Expiration_Month__c != '' && !pattern.matches('[0-9]+',q.Card_Expiration_Month__c)) {
				hasErrors = true;
				errorMessage += '<br>Expiration month must be numeric.';
		}

		if (q.Card_Expiration_Year__c == NULL || q.Card_Expiration_Year__c == '') {
				hasErrors = true;
				errorMessage += '<br>Expiration year is required.';
		}

		if (q.Card_Expiration_Year__c != null && q.Card_Expiration_Year__c != '' && !pattern.matches('[0-9]+',q.Card_Expiration_Year__c)) {
				hasErrors = true;
				errorMessage += '<br>Expiration year must be numeric.';
		}

		if(q.Card_Expiration_Year__c != null && q.Card_Expiration_Year__c != '' && 4!=q.Card_Expiration_Year__c.length()) {
				hasErrors = true;
				errorMessage += '<br>The Expiration Year must be in YYYY format. Please enter a valid Expiration Year.';
		}

		if (q.Card_Expiration_Year__c != null && pattern.matches('[0-9]+',q.Card_Expiration_Year__c) && q.Card_Expiration_Year__c != null && q.Card_Expiration_Year__c != '' && System.now().year()>integer.valueof(q.Card_Expiration_Year__c)) {
				hasErrors = true;
				errorMessage += '<br>The Expiration Date must be in the future. Please enter a valid Expiration Date.';
		}

		if (q.Card_Expiration_Month__c != null && q.Card_Expiration_Year__c != null)
		{
			if (pattern.matches('[0-9]+',q.Card_Expiration_Month__c) && pattern.matches('[0-9]+',q.Card_Expiration_Year__c) && (q.Card_Expiration_Year__c != null && q.Card_Expiration_Month__c != null && q.Card_Expiration_Year__c != '' && q.Card_Expiration_Month__c != '')
				&& (System.now().year()==integer.valueof(q.Card_Expiration_Year__c) &&
				System.now().month()>integer.valueof(q.Card_Expiration_Month__c)))
			{
				hasErrors = true;
				errorMessage += '<br>The Expiration Date must be in the future. Please enter a valid Expiration Date.';
			}
		}

		if (q.Card_Expiration_Month__c != null && pattern.matches('[0-9]+',q.Card_Expiration_Month__c) && q.Card_Expiration_Month__c != null && q.Card_Expiration_Month__c != '' && (integer.valueof(q.Card_Expiration_Month__c)>12 || integer.valueof(q.Card_Expiration_Month__c)<1))
		{
			hasErrors = true;
			errorMessage += '<br>The Expiration Month must be between 1 and 12. Please enter a valid Expiration Month.';
		}
		
		// Use a Try Catch to determine whether the value can be a valid decimal
		if (firstAmountToBeApplied == NULL || firstAmountToBeApplied == '0')
		{
			hasErrors = true;
			errorMessage += '<br>Please enter an amount to be applied for the first card.';
		} else {
			try
			{
				if(Decimal.valueOf(String.valueOf(firstAmountToBeApplied)) < 0)
				{
					hasErrors = true;
					errorMessage += '<br>Amount to be applied must be a number greater than zero.';
				}
				
			} catch (Exception e) {
				hasErrors = true;
				errorMessage += '<br>Amount to be applied must be a number greater than zero.';
			}
		}

		// If any of the second card field are populated then perform additional validation
		if ((q.Second_Card_Holder_Name__c != NULL && q.Second_Card_Holder_Name__c != '') 
			|| (q.Second_Bill_To_Street__c != NULL && q.Second_Bill_To_Street__c != '')
			|| (q.Second_Bill_To_City__c != NULL && q.Second_Bill_To_City__c != '')
			|| (q.Second_Bill_To_State__c != NULL && q.Second_Bill_To_State__c != '')
			|| (q.Second_Bill_To_Postal_Code__c != NULL && q.Second_Bill_To_Postal_Code__c != '')
			|| (q.Second_Bill_To_Country__c != NULL && q.Second_Bill_To_Country__c != '')
			|| (q.Second_Card_Number__c != NULL && q.Second_Card_Number__c != '')
			|| (q.Second_Card_Expiration_Month__c != NULL && q.Second_Card_Expiration_Month__c != '')
			|| (q.Second_Card_Expiration_Year__c != NULL && q.Second_Card_Expiration_Year__c != '')
			|| (secondAmountToBeApplied != NULL && secondAmountToBeApplied != '' && secondAmountToBeApplied != '0'))
		{
			// This is the validation that occurs if any of the second card number fields are populated
			if (q.Second_Card_Holder_Name__c == NULL || q.Second_Card_Holder_Name__c == '') {
				hasErrors = true;
				errorMessage += '<br>Card holder name is required if entering a second credit card.';
			}

			if (q.Second_Bill_To_Street__c == NULL || q.Second_Bill_To_Street__c == '') {
				hasErrors = true;
				errorMessage += '<br>Card billing street is required if entering a second credit card.';
			}

			if (q.Second_Bill_To_City__c == NULL || q.Second_Bill_To_City__c == '') {
				hasErrors = true;
				errorMessage += '<br>Card billing city is required if entering a second credit card.';
			}

			if (q.Second_Bill_To_State__c == NULL || q.Second_Bill_To_State__c == '') {
				hasErrors = true;
				errorMessage += '<br>Card billing state is required if entering a second credit card.';
			}

			if (q.Second_Bill_To_Postal_Code__c == NULL || q.Second_Bill_To_Postal_Code__c == '') {
				hasErrors = true;
				errorMessage += '<br>Card billing zip/postal code is required if entering a second credit card.';
			}

			if (q.Second_Bill_To_Country__c == NULL || q.Second_Bill_To_Country__c == '') {
				hasErrors = true;
				errorMessage += '<br>Card billing country is required if entering a second credit card.';
			}

			// If the card does not pass the Luhn Algorith or is the wrong number of digits
			// for the card type then add an error
			if (q.Second_Card_Number__c != null && q.Second_Card_Number__c != '')
			{
				if (!pattern.matches('[0-9]+',q.Second_Card_Number__c) || (!isLuhnValid(q.Second_Card_Number__c) || ((q.Second_Card_Number__c.startsWith('4') || q.Second_Card_Number__c.startsWith('5')) && q.Second_Card_Number__c.length() != 16 && q.Second_Card_Number__c.length() != 13)
					|| (q.Second_Card_Number__c.startsWith('3') && q.Second_Card_Number__c.length() != 15)) 
					&& q.Second_Card_Number__c != NULL && q.Second_Card_Number__c != '')
				{
					hasErrors = true;
					errorMessage += '<br>The second credit card number is invalid.';
				}
			} // END IF the card does not pass the Luhn Algorith or is the wrong number of digits
			  // for the card type

			if (q.Second_Card_Number__c == NULL || q.Second_Card_Number__c == '') {
				hasErrors = true;
				errorMessage += '<br>M/C, Visa, AMEX # is required if entering a second credit card.';
			}

			if (q.Second_Card_Expiration_Month__c == NULL || q.Second_Card_Expiration_Month__c == '') {
				hasErrors = true;
				errorMessage += '<br>Expiration month is required if entering a second credit card.';
			}

			if (q.Second_Card_Expiration_Month__c != null && q.Second_Card_Expiration_Month__c != '' & !pattern.matches('[0-9]+',q.Second_Card_Expiration_Month__c)) {
				hasErrors = true;
				errorMessage += '<br>Expiration month must be numeric.';
			}

			if (q.Second_Card_Expiration_Year__c == NULL || q.Second_Card_Expiration_Year__c == '') {
				hasErrors = true;
				errorMessage += '<br>Expiration year is required if entering a second credit card.';
			}

			if (q.Second_Card_Expiration_Year__c != null && q.Second_Card_Expiration_Year__c != '' && !pattern.matches('[0-9]+',q.Second_Card_Expiration_Year__c)) {
				hasErrors = true;
				errorMessage += '<br>Expiration year must be numeric.';
			}

			if (q.Second_Card_Expiration_Year__c != null)
			{
				if(pattern.matches('[0-9]+',q.Second_Card_Expiration_Year__c) && q.Second_Card_Expiration_Year__c != null && q.Second_Card_Expiration_Year__c != '' && 4!=q.Second_Card_Expiration_Year__c.length()) {
					hasErrors = true;
					errorMessage += '<br>The Expiration Year must be in YYYY format. Please enter a valid Expiration Year.';
				}
			}

			if (q.Second_Card_Expiration_Year__c != null && pattern.matches('[0-9]+',q.Second_Card_Expiration_Year__c) && q.Second_Card_Expiration_Year__c != null && q.Second_Card_Expiration_Year__c != '' && q.Second_Card_Expiration_Year__c != '' && System.now().year()>integer.valueof(q.Second_Card_Expiration_Year__c)) {
				hasErrors = true;
				errorMessage += '<br>The Expiration Date must be in the future. Please enter a valid Expiration Date.';
			}

			if (q.Second_Card_Expiration_Month__c != null && q.Second_Card_Expiration_Year__c != null)
			{
				if (pattern.matches('[0-9]+',q.Second_Card_Expiration_Month__c) && pattern.matches('[0-9]+',q.Second_Card_Expiration_Year__c) &&
					(q.Second_Card_Expiration_Year__c != '' && q.Second_Card_Expiration_Month__c != '')
					&& System.now().year()==integer.valueof(q.Second_Card_Expiration_Year__c) &&
					System.now().month()>integer.valueof(q.Second_Card_Expiration_Month__c))
				{
					hasErrors = true;
					errorMessage += '<br>The Expiration Date must be in the future. Please enter a valid Expiration Date.';
				}
			}

			if (q.Second_Card_Expiration_Month__c != null && pattern.matches('[0-9]+',q.Second_Card_Expiration_Month__c) && q.Second_Card_Expiration_Month__c != null && q.Second_Card_Expiration_Month__c != '' && (integer.valueof(q.Second_Card_Expiration_Month__c)>12 || integer.valueof(q.Second_Card_Expiration_Month__c)<1)) {
				hasErrors = true;
				errorMessage += '<br>The Expiration Month must be between 1 and 12. Please enter a valid Expiration Month.';
			}

			// Use a Try Catch to determine whether the value can be a valid decimal
			if (secondAmountToBeApplied == NULL || secondAmountToBeApplied == '0')
			{
				hasErrors = true;
				errorMessage += '<br>Amount to be applied is required if entering a second credit card.';
			} else {
				try
				{
					if(Decimal.valueOf(String.valueOf(secondAmountToBeApplied)) < 0)
					{
						hasErrors = true;
						errorMessage += '<br>Amount to be applied must be a number greater than zero.';
					}
				
				} catch (Exception e) {
					hasErrors = true;
					errorMessage += '<br>Amount to be applied must be a number greater than zero.';
				}
			}
				
		} // End of validation that occurs if any of the second card number fields are populated
		
		if (totalAmountToBeApplied > q.Contract_Total__c)
		{
			hasErrors = true;
			errorMessage += '<br>The amounts to be applied cannot be greater than the Contract Total.';
		} 
			
		if (q.Card_Number__c == q.Second_Card_Number__c &&
			q.Card_Number__c != null && q.Card_Number__c != '' &&
			q.Second_Card_Number__c != null && q.Second_Card_Number__c != '')
		{
			hasErrors = true;
			errorMessage += '<br>The two credit card numbers cannot be identical.';
		} 

		// Remove the leading break if it exists
		errorMessage = errorMessage.removeStartIgnoreCase('<br>'); 
		
		// If there is no error, then submit the record and save it.
		if (errorMessage.length() == 0)
		{
			q.Submitted_Date_Time__c = System.now();
			q.Submitted__c = true;
			q.Amount_To_Be_Applied__c = Decimal.valueOf(firstAmountToBeApplied).setScale(2,System.RoundingMode.HALF_UP);
			q.Second_Amount_To_Be_Applied__c = Decimal.valueOf(secondAmountToBeApplied).setScale(2, System.Roundingmode.HALF_UP);
			con.save();
		}
	}
	
	// Perform a Luhn Alorithm on the card number to determine whether it is valid
	public boolean isLuhnValid(String ccNum)
	{
		Integer	digit; // The digit being processed
		Integer	len = ccNum.length(); // The length of the ccNum
		Integer n; // A placeholder temporary number
		Integer	sum = 0; // The sum of the manipulated digits
		
		// Loop through the digits, adding either the digit or the manipulated digit
		// per the Luhn Algorithm
		for (integer i = 0; i < len; i++)
		{
			digit = Integer.valueOf(ccNum.substring(i, i+1));
			
			// If the digit is an alternating digit starting with the first for a
			// card with an even number of digits, or an alternating digit starting with
			// the second for a card with an odd number of digits, double it and add the 
			// resulting digits together - then add that to the running total. Otherwise, simply
			// add the digit to the running total.
			if (Math.mod(i , 2) == math.mod(len, 2))
			{
				// Multiply the digit by 2
				n = digit * 2;
				
				// This formula adds the result if it is less than ten or
				// the two digits added together if it is greater than ten
				sum += Integer.valueOf(Math.floor(n/10)) + Math.mod(n,10);
				
			} else {
				
				sum += digit;
				
			} // END IF - process the digit based on its position in the card number		
		}
		
		// Return whether or not the result is evenly divisible by ten,
		// which indicates that it is a potentially-valid number
		return (Math.mod(sum,10) == 0);
	}
}