class ChangeWhereClauseInTangoTracking < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER VIEW vw_tango24HourRedemptions AS
      SELECT
        u.holdRedemptions,
        u.userID,
        COUNT(tt.tangoTrackingID) AS redemptionCount,
        SUM(tt.cardValue) AS redeemedInPast24Hours
      FROM users u
      LEFT OUTER JOIN tangoTracking tt ON tt.userID = u.userID
        AND tt.sentToTangoOn >= getDate() - 1
        AND (tt.responseType = 'SUCCESS'
        OR tt.responseType IS NULL)
      GROUP BY u.userID, u.holdRedemptions;
    SQL
  end

  def down
    execute <<-SQL
      ALTER VIEW vw_tango24HourRedemptions AS
      SELECT
        u.holdRedemptions,
        u.userID,
        COUNT(tt.tangoTrackingID) AS redemptionCount,
        SUM(tt.cardValue) AS redeemedInPast24Hours
      FROM users u
      LEFT OUTER JOIN tangoTracking tt ON tt.userID = u.userID
        AND tt.sentToTangoOn >= getDate() - 1
      GROUP BY u.userID, u.holdRedemptions;
    SQL
  end
end
