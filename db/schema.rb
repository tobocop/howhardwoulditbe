# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140110214931) do

  create_table "account_information", :force => true do |t|
    t.integer  "user_id",                       :limit => 8,                                                     :null => false
    t.integer  "uia_account_id",                :limit => 8,                                                     :null => false
    t.integer  "users_institution_id",          :limit => 8,                                                     :null => false
    t.integer  "account_id",                    :limit => 8,                                                     :null => false
    t.integer  "http_status",                                                                                    :null => false
    t.text     "http_message"
    t.string   "account_nickname",              :limit => 500
    t.string   "account_number_last_4",         :limit => 4
    t.datetime "aggr_attempt_date"
    t.string   "aggr_status_code",              :limit => 20
    t.datetime "aggr_success_date"
    t.decimal  "balance_amount",                                :precision => 20, :scale => 6
    t.datetime "balance_date"
    t.decimal  "balance_previous_amount",                       :precision => 20, :scale => 6
    t.string   "bank_id",                       :limit => 200
    t.string   "currency_code",                 :limit => 5
    t.string   "description",                   :limit => 2000
    t.integer  "display_position"
    t.integer  "institution_login_id",          :limit => 8
    t.integer  "institution_id",                :limit => 8
    t.datetime "last_txn_date"
    t.string   "registered_user_name",          :limit => 200
    t.string   "status",                        :limit => 200
    t.decimal  "available_balance_amount",                      :precision => 20, :scale => 6
    t.string   "banking_account_type",          :limit => 100
    t.decimal  "interest_amount_ytd",                           :precision => 20, :scale => 6
    t.decimal  "interest_prior_amount_ytd",                     :precision => 20, :scale => 6
    t.string   "interest_type",                 :limit => 100
    t.decimal  "maturity_amount",                               :precision => 20, :scale => 6
    t.datetime "maturity_date"
    t.datetime "open_date"
    t.datetime "origination_date"
    t.decimal  "period_deposit_amount",                         :precision => 20, :scale => 6
    t.decimal  "period_interest_amount",                        :precision => 20, :scale => 6
    t.decimal  "period_interest_rate",                          :precision => 20, :scale => 6
    t.datetime "posted_date"
    t.decimal  "cash_advance_available_amount",                 :precision => 20, :scale => 6
    t.decimal  "cash_advance_balance",                          :precision => 20, :scale => 6
    t.decimal  "cash_advance_interest_rate",                    :precision => 20, :scale => 6
    t.decimal  "cash_advance_max_amount",                       :precision => 20, :scale => 6
    t.string   "credit_account_type",           :limit => 100
    t.decimal  "credit_available_amount",                       :precision => 20, :scale => 6
    t.decimal  "credit_max_amount",                             :precision => 20, :scale => 6
    t.decimal  "current_balance",                               :precision => 20, :scale => 6
    t.string   "detailed_description",          :limit => 2000
    t.decimal  "interest_rate",                                 :precision => 20, :scale => 6
    t.decimal  "last_payment_amount",                           :precision => 20, :scale => 6
    t.datetime "last_payment_date"
    t.decimal  "past_due_amount",                               :precision => 20, :scale => 6
    t.datetime "payment_due_date"
    t.decimal  "payment_min_amount",                            :precision => 20, :scale => 6
    t.decimal  "previous_balance",                              :precision => 20, :scale => 6
    t.decimal  "statement_close_balance",                       :precision => 20, :scale => 6
    t.datetime "statement_end_date"
    t.decimal  "statement_finance_amount",                      :precision => 20, :scale => 6
    t.decimal  "statement_late_fee_amount",                     :precision => 20, :scale => 6
    t.decimal  "statement_purchase_amount",                     :precision => 20, :scale => 6
    t.datetime "created_at",                                                                                     :null => false
    t.datetime "updated_at",                                                                                     :null => false
    t.boolean  "is_active",                                                                    :default => true, :null => false
  end

  create_table "admin_account_logins", :force => true do |t|
    t.integer  "admin_account_id"
    t.string   "result"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "admin_accounts", :force => true do |t|
    t.string "user_name"
    t.string "password"
    t.string "password_salt"
    t.string "permissions"
    t.string "is_active"
  end

  create_table "advertisers", :primary_key => "advertiserID", :force => true do |t|
    t.string   "advertiserName",   :limit => 250,                   :null => false
    t.integer  "createdBy",                       :default => 0,    :null => false
    t.datetime "created",                                           :null => false
    t.integer  "modifiedBy",                      :default => 0,    :null => false
    t.datetime "modified",                                          :null => false
    t.boolean  "isActive",                        :default => true, :null => false
    t.string   "logoURL",          :limit => 500
    t.string   "mapSearchTerm",    :limit => 500
    t.string   "googlePlacesType", :limit => 500
    t.string   "mobileLogoURL",    :limit => 500
    t.boolean  "isRetail"
  end

  create_table "advertisersExcludeTerms", :primary_key => "advertisersExcludeTermID", :force => true do |t|
    t.integer  "advertiserID",                                            :null => false
    t.string   "advertisersExcludeTerm", :limit => 200,                   :null => false
    t.integer  "createdBy",                             :default => 0,    :null => false
    t.datetime "created",                                                 :null => false
    t.integer  "modifiedBy",                            :default => 0,    :null => false
    t.datetime "modified",                                                :null => false
    t.boolean  "isActive",                              :default => true, :null => false
  end

  create_table "advertisersExcludeTerms_backup", :primary_key => "advertisersExcludeTermID", :force => true do |t|
    t.integer  "advertiserID",                                            :null => false
    t.string   "advertisersExcludeTerm", :limit => 200,                   :null => false
    t.integer  "createdBy",                             :default => 0,    :null => false
    t.datetime "created",                                                 :null => false
    t.integer  "modifiedBy",                            :default => 0,    :null => false
    t.datetime "modified",                                                :null => false
    t.boolean  "isActive",                              :default => true, :null => false
  end

  create_table "advertisersSearchTerms", :primary_key => "advertisersSearchTermID", :force => true do |t|
    t.integer  "advertiserID",                                            :null => false
    t.string   "advertisersSearchTerm", :limit => 200,                    :null => false
    t.integer  "createdBy",                            :default => 0,     :null => false
    t.datetime "created",                                                 :null => false
    t.integer  "modifiedBy",                           :default => 0,     :null => false
    t.datetime "modified",                                                :null => false
    t.boolean  "isActive",                             :default => true,  :null => false
    t.boolean  "flagAsPending",                        :default => false, :null => false
  end

  create_table "advertisers_exclude_patterns", :force => true do |t|
    t.integer  "advertiser_id",                                       :null => false
    t.string   "regular_expression", :limit => 200,                   :null => false
    t.text     "comments"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.boolean  "is_active",                         :default => true, :null => false
  end

  create_table "advertisers_search_patterns", :force => true do |t|
    t.integer  "advertiser_id",                                        :null => false
    t.string   "regular_expression", :limit => 200,                    :null => false
    t.text     "comments"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.boolean  "is_active",                         :default => true,  :null => false
    t.boolean  "flag_as_pending",                   :default => false, :null => false
  end

  create_table "affiliates", :primary_key => "affiliateID", :force => true do |t|
    t.string   "affiliate",                         :limit => 500,                                                    :null => false
    t.datetime "created",                                                                                             :null => false
    t.boolean  "isActive",                                                                         :default => true,  :null => false
    t.boolean  "hasIncentedCardRegistration",                                                      :default => false, :null => false
    t.decimal  "cardRegistrationDollarAwardAmount",                 :precision => 12, :scale => 6, :default => 0.0,   :null => false
    t.boolean  "hasIncentedJoin",                                                                  :default => false, :null => false
    t.decimal  "joinDollarAwardAmount",                             :precision => 12, :scale => 6, :default => 0.0,   :null => false
    t.decimal  "cardAddDisplayAmount",                              :precision => 12, :scale => 6, :default => 0.0,   :null => false
    t.string   "cardAddPixel",                      :limit => 1000
    t.text     "disclaimerText"
    t.string   "emailAddPixel",                     :limit => 1000
    t.decimal  "referralCardAddOneTimeAward",                       :precision => 12, :scale => 6, :default => 0.0,   :null => false
    t.integer  "referralsCompletedUntilAward",                                                     :default => 0,     :null => false
  end

  create_table "affiliatesPaths", :primary_key => "affiliatePathID", :force => true do |t|
    t.integer  "affiliateID",                   :null => false
    t.integer  "pathID",                        :null => false
    t.boolean  "isActive",    :default => true, :null => false
    t.datetime "startDate"
    t.datetime "endDate"
  end

  create_table "approvedTransactionsStaging", :primary_key => "approvedTransactionsStagingID", :force => true do |t|
    t.integer  "userID",                      :limit => 8,                                  :null => false
    t.integer  "usersBankProductAccountID",                                                 :null => false
    t.integer  "usersBankProductID",                                                        :null => false
    t.integer  "usersBankID",                 :limit => 8,                                  :null => false
    t.integer  "yodleeTransactionID",         :limit => 8,                                  :null => false
    t.string   "yodleeContainerType",         :limit => 100,                                :null => false
    t.text     "yodleeDescription",                                                         :null => false
    t.datetime "postDate",                                                                  :null => false
    t.integer  "yodleeCategoryID",                                                          :null => false
    t.string   "yodleeCategoryName",          :limit => 300,                                :null => false
    t.decimal  "transactionAmount",                          :precision => 20, :scale => 6, :null => false
    t.string   "currencyCode",                :limit => 10,                                 :null => false
    t.string   "yodleeCategorizationKeyword", :limit => 300,                                :null => false
    t.string   "yodleeTransactionType",       :limit => 300,                                :null => false
    t.datetime "created",                                                                   :null => false
  end

  create_table "archivedTransactions", :primary_key => "archivedTransactionID", :force => true do |t|
    t.integer  "userID",                      :limit => 8
    t.integer  "usersBankProductAccountID",                                                                     :null => false
    t.integer  "usersBankProductID",                                                                            :null => false
    t.integer  "usersBankID",                                                                                   :null => false
    t.integer  "advertiserID"
    t.integer  "advertiserCampaignID_old",    :limit => 8
    t.integer  "usersAwardPeriodID"
    t.datetime "awardPeriodBeginDate"
    t.datetime "awardPeriodEndDate"
    t.decimal  "advertisersRevShare",                         :precision => 12, :scale => 6
    t.integer  "campaignID_old"
    t.datetime "campaignBeginDate_old"
    t.datetime "campaignEndDate_old"
    t.integer  "advertisersSearchTermID"
    t.string   "advertisersSearchTerm",       :limit => 200
    t.integer  "advertisersExcludeTermID"
    t.string   "advertisersExcludeTerm",      :limit => 200
    t.integer  "yodleeTransactionID",         :limit => 8,                                                      :null => false
    t.string   "yodleeContainerType",         :limit => 100,                                                    :null => false
    t.text     "yodleeDescription",                                                                             :null => false
    t.datetime "postDate",                                                                                      :null => false
    t.integer  "yodleeCategoryID",                                                                              :null => false
    t.string   "yodleeCategoryName",          :limit => 300,                                                    :null => false
    t.decimal  "transactionAmount",                           :precision => 20, :scale => 6,                    :null => false
    t.string   "currencyCode",                :limit => 10,                                                     :null => false
    t.string   "yodleeCategorizationKeyword", :limit => 300,                                                    :null => false
    t.string   "yodleeTransactionType",       :limit => 300,                                                    :null => false
    t.integer  "affiliateID"
    t.string   "subID",                       :limit => 100
    t.boolean  "isPendingReview",                                                            :default => false, :null => false
    t.boolean  "inCampaignPeriod_old",                                                                          :null => false
    t.boolean  "inUserAwardPeriod",                                                          :default => false, :null => false
    t.integer  "awardOrder"
    t.integer  "virtualCurrencyID"
    t.decimal  "cpaAmount_old",                               :precision => 12, :scale => 6
    t.datetime "created",                                                                                       :null => false
    t.decimal  "minimumPurchaseAmount",                       :precision => 12, :scale => 6
    t.boolean  "is2x"
    t.boolean  "is3x"
    t.boolean  "isOverMinimumAmount"
    t.integer  "eventID",                     :limit => 8
    t.decimal  "awardAmount_old",                             :precision => 18, :scale => 8
    t.boolean  "hasMondayBonus",                                                             :default => false
    t.decimal  "exchangeRate",                                :precision => 9,  :scale => 3
    t.datetime "cardActivationBeginDate"
    t.datetime "cardActivationEndDate"
    t.boolean  "inCardActivationPeriod",                                                     :default => false
    t.string   "subID2",                      :limit => 200
    t.string   "subID3",                      :limit => 200
    t.string   "subID4",                      :limit => 200
    t.boolean  "isManuallyAwarded",                                                          :default => false, :null => false
    t.boolean  "isManuallyDenied",                                                           :default => false, :null => false
    t.integer  "offerID"
    t.datetime "offerBeginDate"
    t.datetime "offerEndDate"
    t.decimal  "dollarAwardAmount",                           :precision => 12, :scale => 6
    t.boolean  "inOfferPeriod",                                                              :default => false, :null => false
    t.integer  "usersVirtualCurrencyID",      :limit => 8
    t.string   "externalUserID",              :limit => 250
    t.string   "additionalInfo",              :limit => 1000
  end

  create_table "audit_yodleeItems", :primary_key => "audit_yodleeItemID", :force => true do |t|
    t.integer  "userID",         :limit => 8,                     :null => false
    t.string   "yodleeUsername", :limit => 500,                   :null => false
    t.string   "yodleePassword", :limit => 500,                   :null => false
    t.integer  "itemID",         :limit => 8,                     :null => false
    t.datetime "created",                                         :null => false
    t.boolean  "isActive",                      :default => true, :null => false
  end

  create_table "audit_yodleeUsers", :primary_key => "audit_yodleeUserID", :force => true do |t|
    t.integer  "userID",         :limit => 8,                     :null => false
    t.string   "yodleeUsername", :limit => 500,                   :null => false
    t.string   "yodleePassword", :limit => 500,                   :null => false
    t.datetime "created",                                         :null => false
    t.boolean  "isActive",                      :default => true, :null => false
  end

  create_table "authentication_tokens", :force => true do |t|
    t.string   "token"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "user_id",    :limit => 8
  end

  create_table "awardTypes", :primary_key => "awardTypeID", :force => true do |t|
    t.string   "awardType",         :limit => 500,                                                    :null => false
    t.string   "awardCode",         :limit => 100,                                                    :null => false
    t.string   "awardDisplayName",  :limit => 100,                                                    :null => false
    t.decimal  "dollarAmount",                      :precision => 18, :scale => 6
    t.decimal  "maximumAmount",                     :precision => 18, :scale => 6
    t.string   "emailMessage",      :limit => 1000
    t.boolean  "isFreeAward",                                                      :default => true,  :null => false
    t.boolean  "isManualAward",                                                    :default => true,  :null => false
    t.datetime "created"
    t.boolean  "isActive",                                                         :default => true,  :null => false
    t.boolean  "isAcquisitionCost",                                                :default => false, :null => false
    t.string   "mobileMessage",     :limit => 500
  end

  create_table "bankProducts", :primary_key => "bankProductID", :force => true do |t|
    t.integer  "bankID",                                                  :null => false
    t.integer  "contentServiceID",                                        :null => false
    t.string   "accountName",            :limit => 250,                   :null => false
    t.string   "accountTypeDescription", :limit => 250
    t.datetime "created",                                                 :null => false
    t.datetime "modified",                                                :null => false
    t.boolean  "isActive",                              :default => true, :null => false
    t.string   "mfaType",                :limit => 100
  end

  create_table "banks", :primary_key => "bankID", :force => true do |t|
    t.integer  "organizationID",                                    :null => false
    t.integer  "contentServiceID",                                  :null => false
    t.string   "bankName",         :limit => 250,                   :null => false
    t.datetime "created",                                           :null => false
    t.datetime "modified",                                          :null => false
    t.boolean  "isActive",                        :default => true, :null => false
    t.boolean  "isSupported",                     :default => true, :null => false
  end

  create_table "bonusOffers", :primary_key => "bonusOfferID", :force => true do |t|
    t.integer  "advertiserCampaignID", :limit => 8
    t.string   "logoURL",              :limit => 500
    t.string   "shortDescription",     :limit => 500
    t.integer  "createdBy",                           :default => 0,    :null => false
    t.datetime "created",                                               :null => false
    t.integer  "modifiedBy",                          :default => 0,    :null => false
    t.datetime "modified",                                              :null => false
    t.boolean  "isActive",                            :default => true, :null => false
  end

  create_table "bonusRedemptions", :primary_key => "bonusRedemptionID", :force => true do |t|
    t.integer  "userID",                   :limit => 8,                                                   :null => false
    t.integer  "fbUserID",                 :limit => 8
    t.integer  "yodleeTransactionID",      :limit => 8,                                                   :null => false
    t.integer  "advertisersSearchTermID",                                                                 :null => false
    t.decimal  "awardAmount",                           :precision => 18, :scale => 8, :default => 2.0,   :null => false
    t.decimal  "dollarAwardAmount",                     :precision => 18, :scale => 8, :default => 0.2,   :null => false
    t.boolean  "isNotificationSuccessful",                                             :default => false, :null => false
    t.boolean  "isRedeemed",                                                           :default => false, :null => false
    t.datetime "created",                                                                                 :null => false
    t.datetime "modified",                                                                                :null => false
    t.boolean  "isActive",                                                             :default => true,  :null => false
  end

  create_table "business_rule_reasons", :force => true do |t|
    t.string   "name",        :limit => 250,                   :null => false
    t.text     "description",                                  :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.boolean  "is_active",                  :default => true, :null => false
  end

  create_table "cachedBankGeographicRegions", :primary_key => "cachedBankGeographicRegionID", :force => true do |t|
    t.integer  "contentServiceID",                                 :null => false
    t.string   "geographicRegion", :limit => 50,                   :null => false
    t.integer  "createdBy",                      :default => 0,    :null => false
    t.datetime "created",                                          :null => false
    t.integer  "modifiedBy",                     :default => 0,    :null => false
    t.datetime "modified",                                         :null => false
    t.boolean  "isActive",                       :default => true, :null => false
  end

  create_table "cachedBanks", :primary_key => "cachedBankID", :force => true do |t|
    t.integer  "contentServiceID",                                  :null => false
    t.integer  "organizationID",                                    :null => false
    t.string   "bankName",         :limit => 250,                   :null => false
    t.string   "mfaType",          :limit => 50
    t.integer  "createdBy",                       :default => 0,    :null => false
    t.datetime "created",                                           :null => false
    t.integer  "modifiedBy",                      :default => 0,    :null => false
    t.datetime "modified",                                          :null => false
    t.boolean  "isActive",                        :default => true, :null => false
  end

  create_table "cachedLoginForms", :primary_key => "cachedLoginFormID", :force => true do |t|
    t.integer  "contentServiceID",                   :null => false
    t.text     "xmlData",                            :null => false
    t.integer  "createdBy",        :default => 0,    :null => false
    t.datetime "created",                            :null => false
    t.integer  "modifiedBy",       :default => 0,    :null => false
    t.datetime "modified",                           :null => false
    t.boolean  "isActive",         :default => true, :null => false
  end

  create_table "campaignLandingPages", :primary_key => "campaignLandingPageID", :force => true do |t|
    t.string "campaignLandingPage", :limit => 250, :null => false
    t.string "fuseaction",          :limit => 250, :null => false
  end

  create_table "campaignTypes", :primary_key => "campaignTypeID", :force => true do |t|
    t.string "campaignType", :limit => 250
  end

  create_table "campaigns", :primary_key => "campaignID", :force => true do |t|
    t.string   "name",       :limit => 250
    t.string   "mediaType",  :limit => 250
    t.string   "creative",   :limit => 1000
    t.boolean  "isIncent",                   :default => false, :null => false
    t.string   "urlCParam",  :limit => 1000
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created",                                       :null => false
    t.datetime "modified",                                      :null => false
    t.boolean  "isActive",                   :default => true,  :null => false
  end

  create_table "charities", :primary_key => "charityID", :force => true do |t|
    t.string   "charity",           :limit => 300,                    :null => false
    t.string   "description",       :limit => 1000
    t.string   "logoURL",           :limit => 300
    t.integer  "virtualCurrencyID",                                   :null => false
    t.datetime "created",                                             :null => false
    t.datetime "modified",                                            :null => false
    t.boolean  "isActive",                          :default => true, :null => false
  end

  create_table "charityChapters", :primary_key => "charityChapterID", :force => true do |t|
    t.integer  "charityID",                                  :null => false
    t.string   "chapter",   :limit => 300,                   :null => false
    t.string   "location",  :limit => 500,                   :null => false
    t.datetime "created",                                    :null => false
    t.datetime "modified",                                   :null => false
    t.boolean  "isActive",                 :default => true, :null => false
  end

  create_table "checkins", :force => true do |t|
    t.integer  "user_id"
    t.string   "message"
    t.decimal  "lat",           :precision => 12, :scale => 8
    t.decimal  "lng",           :precision => 12, :scale => 8
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.integer  "advertiser_id"
    t.boolean  "to_facebook",                                  :default => false
    t.boolean  "to_twitter",                                   :default => false
  end

  create_table "clickTypes", :primary_key => "clickTypeID", :force => true do |t|
    t.string   "name",        :limit => 30,                    :null => false
    t.string   "description", :limit => 200
    t.integer  "createdBy",                  :default => 0,    :null => false
    t.datetime "created",                                      :null => false
    t.integer  "modifiedBy",                 :default => 0,    :null => false
    t.datetime "modified",                                     :null => false
    t.boolean  "isActive",                   :default => true, :null => false
  end

  create_table "clicks", :primary_key => "clickID", :force => true do |t|
    t.integer  "userID",                    :limit => 8,                     :null => false
    t.integer  "clickTypeID",                                                :null => false
    t.integer  "campaignID"
    t.integer  "advertiserCampaignID",      :limit => 8
    t.integer  "affiliateID"
    t.string   "subID",                     :limit => 100
    t.string   "ip",                        :limit => 15
    t.integer  "isValidAdvertiserCampaign",                :default => 1,    :null => false
    t.integer  "createdBy",                                :default => 0,    :null => false
    t.datetime "created",                                                    :null => false
    t.integer  "modifiedBy",                               :default => 0,    :null => false
    t.datetime "modified",                                                   :null => false
    t.boolean  "isActive",                                 :default => true, :null => false
  end

  create_table "client_applications", :force => true do |t|
    t.string   "name"
    t.integer  "virtual_currency_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "contest_blacklisted_user_ids", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  create_table "contest_prize_levels", :force => true do |t|
    t.integer  "contest_id"
    t.integer  "award_count"
    t.integer  "dollar_amount"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "contest_winners", :force => true do |t|
    t.integer  "contest_id"
    t.integer  "user_id"
    t.integer  "prize_level_id"
    t.integer  "admin_user_id"
    t.boolean  "winner"
    t.boolean  "rejected"
    t.datetime "finalized_at"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "contests", :force => true do |t|
    t.string   "description"
    t.string   "image",                     :limit => 100
    t.text     "prize"
    t.datetime "start_time"
    t.datetime "end_time"
    t.text     "terms_and_conditions"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.datetime "finalized_at"
    t.string   "non_linked_image"
    t.text     "entry_notification"
    t.text     "prize_description"
    t.text     "entry_post_title"
    t.text     "entry_post_body"
    t.text     "winning_post_title"
    t.text     "winning_post_body"
    t.text     "interstitial_title"
    t.text     "interstitial_bold_text"
    t.text     "interstitial_body_text"
    t.string   "interstitial_share_button"
    t.string   "interstitial_reg_link"
    t.text     "disclaimer_text"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "dm_dates", :id => false, :force => true do |t|
    t.integer  "dm_dateKey",                      :null => false
    t.datetime "date"
    t.integer  "dayOfMonth"
    t.integer  "month"
    t.string   "monthName",         :limit => 20
    t.integer  "weekOfMonth"
    t.integer  "year"
    t.integer  "weekOfYear"
    t.string   "quarter",           :limit => 20
    t.string   "dayOfWeek",         :limit => 20
    t.datetime "firstMondayOfWeek"
  end

  create_table "duplicate_registration_attempts", :force => true do |t|
    t.integer  "user_id",                       :limit => 8
    t.integer  "existing_users_institution_id", :limit => 8
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "entries", :force => true do |t|
    t.integer  "contest_id"
    t.integer  "user_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "provider",         :limit => 25
    t.integer  "computed_entries"
    t.integer  "multiplier"
    t.integer  "referral_entries"
    t.string   "source",           :limit => 50
  end

  create_table "errorLog", :primary_key => "errorLogID", :force => true do |t|
    t.string   "severity",     :limit => 10,                 :null => false
    t.string   "category",     :limit => 100,                :null => false
    t.datetime "logdate",                                    :null => false
    t.string   "appendername", :limit => 100,                :null => false
    t.text     "message"
    t.text     "cfc"
    t.text     "method"
    t.text     "arguments"
    t.text     "returnVals"
    t.text     "errorMessage"
    t.text     "stackTrace"
    t.text     "tagContext"
    t.text     "type"
    t.text     "cgi"
    t.integer  "userID",       :limit => 8
    t.text     "userSession"
    t.integer  "pathID",                      :default => 0, :null => false
  end

  create_table "eventTypes", :primary_key => "eventTypeID", :force => true do |t|
    t.string   "name",        :limit => 500,                   :null => false
    t.string   "description", :limit => 200
    t.integer  "createdBy",                  :default => 0,    :null => false
    t.datetime "created",                                      :null => false
    t.integer  "modifiedBy",                 :default => 0,    :null => false
    t.datetime "modified",                                     :null => false
    t.boolean  "isActive",                   :default => true, :null => false
  end

  create_table "events", :primary_key => "eventID", :force => true do |t|
    t.integer  "userID",                   :limit => 8
    t.integer  "eventTypeID",                                               :null => false
    t.integer  "campaignID_old"
    t.integer  "advertiserCampaignID_old"
    t.integer  "affiliateID"
    t.string   "subID",                    :limit => 100
    t.string   "ip",                       :limit => 15
    t.datetime "created",                                                   :null => false
    t.datetime "modified",                                                  :null => false
    t.boolean  "isActive",                                :default => true, :null => false
    t.string   "subID2",                   :limit => 200
    t.string   "subID3",                   :limit => 200
    t.string   "subID4",                   :limit => 200
    t.integer  "pathID",                                  :default => 0,    :null => false
    t.integer  "offersVirtualCurrencyID"
    t.integer  "campaignID"
    t.integer  "landing_page_id"
  end

  create_table "facebookPermissions", :primary_key => "facebookPermissionID", :force => true do |t|
    t.string   "facebookPermission", :limit => 200,                   :null => false
    t.integer  "createdBy",                         :default => 0,    :null => false
    t.datetime "created",                                             :null => false
    t.integer  "modifiedBy",                        :default => 0,    :null => false
    t.datetime "modified",                                            :null => false
    t.boolean  "isActive",                          :default => true, :null => false
  end

  create_table "fishyTransactions", :primary_key => "fishyTransactionsID", :force => true do |t|
    t.integer  "userID",                      :limit => 8,                                  :null => false
    t.integer  "usersBankProductAccountID",                                                 :null => false
    t.integer  "usersBankProductID",                                                        :null => false
    t.integer  "usersBankID",                                                               :null => false
    t.integer  "yodleeTransactionID",         :limit => 8,                                  :null => false
    t.string   "yodleeContainerType",         :limit => 100,                                :null => false
    t.text     "yodleeDescription",                                                         :null => false
    t.datetime "postDate",                                                                  :null => false
    t.integer  "yodleeCategoryID",                                                          :null => false
    t.string   "yodleeCategoryName",          :limit => 300,                                :null => false
    t.decimal  "transactionAmount",                          :precision => 20, :scale => 6, :null => false
    t.string   "currencyCode",                :limit => 10,                                 :null => false
    t.string   "yodleeCategorizationKeyword", :limit => 300,                                :null => false
    t.string   "yodleeTransactionType",       :limit => 300,                                :null => false
    t.datetime "created",                                                                   :null => false
  end

  create_table "freeAwards", :primary_key => "freeAwardID", :force => true do |t|
    t.integer  "userID",                   :limit => 8,                                                      :null => false
    t.decimal  "dollarAwardAmount",                        :precision => 12, :scale => 6,                    :null => false
    t.decimal  "currencyAwardAmount",                      :precision => 18, :scale => 6,                    :null => false
    t.integer  "usersVirtualCurrencyID",                                                                     :null => false
    t.integer  "virtualCurrencyID",                                                                          :null => false
    t.integer  "awardTypeID",                                                                                :null => false
    t.boolean  "isNotificationSuccessful",                                                :default => false, :null => false
    t.boolean  "isSuccessful",                                                            :default => false, :null => false
    t.string   "externalUserID",           :limit => 250
    t.string   "additionalInfo",           :limit => 1000
    t.datetime "created",                                                                                    :null => false
    t.datetime "modified",                                                                                   :null => false
    t.boolean  "isActive",                                                                :default => true,  :null => false
    t.string   "awardID",                  :limit => 200
    t.integer  "qualifyingAwardID",        :limit => 8
    t.integer  "checkin_id",               :limit => 8
  end

  create_table "giftCardClicks", :primary_key => "giftCardClickId", :force => true do |t|
    t.integer  "userId",     :limit => 8
    t.integer  "giftCardId"
    t.string   "ip",         :limit => 15
    t.datetime "created",                  :null => false
    t.datetime "modified",                 :null => false
    t.boolean  "isActive",                 :null => false
  end

  create_table "giftCards", :primary_key => "giftCardId", :force => true do |t|
    t.string   "name",                                                            :null => false
    t.decimal  "faceValue",                        :precision => 18, :scale => 0
    t.decimal  "revShare",                         :precision => 18, :scale => 0, :null => false
    t.string   "logoURL",          :limit => 500
    t.string   "url",              :limit => 500
    t.text     "description"
    t.string   "shortDescription", :limit => 1000
    t.text     "terms"
    t.integer  "pointAward",                                                      :null => false
    t.decimal  "perDollarSpent",                   :precision => 18, :scale => 0, :null => false
    t.integer  "displayOrder"
    t.datetime "created"
    t.datetime "modified"
    t.boolean  "isActive",                                                        :null => false
  end

  create_table "giftCardsTiers", :id => false, :force => true do |t|
    t.integer  "giftCardsTierId",                                  :null => false
    t.integer  "gitCardId",                                        :null => false
    t.decimal  "dollarAwardAmount", :precision => 18, :scale => 0, :null => false
    t.datetime "created",                                          :null => false
    t.datetime "modified",                                         :null => false
    t.boolean  "isActive",                                         :null => false
  end

  create_table "globalExcludeTerms", :primary_key => "globalExcludeTermID", :force => true do |t|
    t.string   "excludeTerm", :limit => 200,                   :null => false
    t.datetime "created",                                      :null => false
    t.datetime "modified",                                     :null => false
    t.boolean  "isActive",                   :default => true, :null => false
  end

  create_table "global_exclude_patterns", :force => true do |t|
    t.string   "regular_expression", :limit => 200,                   :null => false
    t.text     "comments"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.boolean  "is_active",                         :default => true, :null => false
  end

  create_table "global_login_tokens", :force => true do |t|
    t.datetime "expires_at"
    t.string   "token",        :limit => 60
    t.string   "redirect_url"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "hero_promotion_clicks", :force => true do |t|
    t.integer  "hero_promotion_id"
    t.integer  "user_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "image"
  end

  create_table "hero_promotion_users", :force => true do |t|
    t.integer "hero_promotion_id"
    t.integer "user_id"
  end

  add_index "hero_promotion_users", ["hero_promotion_id", "user_id"], :name => "index_hero_promotion_users_on_hero_promotion_id_and_user_id"

  create_table "hero_promotions", :force => true do |t|
    t.string   "image_url_one"
    t.string   "title"
    t.integer  "display_order"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "name"
    t.boolean  "is_active",             :default => true
    t.boolean  "show_linked_users"
    t.boolean  "show_non_linked_users"
    t.text     "link_one"
    t.string   "link_two"
    t.string   "image_url_two"
    t.boolean  "same_tab_one"
    t.boolean  "same_tab_two"
    t.datetime "end_date"
    t.datetime "start_date"
  end

  create_table "institutions", :primary_key => "institutionID", :force => true do |t|
    t.integer  "intuitInstitutionID",                                   :null => false
    t.text     "institutionName",                                       :null => false
    t.text     "homeURL"
    t.string   "phoneNumber",         :limit => 200
    t.text     "emailAddress"
    t.text     "specialText"
    t.string   "currencyCode",        :limit => 100
    t.boolean  "isVirtual",                          :default => false, :null => false
    t.string   "hashValue",           :limit => 200,                    :null => false
    t.boolean  "isSupported",                        :default => true,  :null => false
    t.datetime "dropSupportDate"
    t.datetime "deactivationDate"
    t.datetime "created",                                               :null => false
    t.datetime "modified",                                              :null => false
    t.boolean  "isActive",                           :default => true,  :null => false
    t.string   "logoURL",             :limit => 500
  end

  create_table "institutionsStaging", :primary_key => "institutionStagingID", :force => true do |t|
    t.integer  "intuitInstitutionID",                                   :null => false
    t.text     "institutionName",                                       :null => false
    t.text     "homeURL"
    t.string   "phoneNumber",         :limit => 200
    t.text     "emailAddress"
    t.text     "specialText"
    t.string   "currencyCode",        :limit => 100
    t.boolean  "isVirtual",                          :default => false, :null => false
    t.string   "hashValue",           :limit => 200,                    :null => false
    t.datetime "created",                                               :null => false
    t.boolean  "isActive",                           :default => true,  :null => false
  end

  create_table "institutionsStaging_copy_for_testing", :primary_key => "institutionStaging_copy_for_testing_ID", :force => true do |t|
    t.integer  "intuitInstitutionID",                                   :null => false
    t.text     "institutionName",                                       :null => false
    t.text     "homeURL"
    t.string   "phoneNumber",         :limit => 200
    t.text     "emailAddress"
    t.text     "specialText"
    t.string   "currencyCode",        :limit => 100
    t.boolean  "isVirtual",                          :default => false, :null => false
    t.string   "hashValue",           :limit => 200,                    :null => false
    t.datetime "created",                                               :null => false
    t.boolean  "isActive",                           :default => true,  :null => false
  end

  create_table "intuitErrors", :primary_key => "intuitErrorID", :force => true do |t|
    t.string  "errorPrefix",        :limit => 100,                    :null => false
    t.string  "errorDescription",   :limit => 500,                    :null => false
    t.string  "userMessage",        :limit => 500
    t.boolean "isLoginError",                      :default => false, :null => false
    t.boolean "isMfaError",                        :default => false, :null => false
    t.boolean "isActive",                          :default => true,  :null => false
    t.boolean "sendReverification",                :default => false, :null => false
  end

  create_table "intuit_accounts_to_remove", :force => true do |t|
    t.integer  "user_id"
    t.integer  "intuit_account_id",    :limit => 8
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "users_institution_id"
  end

  create_table "intuit_archived_transactions", :force => true do |t|
    t.integer  "user_id",                     :limit => 8,                                                     :null => false
    t.integer  "users_institution_id",        :limit => 8,                                                     :null => false
    t.integer  "uia_account_id",              :limit => 8,                                                     :null => false
    t.integer  "account_id",                  :limit => 8,                                                     :null => false
    t.integer  "intuit_transaction_id",       :limit => 8,                                                     :null => false
    t.datetime "post_date",                                                                                    :null => false
    t.decimal  "amount",                                      :precision => 20, :scale => 6,                   :null => false
    t.text     "payee_name",                                                                                   :null => false
    t.string   "hashed_value",                :limit => 250,                                                   :null => false
    t.text     "normalized_payee_name"
    t.text     "merchant"
    t.integer  "sic"
    t.string   "source",                      :limit => 250
    t.string   "category_name",               :limit => 250
    t.string   "context_type",                :limit => 250
    t.text     "schedule_c"
    t.integer  "job_id",                                                                                       :null => false
    t.integer  "task_id",                                                                                      :null => false
    t.integer  "business_rule_reason_id",                                                                      :null => false
    t.integer  "line_number",                 :limit => 8
    t.text     "institution_transaction_id"
    t.string   "currency_type",               :limit => 100
    t.integer  "advertiser_id"
    t.integer  "users_award_period_id",       :limit => 8
    t.integer  "offer_id"
    t.integer  "tier_id"
    t.integer  "offers_virtual_currency_id"
    t.integer  "users_virtual_currency_id",   :limit => 8
    t.integer  "virtual_currency_id"
    t.datetime "user_date"
    t.datetime "award_begin_date"
    t.datetime "fuzzy_award_end_date"
    t.datetime "offer_begin_date"
    t.datetime "fuzzy_offer_end_date"
    t.datetime "tier_begin_date"
    t.datetime "fuzzy_tier_end_date"
    t.datetime "account_begin_date"
    t.datetime "fuzzy_account_end_date"
    t.integer  "global_exclude_pattern_id"
    t.integer  "search_pattern_id"
    t.integer  "exclude_pattern_id"
    t.integer  "suspicious_pattern_id"
    t.decimal  "currency_award_amount",                       :precision => 20, :scale => 6
    t.decimal  "dollar_award_amount",                         :precision => 20, :scale => 6
    t.decimal  "minimum_purchase_amount",                     :precision => 20, :scale => 6
    t.decimal  "percent_award_amount",                        :precision => 20, :scale => 6
    t.decimal  "exchange_rate",                               :precision => 20, :scale => 6
    t.string   "external_user_id",            :limit => 250
    t.string   "additional_info",             :limit => 1000
    t.boolean  "is_eligible_for_free_awards"
    t.boolean  "is_modified_by_intuit"
    t.boolean  "is_over_minimum_amount",                                                                       :null => false
    t.boolean  "is_in_wallet",                                                                                 :null => false
    t.boolean  "is_return",                                                                                    :null => false
    t.boolean  "is_intuit_pending",                                                                            :null => false
    t.boolean  "is_search_pattern_pending",                                                                    :null => false
    t.boolean  "is_nonqualified",                                                                              :null => false
    t.boolean  "is_qualified",                                                                                 :null => false
    t.datetime "created_at",                                                                                   :null => false
    t.datetime "updated_at",                                                                                   :null => false
    t.boolean  "is_active",                                                                  :default => true, :null => false
    t.text     "memo"
  end

  create_table "intuit_fishy_transactions", :force => true do |t|
    t.integer  "user_id",                     :limit => 8,                                                     :null => false
    t.integer  "users_institution_id",        :limit => 8,                                                     :null => false
    t.integer  "uia_account_id",              :limit => 8,                                                     :null => false
    t.integer  "account_id",                  :limit => 8,                                                     :null => false
    t.integer  "intuit_transaction_id",       :limit => 8,                                                     :null => false
    t.datetime "post_date",                                                                                    :null => false
    t.decimal  "amount",                                      :precision => 20, :scale => 6,                   :null => false
    t.text     "payee_name",                                                                                   :null => false
    t.string   "hashed_value",                :limit => 250,                                                   :null => false
    t.text     "normalized_payee_name"
    t.text     "merchant"
    t.integer  "sic"
    t.string   "source",                      :limit => 250
    t.string   "category_name",               :limit => 250
    t.string   "context_type",                :limit => 250
    t.text     "schedule_c"
    t.integer  "job_id",                                                                                       :null => false
    t.integer  "task_id",                                                                                      :null => false
    t.integer  "business_rule_reason_id",                                                                      :null => false
    t.integer  "line_number",                 :limit => 8
    t.text     "institution_transaction_id"
    t.string   "currency_type",               :limit => 100
    t.integer  "advertiser_id"
    t.integer  "users_award_period_id",       :limit => 8
    t.integer  "offer_id"
    t.integer  "tier_id"
    t.integer  "offers_virtual_currency_id"
    t.integer  "users_virtual_currency_id",   :limit => 8
    t.integer  "virtual_currency_id"
    t.datetime "user_date"
    t.datetime "award_begin_date"
    t.datetime "fuzzy_award_end_date"
    t.datetime "offer_begin_date"
    t.datetime "fuzzy_offer_end_date"
    t.datetime "tier_begin_date"
    t.datetime "fuzzy_tier_end_date"
    t.datetime "account_begin_date"
    t.datetime "fuzzy_account_end_date"
    t.integer  "global_exclude_pattern_id"
    t.integer  "search_pattern_id"
    t.integer  "exclude_pattern_id"
    t.decimal  "currency_award_amount",                       :precision => 20, :scale => 6
    t.decimal  "dollar_award_amount",                         :precision => 20, :scale => 6
    t.decimal  "minimum_purchase_amount",                     :precision => 20, :scale => 6
    t.decimal  "percent_award_amount",                        :precision => 20, :scale => 6
    t.decimal  "exchange_rate",                               :precision => 20, :scale => 6
    t.string   "external_user_id",            :limit => 250
    t.string   "additional_info",             :limit => 1000
    t.integer  "other_fishy_user_id",         :limit => 8
    t.integer  "suspicious_pattern_id"
    t.boolean  "is_eligible_for_free_awards"
    t.boolean  "is_over_minimum_amount",                                                                       :null => false
    t.boolean  "is_in_wallet",                                                                                 :null => false
    t.boolean  "is_return",                                                                                    :null => false
    t.boolean  "is_fishy",                                                                                     :null => false
    t.boolean  "is_intuit_pending",                                                                            :null => false
    t.boolean  "is_search_pattern_pending",                                                                    :null => false
    t.boolean  "is_nonqualified",                                                                              :null => false
    t.boolean  "is_qualified",                                                                                 :null => false
    t.datetime "created_at",                                                                                   :null => false
    t.datetime "updated_at",                                                                                   :null => false
    t.boolean  "is_active",                                                                  :default => true, :null => false
    t.text     "memo"
    t.boolean  "is_confirmed_fishy"
  end

  create_table "intuit_requests", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "processed"
    t.text     "response"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "intuit_transactions", :force => true do |t|
    t.integer  "user_id",                    :limit => 8,                                                     :null => false
    t.integer  "users_institution_id",       :limit => 8,                                                     :null => false
    t.integer  "uia_account_id",             :limit => 8,                                                     :null => false
    t.integer  "account_id",                 :limit => 8,                                                     :null => false
    t.integer  "intuit_transaction_id",      :limit => 8,                                                     :null => false
    t.datetime "post_date",                                                                                   :null => false
    t.decimal  "amount",                                     :precision => 20, :scale => 6,                   :null => false
    t.text     "payee_name",                                                                                  :null => false
    t.string   "hashed_value",               :limit => 250,                                                   :null => false
    t.text     "normalized_payee_name"
    t.text     "merchant"
    t.integer  "sic"
    t.string   "source",                     :limit => 250
    t.string   "category_name",              :limit => 250
    t.string   "context_type",               :limit => 250
    t.text     "schedule_c"
    t.integer  "job_id",                                                                                      :null => false
    t.integer  "task_id",                                                                                     :null => false
    t.text     "institution_transaction_id"
    t.string   "currency_type",              :limit => 100
    t.integer  "advertiser_id",                                                                               :null => false
    t.integer  "users_award_period_id",      :limit => 8
    t.integer  "offer_id",                                                                                    :null => false
    t.integer  "tier_id",                                                                                     :null => false
    t.integer  "offers_virtual_currency_id",                                                                  :null => false
    t.integer  "users_virtual_currency_id",  :limit => 8,                                                     :null => false
    t.integer  "virtual_currency_id",                                                                         :null => false
    t.datetime "user_date"
    t.integer  "search_pattern_id",                                                                           :null => false
    t.decimal  "currency_award_amount",                      :precision => 20, :scale => 6
    t.decimal  "dollar_award_amount",                        :precision => 20, :scale => 6
    t.string   "external_user_id",           :limit => 250
    t.string   "additional_info",            :limit => 1000
    t.datetime "created_at",                                                                                  :null => false
    t.datetime "updated_at",                                                                                  :null => false
    t.boolean  "is_active",                                                                 :default => true, :null => false
    t.text     "memo"
  end

  create_table "intuit_transactions_staging", :force => true do |t|
    t.integer  "user_id",                     :limit => 8,                                                     :null => false
    t.integer  "users_institution_id",        :limit => 8,                                                     :null => false
    t.integer  "uia_account_id",              :limit => 8,                                                     :null => false
    t.integer  "account_id",                  :limit => 8,                                                     :null => false
    t.integer  "intuit_transaction_id",       :limit => 8,                                                     :null => false
    t.datetime "post_date",                                                                                    :null => false
    t.decimal  "amount",                                      :precision => 20, :scale => 6,                   :null => false
    t.text     "payee_name",                                                                                   :null => false
    t.string   "hashed_value",                :limit => 250,                                                   :null => false
    t.text     "normalized_payee_name"
    t.text     "merchant"
    t.integer  "sic"
    t.string   "source",                      :limit => 250
    t.string   "category_name",               :limit => 250
    t.string   "context_type",                :limit => 250
    t.text     "schedule_c"
    t.integer  "job_id",                                                                                       :null => false
    t.integer  "task_id",                                                                                      :null => false
    t.integer  "business_rule_reason_id",                                                                      :null => false
    t.integer  "line_number",                 :limit => 8
    t.text     "institution_transaction_id"
    t.string   "currency_type",               :limit => 100
    t.integer  "advertiser_id"
    t.integer  "users_award_period_id",       :limit => 8
    t.integer  "offer_id"
    t.integer  "tier_id"
    t.integer  "offers_virtual_currency_id"
    t.integer  "users_virtual_currency_id",   :limit => 8
    t.integer  "virtual_currency_id"
    t.datetime "user_date"
    t.datetime "award_begin_date"
    t.datetime "fuzzy_award_end_date"
    t.datetime "offer_begin_date"
    t.datetime "fuzzy_offer_end_date"
    t.datetime "tier_begin_date"
    t.datetime "fuzzy_tier_end_date"
    t.datetime "account_begin_date"
    t.datetime "fuzzy_account_end_date"
    t.integer  "global_exclude_pattern_id"
    t.integer  "search_pattern_id"
    t.integer  "exclude_pattern_id"
    t.decimal  "currency_award_amount",                       :precision => 20, :scale => 6
    t.decimal  "dollar_award_amount",                         :precision => 20, :scale => 6
    t.decimal  "minimum_purchase_amount",                     :precision => 20, :scale => 6
    t.decimal  "percent_award_amount",                        :precision => 20, :scale => 6
    t.decimal  "exchange_rate",                               :precision => 20, :scale => 6
    t.string   "external_user_id",            :limit => 250
    t.string   "additional_info",             :limit => 1000
    t.integer  "other_fishy_user_id",         :limit => 8
    t.integer  "suspicious_pattern_id"
    t.boolean  "is_eligible_for_free_awards"
    t.boolean  "is_over_minimum_amount",                                                                       :null => false
    t.boolean  "is_in_wallet",                                                                                 :null => false
    t.boolean  "is_return",                                                                                    :null => false
    t.boolean  "is_fishy",                                                                                     :null => false
    t.boolean  "is_intuit_pending",                                                                            :null => false
    t.boolean  "is_search_pattern_pending",                                                                    :null => false
    t.boolean  "is_nonqualified",                                                                              :null => false
    t.boolean  "is_qualified",                                                                                 :null => false
    t.boolean  "is_duplicate"
    t.datetime "created_at",                                                                                   :null => false
    t.datetime "updated_at",                                                                                   :null => false
    t.boolean  "is_active",                                                                  :default => true, :null => false
    t.text     "memo"
  end

  create_table "job_queues", :force => true do |t|
    t.integer  "job_type_id"
    t.integer  "datekey"
    t.string   "hostname",     :limit => 250
    t.boolean  "is_ready",                    :default => false, :null => false
    t.boolean  "is_halted",                   :default => false, :null => false
    t.boolean  "is_failed",                   :default => false, :null => false
    t.boolean  "is_complete",                 :default => false, :null => false
    t.datetime "completed_at"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.boolean  "is_active",                   :default => true,  :null => false
  end

  add_index "job_queues", ["datekey", "job_type_id", "is_active", "completed_at"], :name => "unique_datekey_is_complete_is_active", :unique => true

  create_table "job_types", :force => true do |t|
    t.string   "name",       :limit => 100
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.boolean  "is_active",                 :default => true, :null => false
  end

  create_table "jobs", :force => true do |t|
    t.string   "job_type",             :limit => 250,                    :null => false
    t.integer  "queued_command_id",                                      :null => false
    t.text     "command_line",                                           :null => false
    t.string   "hostname",             :limit => 250,                    :null => false
    t.integer  "estimated_task_count",                                   :null => false
    t.integer  "pid",                                                    :null => false
    t.integer  "starting_id",          :limit => 8
    t.integer  "ending_id",            :limit => 8
    t.string   "id_key_name",          :limit => 250
    t.text     "error_message"
    t.datetime "completed_at"
    t.boolean  "is_complete",                         :default => false, :null => false
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.boolean  "is_active",                           :default => true,  :null => false
    t.boolean  "is_failed",                           :default => false, :null => false
  end

  add_index "jobs", ["queued_command_id"], :name => "IX_jobs_queued_command_id"

  create_table "landing_pages", :force => true do |t|
    t.string   "name"
    t.string   "partial_path"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "loot", :primary_key => "lootID", :force => true do |t|
    t.string   "name",              :limit => 500,                                                   :null => false
    t.decimal  "exchangeRate",                      :precision => 18, :scale => 6
    t.decimal  "faceValue_old",                     :precision => 18, :scale => 6
    t.string   "awardCode",         :limit => 100,                                                   :null => false
    t.string   "redemptionMessage", :limit => 1000
    t.datetime "created"
    t.datetime "modified"
    t.boolean  "isActive",                                                         :default => true, :null => false
    t.integer  "displayOrder"
    t.string   "logoURL",           :limit => 500
    t.text     "description"
    t.text     "terms"
    t.boolean  "isTangoRedemption",                                                :default => true, :null => false
    t.string   "shortDescription",  :limit => 1000
    t.boolean  "is_redeemable"
  end

  create_table "lootAmounts", :primary_key => "lootAmountID", :force => true do |t|
    t.integer  "lootID",                                                             :null => false
    t.decimal  "dollarAwardAmount", :precision => 12, :scale => 6,                   :null => false
    t.datetime "created",                                                            :null => false
    t.datetime "modified",                                                           :null => false
    t.boolean  "isActive",                                         :default => true, :null => false
  end

  create_table "matomyConversions", :primary_key => "matomyConversionID", :force => true do |t|
    t.integer  "userID",      :limit => 8,                       :null => false
    t.string   "clickID",     :limit => 500,                     :null => false
    t.string   "url",         :limit => 1000
    t.boolean  "isProcessed",                 :default => false, :null => false
    t.datetime "processedOn"
    t.text     "response"
    t.datetime "created",                                        :null => false
    t.datetime "modified",                                       :null => false
    t.boolean  "isActive",                    :default => true,  :null => false
  end

  create_table "mfaErrors", :primary_key => "mfaErrorID", :force => true do |t|
    t.string   "mfaType",              :limit => 200
    t.string   "responseCodeType",     :limit => 200
    t.string   "statusCode",           :limit => 200
    t.string   "DataUpdateStatus",     :limit => 200
    t.string   "userDataUpdateStatus", :limit => 200
    t.text     "submittedXML"
    t.text     "responseXML"
    t.datetime "created",                             :null => false
  end

  create_table "mobile_user_agents", :force => true do |t|
    t.string  "regular_expression"
    t.string  "search_type"
    t.string  "description"
    t.boolean "is_active",          :default => true
  end

  create_table "newsArticles", :primary_key => "newsArticleID", :force => true do |t|
    t.string   "source",          :limit => 200,                    :null => false
    t.string   "sourceLink",      :limit => 500,                    :null => false
    t.datetime "publishedOn",                                       :null => false
    t.string   "title",           :limit => 500,                    :null => false
    t.boolean  "hasMoreInfoLink",                :default => false, :null => false
    t.datetime "created",                                           :null => false
    t.boolean  "isActive",                       :default => true,  :null => false
  end

  create_table "nonQualifyingAwards", :primary_key => "nonQualifyingAwardID", :force => true do |t|
    t.integer  "userID",                   :limit => 8,                                                      :null => false
    t.string   "externalUserID",           :limit => 250
    t.integer  "usersVirtualCurrencyID",   :limit => 8,                                                      :null => false
    t.integer  "virtualCurrencyID",                                                                          :null => false
    t.string   "additionalInfo",           :limit => 1000
    t.integer  "yodleeTransactionID",      :limit => 8
    t.integer  "advertisersSearchTermID"
    t.decimal  "dollarAwardAmount",                        :precision => 12, :scale => 6,                    :null => false
    t.decimal  "currencyAwardAmount",                      :precision => 18, :scale => 6,                    :null => false
    t.boolean  "isNotificationSuccessful",                                                :default => false, :null => false
    t.boolean  "isSuccessful",                                                            :default => false, :null => false
    t.datetime "created",                                                                                    :null => false
    t.datetime "modified",                                                                                   :null => false
    t.boolean  "isActive",                                                                :default => true,  :null => false
    t.string   "awardID",                  :limit => 200
    t.integer  "advertiserID"
    t.decimal  "transactionAmount",                        :precision => 12, :scale => 6
    t.integer  "intuit_transaction_id",    :limit => 8
    t.integer  "search_pattern_id"
  end

  create_table "oauthTokens", :primary_key => "oauthTokenID", :force => true do |t|
    t.integer  "userID",                    :limit => 8,                     :null => false
    t.string   "encryptedOauthToken",       :limit => 500,                   :null => false
    t.string   "oauthTokenIV",              :limit => 500,                   :null => false
    t.string   "encryptedOauthTokenSecret", :limit => 500,                   :null => false
    t.string   "oauthTokenSecretIV",        :limit => 500,                   :null => false
    t.datetime "created",                                                    :null => false
    t.boolean  "isActive",                                 :default => true, :null => false
  end

  create_table "offers", :primary_key => "offerID", :force => true do |t|
    t.integer  "advertiserID",                                                                                                 :null => false
    t.datetime "startDate",                                                                                                    :null => false
    t.datetime "endDate",                                                                   :default => '2999-12-31 00:00:00', :null => false
    t.integer  "daysInAwardPeriod",                                                         :default => 0,                     :null => false
    t.decimal  "advertisersRevShare",                        :precision => 12, :scale => 6,                                    :null => false
    t.text     "detailText",                                                                                                   :null => false
    t.datetime "created",                                                                                                      :null => false
    t.datetime "modified",                                                                                                     :null => false
    t.boolean  "isActive",                                                                  :default => true,                  :null => false
    t.string   "advertiserName",              :limit => 250
    t.string   "logoURL",                     :limit => 500
    t.boolean  "isEligibleForFreeAwards",                                                   :default => true,                  :null => false
    t.boolean  "showOnWall",                                                                :default => true,                  :null => false
    t.boolean  "is_new"
    t.boolean  "show_end_date"
    t.boolean  "send_expiring_soon_reminder"
  end

  create_table "offersVirtualCurrencies", :primary_key => "offersVirtualCurrencyID", :force => true do |t|
    t.integer  "offerID",                                 :null => false
    t.integer  "virtualCurrencyID",                       :null => false
    t.integer  "displayOrder"
    t.datetime "created",                                 :null => false
    t.datetime "modified",                                :null => false
    t.boolean  "isActive",              :default => true, :null => false
    t.text     "detailText"
    t.boolean  "is_promotion"
    t.text     "promotion_description"
  end

  create_table "optIns", :primary_key => "optInId", :force => true do |t|
    t.string   "emailAddress", :limit => 1000,                    :null => false
    t.boolean  "isOptedIn",                    :default => false, :null => false
    t.datetime "created",                                         :null => false
    t.datetime "modified",                                        :null => false
  end

  create_table "partnerFreeAwards", :primary_key => "partnerFreeAwardID", :force => true do |t|
    t.integer  "userID",                     :limit => 8,                                                      :null => false
    t.string   "externalUserID",             :limit => 250,                                                    :null => false
    t.integer  "weightlessRedemptionTypeID",                                                                   :null => false
    t.integer  "usersVirtualCurrencyID",                                                                       :null => false
    t.integer  "virtualCurrencyID",                                                                            :null => false
    t.string   "additionalInfo",             :limit => 1000
    t.decimal  "dollarAwardAmount",                          :precision => 12, :scale => 6,                    :null => false
    t.decimal  "currencyAwardAmount",                        :precision => 18, :scale => 6,                    :null => false
    t.integer  "numberOfFailures",                                                          :default => 0,     :null => false
    t.boolean  "isSuccessful",                                                              :default => false, :null => false
    t.string   "postbackURL",                :limit => 1000
    t.integer  "lastHTTPStatus"
    t.string   "lastReturn",                 :limit => 4000
    t.integer  "partnerFreeAwardTypeID"
    t.datetime "created",                                                                                      :null => false
    t.datetime "modified",                                                                                     :null => false
    t.boolean  "isActive",                                                                  :default => true,  :null => false
  end

  create_table "partnerNonQualifyingAwards", :primary_key => "partnerNonQualifyingAwardID", :force => true do |t|
    t.integer  "userID",                  :limit => 8,                                                      :null => false
    t.string   "externalUserID",          :limit => 250
    t.integer  "usersVirtualCurrencyID",  :limit => 8,                                                      :null => false
    t.integer  "virtualCurrencyID",                                                                         :null => false
    t.string   "additionalInfo",          :limit => 1000
    t.integer  "yodleeTransactionID",     :limit => 8,                                                      :null => false
    t.integer  "advertisersSearchTermID",                                                                   :null => false
    t.decimal  "dollarAwardAmount",                       :precision => 12, :scale => 6,                    :null => false
    t.decimal  "currencyAwardAmount",                     :precision => 18, :scale => 6,                    :null => false
    t.integer  "numberOfFailures",                                                       :default => 0,     :null => false
    t.boolean  "isSuccessful",                                                           :default => false, :null => false
    t.string   "postbackURL",             :limit => 1000
    t.integer  "lastHTTPStatus"
    t.string   "lastReturn",              :limit => 4000
    t.datetime "created",                                                                                   :null => false
    t.datetime "modified",                                                                                  :null => false
    t.boolean  "isActive",                                                               :default => true,  :null => false
  end

  create_table "partnerQualifyingAwards", :primary_key => "partnerQualifyingAwardID", :force => true do |t|
    t.integer  "userID",                  :limit => 8,                                                      :null => false
    t.string   "externalUserID",          :limit => 250
    t.integer  "usersVirtualCurrencyID",  :limit => 8,                                                      :null => false
    t.integer  "virtualCurrencyID",       :limit => 8,                                                      :null => false
    t.string   "additionalInfo",          :limit => 1000
    t.integer  "yodleeTransactionID",     :limit => 8,                                                      :null => false
    t.integer  "advertisersSearchTermID",                                                                   :null => false
    t.decimal  "dollarAwardAmount",                       :precision => 12, :scale => 6
    t.decimal  "currencyAwardAmount",                     :precision => 18, :scale => 6
    t.integer  "numberOfFailures",                                                       :default => 0,     :null => false
    t.boolean  "isSuccessful",                                                           :default => false, :null => false
    t.string   "postbackURL",             :limit => 1000
    t.integer  "lastHTTPStatus"
    t.string   "lastReturn",              :limit => 4000
    t.datetime "created",                                                                                   :null => false
    t.datetime "modified",                                                                                  :null => false
    t.boolean  "isActive",                                                               :default => true,  :null => false
  end

  create_table "passwordResetRequests", :primary_key => "passwordResetRequestID", :force => true do |t|
    t.integer  "userID",             :limit => 8,                    :null => false
    t.string   "resetToken",         :limit => 50
    t.boolean  "isValid",                          :default => true, :null => false
    t.datetime "expirationDateTime",                                 :null => false
    t.integer  "createdBy",                        :default => 0,    :null => false
    t.datetime "created",                                            :null => false
    t.integer  "modifiedBy",                       :default => 0,    :null => false
    t.datetime "modified",                                           :null => false
    t.boolean  "isActive",                         :default => true, :null => false
  end

  create_table "password_resets", :force => true do |t|
    t.integer  "user_id"
    t.string   "token",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "password_resets", ["token"], :name => "index_password_resets_on_token", :unique => true

  create_table "path_page_attributes", :force => true do |t|
    t.integer "path_page_type_id",                                   :null => false
    t.string  "element_id",                                          :null => false
    t.string  "value",             :limit => 2000,                   :null => false
    t.boolean "is_active",                         :default => true, :null => false
  end

  create_table "path_page_options", :force => true do |t|
    t.integer "path_page_type_id"
    t.string  "name"
    t.string  "html"
    t.string  "value"
    t.string  "input_type"
    t.string  "is_active"
  end

  create_table "path_page_types", :force => true do |t|
    t.string  "name",                              :null => false
    t.string  "description"
    t.string  "view_name"
    t.string  "layout_name"
    t.string  "action",      :default => "render", :null => false
    t.string  "target"
    t.boolean "is_active",   :default => true,     :null => false
    t.string  "pre_execute"
  end

  create_table "path_pages", :force => true do |t|
    t.integer  "path_id",           :null => false
    t.integer  "path_page_type_id", :null => false
    t.integer  "priority",          :null => false
    t.string   "name",              :null => false
    t.string   "description"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "pre_execute"
  end

  create_table "paths", :primary_key => "pathID", :force => true do |t|
    t.string   "pathName",                                             :null => false
    t.string   "pathDescription",   :limit => 1000,                    :null => false
    t.datetime "startDate",                                            :null => false
    t.datetime "endDate"
    t.string   "objectPath",        :limit => 200,                     :null => false
    t.datetime "created",                                              :null => false
    t.datetime "modified",                                             :null => false
    t.boolean  "isActive",                          :default => true,  :null => false
    t.text     "jsonConfig"
    t.string   "final_destination"
    t.boolean  "is_mobile",                         :default => false
  end

  create_table "pending_jobs", :force => true do |t|
    t.integer  "job_queue_id",      :limit => 8
    t.integer  "begin_user_id",     :limit => 8
    t.integer  "end_user_id",       :limit => 8
    t.datetime "begin_date"
    t.datetime "end_date"
    t.integer  "fishy_user_id",     :limit => 8
    t.text     "command_template",                                  :null => false
    t.text     "notification_list"
    t.boolean  "is_blocking",                    :default => false, :null => false
    t.boolean  "is_serial",                      :default => false, :null => false
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.boolean  "is_active",                      :default => true,  :null => false
  end

  create_table "plink_admin_admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "plink_admin_admins", ["email"], :name => "index_plink_admin_admins_on_email", :unique => true

  create_table "postbackResults", :primary_key => "postbackResultID", :force => true do |t|
    t.integer  "userID",         :limit => 8,                       :null => false
    t.string   "awardID",        :limit => 50,                      :null => false
    t.integer  "awardTypeID"
    t.string   "postbackURL",    :limit => 1000
    t.integer  "lastHTTPStatus"
    t.string   "lastReturn",     :limit => 2000
    t.boolean  "isSuccessful",                   :default => false, :null => false
    t.string   "externalUserID", :limit => 250
    t.string   "additionalInfo", :limit => 1000
    t.datetime "created",                                           :null => false
    t.datetime "modified",                                          :null => false
    t.boolean  "isActive",                       :default => true,  :null => false
  end

  create_table "pre_execute_logs", :force => true do |t|
    t.text     "info"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "preferences", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.boolean  "value",      :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "promotions", :primary_key => "promotionID", :force => true do |t|
    t.integer  "offerID"
    t.string   "promotionName",         :limit => 100
    t.text     "promotionDisplayText"
    t.integer  "promotionDisplayOrder"
    t.string   "logoURL",               :limit => 1000
    t.datetime "beginDate",                                                                              :null => false
    t.datetime "endDate",                                                                                :null => false
    t.datetime "created",                                                                                :null => false
    t.datetime "modified",                                                                               :null => false
    t.boolean  "isActive",                                                             :default => true, :null => false
    t.decimal  "dollarAwardAmount",                     :precision => 12, :scale => 6
    t.string   "shortTerms",            :limit => 1000
  end

  create_table "push_notification_timestamps", :force => true do |t|
    t.datetime "time_stamp",                   :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "is_active",  :default => true, :null => false
  end

  create_table "qualifyingAwards", :primary_key => "qualifyingAwardID", :force => true do |t|
    t.integer  "userID",                          :limit => 8,                                                      :null => false
    t.integer  "yodleeTransactionID",             :limit => 8
    t.integer  "advertisersSearchTermID"
    t.integer  "virtualCurrencyID",               :limit => 8,                                                      :null => false
    t.integer  "usersVirtualCurrencyID",          :limit => 8,                                                      :null => false
    t.decimal  "dollarAwardAmount",                               :precision => 12, :scale => 6,                    :null => false
    t.decimal  "currencyAwardAmount",                             :precision => 18, :scale => 6,                    :null => false
    t.boolean  "isNotificationSuccessful",                                                       :default => false, :null => false
    t.boolean  "isSuccessful",                                                                   :default => false, :null => false
    t.string   "externalUserID",                  :limit => 250
    t.string   "additionalInfo",                  :limit => 1000
    t.datetime "created",                                                                                           :null => false
    t.datetime "modified",                                                                                          :null => false
    t.boolean  "isActive",                                                                       :default => true,  :null => false
    t.string   "awardID",                         :limit => 200
    t.decimal  "transactionAmount",                               :precision => 12, :scale => 6
    t.integer  "advertiserID"
    t.integer  "intuit_transaction_id",           :limit => 8
    t.integer  "search_pattern_id"
    t.boolean  "is_Push_Notification_Successful"
  end

  create_table "questionAnswers", :primary_key => "questionAnswerID", :force => true do |t|
    t.string   "question",                   :limit => 1000,                                                   :null => false
    t.string   "answer",                     :limit => 1000,                                                   :null => false
    t.integer  "userID",                     :limit => 8,                                                      :null => false
    t.boolean  "wasAwardedCredits",                                                         :default => false, :null => false
    t.decimal  "dollarAwardAmount",                          :precision => 12, :scale => 6, :default => 0.0,   :null => false
    t.integer  "weightlessUserRedemptionID",                                                :default => 0,     :null => false
    t.datetime "created",                                                                                      :null => false
    t.datetime "modified",                                                                                     :null => false
    t.boolean  "isActive",                                                                  :default => true,  :null => false
  end

  create_table "queued_commands", :force => true do |t|
    t.text     "command_template",                                        :null => false
    t.integer  "job_queue_id",          :limit => 8,                      :null => false
    t.integer  "queue_index",                                             :null => false
    t.boolean  "is_blocking",                          :default => false, :null => false
    t.boolean  "is_serial",                            :default => false, :null => false
    t.integer  "dependent_queue_index"
    t.integer  "begin_user_id",         :limit => 8
    t.integer  "end_user_id",           :limit => 8
    t.datetime "begin_date"
    t.datetime "end_date"
    t.integer  "estimated_cost"
    t.integer  "user_count"
    t.string   "hostname",              :limit => 250
    t.integer  "parent_job_id",         :limit => 8
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.boolean  "is_active",                            :default => true,  :null => false
    t.integer  "fishy_user_id",         :limit => 8
  end

  create_table "redemptionRequests", :primary_key => "redemptionRequestID", :force => true do |t|
    t.integer  "hipDigitalTicketID", :limit => 8
    t.integer  "retrievalTries",                  :default => 0,     :null => false
    t.boolean  "isComplete",                      :default => false, :null => false
    t.integer  "createdBy",                       :default => 0,     :null => false
    t.datetime "created",                                            :null => false
    t.integer  "modifiedBy",                      :default => 0,     :null => false
    t.datetime "modified",                                           :null => false
    t.boolean  "isActive",                        :default => true,  :null => false
  end

  create_table "redemptions", :primary_key => "redemptionID", :force => true do |t|
    t.integer  "userID",            :limit => 8,                                                     :null => false
    t.integer  "lootID",                                                                             :null => false
    t.integer  "fbUserID",          :limit => 8
    t.datetime "created"
    t.datetime "modified"
    t.boolean  "isActive",                                                        :default => true,  :null => false
    t.boolean  "isPending",                                                       :default => false, :null => false
    t.datetime "sentOn"
    t.decimal  "dollarAwardAmount",                :precision => 12, :scale => 6,                    :null => false
    t.string   "memo",              :limit => 500
    t.boolean  "isDenied",                                                        :default => false, :null => false
    t.integer  "tango_tracking_id"
    t.boolean  "tango_confirmed"
  end

  create_table "referralConversions", :primary_key => "referralConversionID", :force => true do |t|
    t.integer  "referredBy",                      :null => false
    t.integer  "createdUserID",                   :null => false
    t.datetime "created",                         :null => false
    t.boolean  "isActive",      :default => true, :null => false
  end

  create_table "referralTracking", :primary_key => "referralTrackingID", :force => true do |t|
    t.integer  "sentFrom",   :limit => 8,   :null => false
    t.string   "userAction", :limit => 500, :null => false
    t.datetime "created",                   :null => false
    t.datetime "modified",                  :null => false
  end

  create_table "registration_link_mappings", :force => true do |t|
    t.integer "affiliate_id"
    t.integer "campaign_id"
    t.integer "registration_link_id"
  end

  create_table "registration_links", :force => true do |t|
    t.integer  "affiliate_id"
    t.integer  "campaign_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "is_active"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.boolean  "mobile_detection_on"
  end

  create_table "registration_links_landing_pages", :force => true do |t|
    t.integer  "registration_link_id"
    t.integer  "landing_page_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "registration_links_share_pages", :force => true do |t|
    t.integer  "registration_link_id"
    t.integer  "share_page_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "retailFraudBucket", :primary_key => "retailFraudBucketId", :force => true do |t|
    t.integer  "userID",             :limit => 8,                                :null => false
    t.integer  "advertiserId",                                                   :null => false
    t.integer  "debitTransactions",                                              :null => false
    t.decimal  "debitSpendAmount",                :precision => 20, :scale => 6, :null => false
    t.integer  "creditTransactions",                                             :null => false
    t.decimal  "creditRefundAmount",              :precision => 20, :scale => 6, :null => false
    t.datetime "detectedDate",                                                   :null => false
    t.datetime "emailSent"
    t.datetime "ignoredDate"
    t.datetime "wallRemovedDate"
    t.datetime "wallAddedDate"
    t.boolean  "wallCurrentState"
    t.datetime "created"
    t.datetime "modified"
  end

  create_table "retailFraudBucketTransactions", :primary_key => "retailFraudBucketTransactionId", :force => true do |t|
    t.integer  "yodleeArchivedTransactionID", :limit => 8
    t.integer  "intuitArchivedTransactionId", :limit => 8
    t.integer  "userID",                      :limit => 8,                                :null => false
    t.integer  "advertiserId",                                                            :null => false
    t.decimal  "transactionAmount",                        :precision => 20, :scale => 6, :null => false
    t.text     "description",                                                             :null => false
    t.datetime "postDate",                                                                :null => false
    t.datetime "created",                                                                 :null => false
    t.datetime "modified",                                                                :null => false
  end

  create_table "saved_path_page_attributes", :force => true do |t|
    t.integer "path_id",                           :null => false
    t.integer "path_page_type_id",                 :null => false
    t.string  "element_id",                        :null => false
    t.string  "value",             :limit => 2000, :null => false
  end

  create_table "saved_path_page_options", :force => true do |t|
    t.integer  "path_id"
    t.integer  "path_page_type_id"
    t.string   "name"
    t.string   "html"
    t.string   "value"
    t.string   "input_type"
    t.boolean  "is_active"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "share_page_tracking", :force => true do |t|
    t.integer  "registration_link_id"
    t.integer  "share_page_id"
    t.integer  "user_id"
    t.boolean  "shared"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "share_pages", :force => true do |t|
    t.string   "name"
    t.string   "partial_path"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "social_networks", :force => true do |t|
    t.string  "name"
    t.string  "base_url"
    t.boolean "allows_sharing"
    t.boolean "is_active"
  end

  create_table "social_profiles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "social_network_id"
    t.string   "nickname"
    t.string   "remote_profile_id"
    t.string   "remote_avatar_url"
    t.string   "remote_profile_url"
    t.string   "email"
    t.string   "encrypted_oauth_token"
    t.boolean  "user_created"
    t.text     "all_fields"
    t.boolean  "is_active"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "stg_cachedBankGeographicRegions", :primary_key => "stg_cachedBankGeographicRegionID", :force => true do |t|
    t.integer "contentServiceID",               :null => false
    t.string  "geographicRegion", :limit => 50, :null => false
  end

  create_table "stg_cachedBanks", :primary_key => "stg_cachedBankID", :force => true do |t|
    t.integer "contentServiceID",                :null => false
    t.integer "organizationID",                  :null => false
    t.string  "bankName",         :limit => 250, :null => false
    t.string  "mfaType",          :limit => 50
  end

  create_table "suspiciousActivity", :primary_key => "suspiciousActivityID", :force => true do |t|
    t.integer  "userID",                 :limit => 8,                   :null => false
    t.integer  "otherUserID",            :limit => 8,                   :null => false
    t.integer  "sharedTransactionCount",                                :null => false
    t.datetime "created"
    t.datetime "modified"
    t.boolean  "isActive",                            :default => true, :null => false
  end

  create_table "suspiciousKeywords", :primary_key => "suspiciousKeywordID", :force => true do |t|
    t.string   "suspiciousKeyword", :limit => 200,                   :null => false
    t.datetime "created",                                            :null => false
    t.datetime "modified",                                           :null => false
    t.boolean  "isActive",                         :default => true, :null => false
  end

  create_table "tangoTracking", :primary_key => "tangoTrackingID", :force => true do |t|
    t.integer  "userID",              :limit => 8,                                  :null => false
    t.integer  "lootID",                                                            :null => false
    t.string   "cardSku",             :limit => 250,                                :null => false
    t.decimal  "cardValue",                          :precision => 12, :scale => 6, :null => false
    t.string   "recipientName",       :limit => 250,                                :null => false
    t.string   "recipientEmail",      :limit => 250,                                :null => false
    t.datetime "sentToTangoOn",                                                     :null => false
    t.datetime "responseFromTangoOn"
    t.string   "responseType",        :limit => 100
    t.string   "referenceOrderID",    :limit => 100
    t.string   "cardToken",           :limit => 100
    t.string   "cardNumber",          :limit => 100
    t.string   "cardPin",             :limit => 100
    t.text     "raw_response"
  end

  create_table "tasks", :force => true do |t|
    t.integer  "job_id",                                          :null => false
    t.string   "task_number",   :limit => 250,                    :null => false
    t.integer  "batch_size"
    t.integer  "starting_id",   :limit => 8
    t.integer  "ending_id",     :limit => 8
    t.string   "id_key_name",   :limit => 250
    t.text     "filename"
    t.text     "error_message"
    t.text     "backtrace"
    t.integer  "error_count",                  :default => 0,     :null => false
    t.datetime "completed_at"
    t.boolean  "is_complete",                  :default => false, :null => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.boolean  "is_active",                    :default => true,  :null => false
  end

  create_table "tiers", :primary_key => "tierID", :force => true do |t|
    t.integer  "offersVirtualCurrencyID",                                                  :null => false
    t.decimal  "dollarAwardAmount",       :precision => 12, :scale => 6,                   :null => false
    t.decimal  "minimumPurchaseAmount",   :precision => 12, :scale => 6,                   :null => false
    t.datetime "beginDate",                                                                :null => false
    t.datetime "endDate",                                                                  :null => false
    t.boolean  "isActive",                                               :default => true, :null => false
    t.decimal  "percentAwardAmount",      :precision => 5,  :scale => 2
  end

  create_table "transactionDownloadJobs", :primary_key => "transactionDownloadJobID", :force => true do |t|
    t.integer  "startUserID", :limit => 8,                    :null => false
    t.integer  "endUserID",   :limit => 8,                    :null => false
    t.boolean  "isStarted",                :default => false, :null => false
    t.datetime "startedOn"
    t.boolean  "isCompleted",              :default => false, :null => false
    t.datetime "completedOn"
    t.integer  "errorCount",               :default => 0,     :null => false
    t.text     "lastError"
    t.datetime "created",                                     :null => false
  end

  create_table "transaction_description_patterns", :force => true do |t|
    t.string   "regular_expression", :limit => 200,                   :null => false
    t.text     "comments"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.boolean  "is_active",                         :default => true, :null => false
  end

  create_table "transactions", :primary_key => "transactionID", :force => true do |t|
    t.integer  "advertisersSearchTermID",                                                                       :null => false
    t.integer  "advertiserID",                                                                                  :null => false
    t.integer  "userID",                      :limit => 8,                                                      :null => false
    t.integer  "usersBankProductAccountID",   :limit => 8,                                                      :null => false
    t.integer  "usersBankProductID",          :limit => 8,                                                      :null => false
    t.integer  "usersBankID",                                                                                   :null => false
    t.integer  "advertiserCampaignID_old",    :limit => 8
    t.integer  "campaignID_old"
    t.integer  "yodleeCategoryID",                                                                              :null => false
    t.integer  "usersAwardPeriodID",          :limit => 8,                                                      :null => false
    t.string   "advertisersSearchTerm",       :limit => 200,                                                    :null => false
    t.datetime "awardPeriodBeginDate",                                                                          :null => false
    t.datetime "awardPeriodEndDate",                                                                            :null => false
    t.decimal  "advertisersRevShare",                         :precision => 12, :scale => 6,                    :null => false
    t.integer  "yodleeTransactionID",         :limit => 8,                                                      :null => false
    t.string   "yodleeContainerType",         :limit => 100,                                                    :null => false
    t.text     "yodleeDescription",                                                                             :null => false
    t.datetime "postDate",                                                                                      :null => false
    t.string   "yodleeCategoryName",          :limit => 300,                                                    :null => false
    t.decimal  "transactionAmount",                           :precision => 20, :scale => 6,                    :null => false
    t.string   "currencyCode",                :limit => 10,                                                     :null => false
    t.string   "yodleeCategorizationKeyword", :limit => 300,                                                    :null => false
    t.datetime "campaignBeginDate_old"
    t.datetime "campaignEndDate_old"
    t.string   "yodleeTransactionType",       :limit => 300,                                                    :null => false
    t.integer  "affiliateID"
    t.string   "subID",                       :limit => 100
    t.boolean  "isPendingReview",                                                            :default => false, :null => false
    t.integer  "createdBy",                                                                  :default => 0,     :null => false
    t.datetime "created",                                                                                       :null => false
    t.integer  "modifiedBy",                                                                 :default => 0,     :null => false
    t.datetime "modified",                                                                                      :null => false
    t.boolean  "isActive",                                                                   :default => true,  :null => false
    t.integer  "virtualCurrencyID",                                                                             :null => false
    t.decimal  "cpaAmount_old",                               :precision => 12, :scale => 6
    t.decimal  "minimumPurchaseAmount",                       :precision => 12, :scale => 6
    t.boolean  "is2x"
    t.boolean  "is3x"
    t.boolean  "isOverMinimumAmount"
    t.integer  "eventID",                     :limit => 8
    t.decimal  "awardAmount",                                 :precision => 18, :scale => 8
    t.boolean  "hasMondayBonus",                                                             :default => false
    t.decimal  "exchangeRate",                                :precision => 9,  :scale => 3
    t.datetime "cardActivationBeginDate"
    t.datetime "cardActivationEndDate"
    t.string   "subID2",                      :limit => 200
    t.string   "subID3",                      :limit => 200
    t.string   "subID4",                      :limit => 200
    t.boolean  "isManuallyAwarded",                                                          :default => false, :null => false
    t.integer  "usersVirtualCurrencyID",      :limit => 8
    t.integer  "offerID"
    t.datetime "offerBeginDate"
    t.datetime "offerEndDate"
    t.decimal  "dollarAwardAmount",                           :precision => 12, :scale => 6
    t.string   "externalUserID",              :limit => 250
    t.string   "additionalInfo",              :limit => 1000
  end

  create_table "transactions_eligible_for_bonus", :force => true do |t|
    t.boolean  "processed"
    t.integer  "intuit_transaction_id",      :limit => 8
    t.integer  "offer_id"
    t.integer  "offers_virtual_currency_id"
    t.integer  "user_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "transactions_prod_copy_temp", :id => false, :force => true do |t|
    t.integer  "transactionID",               :limit => 8,                                  :null => false
    t.integer  "advertisersSearchTermID",                                                   :null => false
    t.integer  "advertiserID",                                                              :null => false
    t.integer  "userID",                      :limit => 8,                                  :null => false
    t.integer  "usersBankProductAccountID",   :limit => 8,                                  :null => false
    t.integer  "usersBankProductID",          :limit => 8,                                  :null => false
    t.integer  "usersBankID",                                                               :null => false
    t.integer  "advertiserCampaignID",        :limit => 8,                                  :null => false
    t.integer  "campaignID",                                                                :null => false
    t.integer  "yodleeCategoryID",                                                          :null => false
    t.integer  "usersAwardPeriodID",          :limit => 8,                                  :null => false
    t.string   "advertisersSearchTerm",       :limit => 200,                                :null => false
    t.datetime "awardPeriodBeginDate",                                                      :null => false
    t.datetime "awardPeriodEndDate",                                                        :null => false
    t.decimal  "revShare",                                   :precision => 12, :scale => 6, :null => false
    t.integer  "yodleeTransactionID",         :limit => 8,                                  :null => false
    t.string   "yodleeContainerType",         :limit => 100,                                :null => false
    t.text     "yodleeDescription",                                                         :null => false
    t.datetime "postDate",                                                                  :null => false
    t.string   "yodleeCategoryName",          :limit => 300,                                :null => false
    t.decimal  "transactionAmount",                          :precision => 20, :scale => 6, :null => false
    t.string   "currencyCode",                :limit => 10,                                 :null => false
    t.string   "yodleeCategorizationKeyword", :limit => 300,                                :null => false
    t.datetime "campaignBeginDate",                                                         :null => false
    t.datetime "campaignEndDate"
    t.string   "yodleeTransactionType",       :limit => 300,                                :null => false
    t.integer  "affiliateID"
    t.string   "subID",                       :limit => 100
    t.boolean  "isPendingReview",                                                           :null => false
    t.integer  "createdBy",                                                                 :null => false
    t.datetime "created",                                                                   :null => false
    t.integer  "modifiedBy",                                                                :null => false
    t.datetime "modified",                                                                  :null => false
    t.boolean  "isActive",                                                                  :null => false
    t.decimal  "minimumPurchaseAmount",                      :precision => 12, :scale => 6
    t.integer  "virtualCurrencyID",                                                         :null => false
    t.boolean  "isEligibleForMondayBonus"
    t.boolean  "is2x"
    t.boolean  "is3x"
    t.boolean  "isOverMinimumAmount"
    t.decimal  "cpaAmount",                                  :precision => 12, :scale => 6
    t.integer  "eventID",                     :limit => 8
  end

  create_table "travelOfferClicks", :primary_key => "travelOfferClickId", :force => true do |t|
    t.integer  "userId",        :limit => 8
    t.integer  "travelOfferId"
    t.string   "ip",            :limit => 15
    t.datetime "created",                     :null => false
    t.datetime "modified",                    :null => false
  end

  create_table "travelOfferTiers", :primary_key => "travelOfferTierID", :force => true do |t|
    t.integer  "travelOfferID"
    t.decimal  "dollarAwardAmount",     :precision => 12, :scale => 6,                   :null => false
    t.decimal  "minimumPurchaseAmount", :precision => 12, :scale => 6,                   :null => false
    t.datetime "beginDate",                                                              :null => false
    t.datetime "endDate",                                                                :null => false
    t.boolean  "isActive",                                             :default => true, :null => false
    t.integer  "virtualCurrencyId"
  end

  create_table "travelOffers", :primary_key => "travelOfferId", :force => true do |t|
    t.string   "name",                                                            :null => false
    t.decimal  "revShare",                         :precision => 18, :scale => 0, :null => false
    t.string   "logoURL",          :limit => 500
    t.string   "url",              :limit => 500
    t.text     "description"
    t.string   "shortDescription", :limit => 1000
    t.text     "terms"
    t.integer  "displayOrder"
    t.datetime "created"
    t.datetime "modified"
    t.boolean  "isActive",                                                        :null => false
    t.datetime "endDate",                                                         :null => false
  end

  create_table "trialPayConversions", :primary_key => "trialPayConversionID", :force => true do |t|
    t.integer  "userID",          :limit => 8,                       :null => false
    t.string   "trialPayClickID", :limit => 500,                     :null => false
    t.string   "pingerURL",       :limit => 1000
    t.boolean  "isProcessed",                     :default => false, :null => false
    t.datetime "processedOn"
    t.datetime "created",                                            :null => false
    t.datetime "modified",                                           :null => false
    t.boolean  "isActive",                        :default => true,  :null => false
    t.string   "conversionType",  :limit => 200
  end

  create_table "userBankAccountMetadata", :primary_key => "userBankAccountMetadataID", :force => true do |t|
    t.integer  "userID",        :limit => 8,                     :null => false
    t.integer  "itemID",        :limit => 8
    t.integer  "accountID",     :limit => 8
    t.integer  "itemAccountID", :limit => 8
    t.integer  "cardAccountID", :limit => 8
    t.integer  "srcElementID",  :limit => 8
    t.string   "accountNumber", :limit => 100
    t.datetime "created",                                        :null => false
    t.datetime "modified",                                       :null => false
    t.boolean  "isActive",                     :default => true, :null => false
  end

  create_table "userRedemptions", :primary_key => "userRedemptionID", :force => true do |t|
    t.integer  "transactionID",              :limit => 8,                                                     :null => false
    t.integer  "userID",                     :limit => 8,                                                     :null => false
    t.integer  "redemptionRequestID",        :limit => 8
    t.decimal  "requestedAwardAmount",                      :precision => 18, :scale => 8,                    :null => false
    t.decimal  "awardAmount",                               :precision => 18, :scale => 8
    t.integer  "fbUserID",                   :limit => 8
    t.string   "pinCode",                    :limit => 250
    t.boolean  "isFBNotificationSuccessful",                                               :default => false, :null => false
    t.boolean  "isValidAward",                                                             :default => false, :null => false
    t.integer  "createdBy",                                                                :default => 0,     :null => false
    t.datetime "created",                                                                                     :null => false
    t.integer  "modifiedBy",                                                               :default => 0,     :null => false
    t.datetime "modified",                                                                                    :null => false
    t.boolean  "isActive",                                                                 :default => true,  :null => false
  end

  create_table "user_auto_logins", :force => true do |t|
    t.integer  "user_id"
    t.datetime "expires_at"
    t.string   "user_token", :limit => 60
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "user_devices", :force => true do |t|
    t.string   "device_token"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "user_path_contents", :force => true do |t|
    t.text     "content"
    t.string   "layout"
    t.string   "action"
    t.string   "target"
    t.boolean  "was_served"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :primary_key => "userID", :force => true do |t|
    t.integer  "fbUserID",                    :limit => 8
    t.string   "firstName",                   :limit => 250
    t.string   "lastName",                    :limit => 250
    t.string   "username",                    :limit => 250
    t.string   "passwordSalt",                :limit => 250
    t.string   "password",                    :limit => 250
    t.string   "emailAddress",                :limit => 250
    t.boolean  "isMale"
    t.string   "homeZipCode",                 :limit => 10
    t.string   "workZipCode",                 :limit => 10
    t.string   "phoneNumber",                 :limit => 25
    t.string   "mobileNumber",                :limit => 25
    t.datetime "birthday"
    t.string   "ip",                          :limit => 15
    t.integer  "initialAdvertiserCampaignID",                :default => 0,     :null => false
    t.integer  "initialAffiliateID",                         :default => 0,     :null => false
    t.string   "initialSubID",                :limit => 100
    t.datetime "deactivationDate"
    t.string   "userAgent",                   :limit => 500
    t.integer  "createdBy",                                  :default => 0,     :null => false
    t.datetime "created"
    t.integer  "modifiedBy",                                 :default => 0,     :null => false
    t.datetime "modified"
    t.boolean  "isActive",                                   :default => true,  :null => false
    t.integer  "initialCampaignID"
    t.boolean  "hasFailedBank",                              :default => false, :null => false
    t.string   "initialSubid2",               :limit => 100
    t.string   "initialSubid3",               :limit => 100
    t.string   "initialSubid4",               :limit => 100
    t.string   "userHash",                    :limit => 32
    t.boolean  "isDoubleConfirmed",                          :default => false, :null => false
    t.datetime "doubleConfirmDate"
    t.string   "doubleConfirmIP",             :limit => 20
    t.string   "city",                        :limit => 200
    t.string   "state",                       :limit => 200
    t.boolean  "isSubscribed",                               :default => true,  :null => false
    t.boolean  "isInternalUser",                             :default => false, :null => false
    t.boolean  "isOutlier",                                  :default => false, :null => false
    t.datetime "unsubscribeDate"
    t.boolean  "hasHadFullWallet",                           :default => false, :null => false
    t.integer  "lastYodleeRefreshStatusCode"
    t.integer  "primaryVirtualCurrencyID"
    t.datetime "lastAccountSummarySentOn"
    t.boolean  "isForceDeactivated",                         :default => false
    t.boolean  "holdRedemptions"
    t.integer  "oauthTokenID_old",            :limit => 8
    t.boolean  "intuitRegistrationComplete",                 :default => false
    t.string   "gigya_uid"
    t.string   "avatar_thumbnail_url"
    t.string   "shortened_referral_link"
    t.string   "provider",                    :limit => 15
    t.boolean  "daily_contest_reminder"
    t.string   "login_token"
  end

  create_table "usersAwardPeriods", :primary_key => "usersAwardPeriodID", :force => true do |t|
    t.integer  "userID",                     :limit => 8,                                                  :null => false
    t.decimal  "revShare_old",                            :precision => 12, :scale => 6
    t.datetime "beginDate",                                                                                :null => false
    t.datetime "endDate",                                                                                  :null => false
    t.datetime "created",                                                                                  :null => false
    t.datetime "modified",                                                                                 :null => false
    t.boolean  "isActive",                                                               :default => true, :null => false
    t.decimal  "cpaAmount_old",                           :precision => 12, :scale => 6
    t.integer  "eventID",                    :limit => 8
    t.decimal  "dollarAwardAmount_old",                   :precision => 12, :scale => 6
    t.decimal  "minimumPurchaseAmount_old",               :precision => 12, :scale => 6
    t.decimal  "advertisersRevShare",                     :precision => 12, :scale => 6,                   :null => false
    t.integer  "offers_virtual_currency_id", :limit => 8
  end

  add_index "usersAwardPeriods", ["offers_virtual_currency_id"], :name => "index_usersAwardPeriods_on_offers_virtual_currency_id"

  create_table "usersBankProductAccounts", :primary_key => "usersBankProductAccountID", :force => true do |t|
    t.integer  "userID",             :limit => 8,                     :null => false
    t.integer  "bankProductID",                                       :null => false
    t.string   "bankProductAccount", :limit => 500,                   :null => false
    t.string   "itemAccountID",      :limit => 250,                   :null => false
    t.datetime "created",                                             :null => false
    t.datetime "modified",                                            :null => false
    t.boolean  "isActive",                          :default => true, :null => false
    t.integer  "usersBankProductID", :limit => 8,                     :null => false
  end

  create_table "usersBankProducts", :primary_key => "usersBankProductID", :force => true do |t|
    t.integer  "userID",                 :limit => 8,                    :null => false
    t.integer  "bankProductID",                                          :null => false
    t.integer  "itemID",                                                 :null => false
    t.datetime "created",                                                :null => false
    t.datetime "modified",                                               :null => false
    t.boolean  "isActive",                            :default => true,  :null => false
    t.datetime "beginDate"
    t.datetime "endDate"
    t.boolean  "isInYodlee",                          :default => true,  :null => false
    t.integer  "usersBankID",                                            :null => false
    t.boolean  "hasFailedDataRefresh",                :default => false, :null => false
    t.integer  "usersVirtualCurrencyID", :limit => 8,                    :null => false
  end

  create_table "usersBanks", :primary_key => "usersBankID", :force => true do |t|
    t.integer  "userID",           :limit => 8,                     :null => false
    t.integer  "bankID",                                            :null => false
    t.string   "bankUsernameHash", :limit => 150,                   :null => false
    t.datetime "created",                                           :null => false
    t.datetime "modified",                                          :null => false
    t.boolean  "isActive",                        :default => true, :null => false
  end

  create_table "usersCharityChapters", :primary_key => "usersCharityChapterID", :force => true do |t|
    t.integer  "userID",           :limit => 8,                   :null => false
    t.integer  "charityChapterID",                                :null => false
    t.datetime "beginDate",                                       :null => false
    t.datetime "endDate"
    t.datetime "created",                                         :null => false
    t.datetime "modified",                                        :null => false
    t.boolean  "isActive",                      :default => true, :null => false
  end

  create_table "usersFacebookPermissions", :primary_key => "userFacebookPermissionID", :force => true do |t|
    t.integer  "userID",               :limit => 8,                   :null => false
    t.integer  "facebookPermissionID",                                :null => false
    t.boolean  "isOptedIn",                                           :null => false
    t.integer  "createdBy",                         :default => 0,    :null => false
    t.datetime "created",                                             :null => false
    t.integer  "modifiedBy",                        :default => 0,    :null => false
    t.datetime "modified",                                            :null => false
    t.boolean  "isActive",                          :default => true, :null => false
  end

  create_table "usersInstitutionAccounts", :primary_key => "usersInstitutionAccountID", :force => true do |t|
    t.integer  "userID",                           :limit => 8,                     :null => false
    t.integer  "usersInstitutionID",               :limit => 8,                     :null => false
    t.datetime "beginDate",                                                         :null => false
    t.datetime "endDate",                                                           :null => false
    t.integer  "accountID",                        :limit => 8,                     :null => false
    t.string   "status",                           :limit => 500
    t.string   "accountNumberHash",                :limit => 500
    t.string   "accountNumberLast4",               :limit => 4
    t.string   "accountNickname",                  :limit => 500
    t.string   "description",                      :limit => 500
    t.datetime "lastTransactionDate"
    t.datetime "aggrSuccessDate"
    t.datetime "aggrAttemptDate"
    t.string   "aggrStatusCode",                   :limit => 500
    t.string   "currencyCode",                     :limit => 10
    t.string   "accountType",                      :limit => 100
    t.string   "accountTypeDescription",           :limit => 100
    t.boolean  "inIntuit",                                        :default => true, :null => false
    t.datetime "created",                                                           :null => false
    t.datetime "modified",                                                          :null => false
    t.boolean  "isActive",                                        :default => true, :null => false
    t.integer  "usersInstitutionAccountStagingID", :limit => 8,                     :null => false
  end

  create_table "usersInstitutionAccountsStaging", :primary_key => "usersInstitutionAccountStagingID", :force => true do |t|
    t.integer  "userID",                 :limit => 8,                     :null => false
    t.integer  "usersInstitutionID",     :limit => 8,                     :null => false
    t.integer  "accountID",              :limit => 8,                     :null => false
    t.string   "status",                 :limit => 500
    t.string   "accountNumberHash",      :limit => 500
    t.string   "accountNumberLast4",     :limit => 4
    t.string   "accountNickname",        :limit => 500
    t.string   "description",            :limit => 500
    t.datetime "lastTransactionDate"
    t.datetime "aggrSuccessDate"
    t.datetime "aggrAttemptDate"
    t.string   "aggrStatusCode",         :limit => 500
    t.string   "currencyCode",           :limit => 10
    t.string   "accountType",            :limit => 100
    t.string   "accountTypeDescription", :limit => 100
    t.datetime "created",                                                 :null => false
    t.datetime "modified",                                                :null => false
    t.boolean  "inIntuit",                              :default => true, :null => false
  end

  create_table "usersInstitutions", :primary_key => "usersInstitutionID", :force => true do |t|
    t.integer  "userID",                   :limit => 8,                     :null => false
    t.integer  "institutionID",                                             :null => false
    t.integer  "intuitInstitutionLoginID", :limit => 8,                     :null => false
    t.string   "hashCheck",                :limit => 500,                   :null => false
    t.datetime "created",                                                   :null => false
    t.datetime "modified",                                                  :null => false
    t.boolean  "isActive",                                :default => true, :null => false
  end

  create_table "usersIntuitErrors", :primary_key => "usersIntuitErrorID", :force => true do |t|
    t.integer  "userID",             :limit => 8, :null => false
    t.integer  "usersInstitutionID", :limit => 8, :null => false
    t.integer  "intuitErrorID",                   :null => false
    t.datetime "created"
    t.datetime "aggrSuccessDate"
    t.datetime "aggrAttemptDate"
  end

  create_table "usersPromotions", :primary_key => "usersPromotionID", :force => true do |t|
    t.integer  "userID",      :limit => 8,                   :null => false
    t.integer  "promotionID",                                :null => false
    t.datetime "created",                                    :null => false
    t.datetime "modified",                                   :null => false
    t.boolean  "isActive",                 :default => true, :null => false
  end

  create_table "usersReverifications", :primary_key => "usersReverificationID", :force => true do |t|
    t.integer  "userID",                   :limit => 8,                    :null => false
    t.integer  "usersInstitutionID",       :limit => 8,                    :null => false
    t.integer  "usersIntuitErrorID",       :limit => 8,                    :null => false
    t.boolean  "isNotificationSuccessful",              :default => false, :null => false
    t.datetime "startedOn"
    t.datetime "completedOn"
    t.boolean  "userSawQuestion",                       :default => false, :null => false
    t.datetime "created",                                                  :null => false
    t.datetime "modified",                                                 :null => false
    t.boolean  "isActive",                              :default => true,  :null => false
    t.integer  "intuit_error_id"
  end

  create_table "usersToRetryDownload", :id => false, :force => true do |t|
    t.integer  "userID",                     :limit => 8, :null => false
    t.integer  "usersBankProductID",         :limit => 8, :null => false
    t.integer  "yodleeUserReverificationID", :limit => 8, :null => false
    t.datetime "reverificationCreatedOn",                 :null => false
  end

  create_table "usersVirtualCurrencies", :primary_key => "usersVirtualCurrencyID", :force => true do |t|
    t.integer  "userID",            :limit => 8,                                       :null => false
    t.integer  "virtualCurrencyID",                                                    :null => false
    t.string   "externalUserID",    :limit => 250
    t.datetime "startDate",                                                            :null => false
    t.datetime "endDate",                           :default => '2999-12-31 00:00:00', :null => false
    t.datetime "created",                                                              :null => false
    t.datetime "modified",                                                             :null => false
    t.boolean  "isActive",                          :default => true,                  :null => false
    t.string   "additionalInfo",    :limit => 1000
  end

  create_table "users_eligible_for_offer_add_bonus", :force => true do |t|
    t.integer  "user_id"
    t.integer  "offers_virtual_currency_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.boolean  "is_awarded"
  end

  create_table "users_last_post_dates", :force => true do |t|
    t.integer  "user_id",    :limit => 8,                   :null => false
    t.integer  "uia_id",     :limit => 8,                   :null => false
    t.datetime "post_date"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "is_active",               :default => true, :null => false
  end

  create_table "virtualCurrencies", :primary_key => "virtualCurrencyID", :force => true do |t|
    t.string   "currencyName",                   :limit => 50,                                                     :null => false
    t.string   "singularCurrencyName",           :limit => 50,                                                     :null => false
    t.decimal  "exchangeRate",                                   :precision => 9,  :scale => 3,                    :null => false
    t.string   "currencyShortName",              :limit => 5
    t.string   "logoURL",                        :limit => 500
    t.integer  "createdBy",                                                                     :default => 0,     :null => false
    t.datetime "created",                                                                                          :null => false
    t.integer  "modifiedBy",                                                                    :default => 0,     :null => false
    t.datetime "modified",                                                                                         :null => false
    t.boolean  "isActive",                                                                      :default => true,  :null => false
    t.string   "subdomain",                      :limit => 200
    t.decimal  "ourCostPerUnit",                                 :precision => 12, :scale => 6
    t.decimal  "nonQualifyingAwardAmount",                       :precision => 12, :scale => 6, :default => 0.0,   :null => false
    t.string   "siteName",                       :limit => 250
    t.decimal  "doubleConfirmDollarAwardAmount",                 :precision => 12, :scale => 6, :default => 0.0,   :null => false
    t.decimal  "cardAddDollarAwardAmount",                       :precision => 12, :scale => 6, :default => 0.0,   :null => false
    t.string   "siteLogo",                       :limit => 300
    t.string   "helpURL",                        :limit => 1000
    t.decimal  "nonQualifyingDollarAwardAmount",                 :precision => 12, :scale => 6, :default => 0.0,   :null => false
    t.string   "redemptionURL",                  :limit => 1000
    t.string   "siteURL",                        :limit => 1000
    t.text     "aboutUsText"
    t.boolean  "requireExternalUserID",                                                         :default => false, :null => false
    t.boolean  "hasPostbackProcess",                                                            :default => false, :null => false
    t.boolean  "isCharity",                                                                     :default => false, :null => false
    t.string   "currencyPrefix",                 :limit => 10
    t.boolean  "isUs",                                                                          :default => false, :null => false
    t.boolean  "hasLoot",                                                                       :default => false, :null => false
    t.boolean  "hasThirdPartyNotification",                                                     :default => false, :null => false
    t.decimal  "partnerPayoutPercent",                           :precision => 5,  :scale => 4, :default => 0.0,   :null => false
    t.boolean  "hasAllOffers",                                                                  :default => false, :null => false
    t.boolean  "requiresPartnerConfirmation",                                                   :default => false, :null => false
    t.boolean  "showTiersAsPercent",                                                            :default => false, :null => false
  end

  create_table "virtualCurrenciesPaths", :primary_key => "virtualCurrenciesPathID", :force => true do |t|
    t.integer  "virtualCurrencyID",                   :null => false
    t.integer  "pathID",                              :null => false
    t.boolean  "isActive",          :default => true, :null => false
    t.datetime "startDate"
    t.datetime "endDate"
  end

  create_table "walletItems", :primary_key => "walletItemID", :force => true do |t|
    t.integer  "walletID",                                                :null => false
    t.integer  "advertiserID_old"
    t.integer  "virtualCurrencyID_old"
    t.integer  "usersAwardPeriodID",      :limit => 8
    t.datetime "created",                                                 :null => false
    t.datetime "modified",                                                :null => false
    t.boolean  "isActive",                              :default => true, :null => false
    t.integer  "walletSlotID",                                            :null => false
    t.integer  "walletSlotTypeID",                                        :null => false
    t.integer  "offersVirtualCurrencyID"
    t.string   "type"
    t.string   "unlock_reason",           :limit => 50
  end

  create_table "walletItemsHistory", :primary_key => "walletItemHistoryID", :force => true do |t|
    t.integer  "walletID",                                               :null => false
    t.integer  "advertiserID_old"
    t.integer  "virtualCurrencyID_old"
    t.integer  "usersAwardPeriodID",      :limit => 8
    t.datetime "created",                                                :null => false
    t.datetime "modified",                                               :null => false
    t.boolean  "isActive",                             :default => true, :null => false
    t.integer  "walletSlotID"
    t.integer  "walletSlotTypeID"
    t.integer  "walletItemID"
    t.integer  "offersVirtualCurrencyID"
  end

  create_table "walletSlotTypes", :primary_key => "walletSlotTypeID", :force => true do |t|
    t.string "walletSlotType", :limit => 200
  end

  create_table "walletSlots", :primary_key => "walletSlotID", :force => true do |t|
    t.integer "walletSlotTypeID",                  :null => false
    t.string  "lockedImage",        :limit => 200, :null => false
    t.string  "lockedText",         :limit => 400, :null => false
    t.string  "unLockedImage",      :limit => 200, :null => false
    t.string  "unLockedText",       :limit => 200, :null => false
    t.integer "displayOrder",                      :null => false
    t.string  "techNote",           :limit => 200, :null => false
    t.string  "mobileLockedText",   :limit => 500
    t.string  "mobileUnLockedText", :limit => 500
  end

  create_table "wallets", :primary_key => "walletID", :force => true do |t|
    t.integer  "userID",   :limit => 8,                   :null => false
    t.datetime "created",                                 :null => false
    t.datetime "modified",                                :null => false
    t.boolean  "isActive",              :default => true, :null => false
  end

  create_table "weightlessRedemptionTypes", :primary_key => "weightlessRedemptionTypeID", :force => true do |t|
    t.string   "weightlessRedemptionType", :limit => 500,                                                   :null => false
    t.string   "weightlessCode",           :limit => 100,                                                   :null => false
    t.datetime "created"
    t.decimal  "dollarAmount",                             :precision => 18, :scale => 6
    t.decimal  "maximumAmount",                            :precision => 18, :scale => 6
    t.string   "emailMessage",             :limit => 1000
    t.boolean  "isActive",                                                                :default => true, :null => false
  end

  create_table "weightlessUserRedemptions", :primary_key => "weightlessUserRedemptionID", :force => true do |t|
    t.integer  "userID",                     :limit => 8,                                                   :null => false
    t.integer  "fbUserID",                   :limit => 8
    t.integer  "weightlessRedemptionTypeID",                                                                :null => false
    t.decimal  "awardAmount",                             :precision => 12, :scale => 6,                    :null => false
    t.boolean  "isNotificationSuccessful",                                               :default => false, :null => false
    t.boolean  "isRedeemed",                                                             :default => false, :null => false
    t.datetime "created"
    t.datetime "modified"
    t.boolean  "isActive",                                                               :default => true,  :null => false
    t.decimal  "dollarAmount",                            :precision => 12, :scale => 6,                    :null => false
    t.integer  "virtualCurrencyID",                                                                         :null => false
    t.integer  "affiliateID"
  end

  create_table "yodleeCallLog", :primary_key => "yodleeCallLogID", :force => true do |t|
    t.string   "severity",     :limit => 10,                 :null => false
    t.string   "category",     :limit => 100,                :null => false
    t.datetime "logdate",                                    :null => false
    t.string   "appendername", :limit => 100,                :null => false
    t.text     "message"
    t.text     "yodleeAction"
    t.text     "calledURL"
    t.text     "requestXML"
    t.text     "returnXML"
    t.integer  "userID"
    t.text     "userSession"
    t.integer  "pathID",                      :default => 0, :null => false
  end

  create_table "yodleeCategories", :primary_key => "yodleeCategoryID", :force => true do |t|
    t.string   "category",   :limit => 200,                   :null => false
    t.integer  "categoryID",                                  :null => false
    t.integer  "createdBy",                 :default => 0,    :null => false
    t.datetime "created",                                     :null => false
    t.integer  "modifiedBy",                :default => 0,    :null => false
    t.datetime "modified",                                    :null => false
    t.boolean  "isActive",                  :default => true, :null => false
  end

  create_table "yodleeTransactionsStaging", :primary_key => "yodleeTransactionsStagingID", :force => true do |t|
    t.integer  "userID",                      :limit => 8
    t.integer  "usersBankProductAccountID",                                                                    :null => false
    t.integer  "usersBankProductID",                                                                           :null => false
    t.integer  "usersBankID",                                                                                  :null => false
    t.integer  "yodleeTransactionID",         :limit => 8,                                                     :null => false
    t.string   "yodleeContainerType",         :limit => 100,                                                   :null => false
    t.text     "yodleeDescription",                                                                            :null => false
    t.datetime "postDate",                                                                                     :null => false
    t.integer  "yodleeCategoryID",                                                                             :null => false
    t.string   "yodleeCategoryName",          :limit => 300,                                                   :null => false
    t.decimal  "transactionAmount",                          :precision => 20, :scale => 6,                    :null => false
    t.string   "currencyCode",                :limit => 10,                                                    :null => false
    t.string   "yodleeCategorizationKeyword", :limit => 300,                                                   :null => false
    t.string   "yodleeTransactionType",       :limit => 300,                                                   :null => false
    t.boolean  "isPendingReview",                                                           :default => false, :null => false
    t.datetime "created",                                                                                      :null => false
    t.boolean  "isFishy",                                                                   :default => false, :null => false
  end

  create_table "yodleeTransactionsStaging_tempBackup", :id => false, :force => true do |t|
    t.integer  "yodleeTransactionsStagingID"
    t.integer  "userID",                                                                                       :null => false
    t.integer  "usersBankProductAccountID",                                                                    :null => false
    t.integer  "usersBankProductID",                                                                           :null => false
    t.integer  "usersBankID",                                                                                  :null => false
    t.integer  "advertiserCampaignID",        :limit => 8
    t.integer  "usersAwardPeriodID",          :limit => 8
    t.datetime "awardPeriodBeginDate"
    t.datetime "awardPeriodEndDate"
    t.decimal  "revShare",                                   :precision => 12, :scale => 6
    t.integer  "campaignID"
    t.integer  "affiliateID"
    t.string   "subID",                       :limit => 100
    t.datetime "campaignBeginDate"
    t.datetime "campaignEndDate"
    t.integer  "advertiserID"
    t.integer  "advertisersSearchTermID"
    t.string   "advertisersSearchTerm",       :limit => 200
    t.integer  "advertisersExcludeTermID"
    t.string   "advertisersExcludeTerm",      :limit => 200
    t.integer  "yodleeTransactionID",         :limit => 8,                                                     :null => false
    t.string   "yodleeContainerType",         :limit => 100,                                                   :null => false
    t.text     "yodleeDescription",                                                                            :null => false
    t.datetime "postDate",                                                                                     :null => false
    t.integer  "yodleeCategoryID",                                                                             :null => false
    t.string   "yodleeCategoryName",          :limit => 300,                                                   :null => false
    t.decimal  "transactionAmount",                          :precision => 20, :scale => 6,                    :null => false
    t.string   "currencyCode",                :limit => 10,                                                    :null => false
    t.string   "yodleeCategorizationKeyword", :limit => 300,                                                   :null => false
    t.string   "yodleeTransactionType",       :limit => 300,                                                   :null => false
    t.boolean  "isPendingReview",                                                           :default => false, :null => false
    t.boolean  "inCampaignPeriod",                                                          :default => false, :null => false
    t.boolean  "inUserAwardPeriod",                                                         :default => false, :null => false
    t.integer  "awardOrder"
    t.integer  "virtualCurrencyID"
    t.decimal  "cpaAmount",                                  :precision => 12, :scale => 6
    t.datetime "created",                                                                                      :null => false
    t.decimal  "minimumPurchaseAmount",                      :precision => 12, :scale => 6
    t.boolean  "is2x"
    t.boolean  "is3x"
    t.boolean  "isOverMinimumAmount"
    t.integer  "eventID",                     :limit => 8
    t.decimal  "awardAmount",                                :precision => 18, :scale => 8
    t.boolean  "hasMondayBonus"
    t.decimal  "exchangeRate",                               :precision => 9,  :scale => 3
    t.datetime "cardActivationBeginDate"
    t.datetime "cardActivationEndDate"
    t.boolean  "inCardActivationPeriod"
    t.integer  "eventOrder"
  end

  create_table "yodleeUserReverificationTypes", :primary_key => "yodleeUserReverificationTypeID", :force => true do |t|
    t.string "yodleeUserReverificationType", :limit => 200,  :null => false
    t.string "actionToTake",                 :limit => 200,  :null => false
    t.string "reason",                       :limit => 1000
  end

  create_table "yodleeUserReverifications", :primary_key => "yodleeUserReverificationID", :force => true do |t|
    t.integer  "userID",                         :limit => 8,                    :null => false
    t.integer  "usersBankProductID",             :limit => 8,                    :null => false
    t.integer  "yodleeUserReverificationTypeID",                                 :null => false
    t.text     "storedResponse"
    t.datetime "startedOn"
    t.datetime "completedOn"
    t.datetime "created",                                                        :null => false
    t.datetime "modified",                                                       :null => false
    t.boolean  "isActive",                                    :default => true,  :null => false
    t.boolean  "userSawQuestion",                             :default => false, :null => false
  end

end
