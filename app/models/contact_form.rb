class ContactForm

  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :first_name, :last_name, :email, :message_text, :category

  def persisted?
    false
  end

end