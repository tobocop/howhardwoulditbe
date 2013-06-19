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