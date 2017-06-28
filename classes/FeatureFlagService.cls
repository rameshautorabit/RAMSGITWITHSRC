public class FeatureFlagService {

    /*
     * Helper methods to show status of feature flags
     */

    public static Boolean isMdmAddressFeatureActive() {
        return isFeatureFlagSet(Feature_Flags__c.MDM_Address_Feature__c);
    }

    public static Boolean isMdmMergeFeatureActive() {
        return isFeatureFlagSet(Feature_Flags__c.MDM_Merge_feature__c);
    }

    public static Boolean isSinglePaneAddressFeatureActive() {
        return isFeatureFlagSet(Feature_Flags__c.Single_Pane_Address_Feature__c);
    }

    public static Boolean isSinglePaneMergeFeatureActive() {
        return isFeatureFlagSet(Feature_Flags__c.Single_Pane_Merge_Feature__c);
    }
    
    public static Boolean isSinglePaneCCLUFeatureActive() {
    	return isFeatureFlagSet(Feature_Flags__c.Single_Pane_CCLU_Feature__c);	
    }
    
    public static Boolean isSinglePaneAddressCleansingFeatureActive() {
    	return isFeatureFlagSet(Feature_Flags__c.Single_Pane_Address_Cleansing_Feature__c);	
    }    
    
    /*
     * Generic method that shows the state of various feature
     * flags
     */    

    private static Boolean isFeatureFlagSet(SObjectField field) {
	    Feature_Flags__c profileVal = Feature_Flags__c.getInstance(UserInfo.getProfileId());
        Object orgLevelValue = Feature_Flags__c.getOrgDefaults().get(field);
        Object profileLevelValue = profileVal != null ? profileVal.get(field) : false;
        return Boolean.valueOf(orgLevelValue == null ? false : orgLevelValue) || Boolean.valueOf(profileLevelValue == null ? false : profileLevelValue);
    }
        
}