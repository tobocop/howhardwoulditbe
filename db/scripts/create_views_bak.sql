
CREATE VIEW [dbo].[vw_awards]
AS
SELECT
	fa.freeAwardID,
	NULL AS qualifyingAwardID,
	NULL AS nonQualifyingAwardID,
	'F' + CONVERT(varchar(200), fa.freeAwardID) AS awardID,
	at.awardType AS awardType,
	fa.awardTypeID,
	NULL AS advertiserName,
	NULL AS transactionAmount,
	NULL AS yodleeTransactionID,
	fa.userID,
	fa.externalUserID,
	fa.usersVirtualCurrencyID,
	fa.virtualCurrencyID,
	fa.additionalInfo,
	fa.dollarAwardAmount,
	fa.currencyAwardAmount,
	fa.isNotificationSuccessful,
	fa.isSuccessful,
	fa.isActive,
	fa.created
FROM freeAwards fa
INNER JOIN awardTypes at ON fa.awardTypeID = at.awardTypeID
UNION ALL
SELECT
	NULL AS freeAwardID,
	qa.qualifyingAwardID,
	NULL AS nonQualifyingAwardID,
	'Q' + CONVERT(varchar(200), qa.qualifyingAwardID) AS awardID,
	'qualified' AS awardType,
	NULL AS awardTypeID,
	a.advertiserName,
	qa.transactionAmount,
	qa.yodleeTransactionID,
	qa.userID,
	qa.externalUserID,
	qa.usersVirtualCurrencyID,
	qa.virtualCurrencyID,
	qa.additionalInfo,
	qa.dollarAwardAmount,
	qa.currencyAwardAmount,
	qa.isNotificationSuccessful,
	qa.isSuccessful,
	qa.isActive,
	qa.created
FROM qualifyingAwards qa
INNER JOIN advertisers a ON qa.advertiserID = a.advertiserID
UNION ALL
SELECT
	NULL AS freeAwardID,
	NULL AS qualifyingAwardID,
	nqa.nonQualifyingAwardID,
	'N' + CONVERT(varchar(200), nqa.nonQualifyingAwardID) AS awardID,
	'Non-qualifying' AS awardType,
	NULL AS awardTypeID,
	a.advertiserName,
	nqa.transactionAmount,
	nqa.yodleeTransactionID,
	nqa.userID,
	nqa.externalUserID,
	nqa.usersVirtualCurrencyID,
	nqa.virtualCurrencyID,
	nqa.additionalInfo,
	nqa.dollarAwardAmount,
	nqa.currencyAwardAmount,
	nqa.isNotificationSuccessful,
	nqa.isSuccessful,
	nqa.isActive,
	nqa.created
FROM nonQualifyingAwards nqa
INNER JOIN advertisers a ON nqa.advertiserID = a.advertiserID
;


CREATE view vw_debitsCredits as
select sub.*
FROM
(
	select vwar.userID,
		vwar.awardType,
		0 as isReward,
		0 as isPending,
		0 as isDenied,
		vwar.message as awardDisplayName,
		vwar.mobileMessage as mobileDisplayName,
		vwar.dollarAwardAmount,
		vwar.virtualCurrencyID,
		vwar.currencyAwardAmount,
		vwar.currencyPrefix,
		vwar.displayCurrencyName,
		vwar.created as sentOn,
		vwar.created
	from vw_allRewards vwar
	union all
	SELECT
		r.userID,
		'Loot' AS awardType,
	 	1 as isReward,
		r.isPending as isPending,
		r.isDenied as isDenied,
		'$' + convert(varchar, convert(int, r.dollarAwardAmount)) + ' ' + l.name AS awardDisplayName,
		'$' + convert(varchar, convert(int, r.dollarAwardAmount)) + ' ' + l.name AS mobileDisplayName,
		r.dollarAwardAmount * -1 AS dollarAwardAmount,
		NULL AS virtualCurrencyID,
		r.dollarAwardAmount * vc.exchangeRate * -1 AS currencyAwardAmount,
		'' as currencyPrefix,
		'Plink Points' as displayCurrencyName,
		r.sentOn,
		r.created
	FROM redemptions r
	inner join users u on u.userID = r.userID
	inner join virtualCurrencies vc on u.primaryVirtualCurrencyID = vc.virtualCurrencyID
	INNER JOIN loot l ON r.lootID = l.lootID
	where r.isActive = 1
) sub;



CREATE view [dbo].[vw_userBalances] as

select u.userID,
	SUM(
		case when vdc.dollarAwardAmount > 0 then vdc.dollarAwardAmount
		else 0
		end
	) as lifetimeBalance,
	sum(isNull(vdc.dollarAwardAmount, 0)) as dollarCurrentBalance,
	sum(isNull(vdc.currencyAwardAmount, 0)) as currencyCurrentBalance,
	CASE
		when sum(isNull(vdc.dollarAwardAmount, 0)) >= (
			select min(dollarAwardAmount)
			from lootAmounts
			where isActive = 1
		) THEN 1
		ELSE 0
	END as canRedeem
FROM users u
LEFT OUTER join vw_debitsCredits vdc on u.userID = vdc.userID
	and vdc.virtualCurrencyID = u.primaryVirtualCurrencyID
group by u.userID;
;
