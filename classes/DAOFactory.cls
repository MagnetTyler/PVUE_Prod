public with sharing class DAOFactory {

    public static Boolean TEST_OVERRIDE = false;
    public Boolean IsRunningAsTest {
        get {
            if (IsRunningAsTest == null) {
                IsRunningAsTest = TEST_OVERRIDE || Test.isRunningTest();
            }
            return IsRunningAsTest;
        }
        set;
    }

    public ESBDAO getESBDao(){
        ESBDAO result = IsRunningAsTest ? new ESBMockDAO() : new ESBDAO();
        return result;
    }

}