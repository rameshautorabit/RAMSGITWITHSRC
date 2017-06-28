trigger DuplicateRecordItemTrigger on DuplicateRecordItem (after insert) {

	if (trigger.isAfter)
		if (trigger.isInsert) 
			update new SSVDuplicateDetector(trigger.new).stampDuplicates();
}