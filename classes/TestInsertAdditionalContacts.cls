public class TestInsertAdditionalContacts 
{
	public static testMethod void test()
	{
		Account a1 = new Account(Name = 'Test1', Segment__c = 'Architect', Member_Since__c = System.today());
		insert a1;
		Contact c1 = new Contact(AccountId = a1.Id,
									FirstName = 'Test1First', 
									LastName = 'Test1Last',
									Last_Name_Additional1__c = 'Test1LastAdd1' , 
									First_Name_Additional1__c = 'Test1FirstAdd1' ,
									Email_Additional1__c = 'Test1EmailAdd1@null.com' ,
									Phone_Additional1__c = '1234567890' ,
									Fax_Additional1__c = '1234567890' ,
									Title_Additional1__c = 'Test1titleAdd1',
									Last_Name_Additional2__c = 'Test1LastAdd2' , 
									First_Name_Additional2__c = 'Test1FirstAdd2' ,
									Email_Additional2__c = 'Test1EmailAdd2@null.com' ,
									Phone_Additional2__c = '1234567890' ,
									Fax_Additional2__c = '1234567890' ,
									Title_Additional2__c = 'Test1titleAdd2');
		insert c1;
		
		List<Contact> cs = [select Id, LastName from Contact where AccountId = :a1.Id
								ORDER BY LastName ASC];
		System.debug(cs.size());
		System.debug(cs);
		System.assert(cs.size() == 3); 
		System.assert(cs[0].LastName == 'Test1Last');
		System.assert(cs[1].LastName == 'Test1LastAdd1');
		System.assert(cs[2].LastName == 'Test1LastAdd2');
	}
}