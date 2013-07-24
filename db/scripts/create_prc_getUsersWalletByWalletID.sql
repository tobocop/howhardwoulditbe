/****** Object:  StoredProcedure [dbo].[prc_getUsersWalletByWalletID]    Script Date: 7/23/2013 4:34:15 PM ******/
CREATE PROCEDURE prc_getUsersWalletByWalletID
	-- Add the parameters for the stored procedure here
	@walletID INT
AS
BEGIN

SELECT
	CASE
		WHEN wi.walletItemID IS NOT NULL AND a.advertiserID IS NULL THEN 'unassignedSlot'
		WHEN wi.walletItemID IS NULL THEN 'lockedSlot'
		ELSE 'populatedSlot'
	END AS slotStatus,
	CASE
		WHEN wi.walletItemID IS NOT NULL AND a.advertiserID IS NULL THEN ws.unlockedImage
		WHEN wi.walletItemID IS NULL THEN ws.lockedImage
		ELSE isNull(o.logoURL, a.logoURL)
	END AS logoURL,
	CASE
		WHEN wi.walletItemID IS NOT NULL AND a.advertiserID IS NULL THEN ws.unlockedImage
		WHEN wi.walletItemID IS NULL THEN ws.lockedImage
		ELSE a.mobilelogoURL
	END AS mobileLogoURL,
	CASE
		WHEN wi.walletItemID IS NOT NULL AND a.advertiserID IS NULL THEN ws.unlockedText
		WHEN wi.walletItemID IS NULL THEN ws.lockedText
		ELSE ''
	END AS shortDescription,
	CASE
		WHEN wi.walletItemID IS NOT NULL AND a.advertiserID IS NULL THEN ws.mobileUnlockedText
		WHEN wi.walletItemID IS NULL THEN ws.mobileLockedText
		ELSE ''
	END AS mobileShortDescription,
	CASE
		WHEN dbo.udf_getDateOnly(o.endDate) < dbo.udf_getDateOnly(getDate()) THEN 1
		ELSE 0
	END AS isOfferExpired,
	CONVERT(VARCHAR(12), uap.endDate, 107) AS usersAwardPeriodEndDate,
	CONVERT(VARCHAR(12),o.endDate, 107) as offerEndDate,
	isNull(o.advertiserName, a.advertiserName) as advertiserName,
	a.advertiserID,
	a.mapSearchTerm,
	a.googlePlacesType,
	wi.walletItemID,
	wi.walletID,
	wi.usersAwardPeriodID,
	isNull(wi.offersVirtualCurrencyID, 0) as offersVirtualCurrencyID,
	ISNULL(vc.exchangeRate, 0) AS exchangeRate,
	vc.virtualCurrencyID,
	vc.currencyName,
	vc.singularCurrencyName,
	vc.currencyShortName,
	uap.beginDate,
	uap.endDate,
	uap.advertisersRevShare,
	ovc.offersVirtualCurrencyID,
	o.endDate AS rawOfferEndDate,
	o.offerID,
	ws.walletSlotID,
	ws.walletSlotTypeID,
	wst.walletSlotType,
	isNull(DATEDIFF(d, GETDATE(), uap.endDate), 1) AS daysLeft
FROM walletSlots ws
INNER JOIN walletSlotTypes wst on ws.walletSlotTypeID = wst.walletSlotTypeID
LEFT OUTER JOIN walletItems wi ON ws.walletSlotID = wi.walletSlotID
	AND wi.walletID = @walletID
LEFT OUTER JOIN offersVirtualCurrencies ovc ON wi.offersVirtualCurrencyID = ovc.offersVirtualCurrencyID
	AND ovc.isActive = 1
LEFT OUTER JOIN offers o ON ovc.offerID = o.offerID
	AND o.isActive = 1
LEFT OUTER JOIN advertisers a ON o.advertiserID = a.advertiserID
	AND a.isActive = 1
LEFT OUTER JOIN virtualCurrencies vc ON ovc.virtualCurrencyID = vc.virtualCurrencyID
	AND vc.isActive = 1
LEFT JOIN dbo.usersAwardPeriods uap ON wi.usersAwardPeriodID = uap.usersAwardPeriodID
	AND uap.isActive = 1
ORDER BY a.advertiserID desc, wi.walletItemID desc, ws.displayOrder desc


END
