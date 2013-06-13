class User < ActiveRecord::Base
  self.primary_key = "userID"

  attr_accessible :email, :first_name, :password_hash, :salt

  belongs_to :primary_virtual_currency, class_name: "VirtualCurrency", foreign_key: "primaryVirtualCurrencyID"

  validates :email, :first_name, :password_hash, :salt, presence: true

  before_create :set_default_virtual_currency

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

  def created_at
    self.created
  end

  def updated_at
    self.modified
  end

  def self.find_by_email(email)
    where(:emailAddress => email).first
  end

  private

  def timestamp_attributes_for_create
    super << :created
  end

  def timestamp_attributes_for_update
    super << :modified
  end

  def set_default_virtual_currency
    self.primary_virtual_currency = VirtualCurrency.default
  end
end
