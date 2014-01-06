ALTER VIEW [dbo].[vw_active_intuit_accounts] AS
SELECT
  uia.usersInstitutionAccountID AS uia_id,
  uia.usersInstitutionID AS users_institution_id,
  u.userID AS user_id,
  u.primaryVirtualCurrencyID AS primary_virtual_currency_id,
  uia.usersInstitutionAccountStagingID AS uia_staging_id,
  uia.beginDate AS uia_begin_date,
  uia.endDate AS uia_end_date,
  uia.accountID AS uia_account_id,
  ulpd.id AS users_last_post_date_id,
  ulpd.post_date
FROM users u
INNER JOIN usersInstitutionAccounts uia ON u.userID = uia.userID
LEFT OUTER JOIN users_last_post_dates ulpd ON u.userID = ulpd.user_id AND uia.usersInstitutionAccountID = ulpd.uia_id
WHERE u.isActive = 1
  AND (u.isForceDeactivated = 0 OR u.isForceDeactivated IS NULL)
  AND uia.isActive = 1
  AND (ulpd.is_active = 1 OR ulpd.is_active IS NULL)
  AND dbo.udf_getDateOnly(uia.beginDate) <= dbo.udf_getDateOnly(getDate())
  AND dbo.udf_calculateFuzzyDate(dbo.udf_getDateOnly(uia.endDate)) >= dbo.udf_getDateOnly(getDate())
  AND uia.inIntuit = 1;
