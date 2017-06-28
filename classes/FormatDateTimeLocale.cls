public class FormatDateTimeLocale {
    public DateTime dateTimeValue { get; set; }
    public String dateTimeFormat {get;set;}
    public String getTimeZoneValue() {
        if( dateTimeValue != null ) {
            String localeFormatDT = null;
            if (dateTimeFormat !=null)
            {
                 localeFormatDT = dateTimeValue.format(dateTimeFormat);
            }
            else
            {
                localeFormatDT = dateTimeValue.format();
            }
            return localeFormatDT;
        }
        return null;
    }
}