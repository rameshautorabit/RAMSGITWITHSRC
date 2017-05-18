global class SchedulerClassTest Implements Schedulable {
     
     static Integer i = 0;
     
     global void execute(SchedulableContext sc)
        {
            setToMiko();
        }

        public void setToMiko()
        {
            List<Sche__c> listSche = new List<Sche__c>();
            listSche = [SELECT ID,Sam__c FROM Sche__c];

            for(Sche__c she : listSche)
            {
                i++;
                she.Sam__c = 'Sample Test' + i;
            }

            update listSche;
            System.debug('Scheduler function: ' + [SELECT ID,Sam__c FROM Sche__c]);
        }

}