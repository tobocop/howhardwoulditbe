namespace :wallet do
  desc 'Alter `prc_getUsersWalletByWalletID` to return the same values with the new walletItems structure'
  task alter_prc_getUsersWalletByWalletID: :environment do
    ActiveRecord::Base.connection.execute(<<statement
ALTER PROCEDURE prc_getUsersWalletByWalletID
	-- Add the parameters for the stored procedure here
	@walletID INT
AS
BEGIN

SELECT
CASE
WHEN wi.type = 'Plink::OpenWalletItemRecord' THEN 'unassignedSlot'
WHEN wi.type = 'Plink::LockedWalletItemRecord' THEN 'lockedSlot'
ELSE 'populatedSlot'
END AS slotStatus,
CASE
WHEN wi.type = 'Plink::OpenWalletItemRecord' THEN 'assets/images/plus.png'
WHEN wi.type = 'Plink::LockedWalletItemRecord' THEN 'assets/images/locked.png'
ELSE isNull(o.logoURL, a.logoURL)
END AS logoURL,
CASE
WHEN wi.type = 'Plink::OpenWalletItemRecord' THEN 'assets/images/plus.png'
WHEN wi.type = 'Plink::LockedWalletItemRecord' THEN 'assets/images/locked.png'
ELSE a.mobilelogoURL
END AS mobileLogoURL,
CASE
WHEN wi.type = 'Plink::OpenWalletItemRecord' THEN 'Select a restaurant from the left to start earning rewards from Plink!'
WHEN wi.type = 'Plink::LockedWalletItemRecord' THEN 'Click here to figure out how to unlock this slot'
ELSE ''
END AS shortDescription,
CASE
WHEN wi.type = 'Plink::OpenWalletItemRecord' THEN 'Select an offer'
WHEN wi.type = 'Plink::LockedWalletItemRecord' THEN 'Complete an offer or refer a friend to unlock'
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
wi.walletSlotID,
wi.walletSlotTypeID,
'referral' as walletSlotType,
isNull(DATEDIFF(d, GETDATE(), uap.endDate), 1) AS daysLeft
FROM walletItems wi
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
WHERE  wi.walletID = @walletID
ORDER BY a.advertiserID desc, wi.walletID desc, wi.walletItemID
END
statement
)
  end
end

