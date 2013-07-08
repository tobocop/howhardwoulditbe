class ContactController < ApplicationController

  def new
    @contact_form = ContactForm.new
  end

  def create
    contact_form_params = params[:contact_form]

    @contact_form = ContactForm.new(contact_form_params)

    if @contact_form.valid?

      ContactMailer.contact_email(
          from: contact_form_params[:email],
          first_name: contact_form_params[:first_name],
          last_name: contact_form_params[:last_name],
          category: contact_form_params[:category],
          message_text: contact_form_params[:message_text]
      ).deliver

      redirect_to thank_you_contact_path
    else
      render 'new'
    end
  end

  def thank_you

  end

end