CREATE view vw_offerExclusions as
select u.userID,
	offers.offerID
from users u
inner join (
	select o.offerID,
		a.advertiserName
	from offers o
	inner join advertisers a on o.advertiserID = a.advertiserID
	WHERE a.advertiserName IN ('Gap', 'Old Navy', 'Kmart', 'Sears')
) offers on
		(right(u.userID, 1) = 1 AND offers.advertiserName = 'Gap')
		OR
		(right(u.userID, 1) = 2 AND offers.advertiserName = 'Old Navy')
		OR
		(right(u.userID, 1) = 3 AND offers.advertiserName = 'Kmart')
		OR
		(right(u.userID, 1) = 4 AND offers.advertiserName = 'Sears')
where u.created > getDate() - 60;
