module Plink
  class User < ActiveRecord::Base
    self.table_name = 'users'
    self.primary_key = 'userID'

    include Plink::LegacyTimestamps

    attr_accessible :email, :first_name, :password_hash, :salt, :avatar_thumbnail_url

    belongs_to :primary_virtual_currency, class_name: 'Plink::VirtualCurrency', foreign_key: 'primaryVirtualCurrencyID'
    has_one :wallet, class_name: 'Plink::WalletRecord', foreign_key: 'userID'
    has_many :wallet_items, through: :wallet
    has_many :empty_wallet_items, through: :wallet

    has_one :user_balance, class_name: 'Plink::UserBalance', foreign_key: 'userID'

    validates :first_name, presence: {message: 'Please enter a First Name'}
    validates :email, presence: {message: 'Please enter a valid email address'}
    validates :password_hash, :salt, presence: true

    before_create :set_default_virtual_currency
    validate :email_is_not_in_database

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

    def lifetime_balance
      user_balance.lifetime_balance
    end

    def can_redeem?
      user_balance.can_redeem?
    end

    def primary_virtual_currency_id
      primaryVirtualCurrencyID
    end

    def empty_wallet_item
      empty_wallet_items.first
    end

    private

    def email_is_not_in_database
      if emailAddress_changed? && self.class.find_by_email(email)
        errors.add(:email, "You've entered an email address that is already registered with Plink. If you believe there is an error, please contact support@plink.com.")
      end
    end

    def set_default_virtual_currency
      self.primary_virtual_currency = Plink::VirtualCurrency.default
    end
  end
end
