public class ReturnReceipt {
	
	/*
	 *	Controller for the Return Receipt visualforce email template and components
	 *
	 */
	
	public Id caseId {get; set;}
	public Boolean isPackingSlip {get; set;}
	
	private Map<String, String> subMap;
	private String packingSlipDC;
	
	public ReturnReceipt() {
		
		// The case Id is either passed in as a page parameter or it comes to the page via
		// the visualforce email template (ReturnReceipt.email)
		packingSlipDC = '';
		Id cIdParameter = ApexPages.currentPage().getParameters().get('caseId');
		if (String.isNotBlank(cIdParameter)) {
			caseId = cIdParameter;
			packingSlipDC = ApexPages.currentPage().getParameters().get('packingSlipDC');
		}
		
		isPackingSlip = (String.isBlank(packingSlipDC)) ? false : true;
		subMap = new Map<String, String>();
		
		system.debug('*****ReturnReceipt constructor isPackingSlip = ' + isPackingSlip + ' packingSlipDC = ' + packingSlipDC);
	}
	
	public Map<String, String> getHeaderFooterContent(Id caseId) {
		
		system.debug('*****ReturnReceipt getHeaderFooterContent isPackingSlip = ' + isPackingSlip + ' packingSlipDC = ' + packingSlipDC);
		
		Map<String, String> hfMap = new Map<String, String>();
		
		// Read in the Case, Order, Template and Brand related data we need to populate the email
		Case rhCase = new Case();
		rhCase = [select Id, RH_Order_Number__c, Client_Type__c, Send_To__c, Return_Date__c, 
				Send_to_Address_1__c, Send_to_Address_2__c, Send_to_Company__c, Send_to_City__c, 
				Send_to_Email__c, Send_to_First_Name__c, Send_to_Last_Name__c, 
				Send_to_State__c, Send_to_Zip__c, Send_to_Country_Code__c, Send_to_Day_Phone__c 
				from Case where Id = :caseId];
		
		RH_Order__c rhOrder = new RH_Order__c();
		rhOrder = [select Id, Name, Sold_To_Address_1__c, Sold_to_Address_2__c, Sold_to_Company__c, Sold_to_City__c, 
				Sold_to_Country__c, Sold_to_Country_Code__c, Sold_to_Email__c, Sold_to_First_Name__c, Sold_to_Last_Name__c, 
				Sold_to_State__c, Sold_to_Zip__c, Sold_to_Day_Phone__c, Division__c, Opportunity__c, Opportunity__r.Ops_Contact__c 
				from RH_Order__c where Id = :rhCase.RH_Order_Number__c];
		
		Ship_To__c rhShipTo = new Ship_To__c();
		rhShipTo = [select Id, Name, Order__c, Ship_to_First_Name__c, Ship_to_Last_Name__c, 
				Ship_to_Address_1__c, Ship_to_Address_2__c, Ship_to_Company__c, Ship_to_City__c, Ship_to_Day_Phone__c, 
				Ship_to_State__c, Ship_to_Zip__c, Ship_to_Country__c, Ship_to_Email__c, Ship_to_Country_Code__c 
				from Ship_To__c where Order__c = :rhOrder.Id and Name = '1' limit 1];
		
        String rhBrandLogoURL = '';
        String rhBrandHomePageURL = '';
        String rhBrandLogoWidth = '';
        String rhBrandLogoHeight = '';
        
        RH_Brand__c rhb = null;
        if (String.isNotBlank(rhOrder.Division__c)) {
            rhb = RH_Brand__c.getInstance(rhOrder.Division__c);
        }
        if (rhb == null) {
            rhb = RH_Brand__c.getInstance('999');
        }
        rhBrandLogoURL = rhb.Brand_Logo_URL__c;
        rhBrandHomePageURL = rhb.Brand_Home_Page_URL__c;
        rhBrandLogoWidth = rhb.Brand_Logo_Width__c;
        rhBrandLogoHeight = rhb.Brand_Logo_Height__c;
        
        String rhBrandLogo = '<a style="color:#000" href="' + rhBrandHomePageURL + '" target="_blank"><img src="' + rhBrandLogoURL + '" width="' + rhBrandLogoWidth + '" height="'+ rhBrandLogoHeight + '"></a>';
        
        // Determine client address information to use
        String clientFirstName = rhOrder.Sold_to_First_Name__c;
        String clientLastName = rhOrder.Sold_to_Last_Name__c;
        String clientAddress1 = rhOrder.Sold_to_Address_1__c;
        String clientAddress2 = rhOrder.Sold_to_Address_2__c;
        String clientCity = rhOrder.Sold_to_City__c;
        String clientState = rhOrder.Sold_to_State__c;
        String clientPostalCode = rhOrder.Sold_to_Zip__c;
        String clientPhone = rhOrder.Sold_to_Day_Phone__c;
        String clientEmail = rhOrder.Sold_to_Email__c;
        if (!isPackingSlip) {
        	if (rhCase.Send_To__c == 'Ship To 1') {
        		clientFirstName = rhShipTo.Ship_to_First_Name__c;
				clientLastName = rhShipTo.Ship_to_Last_Name__c;
				clientAddress1 = rhShipTo.Ship_to_Address_1__c;
				clientAddress2 = rhShipTo.Ship_to_Address_2__c;
				clientCity = rhShipTo.Ship_to_City__c;
				clientState = rhShipTo.Ship_to_State__c;
				clientPostalCode = rhShipTo.Ship_to_Zip__c;
				clientPhone = rhShipTo.Ship_to_Day_Phone__c;
				clientEmail = rhShipTo.Ship_to_Email__c;
        	}
        	if (rhCase.Send_To__c == 'Alternate Address (Contact)') {
        		clientFirstName = rhCase.Send_to_First_Name__c;
				clientLastName = rhCase.Send_to_Last_Name__c;
				clientAddress1 = rhCase.Send_to_Address_1__c;
				clientAddress2 = rhCase.Send_to_Address_2__c;
				clientCity = rhCase.Send_to_City__c;
				clientState = rhCase.Send_to_State__c;
				clientPostalCode = rhCase.Send_to_Zip__c;
				clientPhone = rhCase.Send_to_Day_Phone__c;
				clientEmail = rhCase.Send_to_Email__c;
        	}
        }
        
        hfMap.put('%rhBrandLogo%', rhBrandLogo);
        hfMap.put('%rhBrandHomePageURL%', rhBrandHomePageURL);
        hfMap.put('%orderNumber%', rhOrder.Name);
        String clientName = Utility.toFirstCap(clientFirstName, 3);
        if (String.isNotBlank(clientName)) {
            clientName += ' ';
        }
        clientName += Utility.toFirstCap(clientLastName, 0);
        hfMap.put('%clientName%', (String.isBlank(clientName) ? ' ' : clientName));
        hfMap.put('%clientAddr1%', Utility.toFirstCap(clientAddress1, 0));
        hfMap.put('%clientAddr2%', Utility.toFirstCap(clientAddress2, 0));
        hfMap.put('%clientCity%', Utility.toFirstCap(clientCity, 0));
        hfMap.put('%clientState%', Utility.toFirstCap(clientState, 3));
        hfMap.put('%clientPostalCode%', clientPostalCode);
        hfMap.put('%clientPhone%', Utility.formatPhone10(clientPhone));
        hfMap.put('%clientEmail%', clientEmail);
        
        BillingSummaryTemplate__c bst = BillingSummaryTemplate__c.getInstance(rhCase.Client_Type__c);
        User contractPM = new User();
        String contactEmail = bst.Email2__c;
        String contactPhone = bst.Phone3__c;
        
        if (rhCase.Client_Type__c == 'Contract') {
            if (rhOrder.Opportunity__c != null && rhOrder.Opportunity__r.Ops_Contact__c != null) {
                contractPM = [select Id, Name, Email, Phone from User where Id = :rhOrder.Opportunity__r.Ops_Contact__c];
                contactEmail = contractPM.Email.replaceFirst('@rh', '@RH');
                if (String.isNotBlank(contractPM.Phone)) {
                    contactPhone = contractPM.Phone;
                    if (contactPhone.startsWith('(')) {
                        contactPhone = contactPhone.remove(' ');
                        contactPhone = contactPhone.substring(1);
                        contactPhone = contactPhone.replaceFirst('[)]', '-');
                    }
                }
            }   
        }
        
        hfMap.put('%contactEmail%', contactEmail);
        hfMap.put('%contactPhone%', contactPhone);
		
		return hfMap;
	}
	
