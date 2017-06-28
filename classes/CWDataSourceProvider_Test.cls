/* Test class for CW Data Source Provider */
  
@isTest
private class CWDataSourceProvider_Test {
    
    @isTest
   	static void testGetConnection() {
      DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();

      Test.startTest();
      CWDataSourceProvider provider = new CWDataSourceProvider();
      DataSource.Connection connection = provider.getConnection(connectionParams);
      Test.stopTest();
      system.assertNotEquals(null, connection, 'Message');
   }

   @isTest
   static void testGetAuthenticationCapabilities() {
      Test.startTest();
      CWDataSourceProvider provider = new CWDataSourceProvider();
      List<DataSource.AuthenticationCapability> capabilities = provider.getAuthenticationCapabilities();
      Test.stopTest();
      system.assertEquals(DataSource.AuthenticationCapability.ANONYMOUS, capabilities[0], 'Message');
   }

   @isTest
   static void testGetCapabilities() {
      Test.startTest();
      CWDataSourceProvider provider = new CWDataSourceProvider();
      List<DataSource.Capability> capabilities = provider.getCapabilities();
      Test.stopTest();
 
      system.assertEquals(DataSource.Capability.ROW_QUERY, capabilities[0], 'Message');
      //system.assertEquals(DataSource.Capability.ROW_CREATE, capabilities[1], 'Message');
      //system.assertEquals(DataSource.Capability.ROW_UPDATE, capabilities[2], 'Message');
      //system.assertEquals(DataSource.Capability.ROW_DELETE, capabilities[3], 'Message');
   } 
}