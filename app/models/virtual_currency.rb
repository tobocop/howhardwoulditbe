class VirtualCurrency < ActiveRecord::Base
  self.table_name = "virtualCurrencies"
  self.primary_key = "virtualCurrencyID"

  attr_accessible :name, :subdomain, :exchange_rate, :site_name, :singular_name

  validates :name, :subdomain, :exchange_rate, :site_name, :singular_name, presence: true
  validates :subdomain, uniqueness: true

  def self.default
    self.find_by_subdomain("www")
  end

  def name=(name)
    self.currencyName = name
  end

  def name
    self.currencyName
  end

  def exchange_rate=(rate)
    self.exchangeRate = rate
  end

  def exchange_rate
    self.exchangeRate
  end

  def site_name=(site_name)
    self.siteName = site_name
  end

  def site_name
    siteName
  end

  def singular_name=(singular_name)
    self.singularCurrencyName = singular_name
  end

  def singular_name
    singularCurrencyName
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