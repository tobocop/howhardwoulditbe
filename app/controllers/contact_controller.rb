class ContactController < ApplicationController
  def new
    @contact_form = ContactForm.new
  end

  def create
    @contact_form = ContactForm.new(contact_form_params)

    if @contact_form.valid?
      deliver_contact_email
      redirect_to wallet_path, notice: 'Thank you for contacting Plink.'
    else
      render 'new'
    end
  end

  private

  def deliver_contact_email
    ContactMailer.contact_email(email_params).deliver
  end

  def email_params
    {
      from: contact_form_params[:email],
      first_name: contact_form_params[:first_name],
      last_name: contact_form_params[:last_name],
      category: contact_form_params[:category],
      message_text: contact_form_params[:message_text]
    }
  end

  def contact_form_params
    params[:contact_form]
  end
end
