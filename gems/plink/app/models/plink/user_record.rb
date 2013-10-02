module Plink
  class UserRecord < ActiveRecord::Base
    self.table_name = 'users'
    self.primary_key = 'userID'

    VALID_EMAIL_REGEXP = /
    ^[^+]+             # One or more not '+' signs
    @                  # @ sign is mandatory
    .+                 # One or more characters
    \.                 # A literal dot
    .+                 # One or more characters
    $/x

    VALID_PROVIDERS = %w[facebook organic twitter]

    include Plink::LegacyTimestamps

    attr_accessible :avatar_thumbnail_url, :birthday, :city, :daily_contest_reminder, :email,
      :first_name, :hold_redemptions, :ip, :is_male,  :last_name, :password_hash, :provider,
      :salt, :state, :username, :zip

    alias_attribute :email, :emailAddress
    alias_attribute :first_name, :firstName
    alias_attribute :last_name, :lastName
    alias_attribute :is_subscribed, :isSubscribed
    alias_attribute :is_male, :isMale
    # Legacy naming for password_hash is password, which is kinda confusing.
    alias_attribute :password_hash, :password
    alias_attribute :salt, :passwordSalt
    alias_attribute :primary_virtual_currency_id, :primaryVirtualCurrencyID
    alias_attribute :hold_redemptions, :holdRedemptions
    alias_attribute :zip, :homeZipCode

    delegate :can_redeem?, :currency_balance, :current_balance, :lifetime_balance,
      to: :user_balance

    belongs_to :primary_virtual_currency, class_name: 'Plink::VirtualCurrency', foreign_key: 'primaryVirtualCurrencyID'
    has_one :wallet, class_name: 'Plink::WalletRecord', foreign_key: 'userID'
    has_one :user_balance, class_name: 'Plink::UserBalance', foreign_key: 'userID'
    has_many :wallet_item_records, through: :wallet
    has_many :open_wallet_items, through: :wallet
    has_many :referral_conversion_records, class_name: 'Plink::ReferralConversionRecord', foreign_key: 'referredBy'
    has_many :qualifying_award_records, class_name: 'Plink::QualifyingAwardRecord', foreign_key: 'userID'

    validates :first_name, presence: true, format: {with: /\A[a-zA-Z0-9_\- ]+\z/, if: 'first_name.present?'}
    validates :email, presence: true, format: {with: VALID_EMAIL_REGEXP}
    validates :password_hash, :salt, presence: true
    validates :new_password, length: {minimum: 6}, confirmation: true, if: 'new_password.present?'
    validates :provider, inclusion: {in: VALID_PROVIDERS}
    validate :email_is_not_in_database

    before_create :set_default_virtual_currency

    scope :users_with_qualifying_transactions, -> {
      joins('INNER JOIN qualifyingAwards ON qualifyingAwards.userID = users.userID')
      .where('qualifyingAwards.isSuccessful = 1')
    }

    def self.user_ids_with_qualifying_transactions
      users_with_qualifying_transactions.select("DISTINCT #{self.table_name}.userID").map(&:userID)
    end

    def self.find_by_email(email)
      where(:emailAddress => email).first
    end

    def self.find_by_id(id)
      find_by_userID(id)
    end

    def new_password=(unhashed_password)
      @new_password = unhashed_password

      if valid?
        password = Password.new(unhashed_password: @new_password)
        self.password_hash = password.hashed_value
        self.salt = password.salt
      end
    end

    def new_password
      @new_password
    end

    def new_password_confirmation=(unhashed_password)
      @new_password_confirmation = unhashed_password
    end

    def new_password_confirmation
      @new_password_confirmation
    end

    def open_wallet_item
      open_wallet_items.first
    end

    def opt_in_to_daily_contest_reminders!(state=true)
      raise ArgumentError, 'can only set boolean values' unless state == !!state

      update_attribute(:daily_contest_reminder, state)
    end

  private

    def email_is_not_in_database
      if emailAddress_changed? && self.class.find_by_email(email)
        errors.add(:email, :already_registered)
      end
    end

    def set_default_virtual_currency
      self.primary_virtual_currency = Plink::VirtualCurrency.default
    end
  end
end
