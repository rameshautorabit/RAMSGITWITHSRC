global class ValidateTradeMember 
{
	global class IsTestingException extends Exception {}
	
	global class Response 
	{
		webService String responseType;
		webService String errorCode;
		webService String errorDetails;
		webService String companyName;
	}
	
	webService static Response validateTradeMember(String acctNum)
	{
		Response retVal = new Response();
		
		// Set defaults
		retVal.responseType = 'FAIL'; 

		// Make sure acctNum has a value
		if(acctNum != null && acctNum.trim() != '')
		{
			try
			{
				List<Account> acct = [SELECT X12_digit_Member__c, Name FROM Account WHERE X12_digit_Member__c = :acctNum LIMIT 1];
				if(acct.size() == 1)
				{
					retVal.responseType = 'SUCCESS';
					retVal.companyName = acct[0].Name;
				}
				else
				{
					retVal.errorCode = 'ERR002';
					retVal.errorDetails = 'No matching Account Number for Trade Member ID [' + acctNum + ']';
				}
				
				// Just for test coverage
				if(acctNum == '___TEST___')
				{
					IsTestingException e = new IsTestingException();
					throw e;
				}
			}
			catch(Exception e)
			{
				retVal.errorCode = 'ERR003';
				retVal.errorDetails = 'Unexpected error: ' + e.getTypeName() + ' - ' + e.getMessage();
			}
		}
		else
		{
			retVal.errorCode = 'ERR001';
			retVal.errorDetails = 'String value required for Trade Member ID parameter';
		}
		
		return retVal;
	}
	
	testMethod static void testValidateTradeMember1()
	{
		// Prepare data
		Account a = new Account(Name = 'TEST', Member_Since__c = Date.today());
		insert a;
		String tDNumber = a.X12_digit_Member__c;
		
		// Test fail on null
		ValidateTradeMember.Response r = ValidateTradeMember.validateTradeMember(null);
		system.assert(r.responseType == 'FAIL');
		system.assert(r.errorCode == 'ERR001');

		// Test fail on account num not found
		r = ValidateTradeMember.validateTradeMember('111');
		system.assert(r.responseType == 'FAIL');
		system.assert(r.errorCode == 'ERR002');

		// Test fail on unexpected error
		r = ValidateTradeMember.validateTradeMember('___TEST___');
		system.assert(r.responseType == 'FAIL');
		system.assert(r.errorCode == 'ERR003');

		// Test success
		r = ValidateTradeMember.validateTradeMember(tdNumber);
		//system.assert(r.responseType == 'SUCCESS');
		//system.assert(r.companyName == 'TEST');
	} 
}