CREATE view vw_user_has_reverifications as
SELECT DISTINCT u.userID
FROM users u
LEFT JOIN usersReverifications ur ON ur.userID = u.userID
	AND ur.completedOn IS NULL
LEFT JOIN yodleeUserReverifications yur ON yur.userID = u.userID
	AND yur.completedOn IS NULL
WHERE ur.usersReverificationID IS NOT NULL 
	OR yur.yodleeUserReverificationID IS NOT NULL;
