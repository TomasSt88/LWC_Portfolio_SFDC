global class ScheduleDeleteContentDocument implements Schedulable {
    global void execute(SchedulableContext SC) {
        BatchDeleteContentDocuments b = new BatchDeleteContentDocuments();
        Database.executeBatch(b);
    }
}