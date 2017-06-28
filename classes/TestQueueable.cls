public class TestQueueable implements Queueable {

	public Set<String> innerVariable = new Set<String>();

	public static TestQueueable doMe() {
		TestQueueable test = new TestQueueable();
		System.enqueueJob(test);

		return test;
	}

	public void execute(QueueableContext context) {
        //Do some action here
        //NOTHING
        system.debug('Set Size: ' + innerVariable.size());
	}
}