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
