/****** Object:  View [dbo].[vw_oauth_tokens]    Script Date: 6/24/2013 4:13:21 PM ******/
CREATE view [dbo].[vw_oauth_tokens] as
select u.userID, max(ot.oauthTokenID) as oauthTokenID
from users u
inner join oauthTokens ot on u.userID = ot.userID
WHERE ot.isACtive = 1
group by u.userID;