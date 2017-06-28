/***************************************************************************************
    PURPOSE
        Test Controller FormatDateTimeLocal

    ENTRY POINTS
        FormatDateTimeLocale class, VF component
    
    CHANGE LOG
        [[Version; Date; Author; Description]]
        v0.1; 2014/08/25; Carl Weiss/Forefront;
***************************************************************************************/
@isTest
public class FormatDateTimeLocal_Test {
    static testmethod void test_FormatDateTimeLocale()
    {
        FormatDateTimeLocale fdt = new FormatDateTimeLocale();
        fdt.dateTimeFormat = 'yyyy';
        fdt.dateTimeValue = DateTime.now();
        String test = fdt.getTimeZoneValue();
        System.debug(test);
        System.assertEquals(String.ValueOf(DateTime.now().year()), test, 'Value: ' + test + ' = CurrentYear: ' +  String.ValueOf(DateTime.now().year()));
        
        FormatDateTimeLocale fdt1 = new FormatDateTimeLocale();
        String test1 = fdt1.getTimeZoneValue();
        System.debug(test1);
        
        FormatDateTimeLocale fdt2 = new FormatDateTimeLocale();
        fdt2.dateTimeValue = DateTime.now();
        String test2 = fdt2.getTimeZoneValue();
        System.debug(test2);
    }
}