	private static String productDescription(String ecommerceDisplayName, String CWItemDescription) {
		String prodDesc;
		
		prodDesc = ecommerceDisplayName;
		if (String.isBlank(prodDesc) || prodDesc == 'PRODUCT NOT AVAILABLE') {
			prodDesc = CWItemDescription;
		}
		
		return prodDesc;
	}
	
	private static String productImageURL(String imageURL) {
		String prodImageURL;
		
		prodImageURL = imageURL;
		if (String.isBlank(prodImageURL)) {
			prodImageURL = Application_Settings__c.getInstance('ProductImageNotAvailableURL').Value_Text__c;
		}
		
		return prodImageURL;
	}
	
	// Populate the substitution map with all the data for the Return Receipt email
	public Map<String, String> gethtmlMap() {
		
		subMap.clear();
		
		// Get the data for the return receipt header and footer data
		subMap.putAll(getHeaderFooterContent(caseId));
		
		// Get the data for the return receipt detail
		Case rhCase = new Case();
		rhCase = [select Id, RH_Order_Number__c, RH_Order_Number__r.Name, Return_Location__c, Return_Date__c from Case where Id = :caseId];
			
		List<Case_Line_Items__c> rhCaseLineList = new List<Case_Line_Items__c>();		
		String cliQuery = 'SELECT Id, Case_Number__c, Unit_Price__c, Quantity_Returned__c, Return_DC__c, Return_Type__c, '
					+ 'Return_Reason__c, Return_Reason_Description__c, Refund_Deposit__c, CW_Return_Code__c, Return_Amount__c, '
					+ 'Exchange__c, No_Charge_Replacement__c, Exch_Amount__c, Exch_Cost__c, Exch_Price__c, Exch_Quantity__c, '
                    + 'Exch_Unit_Price__c, Price_Override_Amount__c, Price_Override_Type__c, Complimentary_Credit__c, '
                    + 'Exch_Product__c, Exch_Product__r.Name, Exch_Product__r.ECommerce_Display_Name__c, '
					+ 'Exch_Product__r.CW_Item_Description__c, Exch_Product__r.Product_Image_URL__c, '
					+ 'CW_SKU_ID__c, CW_SKU_ID__r.Name, CW_SKU_ID__r.ECommerce_Display_Name__c, '
					+ 'CW_SKU_ID__r.CW_Item_Description__c, CW_SKU_ID__r.SKU_Ship_Via__c, '
					+ 'CW_SKU_ID__r.Product_Image_URL__c, CW_SKU_ID__r.Dropship__c FROM Case_Line_Items__c';
		String cliWhere = ' WHERE Case_Number__c = \'' + caseId + '\'';
		
		// Read in all of the Case Lines or only those for the packing slip
		if (isPackingSlip) {
			if (packingSlipDC == 'Blank') {
				cliWhere += ' AND (Return_DC__c = \'\' OR Return_DC__c = null)';
			} else {
				cliWhere += ' AND Return_DC__c = \'' + packingSlipDC + '\'';
			}
			cliWhere += ' AND Return_Reason__c != \'Defective - MOS\' AND Return_Reason__c != \'Damaged - MOS\'';
		}
		
		rhCaseLineList = Database.query(cliQuery + cliWhere);
		
		// Determine if hdl pickup required
		Boolean hdlPickup = false;
		for (Case_Line_Items__c cli :rhCaseLineList) {
			if (cli.CW_SKU_ID__r.SKU_Ship_Via__c == '5' || cli.CW_SKU_ID__r.SKU_Ship_Via__c == '6') {
				hdlPickup = true;
			}
		}
		
		String psSubTitle = ' ';
		if (!isPackingSlip) {
			subMap.put('%returnTitle%', 'Return Receipt');
		} else {
			subMap.put('%returnTitle%', 'Product Return Packing Slip');
			if (hdlPickup) {
				psSubTitle = '<tr><td><p style="color: #333; margin:25px 10px 15px 10px;font-family:\'minion-pro\',Times,\'Times New Roman\';font-size:18px;text-align:center;font-weight:normal;text-transform:uppercase">Requires HDL Pickup</p></td></tr>';
			}
		}
		subMap.put('%packingSlipSubTitle%', psSubTitle);
		subMap.put('%infoTitle%', 'Return Information');
		subMap.put('%infoSubTitle1%', 'Return Gallery');
		subMap.put('%infoSubData1%', rhCase.Return_Location__c);
		subMap.put('%infoSubTitle2%', 'Return Received');
		subMap.put('%infoSubData2%', Utility.usWrittenDate(rhCase.Return_Date__c.date(), true));
		
		// Build the HTML for the return/exchange table
		String returnType = 'return';
		String rrDetail = ' ';
		Decimal totalBilled = 0;
		Decimal totalRefund = 0;
		Decimal lineAmt;
		Decimal	exchQty;
		Decimal exchAmt;
		Decimal rtnAmt;
		Decimal rtnTotal;
		Decimal exchTotal;
		Boolean showRtnTotal;
		Boolean showExchTotal;
		Boolean specialTotals;
		String complimentaryCredit = 'FALSE';
		if (!rhCaseLineList.isEmpty()) {
			if (isPackingSlip) {
				rrDetail = '<tr>';
			} else {
				rrDetail = '<tr style="page-break-before: always;">';
			}
			rrDetail += '<td style="vertical-align:top;border-top:1px solid #333;height:auto">';
			
			if (!isPackingSlip) {
				rrDetail += '<table cellpadding="0" cellspacing="0" style="color:#333;font-family:\'minion-pro\',sans-serif;font-size:11px;vertical-align:top;margin:20px auto 10px auto;width:700px;height:auto;text-transform:uppercase">';
				rrDetail += '<thead style="text-align:left">';
				rrDetail += '<tr style="text-align:left; line-height:15px">';
				rrDetail += '<th style="width:80px"> </th>';
				rrDetail += '<th style="width:260px"> </th>';
				rrDetail += '<th style="text-align:center;width:110px"> </th>';
				rrDetail += '<th style="text-align:center;width:70px"> </th>';
				rrDetail += '<th style="text-align:center;width:70px">Discounted</th>';
				rrDetail += '<th style="text-align:center;width:40px"> </th>';
				rrDetail += '<th style="text-align:center;width:70px"> </th>';
				rrDetail += '</tr>';
				rrDetail += '<tr style="text-align:left; line-height:15px">';
				rrDetail += '<th style="width:80px"> </th>';
				rrDetail += '<th style="width:260px">Item</th>';
				rrDetail += '<th style="text-align:center;width:110px">SKU</th>';
				rrDetail += '<th style="text-align:center;width:70px">Price</th>';
				rrDetail += '<th style="text-align:center;width:70px">Price</th>';
				rrDetail += '<th style="text-align:center;width:40px">Qty</th>';
				rrDetail += '<th style="text-align:center;width:70px">Total</th>';
				rrDetail += '</tr>';
				rrDetail += '</tr></thead></table>';
			} else {
				rrDetail += '<table cellpadding="0" cellspacing="0" style="border-bottom:1px solid #ccc;color:#333;font-family:\'minion-pro\',sans-serif;font-size:11px;vertical-align:top;margin:20px auto 10px auto;width:650px;height:auto;line-height:15px;text-transform:uppercase">';
				rrDetail += '<thead style="text-align:left">';
				rrDetail += '<tr style="text-align:left">';
				rrDetail += '<th style="width:80px"> </th>';
				rrDetail += '<th style="width:300px"><br/>Item</th>';
				rrDetail += '<th style="width:70px"><br/>SKU</th>';
				rrDetail += '<th style="text-align:center;width:40px">Rtn<br/>Code</th>';
				rrDetail += '<th style="text-align:center;width:40px">Ship<br/>Via</th>';
				rrDetail += '<th style="text-align:center;width:40px">Rtn<br/>DC</th>';
				rrDetail += '<th style="text-align:center;width:40px"><br/>Qty</th>';
				rrDetail += '<th style="text-align:center;width:40px">Qty<br/>In Box</th>';
				rrDetail += '</tr></thead></table>';
			}
			
			for (Case_Line_Items__c cli :rhCaseLineList) {
				
				specialTotals = false;
				
				if (cli.Complimentary_Credit__c) {
					complimentaryCredit = 'TRUE';
				}
				
				rtnAmt = (cli.Return_Amount__c == null) ? cli.Unit_Price__c * cli.Quantity_Returned__c : cli.Return_Amount__c;
				rtnTotal = rtnAmt;
				exchTotal = 0;
				if (cli.Exchange__c) {
					
					exchTotal = cli.Exch_Cost__c;
					exchQty = cli.Exch_Quantity__c;
					exchAmt = cli.Exch_Amount__c;
					
					if (cli.No_Charge_Replacement__c) {
						
						if (cli.CW_SKU_ID__c == cli.Exch_Product__c) {
							
							if (cli.Unit_Price__c <= cli.Exch_Unit_Price__c) {
								if (cli.Quantity_Returned__c >= exchQty) {
									rtnTotal = rtnTotal - exchAmt;
								} else {
									rtnTotal = 0;
								}
							} else {
								if (cli.Quantity_Returned__c >= exchQty) {
									rtnTotal = rtnTotal - exchAmt;
								} else {
									specialTotals = true;
									exchQty = cli.Quantity_Returned__c;
									exchAmt = cli.Exch_Price__c * exchQty;
									rtnTotal = (cli.Unit_Price__c - cli.Exch_Price__c) * cli.Quantity_Returned__c;
								}
							}
							
						} else {
							
							if (cli.Exch_Price__c == cli.Unit_Price__c) {
								if (rtnAmt >= exchAmt) {
									rtnTotal = rtnAmt - exchAmt;
								} else {
									rtnTotal = 0;
								}
							}
						}
					}
					
					returnType = 'return/exchange';
				}
				
				totalRefund += rtntotal;
				totalBilled += exchTotal;
				
				rrDetail += '<div style="page-break-inside:avoid;">';
				if (!isPackingSlip) {
					showExchTotal = false;
					showRtnTotal = (!cli.Exchange__c) ? true : false;
					rrDetail += returnReceiptDetailRow(cli, true, showRtnTotal, showExchTotal, rtnTotal, rtnAmt, exchTotal, exchAmt, exchQty);
					if (cli.Exchange__c) {
						showExchTotal = (specialTotals) ? false : true;
						rrDetail += returnReceiptDetailRow(cli, false, true, showExchTotal, rtnTotal, rtnAmt, exchTotal, exchAmt, exchQty);
						if (specialTotals) {
							exchQty = cli.Exch_Quantity__c - cli.Quantity_Returned__c;
							exchAmt = exchQty * cli.Exch_Price__c;
							rrDetail += '<br/>';
							rrDetail += returnReceiptDetailRow(cli, false, false, true, rtnTotal, rtnAmt, exchTotal, exchAmt, exchQty);
						}
					}
					
				} else {
					
					rrDetail += returnReceiptDetailRow(cli, true, false, false, 0, 0, 0, 0, 0);
				}
				rrDetail += '</div>';
			}
			
			rrDetail += '</td></tr>';
		}
		
		subMap.put('%returnType%', returnType);
		subMap.put('%complimentaryCredit%', complimentaryCredit);
		subMap.put('%returnReceiptDetail%', rrDetail);
				
		String estimatedRefund = (totalRefund == 0) ? 'n/a' : Utility.htmlDollarAmount(totalRefund, true);
		subMap.put('%estimatedRefund%', estimatedRefund);
		
		String estimatedBilled = (totalBilled == 0) ? 'n/a' : Utility.htmlDollarAmount(totalBilled, true);
		subMap.put('%estimatedBilled%', estimatedBilled);
		
		// Make sure there are no null values in our substitution map
		for (String tag:subMap.keySet()) {
			if (subMap.get(tag) == null) {
				subMap.put(tag, '');
			}
		}
		
		return subMap;
	}
	
