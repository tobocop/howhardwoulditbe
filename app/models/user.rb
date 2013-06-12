class User < ActiveRecord::Base
  self.primary_key = "userID"

  attr_accessible :email

  belongs_to :primary_virtual_currency, class_name: "VirtualCurrency", foreign_key: "primaryVirtualCurrencyID"

  validates :email, presence: true

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

  private

  def timestamp_attributes_for_create
    super << :created
  end

  def timestamp_attributes_for_update
    super << :modified
  end
end
