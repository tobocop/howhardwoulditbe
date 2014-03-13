/****** Object:  StoredProcedure [dbo].[prc_enforce_transaction_limits]    Script Date: 2013-11-21 ******/
ALTER PROCEDURE prc_enforce_transaction_limits
AS
BEGIN
  UPDATE intuit_transactions_staging
  SET is_qualified = 0,
    business_rule_reason_id = 500
  FROM intuit_transactions_staging its
  INNER JOIN (
    SELECT sub.id,
      RANK() OVER (
        PARTITION BY sub.user_id, sub.advertiser_id ORDER BY sub.priority, sub.post_date, sub.id
      ) AS award_count
    FROM (
      SELECT it.user_id,
        it.advertiser_id,
        it.id,
        1 AS priority,
        it.post_date,
        'transactions' AS selected_table
      FROM intuit_transactions it
      INNER JOIN advertisers a ON it.advertiser_id = a.advertiserID
      WHERE a.advertiserName IN ('Staples', 'Office Depot')
        AND it.post_date >= getDate() - 30
        AND it.post_date >= '2013-11-21'
      UNION
      SELECT its.user_id,
        its.advertiser_id,
        its.id,
        2 AS priority,
        its.post_date,
        'staging' AS selected_table
      FROM intuit_transactions_staging its
      INNER JOIN advertisers a ON its.advertiser_id = a.advertiserID
      WHERE a.advertiserName IN ('Staples', 'Office Depot')
        AND its.post_date >= getDate() - 30
        AND its.post_date >= '2013-11-21'
        AND (its.is_duplicate = 0 OR its.is_duplicate IS NULL)
    ) sub
  ) ranked_transactions ON its.id = ranked_transactions.id
  WHERE ranked_transactions.award_count > 10
END
