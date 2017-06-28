/**
 *  SSVMatcher.cls
 *  @description	Matcher factory to contain and create different
 *               	matching implementations for consolidation of
 *               	Source System View records
 *  @author Ernesto Valdes, Traction On Demand
 */
public class SSVMatcher {

	/**
	 *  IMatcher
	 *  @description	Matching interface for Source System View consolidation
	 *  @author Ernesto Valdes, Traction On Demand
	 */
	public interface IMatcher {
		Boolean matches(SSVCleansed ssvc1, SSVCleansed ssvc2);
	}

	public abstract class Matcher implements IMatcher {

		public Boolean shouldMatch(SSVCleansed ssvc1, SSVCleansed ssvc2) {
			
			// Match only records of the same match type
			// Match only records within the same duplicate set
			return 	duplicateSetMatches(ssvc1, ssvc2) && matchTypeMatches(ssvc1, ssvc2);
		}

		public virtual Boolean matches(SSVCleansed ssvc1, SSVCleansed ssvc2) {
			return shouldMatch(ssvc1, ssvc2);
		}
	}

	/**
	 *  CompanyMatcher
	 *  @description	Implements matching criteria for APEX consolidation of
	 *               	source system view records representing companies
	 *  @author Ernesto Valdes, Traction On Demand
	 */
	public class CompanyMatcher extends Matcher {
		
		public override Boolean matches(SSVCleansed ssvc1, SSVCleansed ssvc2) {
			
			// match on
			// 1. Type - has to both be company
			// 2. duplicate set (matching name / address etc) 
			// OR
			// 3. Trade ID (if the trade ID matches then not care about the name / address)
			
			return matchTypeMatches(ssvc1, ssvc2) && (
				(noTradeToMatch(ssvc1, ssvc2) && duplicateSetMatches(ssvc1, ssvc2)) || tradeNumberMatches(ssvc1, ssvc2)
			);
		}
				
	}

	/**
	 *  PersonMatcher
	 *  @description	Implements matching criteria for APEX consolidation of
	 *               	source system view records representing individial people
	 *  @author Ernesto Valdes, Traction On Demand
	 */
	public class PersonMatcher extends Matcher {

		public override Boolean matches(SSVCleansed ssvc1, SSVCleansed ssvc2) {
			
			if (shouldMatch(ssvc1, ssvc2) && nameMatches(ssvc1, ssvc2)) {

				return (emailsNotNull(ssvc1, ssvc2) && emailMatches(ssvc1, ssvc2)) || addressMatches(ssvc1, ssvc2);

			}
			 
			return false;

		}
	}

	/**
	 *  ContactMatcher
	 *  @description	Implements matching criteria for APEX consolidation of
	 *               	source system view records representing contacts at companies
	 *  @author Ernesto Valdes, Traction On Demand
	 */
	public class ContactMatcher extends Matcher {

		public override Boolean matches(SSVCleansed ssvc1, SSVCleansed ssvc2) {

			if (shouldMatch(ssvc1, ssvc2) &&
				nameMatches(ssvc1, ssvc2)) {

				if (
						(
							!parentDuplicateSetIdsNull(ssvc1, ssvc2) && 
						 	parentDuplicateSetMatches(ssvc1, ssvc2)
						) 
						||
						(	
							parentDuplicateSetIdsNull(ssvc1, ssvc2) && 
							companyMatches(ssvc1, ssvc2) &&
							addressMatches(ssvc1, ssvc2)
						)
						||
							tradeNumberMatches(ssvc1, ssvc2)
						||
							parentAccountMatches(ssvc1, ssvc2)
					) {

					return (emailsNotNull(ssvc1, ssvc2) && emailMatches(ssvc1, ssvc2)) || addressMatches(ssvc1, ssvc2);

				} 

			} 
			
			return false;
		}
	}

