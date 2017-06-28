/**
 * @description Workaround the database's result classes not inheriting from a common class
 * @author  John Rogers, Traction on Demand
 * @date 27/10/2015
 * TODO-jdr move into trac-utils
 */
public class DatabaseResultHolder {


    // The results of the save
    Database.SaveResult saveResult;

    // The results of the upsert
    Database.UpsertResult upsertResult;

    // The results of the delete
    Database.DeleteResult deleteResult;

    public DatabaseResultHolder(Database.SaveResult saveResult) {
        this.saveResult = saveResult;
    }

    public DatabaseResultHolder(Database.UpsertResult upsertResult) {
        this.upsertResult = upsertResult;
    }

    public DatabaseResultHolder(Database.DeleteResult deleteResult) {
        this.deleteResult = deleteResult;
    }

    public static List<DatabaseResultHolder> createHolders(List<Database.SaveResult> results) {
        List<DatabaseResultHolder> holders = new List<DatabaseResultHolder>();
        for (Database.SaveResult result : results) {
            holders.add(new DatabaseResultHolder(result));
        }
        return holders;
    }

    public static List<DatabaseResultHolder> createHolders(List<Database.UpsertResult> results) {
        List<DatabaseResultHolder> holders = new List<DatabaseResultHolder>();
        for (Database.UpsertResult result : results) {
            holders.add(new DatabaseResultHolder(result));
        }
        return holders;
    }

    public static List<DatabaseResultHolder> createHolders(List<Database.DeleteResult> results) {
        List<DatabaseResultHolder> holders = new List<DatabaseResultHolder>();
        for (Database.DeleteResult result : results) {
            holders.add(new DatabaseResultHolder(result));
        }
        return holders;
    }
    
    public Boolean isSuccess() {
        if (saveResult != null) {
            return saveResult.isSuccess();
        } else if (upsertResult != null) {
            return upsertResult.isSuccess();
        } else {
            return deleteResult.isSuccess();
        }
    }

    public List<Database.Error> getErrors() {
        if (saveResult != null) {
            return saveResult.getErrors();
        } else if (upsertResult != null) {
            return upsertResult.getErrors();
        } else {
            return deleteResult.getErrors();
        }
    }
}