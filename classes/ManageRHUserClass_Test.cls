@isTest(SeeAllData=true)
private class ManageRHUserClass_Test 
{
  /*  static testMethod void myUnitTest() 
    {
        //Create Users
        Profile p=[SELECT Id, Name FROM Profile WHERE Name='CSC Backend Associate'];
        List<User> lstOfUsers =new List<User>();
        //Create User 1 with department 'Accommodations'
        User u1 = new User(alias = 'tuser1', 
                        email='standarduser1@test.com', 
                        emailencodingkey='UTF-8', 
                        lastname='User',
                        firstname='First',
                        languagelocalekey='en_US', 
                        localesidkey='en_US', 
                        profileid = p.Id, 
                        timezonesidkey='America/Los_Angeles', 
                        username='standarduserFF1@testorg.com',
                        department='Accommodations',
                        isActive=true
                        );
        //insert u1;
        lstOfUsers.add(u1);
		
        //Create User 2 with department 'Order Inquiries'
        User u2 = new User(alias = 'tuser2', 
                        email='standarduser2@test.com', 
                        emailencodingkey='UTF-8', 
                        lastname='User',
                        firstname='Second',
                        languagelocalekey='en_US', 
                        localesidkey='en_US', 
                        profileid = p.Id, 
                        timezonesidkey='America/Los_Angeles', 
                        username='standarduserFF2@testorg.com',
                        department='Order Inquiries',
                        isActive=true
                        );
        //insert u2;
		lstOfUsers.add(u2);
		
		//Create User 3 with department 'Accommodations'
        User u3 = new User(alias = 'tuser3', 
                        email='standarduser3@test.com', 
                        emailencodingkey='UTF-8', 
                        lastname='User',
                        firstname='Third',
                        languagelocalekey='en_US', 
                        localesidkey='en_US', 
                        profileid = p.Id, 
                        timezonesidkey='America/Los_Angeles', 
                        username='standarduserFF3@testorg.com',
                        department='Accommodations',
                        isActive=false
                        );
        //insert u3;
		lstOfUsers.add(u3);
		
		//Create User 3 with department 'Accommodations'
        User u4 = new User(alias = 'tuser4', 
                        email='standarduser4@test.com', 
                        emailencodingkey='UTF-8', 
                        lastname='User',
                        firstname='Fourth',
                        languagelocalekey='en_US', 
                        localesidkey='en_US', 
                        profileid = p.Id, 
                        timezonesidkey='America/Los_Angeles', 
                        username='standarduserFF4@testorg.com',
                        department='Test Dept',
                        isActive=false
                        );
        //insert u4;
		lstOfUsers.add(u4);
		
		insert lstOfUsers;
		
		User thisUser=[SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
		System.runAs(thisUser) 
		{
	        //Deactivate User 
			u2.IsActive=false;
			update u2;
		}
        
   }*/
}