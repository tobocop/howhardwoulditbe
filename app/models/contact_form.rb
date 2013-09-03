class ContactForm

  include ActiveModel::Validations
  include ActiveModel::Conversion

  validates_presence_of :first_name, :last_name, :email, :message_text
  validates :email, format: {with: Plink::UserRecord::VALID_EMAIL_REGEXP, allow_blank: true}

  attr_accessor :first_name, :last_name, :email, :message_text, :category

  def initialize(params = {})
    self.first_name = params[:first_name]
    self.last_name = params[:last_name]
    self.email = params[:email]
    self.message_text = params[:message_text]
  end

  def persisted?
    false
  end

end
