module PlinkAdmin
  class ContactsController < ApplicationController

    def index
      @contacts = Plink::ContactRecord.all
    end

    def new
      contact_data
      @contact = Plink::ContactRecord.new
    end

    def create
      @contact = Plink::ContactRecord.create(params[:contact])

      if @contact.persisted?
        flash[:notice] = 'Contact created successfully'
        redirect_to contacts_path
      else
        contact_data
        flash.now[:notice] = 'Contact could not be created'
        render 'new'
      end
    end

    def edit
      contact_data
      @contact = Plink::ContactRecord.find(params[:id])
    end

    def update
      @contact = Plink::ContactRecord.find(params[:id])

      if @contact.update_attributes(params[:contact])
        flash[:notice] = 'Contact updated'
        redirect_to contacts_path
      else
        contact_data
        flash.now[:notice] = 'Contact could not be updated'
        render 'edit'
      end
    end

  private

    def contact_data
      @brands = Plink::BrandRecord.order(:name).all
    end
  end
end
