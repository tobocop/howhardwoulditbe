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

    attr_accessible :avatar_thumbnail_url, :email, :first_name, :password_hash, :provider,
      :salt

    alias_attribute :is_subscribed, :isSubscribed

    belongs_to :primary_virtual_currency, class_name: 'Plink::VirtualCurrency', foreign_key: 'primaryVirtualCurrencyID'
    has_one :wallet, class_name: 'Plink::WalletRecord', foreign_key: 'userID'
    has_many :wallet_item_records, through: :wallet
    has_many :open_wallet_items, through: :wallet
    has_one :user_balance, class_name: 'Plink::UserBalance', foreign_key: 'userID'

    validates :first_name, presence: true, format: {with: /\A[a-zA-Z]+\z/, if: 'first_name.present?'}
    validates :email, presence: true, format: {with: VALID_EMAIL_REGEXP}
    validates :password_hash, :salt, presence: true
    validates :new_password, length: {minimum: 6}, confirmation: true, if: 'new_password.present?'
    validate :email_is_not_in_database
    validates :provider, inclusion: {in: VALID_PROVIDERS}

    before_create :set_default_virtual_currency

    scope :users_with_qualifying_transactions, -> {
      joins('INNER JOIN qualifyingAwards ON qualifyingAwards.userID = users.userID')
      .where('qualifyingAwards.isSuccessful = 1')
    }

    def self.user_ids_with_qualifying_transactions
      users_with_qualifying_transactions.map(&:userID)
    end

    def self.find_by_email(email)
      where(:emailAddress => email).first
    end

    def self.find_by_id(id)
      find_by_userID(id)
    end

    def first_name=(first_name)
      self.firstName = first_name
    end

    def first_name
      firstName
    end

    def email=(email)
      self.emailAddress = email
    end

    def email
      emailAddress
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

    # Legacy naming for password_hash is password, which is kinda confusing.
    def password_hash=(password_hash)
      self.password = password_hash
    end

    def password_hash
      password
    end

    def salt=(salt)
      self.passwordSalt = salt
    end

    def salt
      passwordSalt
    end

    def current_balance
      user_balance.current_balance
    end

    def currency_balance
      user_balance.currency_balance
    end

    def lifetime_balance
      user_balance.lifetime_balance
    end

    def can_redeem?
      user_balance.can_redeem?
    end

    def primary_virtual_currency_id
      primaryVirtualCurrencyID
    end

    def open_wallet_item
      open_wallet_items.first
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
