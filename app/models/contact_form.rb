class ContactForm

  include ActiveModel::Validations
  include ActiveModel::Conversion

  validates_presence_of :first_name, :last_name, :email

  attr_accessor :first_name, :last_name, :email, :message_text, :category

  def initialize(params = {})
    self.first_name = params[:first_name]
    self.last_name = params[:last_name]
    self.email = params[:email]
  end

  def persisted?
    false
  end

end