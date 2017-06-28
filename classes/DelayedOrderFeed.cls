public class DelayedOrderFeed {
	
	public DelayedOrderFeed() {
		
	}
	
	public class DelayedOrderFeedHistory {
		public String NN {get; set;}	// Notice Number
		public String ND {get; set;}	// Notice Date
		public String CD {get; set;}	// Current Available Date
		
		public DelayedOrderFeedHistory() {
			NN = null;
			ND = null;
			CD = null;
		}
		
		public DelayedOrderFeedHistory(String noticeNumber, String noticeDate, String currentDate) {
			NN = noticeNumber;
			ND = noticeDate;
			CD = currentDate;
		}
	}
	
	public class DelayedOrderFeedDateChange {
		public String ND {get; set;}	// Notice Date
		public String CD {get; set;}	// Current Available Date
		
		public DelayedOrderFeedDateChange() {
			ND = null;
			CD = null;
		}
	
		public DelayedOrderFeedDateChange(String noticeDate, String currentDate) {
			ND = noticeDate;
			CD = currentDate;
		}
	}
}