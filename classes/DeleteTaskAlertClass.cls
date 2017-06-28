public without sharing class DeleteTaskAlertClass
{
	public Id taskId{get;Set;}
	public DeleteTaskAlertClass(ApexPages.StandardController controller)
	{
		taskId=controller.getId();
	}
	


}