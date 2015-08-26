@isTest
public class DataCategoryInfoTest {
    
    static testMethod void DataCategoryInfoUnitTest(){
        DataCategoryInfo controller = new DataCategoryInfo( 'test name' , 'test label' , 'test displayname' );
        controller.getDisplayName();
        controller.getLabel();
        controller.getName();
    }

}