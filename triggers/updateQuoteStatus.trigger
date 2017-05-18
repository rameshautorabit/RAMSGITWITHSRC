trigger updateQuoteStatus on Order__c (after insert) {

    List<Id> quoteLidList = new list<id>();

    if(trigger.isinsert)
    {
        for(Order__C orderObj : Trigger.new)
        {
            quoteLidList.add(orderObj.quote__c);

        }

    }
    List<Quote> quoteList = [select id,name from Quote where id  in :quoteLidList];
    for(quote quoteObj : quoteList)
    {
        quoteObj.status = 'Accepted-Order Created';
    }
    update quoteList;

}