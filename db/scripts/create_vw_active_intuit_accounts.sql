/****** Object:  View [dbo].[vw_active_intuit_accounts]    Script Date: 6/24/2013 4:12:51 PM ******/
CREATE VIEW [dbo].[vw_active_intuit_accounts] AS
SELECT
  uia.usersInstitutionAccountID AS uia_id,
  uia.usersInstitutionID AS users_institution_id,
  u.userID AS user_id,
  u.primaryVirtualCurrencyID AS primary_virtual_currency_id,
  uia.usersInstitutionAccountStagingID AS uia_staging_id,
  uia.beginDate AS uia_begin_date,
  uia.endDate AS uia_end_date,
  -- dbo.udf_calculateFuzzyDate(dbo.udf_getDateOnly(uia.endDate)) AS users_institution_account_fuzzy_end_date,
  uia.accountID AS uia_account_id,
  ulpd.id AS users_last_post_date_id,
  ulpd.post_date,
  oat.oauthTokenID AS oauth_token_id,
  oat.encryptedOauthToken AS encrypted_oauth_token,
  oat.oauthTokenIV AS oauth_token_iv,
  oat.encryptedOauthTokenSecret AS encrypted_oauth_token_secret,
  oat.oauthTokenSecretIV AS oauth_token_secret_iv
FROM users u
INNER JOIN vw_oauth_tokens vwoat on u.userID = vwoat.userID
INNER JOIN oauthTokens oat ON vwoat.oauthTokenID = oat.oauthTokenID
INNER JOIN usersInstitutionAccounts uia ON u.userID = uia.userID
LEFT OUTER JOIN users_last_post_dates ulpd ON u.userID = ulpd.user_id AND uia.usersInstitutionAccountID = ulpd.uia_id
WHERE u.isActive = 1
  AND (u.isForceDeactivated = 0 OR u.isForceDeactivated IS NULL)
  AND oat.isActive = 1
  AND uia.isActive = 1
  AND (ulpd.is_active = 1 OR ulpd.is_active IS NULL)
  AND dbo.udf_getDateOnly(uia.beginDate) <= dbo.udf_getDateOnly(getDate())
  AND dbo.udf_calculateFuzzyDate(dbo.udf_getDateOnly(uia.endDate)) >= dbo.udf_getDateOnly(getDate())
  AND uia.inIntuit = 1;
