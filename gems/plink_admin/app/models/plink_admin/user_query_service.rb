module PlinkAdmin
  class UserQueryService < Warehouse
    self.table_name = 'dm_users'

    def self.users_removed_for_103_errors
      query = "
        SELECT    TOP 2000 u.email_address AS email,
          ISNULL(u.first_name,'') + ' ' + ISNULL(u.last_name,'') AS name,
          u.first_name,
          r.user_id,
          a.institution_name,
          COALESCE(u.last_posting_date, u.link_date) AS last_tracked_date,
          r.id

        FROM    ref_removed_intuit_accounts r
        JOIN    dm_users u ON r.user_id = u.user_id
        JOIN    dm_accounts a ON r.account_id = a.account_id AND r.sub_account_id = a.sub_account_id

        WHERE   r.removal_reason = 'Error code 103'
        AND     u.is_force_deactivated = 0
        AND     u.currency_id = 3
        AND     COALESCE(u.last_posting_date, u.link_date) < GETDATE() - 10
        AND     r.sent_reverification IS NULL

        ORDER BY  random();
      "

      connection.select_all(query)
    end
  end
end
