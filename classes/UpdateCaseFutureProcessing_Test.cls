/* Author SP@ForeFront
 * Purpose To Test a batch job to set cases whose future processing dates are today or earlier not to future processing
 * Last Modified 8/19/2014
 */
@isTest
public class UpdateCaseFutureProcessing_Test {
	
	static testMethod void testBatch() {
		
		PrepareData.populateCustomSettings();
		
		List<Case> cases = new List<Case>();
		for (Integer i=-10; i<10; i++) {
			Case c = new Case();
			c.Future_Processing_Date__c = Date.today().addDays(i);
			c.Future_Processing__c = true;
			c.New_Address__c = 'Address';
			cases.add(c);
		}
        insert cases;
		
		Test.startTest();
		String query ='SELECT Id, Future_Processing__c FROM Case WHERE ( Future_Processing__c = NULL OR Future_Processing_Date__c <= '+ ((Datetime)Date.today()).formatGMT('yyyy-MM-dd') +') AND Future_Processing__c = true';
		UpdateCaseFutureProcessing b = new UpdateCaseFutureProcessing(query); 
		Database.executebatch(b);
		Test.stopTest();
        b = new UpdateCaseFutureProcessing();
        
        List<Case> futureCases = new List<Case>();
        futureCases = [select Id from Case where Future_Processing__c = false];
        system.assertEquals(11, futureCases.size());
    }
}