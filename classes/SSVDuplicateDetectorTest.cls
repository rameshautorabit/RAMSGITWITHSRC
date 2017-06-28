@isTest
private class SSVDuplicateDetectorTest {

	@isTest static void stampDuplicateSet() {

		// Given
		// Create new ssv record
		Source_System_View__c testSSV = TestDataFactory.createSSV(true);

		// Create duplicate set
		DuplicateRule testDuplicateRule = [
			SELECT Id
			FROM DuplicateRule
			WHERE SobjectType = 'Source_System_View__c'
			LIMIT 1
		];
		DuplicateRecordSet testDuplicateSet = new DuplicateRecordSet(
			DuplicateRuleId = testDuplicateRule.Id
			);
		insert testDuplicateSet;

		testDuplicateSet = [
			SELECT Id, Duplicate_Record_Set_Number__c
			FROM DuplicateRecordSet
			WHERE Id = :testDuplicateSet.Id
		];

		// When
		// Create duplicate record item
		DuplicateRecordItem testDuplicateItem = new DuplicateRecordItem(
			DuplicateRecordSetId = testDuplicateSet.Id,
			RecordId = testSSV.Id
			);
		insert testDuplicateItem;

		// Then
		testSSV = [
			SELECT Id, Duplicate_Set_ID__c, Stewardship_Review_Required__c, 
					Stewardship_Review_Description__c
			FROM Source_System_View__c
			WHERE Id = :testSSV.Id
		];
		system.assertEquals(testDuplicateSet.Duplicate_Record_Set_Number__c, testSSV.Duplicate_Set_ID__c);
	}

	@isTest static void flagForStewardshipOnChange() {

		// Given
		// Create new ssv record
		Source_System_View__c testSSV1 = TestDataFactory.createSSV(true);
		Source_System_View__c testSSV2 = TestDataFactory.createSSV(true);

		// Get existing duplicate rule
		DuplicateRule testDuplicateRule = [
			SELECT Id
			FROM DuplicateRule
			WHERE SobjectType = 'Source_System_View__c'
			LIMIT 1
		];

		// Create duplicate sets
		DuplicateRecordSet testDuplicateSet1 = new DuplicateRecordSet(
			DuplicateRuleId = testDuplicateRule.Id
			);
		DuplicateRecordSet testDuplicateSet2 = new DuplicateRecordSet(
			DuplicateRuleId = testDuplicateRule.Id
			);
		insert new List<DuplicateRecordSet>{testDuplicateSet1, testDuplicateSet2};

		testDuplicateSet1 = [
			SELECT Id, Duplicate_Record_Set_Number__c
			FROM DuplicateRecordSet
			WHERE Id = :testDuplicateSet1.Id
		];
		testDuplicateSet2 = [
			SELECT Id, Duplicate_Record_Set_Number__c
			FROM DuplicateRecordSet
			WHERE Id = :testDuplicateSet2.Id
		];

		// When
		// Create duplicate record items
		DuplicateRecordItem testDuplicateItem1 = new DuplicateRecordItem(
			DuplicateRecordSetId = testDuplicateSet1.Id,
			RecordId = testSSV1.Id
			);
		DuplicateRecordItem testDuplicateItem2 = new DuplicateRecordItem(
			DuplicateRecordSetId = testDuplicateSet1.Id,
			RecordId = testSSV2.Id
			);
		insert new List<DuplicateRecordItem>{testDuplicateItem1, testDuplicateItem2};

		// Then
		// Verify that duplicate record items were stamped
		testSSV1 = [
			SELECT Id, Duplicate_Set_ID__c, Stewardship_Review_Required__c, 
					Stewardship_Review_Description__c
			FROM Source_System_View__c
			WHERE Id = :testSSV1.Id
		];
		system.assertEquals(testDuplicateSet1.Duplicate_Record_Set_Number__c, testSSV1.Duplicate_Set_ID__c);
		system.assertEquals(false, testSSV1.Stewardship_Review_Required__c);
		system.assertEquals(null, testSSV1.Stewardship_Review_Description__c);

		testSSV2 = [
			SELECT Id, Duplicate_Set_ID__c, Stewardship_Review_Required__c, 
					Stewardship_Review_Description__c
			FROM Source_System_View__c
			WHERE Id = :testSSV2.Id
		];
		system.assertEquals(testDuplicateSet1.Duplicate_Record_Set_Number__c, testSSV2.Duplicate_Set_ID__c);
		system.assertEquals(false, testSSV2.Stewardship_Review_Required__c);
		system.assertEquals(null, testSSV2.Stewardship_Review_Description__c);

		// Create duplicate record item linking record to second duplicate set
		DuplicateRecordItem testDuplicateItem3 = new DuplicateRecordItem(
			DuplicateRecordSetId = testDuplicateSet2.Id,
			RecordId = testSSV1.Id
			);
		// Create duplicate record item linking record to second duplicate set
		DuplicateRecordItem testDuplicateItem4 = new DuplicateRecordItem(
			DuplicateRecordSetId = testDuplicateSet2.Id,
			RecordId = testSSV2.Id
			);
		insert new List<DuplicateRecordItem>{testDuplicateItem3, testDuplicateItem4};

		// Then
		// Verify that record was not flagged for stewardship review
		testSSV1 = [
			SELECT Id, Duplicate_Set_ID__c, Stewardship_Review_Required__c, 
					Stewardship_Review_Description__c
			FROM Source_System_View__c
			WHERE Id = :testSSV1.Id
		];
		system.assertEquals(testDuplicateSet2.Duplicate_Record_Set_Number__c, testSSV1.Duplicate_Set_ID__c);
		system.assertEquals(false, testSSV1.Stewardship_Review_Required__c);
		system.assertEquals(null, testSSV1.Stewardship_Review_Description__c);

		// Verify that record was not flagged for stewardship review
		testSSV2 = [
			SELECT Id, Duplicate_Set_ID__c, Stewardship_Review_Required__c, 
					Stewardship_Review_Description__c
			FROM Source_System_View__c
			WHERE Id = :testSSV2.Id
		];
		system.assertEquals(testDuplicateSet2.Duplicate_Record_Set_Number__c, testSSV2.Duplicate_Set_ID__c);
		system.assertEquals(false, testSSV2.Stewardship_Review_Required__c);
		system.assertEquals(null, testSSV2.Stewardship_Review_Description__c);
	}

