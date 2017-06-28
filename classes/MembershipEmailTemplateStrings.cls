public class MembershipEmailTemplateStrings { 
	
	// preview 
	
	// any - happy path
	public static String previewA = 'Save 25% on Everything. Every Day.';
	// any - auto renew = false
	public static String previewB = 'Renew Your RH Members Program Benefits Today for Only $100 Annually.';
	// 60/30/5 - expiring CC
	public static String previewC = 'Don’t Let Your RH Members Program Benefits Expire.';
	// 60/30/5 - no CC
	public static String previewD = 'Don’t Let Your RH Members Program Benefits Expire.';
	// 1 day - expiring CC
	public static String previewE = 'Renew Your RH Members Program Benefits Today for Only $100 Annually.';	
	// 1 day - no CC
	public static String previewF = 'Renew Your RH Members Program Benefits Today for Only $100 Annually.';
	// -1 day - Expired
	public static String previewG = 'Renew Your RH Members Program Benefits Today for Only $100 Annually.';
	
	// pre-amble
	public static String P1 = 'While Albert Einstein – esteemed physicist, philosopher and developer of the theory of relativity – wasn’t talking about the chaotic state of retail promotions when he penned the quote above, his sentiment captures a feeling many of us share. Our lives are filled with complexity – and we long to break through the clutter to find simplicity. To that end, we set out to reimagine the shopping experience with the RH Members Program. To put your needs first. And to focus on our products, not endless promotions. One year later, we hope that we’ve delivered on that promise, offering what you want, when you want it, always at 25% savings. Every day.';
	public static String P2 = 'As an RH Member, you have exclusive access to the program’s many rewarding benefits, which include 25% savings on all full-priced merchandise*, 20% savings on all sale items, complimentary interior design services, a personal concierge service to manage your orders,[preamblecanadiancontent] and early access to our clearance events.';
	public static String P3 = 'In addition, you can take advantage of complimentary design services at your local gallery. Our team of talented professionals looks forward to helping you reimagine one room, or an entire home indoors or out.';
	
	// Main Paragraph Text   
	
	// Happy Path -> Canadian
	public static String A = 'As a reminder, your membership will be extended on [expirationdate], for [membershipamount] a [membershiptermunit], plus estimated tax of [membershiptaxamount]**. We’ll use the valid method of payment we have on file each [membershiptermunit].';
	public static String AR = 'Your membership will be extended on [expirationdate] and your account charged [membershipamount] for another year**. We’ll use the valid method of payment we have on file.';
	
	// Expiring CC -> Canadian
	public static String B = 'As a reminder, your membership will be extended on [expirationdate], for [membershipamount] a [membershiptermunit], plus estimated tax of [membershiptaxamount]**. However, your method of payment will be expiring soon. [updatePaymentMethod] to ensure uninterrupted service.';
	public static String BR = 'Your membership will be extended on [expirationdate] for [membershipamount] a year**. However, your method of payment will be expiring soon. Simply visit your RH Members Program profile and update your payment information [updatePaymentMethod_Revised].';
	
	// No CC -> Canadian
	public static String C = 'As a reminder, your membership will be extended on [expirationdate], for [membershipamount] a [membershiptermunit], plus estimated tax of [membershiptaxamount]**. However, we don\'t have a valid form of payment for your account. [updatePaymentMethod] to ensure uninterrupted service.';
	public static String CR = 'Your membership will be extended on [expirationdate] for $100 a year**. However, we don\'t have a valid form of payment for your account. Simply visit your RH Members Program profile and update your payment information [updatePaymentMethod_Revised].';
	
	// Happy Path -> Non-Canadian
	public static String D = 'As a reminder, your membership will be extended on [expirationdate] and your account charged [membershipamount] plus applicable tax for another [membershiptermunit]. We’ll use the valid method of payment we have on file each [membershiptermunit].';
	public static String DR = 'Your membership will be extended on [expirationdate] and your account charged [membershipamount] for another year, plus applicable tax. We’ll use the valid method of payment we have on file.';
	
	// Expiring CC -> Non-Canadian
	public static String E = 'As a reminder, your membership will be extended on [expirationdate], for [membershipamount] a [membershiptermunit], plus applicable tax. However, your method of payment will be expiring soon. [updatePaymentMethod] to ensure uninterrupted service.';
	public static String ER = 'Your membership will be extended on [expirationdate] for $100 a year, plus applicable tax. However, your method of payment will be expiring soon. Simply visit your RH Members Program profile and update your payment information [updatePaymentMethod_Revised].';
	
	// No CC -> Non-Canadian
	public static String F = 'As a reminder, your membership will be extended on [expirationdate], for [membershipamount] a [membershiptermunit], plus applicable tax. However, we don\'t have a valid form of payment for your account. [updatePaymentMethod] to ensure uninterrupted service.';
	public static String FR = 'Your membership will be extended on [expirationdate] for $100 a year, plus applicable tax. However, we don\'t have a valid form of payment for your account. Simply visit your RH Members Program profile and update your payment information [updatePaymentMethod_Revised].';
	
	public static String G = 'We understand you\'ve elected not to renew your membership. If you\'re planning on shopping for your home this year, or would like to take advantage of complimentary Interior Design Services, we hope you\'ll [reEnrollRHMembersProgram] for only [membershipamount] plus applicable tax.';
	public static String CG = 'We understand you\'ve elected not to renew your membership. If you\'re planning on shopping for your home this year, or would like to take advantage of complimentary Interior Design Services, we hope you\'ll [reEnrollRHMembersProgram] for only [membershipamount], plus estimated tax of [membershiptaxamount]**.';
	
	public static String H = 'Unfortunately, we\'ve been unable to obtain payment for your membership and your benefits will expire tomorrow, [expirationdate]. If you\'re planning on shopping for your home this year, or would like to take advantage of complimentary Interior Design Services, we hope you\'ll renew your membership for only [membershipamount] a [membershiptermunit], plus estimated tax of [membershiptaxamount]**. [updatePaymentMethod] to ensure uninterrupted service.';
	public static String I = 'Unfortunately, we\'ve been unable to obtain payment for your membership and your benefits will expire tomorrow, [expirationdate]. If you\'re planning on shopping for your home this year, or would like to take advantage of complimentary Interior Design Services, we hope you\'ll renew your membership for only [membershipamount] plus applicable tax [applicablemembershiptaxamount]. [updatePaymentMethod] to ensure uninterrupted service.';
	
	// AutoRenew = false -> Non-Canadian
	public static String J = 'As a reminder, your membership will expire on [expirationdate] as you have not elected to automatically re-enroll. If you\'re planning on shopping for your home this year, or would like to take advantage of complimentary Interior Design Services, we hope you\'ll [reEnrollRHMembersProgram] for only [membershipamount] plus applicable tax. We encourage you to do so to ensure uninterrupted service.';
	public static String JR = 'Your membership will expire on [expirationdate] as you have not elected to automatically re-enroll. To [reEnrollRHMembersProgram_Revised], simply visit your RH Members Program profile, validate your payment information, and extend your Membership for $100 annually plus applicable tax.'; 
	
	// AutoRenew = false -> Canadian	
	public static String K = 'As a reminder, your membership will expire on [expirationdate] as you have not elected to automatically re-enroll. If you\'re planning on shopping for your home this year, or would like to take advantage of complimentary Interior Design Services, we hope you\'ll [reEnrollRHMembersProgram] for only [membershipamount] a [membershiptermunit], plus estimated tax of [membershiptaxamount]**. We encourage you to do so to ensure uninterrupted service.';
	public static String KR = 'Your membership will expire on [expirationdate] as you have not elected to automatically re-enroll. To [reEnrollRHMembersProgram_Revised], simply visit your RH Members Program profile, validate your payment information, and extend your Membership for $100 annually**.';
	
	// Happy Path -> Quebec
	public static String L = 'As a reminder, your membership will be extended on [expirationdate], for [membershipamount] a [membershiptermunit], plus estimated tax of [membershiptaxamount]**.  We’ll use the valid method of payment we have on file.';
	public static String LR = 'Your membership will be extended on [expirationdate] and your account charged $100 for another year**. We’ll use the valid method of payment we have on file.';
	
	public static String M = 'As a reminder, your membership will expire on [expirationdate]. If you\'re planning on shopping for your home this year, or would like to take advantage of complimentary Interior Design Services, [updatePaymentMethod] and extend your Membership for another year for only [membershipamount] plus [membershiptaxamount]** estimated tax. We encourage you to do so to ensure uninterrupted service.';
	public static String N = 'As a reminder, your membership will expire on [expirationdate]. If you\'re planning on shopping for your home this year, or would like to take advantage of complimentary Interior Design Services, [updatePaymentMethod], update your credit card information, and extend your Membership for another [membershiptermunit] for only [membershipamount] plus [membershiptaxamount]** estimated tax. We encourage you to do so to ensure uninterrupted service.';
	public static String O = 'As a reminder, your membership will expire on [expirationdate]. If you\'re planning on shopping for your home this year, or would like to take advantage of complimentary Interior Design Services, [updatePaymentMethod], update your credit card information, which is also expiring soon, and extend your Membership for another [membershiptermunit] for only [membershipamount] plus [membershiptaxamount]** estimated tax. We encourage you to do so to ensure uninterrupted service.';
	public static String P = 'As a reminder, your membership will expire tomorrow, [expirationdate] as you have not elected to automatically re-enroll. If you\'re planning on shopping for your home this year, or would like to take advantage of complimentary Interior Design Services, we hope you\'ll [reEnrollRHMembersProgram] for only [membershipamount] plus applicable tax. We encourage you to do so to ensure uninterrupted service.';
	
	// AutoRenew = false -> Quebec
	public static String Q = 'As a reminder, your membership will expire on [expirationdate]. If you\'re planning on shopping for your home this year, or would like to take advantage of complimentary Interior Design Services, [memberProfileHyperlink], validate your payment information, and extend your Membership for another year for only [membershipamount] plus [membershiptaxamount]** estimated tax. We encourage you to do so to ensure uninterrupted service.';
	public static String QR = 'Your membership will expire on [expirationdate] as you have not elected to automatically re-enroll. To [reEnrollRHMembersProgram_Revised], simply visit your RH Members Program profile, validate your payment information, and extend your Membership for $100 annually**.';
	public static String Q60R = 'Your membership will expire on 03/05/17 and we hope you’ll [reEnrollRHMembersProgram_Revised_60R]. Simply visit your RH Members Program profile, validate your payment information, and extend your membership for $100 a year.**';
	
	// Benefits Block Text
	public static String benefitsA = '<p style="padding-top: 35px; text-transform: uppercase">Your valuable Member benefits include:</p><p style="padding-top: 10px">25% Savings on Everything RH*. Every Day.</p><p>Additional 20% Savings on All Sale - For a Limited Time</p><p>Complimentary Interior Design Services</p><p>Concierge Service to Manage Your Orders</p><p>Early Access to Clearance Events</p>';
	public static String benefitsB = '<p style="padding-top: 35px; text-transform: uppercase">Your valuable Member benefits include:</p><p style="padding-top: 10px">25% Savings on Everything RH*. Every Day.</p><p>Additional 20% Savings on All Sale - For a Limited Time</p><p>Complimentary Interior Design Services</p><p>Concierge Service to Manage Your Orders</p><p>Preferred Financing† Plans on the RH Credit Card Available. Subject to Approval</p><p>Early Access to Clearance Events</p>';

	// Action Block Text
	public static String ActionA = '<p>If you have any questions about the RH Members Program, please email us at <a style="color: #fff; text-decoration:none;" href="mailto:RHMembers@rh.com">RHMembers@rh.com</a> or call the RH Concierge at <a href="tel:8888894739" style="text-decoration:none; color:#fff; border:none;">888.889.4739</a>.</p>';
	public static String ActionB = '<p>If you have any questions about the RH Members Program, please email us at <a style="color: #fff; text-decoration:none;" href="mailto:RHMembers@rh.com">RHMembers@rh.com</a> or call the RH Concierge at <a href="tel:8888894739" style="text-decoration:none; color:#fff; border:none;">888.889.4739</a>. If you do not wish to continue your membership, visit [memberProfileHyperlink]. Otherwise, your membership will continue as of [expirationdate].</p>'; 
	public static String ActionC = '<p>If you have any questions about the Program and how we can best serve you, please don’t hesitate to visit our website at <a href="https://www.restorationhardware.com/membership.jsp" style="color:#fff; border:none;">restorationhardware.com/rhmembersprogram</a> or call your personal RH Concierge at <a href="tel:8888894739" style="text-decoration:none; color:#fff; border:none;">888.889.4739</a>.</p>';
	
	// Best Wishes Block Text
	public static String bestWishesA = '<p>We hope you\'ll rejoin the RH Members Program and enjoy its rewarding benefits for another year.</p>'; //New
	public static String bestWishesB = '<p>We hope you\'ll continue to enjoy the rewarding benefits of the RH Members Program.</p>'; //New
	public static String bestWishesC = '<p>We hope you\'ll rejoin the RH Members Program and enjoy its rewarding benefits for another year.</p>';

	// Legal Fine Print Text
	public static String legalA = '<p style="color: #999; font-size: 11px; font-family: \'proxima-nova \', \'open-sans\', Arial, Helvetica, sans-serif; text-align:left;">*Limited exclusions apply. See [membersTermsAndConditions] for more details.</p><p style="color: #999; font-size: 11px; font-family: \'proxima-nova \', \'open-sans\', Arial, Helvetica, sans-serif; text-align:left;">**Membership fee is $100 plus $15 estimated tax. Amounts are in US Dollars. Tax amounts are estimates only and may vary based on your billing address.</p>';
	public static String legalB	= '<p style="color: #999; font-size: 11px; font-family: \'proxima-nova \', \'open-sans\', Arial, Helvetica, sans-serif; text-align:left;">*Limited exclusions apply. See [membersTermsAndConditions] for more details.</p><p style="color: #999; font-size: 11px; font-family: \'proxima-nova \', \'open-sans\', Arial, Helvetica, sans-serif; text-align:left;">† Promotional financing available with RH credit card accounts offered by Comenity Bank, which determines qualifications for credit and promotion eligibility. Minimum purchase and minimum monthly payments are required. Subject to credit approval and availability. Account must be in good standing at time of transaction.</p>';

	// Preview Text is not dynamic currently, always states 
	// 'Enjoy 25% Savings on Everything RH. Every Day.';

	// Subject
	public static String subjectA = 'Important: RH Members Program Update';
	public static String subjectAR = 'Don’t Let Your Membership Expire. Act Now.';
	
	public static String subjectB = 'Action Required Now on Your RH Members Program Account.';
	public static String subjectB30 = 'Information Needed Now on Your RH Members Program Account';
	
	// 5 day - expiring CC / no CC
	public static String subjectC = 'Immediate Action Required on Your RH Members Program Account';
	public static String subjectCR = 'Information Needed Immediately on Your RH Members Program Account';
	
	// 5 day  - auto renew = false
	public static String subjectF = 'Your RH Members Program Benefits Will Expire Soon. Act Now to Re-enroll.';
	public static String subjectF30 = 'Don’t Let Your Membership Expire. Act Now';
	public static String subjectFR = 'Don’t Let Your Membership Expire. Act Immediately.';

	// 1 day -- expiring CC / no CC / Auto Renew = false
	public static String subjectD = 'Last Day to Re-enroll in the RH Members Program.';
	public static String subjectDR = 'Last Day to Re-enroll in the RH Members Program. Act Now.';
		
	public static String subjectE = 'Your RH Members Program Benefits Have Expired. Act Now to Re-enroll.';
		
	    
}