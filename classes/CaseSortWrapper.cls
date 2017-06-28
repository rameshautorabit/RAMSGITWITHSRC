/***************************************************************************************
    CLIENT
        Restoration Hardware
            
    PURPOSE
		Wrapper Method to control the list sort order of cases

    TEST CLASS
        CaseSortWrapper_Test
        
    ENTRY POINTS
                        
    
    CHANGE LOG
        [[Version; Date; Author; Description]]
        v0.1; 2014/06/1; Carl Weiss/Forefront;
***************************************************************************************/
global class CaseSortWrapper Implements Comparable
{
	public Case c;

	public CaseSortWrapper(Case cs)
	 {
		c = cs;
	 }

	 global Integer compareTo(Object compareTo)
	 {
	 	CaseSortWrapper compareToCase = (CaseSortWrapper)compareTo;
	 	Integer returnVal = 0;
	 	//implement sort logic 
	 	

	 	return returnVal;

	 }
}