	@isTest static void dontflagForStewardshipOnPartialChange() {

		// Given
		// Create new ssv record
		Source_System_View__c testSSV1 = TestDataFactory.createSSV(true);
		Source_System_View__c testSSV2 = TestDataFactory.createSSV(true);

		// Get existing duplicate rule
		DuplicateRule testDuplicateRule = [
			SELECT Id
			FROM DuplicateRule
			WHERE SobjectType = 'Source_System_View__c'
			LIMIT 1
		];

		// Create duplicate sets
		DuplicateRecordSet testDuplicateSet1 = new DuplicateRecordSet(
			DuplicateRuleId = testDuplicateRule.Id
			);
		DuplicateRecordSet testDuplicateSet2 = new DuplicateRecordSet(
			DuplicateRuleId = testDuplicateRule.Id
			);
		insert new List<DuplicateRecordSet>{testDuplicateSet1, testDuplicateSet2};

		testDuplicateSet1 = [
			SELECT Id, Duplicate_Record_Set_Number__c
			FROM DuplicateRecordSet
			WHERE Id = :testDuplicateSet1.Id
		];
		testDuplicateSet2 = [
			SELECT Id, Duplicate_Record_Set_Number__c
			FROM DuplicateRecordSet
			WHERE Id = :testDuplicateSet2.Id
		];

		// When
		// Create duplicate record items
		DuplicateRecordItem testDuplicateItem1 = new DuplicateRecordItem(
			DuplicateRecordSetId = testDuplicateSet1.Id,
			RecordId = testSSV1.Id
			);
		DuplicateRecordItem testDuplicateItem2 = new DuplicateRecordItem(
			DuplicateRecordSetId = testDuplicateSet1.Id,
			RecordId = testSSV2.Id
			);
		insert new List<DuplicateRecordItem>{testDuplicateItem1, testDuplicateItem2};

		// Then
		// Verify that duplicate record items were stamped
		testSSV1 = [
			SELECT Id, Duplicate_Set_ID__c, Stewardship_Review_Required__c, 
					Stewardship_Review_Description__c
			FROM Source_System_View__c
			WHERE Id = :testSSV1.Id
		];
		system.assertEquals(testDuplicateSet1.Duplicate_Record_Set_Number__c, testSSV1.Duplicate_Set_ID__c);
		system.assertEquals(false, testSSV1.Stewardship_Review_Required__c);
		system.assertEquals(null, testSSV1.Stewardship_Review_Description__c);

		testSSV2 = [
			SELECT Id, Duplicate_Set_ID__c, Stewardship_Review_Required__c, 
					Stewardship_Review_Description__c
			FROM Source_System_View__c
			WHERE Id = :testSSV2.Id
		];
		system.assertEquals(testDuplicateSet1.Duplicate_Record_Set_Number__c, testSSV2.Duplicate_Set_ID__c);
		system.assertEquals(false, testSSV2.Stewardship_Review_Required__c);
		system.assertEquals(null, testSSV2.Stewardship_Review_Description__c);

		// Create duplicate record item linking record to second duplicate set
		DuplicateRecordItem testDuplicateItem3 = new DuplicateRecordItem(
			DuplicateRecordSetId = testDuplicateSet2.Id,
			RecordId = testSSV1.Id
			);
		insert testDuplicateItem3;

		// Then
		// Verify that record was flagged for stewardship review
		testSSV1 = [
			SELECT Id, Duplicate_Set_ID__c, Stewardship_Review_Required__c, 
					Stewardship_Review_Description__c
			FROM Source_System_View__c
			WHERE Id = :testSSV1.Id
		];
		system.assertEquals(testDuplicateSet2.Duplicate_Record_Set_Number__c, testSSV1.Duplicate_Set_ID__c);
		system.assertEquals(true, testSSV1.Stewardship_Review_Required__c);
		system.assertNotEquals(null, testSSV1.Stewardship_Review_Description__c);
	}
}