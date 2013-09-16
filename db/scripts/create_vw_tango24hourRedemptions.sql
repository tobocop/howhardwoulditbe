CREATE VIEW vw_tango24HourRedemptions AS
SELECT
	u.holdRedemptions,
	u.userID,
	COUNT(tt.tangoTrackingID) AS redemptionCount,
	SUM(tt.cardValue) AS redeemedInPast24Hours
FROM users u
LEFT OUTER JOIN tangoTracking tt ON tt.userID = u.userID
	AND tt.sentToTangoOn >= getDate() - 1
GROUP BY u.userID, u.holdRedemptions;
