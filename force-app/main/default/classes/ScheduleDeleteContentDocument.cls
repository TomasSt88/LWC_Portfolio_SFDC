public with sharing class ScheduleDeleteContentDocument implements Schedulable {
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new BatchDeleteContentDocuments());
  }
}
