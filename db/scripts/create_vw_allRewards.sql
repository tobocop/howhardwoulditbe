CREATE VIEW [dbo].[vw_allRewards]
AS
SELECT vwa.userID,
	vwa.currencyAwardAmount,
	vwa.dollarAwardAmount,
	vwa.created,
	vwa.virtualCurrencyID,
	vwa.awardType,
	vwa.isNotificationSuccessful,
	vwa.awardID,
	vc.currencyPrefix,
	vc.currencyName,
	CASE
		when vwa.currencyAwardAmount = 1 then vc.singularCurrencyName
		else  vc.currencyName
	end as displayCurrencyName,
	CASE
		WHEN vwa.qualifyingAwardID is not null then 'for visiting ' + isNull(a.advertiserName, 'one of our partners')
		WHEN vwa.freeAwardID IS NOT NULL AND vwa.awardType = 'CheckInBonus' THEN 'Check-in at ' + ISNULL(checkin_query.advertiser_name, 'one of our partners')
		WHEN vwa.freeAwardID is not null then replace(at.emailMessage, 'through Plink ', '')
		ELSE 'for participating in the Plink program'
	end as message,
	CASE
		WHEN vwa.qualifyingAwardID is not null then isNull(a.advertiserName, 'one of our partners')
		WHEN vwa.freeAwardID IS NOT NULL AND vwa.awardType = 'CheckInBonus' THEN 'Check-in at ' + ISNULL(checkin_query.advertiser_name, 'one of our partners')
		WHEN vwa.freeAwardID is not null then at.mobileMessage
		ELSE 'Bonus'
	end as mobileMessage
FROM vw_awards vwa
inner join virtualCurrencies vc on vwa.virtualCurrencyID = vc.virtualCurrencyID
LEFT JOIN qualifyingAwards qa on qa.qualifyingAwardID = vwa.qualifyingAwardID
LEFT JOIN advertisers a on qa.advertiserID = a.advertiserID
LEFT JOIN freeAwards fa on vwa.freeAwardID = fa.freeAwardID
LEFT JOIN awardTypes at on at.awardTypeID = fa.awardTypeID
LEFT OUTER JOIN (
	SELECT
		fa.freeAwardID,
		c.id,
		c.advertiser_id,
		aa.advertiserName AS advertiser_name
	FROM freeAwards fa
	INNER JOIN checkins c ON fa.checkin_id = c.id
	INNER JOIN advertisers aa ON c.advertiser_id = aa.advertiserID
	WHERE fa.isSuccessful = 1
		AND fa.isActive = 1
		AND fa.checkin_id IS NOT NULL
) checkin_query ON fa.freeAwardID = checkin_query.freeAwardID
WHERE vwa.isSuccessful = 1
	AND vwa.isActive = 1
;


