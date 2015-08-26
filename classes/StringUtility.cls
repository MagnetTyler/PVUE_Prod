public class StringUtility {

    public static Boolean isValidId(String strId) {
        Boolean isValid = false;
        try {
            ID recId = (ID) strId;
            isValid = true;
        } catch( Exception e ) { }
        return isValid;
    }
}