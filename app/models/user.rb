class User < ActiveRecord::Base
  self.primary_key = "userID"

  attr_accessible :email

  belongs_to :primary_virtual_currency, class_name: "VirtualCurrency", foreign_key: "primaryVirtualCurrencyID"

  validates :email, presence: true

  before_create :set_default_virtual_currency

  def email=(email)
    self.emailAddress = email
  end

  def email
    emailAddress
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
