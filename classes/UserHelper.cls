/**
 * @description Helper class for the user object
 * @author John Rogers, Traction on Demand
 * @date 2016-02-25
 */
public class UserHelper {

    public static Map<Id, User> userMap = new Map<Id, User>();

    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-02-25
     * @param       userId : The user ID
     * @return True if the current user has the 'Single_View_of_Customer_Process_User__c' flag set
     */
    public static Boolean isIntegrationUser() {
        return isIntegrationUser(UserInfo.getUserId());
    }
	
    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-02-25
     * @param       userId : The user ID
     * @return True if the given user has the 'Single_View_of_Customer_Process_User__c' flag set
     */
    public static Boolean isIntegrationUser(Id userId) {
        User u = userMap.get(userId);
        if (u == null) {
            List<User> users = [
                SELECT Single_View_of_Customer_Process_User__c 
                FROM User
                WHERE Id = :userId
            ];
            if (users.isEmpty()) {
                return false;
            } else {
                u = users[0];
                userMap.put(userId, u);
            }
        }
        return u.Single_View_of_Customer_Process_User__c;
    }
}