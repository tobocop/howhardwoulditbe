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