	/**
	 *  NoMatcher
	 *  @description	Implements matching criteria for APEX consolidation of
	 *               	source system view records that have no match type
	 *  @author Ernesto Valdes, Traction On Demand
	 */
	public class NoMatcher extends Matcher {}

	/**
	 *  @description Factory method, creates the requested type of consolidation matcher
	 *  @author 	 Ernesto Valdes, Traction on Demand.
	 *  @date        2016-02-01
	 *  @param       matchType     The requested matcher type
	 *  @return                    An instance of requested matcher
	 *                             or a default matcher if request is invalid
	 */
	public static IMatcher createMatcher(String matchType) {

		if (matchType == 'Person') return new PersonMatcher();
		else if (matchType == 'Company') return new CompanyMatcher();
		else if (matchType == 'Contact') return new ContactMatcher();
		else return new NoMatcher();
	}

	public static Boolean matchTypeMatches(SSVCleansed ssvc1, SSVCleansed ssvc2) {
		return 	ssvc1.matchType == ssvc2.matchType;
	}

	public static Boolean parentDuplicateSetIdsNull(SSVCleansed ssvc1, SSVCleansed ssvc2) {
		return 	ssvc1.companyDuplicateSetId == null && 
				ssvc2.companyDuplicateSetId == null;
	}

	public static Boolean duplicateSetMatches(SSVCleansed ssvc1, SSVCleansed ssvc2) {
		return 	ssvc1.duplicateSetId == ssvc2.duplicateSetId;
	}

	public static Boolean parentDuplicateSetMatches(SSVCleansed ssvc1, SSVCleansed ssvc2) {
		return 	ssvc1.companyDuplicateSetId == ssvc2.companyDuplicateSetId;
	}

	public static Boolean nameMatches(SSVCleansed ssvc1, SSVCleansed ssvc2) {
		return 	ssvc1.firstNameMatchKey == ssvc2.firstNameMatchKey &&
				ssvc1.lastNameMatchKey == ssvc2.lastNameMatchKey;
	}
	
	public static Boolean parentAccountMatches(SSVCleansed ssvc1, SSVCleansed ssvc2) {
		return (ssvc1.accountId != null && ssvc1.accountId == ssvc2.accountId) || (ssvc1.companyAccountId != null && ssvc1.companyAccountId == ssvc2.companyAccountId);
	}
	
	public static Boolean noTradeToMatch(SSVCleansed ssvc1, SSVCleansed ssvc2) {
		return String.isEmpty(ssvc1.tradeID) || String.isEmpty(ssvc2.tradeID); 
	}
	
	public static Boolean tradeNumberMatches(SSVCleansed ssvc1, SSVCleansed ssvc2) {
		return 
			!String.isEmpty(ssvc1.tradeID) 
			&& 
			!String.isEmpty(ssvc2.tradeID)
			&&
			ssvc1.tradeID.compareTo(ssvc2.tradeID) == 0;
	}

	public static Boolean companyMatches(SSVCleansed ssvc1, SSVCleansed ssvc2) {
		return 	ssvc1.companyNameMatchKey == ssvc2.companyNameMatchKey;
	}

	public static Boolean emailsNull(SSVCleansed ssvc1, SSVCleansed ssvc2) {
		return 	ssvc1.emailMatchKey == null && 
				ssvc2.emailMatchKey == null;
	}

	public static Boolean emailsNotNull(SSVCleansed ssvc1, SSVCleansed ssvc2) {
		return 	ssvc1.emailMatchKey != null && 
				ssvc2.emailMatchKey != null;
	}

	public static Boolean emailMatches(SSVCleansed ssvc1, SSVCleansed ssvc2) {
		return 	ssvc1.emailMatchKey == ssvc2.emailMatchKey;
	}
	
	public static Boolean addressMatches(SSVCleansed ssvc1, SSVCleansed ssvc2) {
		return 	ssvc1.addressMatchKey != null && 
				ssvc2.addressMatchKey != null &&
				ssvc1.addressMatchKey == ssvc2.addressMatchKey;
	}
}