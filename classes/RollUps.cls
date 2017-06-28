/**
 * @description Container for roll up operations
 * @author John Rogers
 * @date 02-11-2016
 */
public class RollUps {

    /**
     * @description Lazy roll up
     *     Roll up type: Sum
     *     Child type: RH_Order
     *     Parent type: Contact
     *     Lookup field: Contact_Sold_To
     *     Child field: Total_Order_Amount
     *     Parent field: Total_Business_Contact_Lifetime_Value
     *     Exclude all children orders that have Status = 'Cancelled'
     * @author John Rogers, Traction on Demand
     * @date 2016-02-09
     */
    public class ContactLifetimeValueRollUp extends LazyRollUp {

        public ContactLifetimeValueRollUp() {
            ruType = RollUp.RollUpType.SUM;
            lastImpactOnRollUpField = RH_Order__c.Last_Impact_On_Contact_Lifetime_Value__c;
            lookupField = RH_Order__c.Contact_Sold_To__c;
            childField = RH_Order__c.Total_Order_Amount__c;
            parentField = Contact.Total_Lifetime_Value__c;
            rollUpCriteriaClause = 'Total_Order_Amount__c != null AND Status__c != \'Cancelled\'';
        }

        /**
         * @description Returns true if the given child record fits the roll up criteria
         * @author John Rogers, Traction on Demand
         * @date   2016-02-09
         * @param  obj : The record
         * @return True if the child record fits the roll up criteria
         */
        public override Boolean fitsRollUpCriteria(SObject obj) {
            RH_Order__c order = (RH_Order__c) obj;
            return (order.Total_Order_Amount__c != null &&
                order.Status__c != 'Cancelled');
        }
    }

    /**
     * @description Lazy roll up
     *      Roll up type: Sum
     *      Child type: RH_Order
     *      Parent type: Account
     *      Lookup field: Account_Sold_To__c
     *      Child field: Total_Order_Amount
     *      Parent field: Total_Company_Lifetime_Value
     *      Exclude all children orders that have Status = 'Cancelled'
     * @author John Rogers, Traction on Demand
     * @date 2016-02-09
     */
    public class AccountLifetimeValueRollUp extends LazyRollUp {

        public AccountLifetimeValueRollUp() {
            ruType = RollUp.RollUpType.SUM;
            lastImpactOnRollUpField = RH_Order__c.Last_Impact_On_Account_Lifetime_Value__c;
            lookupField = RH_Order__c.Account_Sold_To__c;
            childField = RH_Order__c.Total_Order_Amount__c;
            parentField = Account.Total_Company_Lifetime_Value__c;
            rollUpCriteriaClause = 'Total_Order_Amount__c != null AND Status__c != \'Cancelled\'';
        }

        /**
         * @description Returns true if the given child record fits the roll up criteria
         * @author John Rogers, Traction on Demand
         * @date   2016-02-09
         * @param  obj : The record
         * @return True if the child record fits the roll up criteria
         */
        public override Boolean fitsRollUpCriteria(SObject obj) {
            RH_Order__c order = (RH_Order__c) obj;
            return (order.Total_Order_Amount__c != null &&
                order.Status__c != 'Cancelled');
        }
    }

}