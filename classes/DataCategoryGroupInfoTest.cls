@isTest
public class DataCategoryGroupInfoTest {

    static testMethod void DataCategoryGroupInfoUnitTest(){
        DataCategoryGroupInfo holdDataController = new DataCategoryGroupInfo('Test Name', 'Test Label', 'Description Test', new list<DataCategoryInfo>());
        
        system.assert( holdDataController.getDescription() == 'Description Test' );
        system.assert( holdDataController.getGroupStructure() != null );
        system.assert( holdDataController.getLabel() == 'Test Label' );
        system.assert( holdDataController.getName() == 'Test Name' );
    }
}