	// Build the HTML for one row of the return receipt detail
	public String returnReceiptDetailRow(Case_Line_Items__c cli, Boolean rtn, Boolean showRtnTotal, Boolean showExchTotal, Decimal rtnTot, Decimal rtnAmt, Decimal exchTot, Decimal exchAmt, Decimal exchQty) {
		String rrDetail = '';
		String prodDesc;
		String prodImageURL;
		String prodName;
		String rtnCode;
		String rtnNotes;
		String unitPrice;
		String exchPrice;
		String quantity;
		String total;
		String rtnTotal;
		String exchTotal;
		String shipVia;
		String rtnDC;
		String totalRefund;
		Decimal up;
		Decimal ep;
		Decimal qty;
		Decimal tot;
		
		system.debug('***** returnReceiptDetailRow rtn = ' + rtn + ' showRtnTotal = ' + showRtnTotal + ' showExchTotal = ' + showExchTotal + ' rtnTot = ' + rtnTot + ' rtnAmt = ' + rtnAmt + ' exchTot = ' + exchTot + ' exchQty = ' + exchQty + ' exchAmt = ' + exchAmt);
		
		if (isPackingSlip) {
			shipVia = (String.isBlank(cli.CW_SKU_ID__r.SKU_Ship_Via__c)) ? ' ' : cli.CW_SKU_ID__r.SKU_Ship_Via__c;
			rtnDC = (String.isBlank(cli.Return_DC__c)) ? ' ' : cli.Return_DC__c;
			rtnNotes = (String.isBlank(cli.Return_Reason_Description__c)) ? ' ' : cli.Return_Reason_Description__c;
			rtnCode = (String.isBlank(cli.CW_Return_Code__c)) ? ' ' : cli.CW_Return_Code__c;
		}
		
		if (rtn) {
			prodDesc = productDescription(cli.CW_SKU_ID__r.ECommerce_Display_Name__c, cli.CW_SKU_ID__r.CW_Item_Description__c);
			prodImageURL = productImageURL(cli.CW_SKU_ID__r.Product_Image_URL__c);
			prodName = cli.CW_SKU_ID__r.Name;
			qty = cli.Quantity_Returned__c;
			up = cli.Unit_Price__c;
			tot = rtnAmt;
		} else {
			prodDesc = productDescription(cli.Exch_Product__r.ECommerce_Display_Name__c, cli.Exch_Product__r.CW_Item_Description__c);
			prodImageURL = productImageURL(cli.Exch_Product__r.Product_Image_URL__c);
			prodName = cli.Exch_Product__r.Name;
			qty = exchQty;
			up = cli.Exch_Price__c;
			tot = exchAmt;
		}
		
		if (!(qty > 0)) {
			qty = 0;
		}
		quantity = (rtn && !isPackingSlip) ? '-' + String.valueOf(qty) : String.valueOf(qty);
		
		up = (rtn) ? cli.Unit_Price__c : cli.Exch_Unit_Price__c;
		if (!(up > 0)) {
			up = 0;
		}
		if (rtn && !cli.Refund_Deposit__c && cli.CW_SKU_ID__r.Dropship__c) {
			up = up / 2;
		}
		unitPrice = (up == 0) ? '&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;&nbsp;' : Utility.htmlDollarAmount(up, true);
		
		ep = cli.Exch_Price__c;
		if (!(ep > 0) || ep == up || rtn || cli.Return_Type__c == 'MIS-SHIP') {
			ep = 0;
		}
		exchPrice = (ep == 0) ? '&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;&nbsp;' : Utility.htmlDollarAmount(ep, true);
		
		if (!(tot > 0) || cli.Return_Type__c == 'MIS-SHIP') {
			tot = 0;
		}
		if (rtn) {
			total = '<span style="color:red;">(' + Utility.htmlDollarAmount(tot, true) + ')</span>';
		} else {
			total = Utility.htmlDollarAmount(tot, true);
		}
		if (tot == 0) {
			total = '&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;&nbsp;';
		}
		
		rtnTotal = (rtnTot == 0) ? '&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;&nbsp;' : '<span style="color:red;">(' + Utility.htmlDollarAmount(rtnTot, true) + ')</span>';
		totalRefund = 'Total Refund';
		if (cli.Complimentary_Credit__c && rtnTot > 0) {
			totalRefund += ' - *Complimentary Credit';
		}
		exchTotal = (exchTot == 0) ? '&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;&nbsp;' : Utility.htmlDollarAmount(exchTot, true);
		
		if (!isPackingSlip) {
			if (rtn) {
				prodDesc = '<b>Return:</b> ' + prodDesc;
				rrDetail += '<table cellpadding="0" cellspacing="0" style="text-align:left;font-size:12px;vertical-align:top;margin:0 auto;width:700px;height:auto;border-top:1px solid #ccc;padding:10px 0px 0px 0px">';
			} else {
				prodDesc = '<b>Exchange:</b> ' + prodDesc;
				rrDetail += '<table cellpadding="0" cellspacing="0" style="text-align:left;font-size:12px;vertical-align:top;margin:0 auto;width:700px;height:auto;">';
			}
		} else {
			if (cli.Return_Type__c == 'MIS-SHIP') {
				prodDesc += ' (MIS-SHIP)';
			}
			rrDetail += '<table cellpadding="0" cellspacing="0" style="text-align:left;font-size:12px;vertical-align:top;margin:0 auto;width:650px;height:auto;">';
		}
		
		rrDetail += '<tbody>';
		rrDetail += '<tr>';
		
		if (!isPackingSlip) {
			rrDetail += '<td style="width:80px;vertical-align:top">';
			rrDetail += '<table cellpadding="0" cellspacing="0" style="color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
			rrDetail += '<tbody><tr><td valign="top" style="padding: 0px 5px 10px 5px" class="order-item-image"><img height="70" width="70" src="' + prodImageURL + '" alt="" title=""></td></tr></tbody>';
			rrDetail += '</table></td>';
			
			rrDetail += '<td style="width:260px;vertical-align:top">';
			rrDetail += '<table cellpadding="0" cellspacing="0" style="color:#666;font-family:\'minion-pro\',sans-serif;">';
			rrDetail += '<tbody><tr><td height="25" style="vertical-align:top;padding-right:10px;padding-bottom:5px;line-height:17px;font-size:11px;text-transform:uppercase;">' + prodDesc + '</td></tr></tbody>';
			rrDetail += '</table></td>';
			
			rrDetail += '<td style="width:110px;vertical-align:top;">';
			rrDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
			rrDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:center;vertical-align:top">' + prodName + '</td></tr></tbody>';
			rrDetail += '</table></td>';
			
			rrDetail += '<td style="width:70px;vertical-align:top">';
			rrDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
			rrDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:center;vertical-align:top">' + unitPrice + '</td></tr></tbody>';
			rrDetail += '</table></td>';
			
			rrDetail += '<td style="width:70px;vertical-align:top">';
			rrDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
			rrDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + exchPrice + '</td></tr></tbody>';
			rrDetail += '</table></td>';
			
			rrDetail += '<td style="width:40px;vertical-align:top">';
			rrDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
			rrDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + quantity + '</td></tr></tbody>';
			rrDetail += '</table></td>';
			
			rrDetail += '<td style="width:70px;vertical-align:top">';
			rrDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
			rrDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + total + '</td></tr></tbody>';
			rrDetail += '</table></td>';
			
			if (showRtnTotal || showExchTotal) {
				rrDetail += '</tr>';
				
				if (showRtnTotal) {
					rrDetail += '<tr>';
					rrDetail += '<td colspan="5" style="vertical-align:top">';
					rrDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
					rrDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + totalRefund + '</td></tr></tbody>';
					rrDetail += '</table></td>';
					
					rrDetail += '<td colspan="2" style="vertical-align:top">';
					rrDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
					rrDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + rtnTotal + '</td></tr></tbody>';
					rrDetail += '</table></td>';
					if (showExchTotal) {
					rrDetail += '</tr>';
					}
				}
				
				if (showExchTotal) {
					rrDetail += '<tr>';
					rrDetail += '<td colspan="5" style="vertical-align:top">';
					rrDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
					rrDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">Total New Charge</td></tr></tbody>';
					rrDetail += '</table></td>';
					
					rrDetail += '<td colspan="2" style="vertical-align:top">';
					rrDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
					rrDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + exchTotal + '</td></tr></tbody>';
					rrDetail += '</table>';
					rrDetail += '<br/><br/>';
					rrDetail += '</td>';
				}
			}
				
		} else {
			
			rrDetail += '<td style="width:80px;vertical-align:top">';
			rrDetail += '<table cellpadding="0" cellspacing="0" style="color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
			rrDetail += '<tbody><tr><td valign="top" style="padding: 0px 5px 10px 5px" class="order-item-image"><img height="70" width="70" src="' + prodImageURL + '" alt="" title=""></td></tr></tbody>';
			rrDetail += '</table></td>';
			
			rrDetail += '<td style="width:300px;vertical-align:top">';
			rrDetail += '<table cellpadding="0" cellspacing="0" style="color:#666;font-family:\'minion-pro\',sans-serif;">';
			rrDetail += '<tbody>';
			rrDetail += '<tr><td height="25" style="vertical-align:top;padding-right:10px;padding-bottom:5px;line-height:17px;font-size:11px;text-transform:uppercase;">' + prodDesc + '</td></tr>';
			rrDetail += '<tr><td height="25" style="vertical-align:top;padding-right:10px;padding-bottom:5px;line-height:12px;font-size:10px;">RETURN NOTES: ' + rtnNotes + '</td></tr>';
			rrDetail += '</tbody>';
			rrDetail += '</table></td>';
			
			rrDetail += '<td style="width:70px;vertical-align:top;">';
			rrDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
			rrDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + prodName + '</td></tr></tbody>';
			rrDetail += '</table></td>';
			
			rrDetail += '<td style="width:40px;vertical-align:top">';
			rrDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
			rrDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + rtnCode + '</td></tr></tbody>';
			rrDetail += '</table></td>';
			
			rrDetail += '<td style="width:40px;vertical-align:top">';
			rrDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
			rrDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + shipVia + '</td></tr></tbody>';
			rrDetail += '</table></td>';
			
			rrDetail += '<td style="width:40px;vertical-align:top">';
			rrDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
			rrDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + rtnDC + '</td></tr></tbody>';
			rrDetail += '</table></td>';
			
			rrDetail += '<td style="width:40px;vertical-align:top">';
			rrDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
			rrDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top">' + quantity + '</td></tr></tbody>';
			rrDetail += '</table></td>';
			
			rrDetail += '<td style="width:40px;vertical-align:top">';
			rrDetail += '<table cellpadding="0" cellspacing="0" style="float:right;color:#666;line-height:17px;font-family:\'minion-pro\',sans-serif;font-size:11px;text-transform:uppercase">';
			rrDetail += '<tbody><tr><td height="25" style="padding-right:10px;text-align:right;vertical-align:top;border-bottom:1px solid #ccc;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td></tr></tbody>';
			rrDetail += '</table></td>';
			
		}
			
		rrDetail += '</tr>';
		rrDetail += '</tbody>';
		rrDetail += '</table>';
		
		return rrDetail;
	}
}