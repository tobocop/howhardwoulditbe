module Lyris
  class UserDataCollector

    attr_reader :account_add_event, :currency_name, :email_capture_event, :user_id, :user

    def initialize(user_id, currency_name)
      @currency_name = currency_name
      @user_id = user_id
      @user = Plink::UserService.new.find_by_id(user_id)
      @account_add_event = Plink::EventService.get_card_add_event(user_id)
      @email_capture_event = Plink::EventService.get_email_capture_event(user_id)
    end

    def to_hash
      {
        bank_registered: account_add_event.present?,
        birthday: user.birthday,
        first_name: user.first_name,
        gender: gender,
        incentivized_on_card_reg: incentivized_on_card_reg?,
        incentivized_on_join: incentivized_on_join?,
        is_subscribed: user.is_subscribed,
        last_name: user.last_name,
        registration_affiliate_id: registration_affiliate_id,
        registration_date: registration_date,
        state: user.state,
        user_id: user.id,
        virtual_currency: currency_name,
        zip: user.zip
      }
    end

  private

    def gender
      if user.is_male
        'Male'
      elsif user.is_male == false
        'Female'
      else
        nil
      end
    end

    def incentivized_on_card_reg?
      if account_add_event && account_add_event.affiliate_record
        account_add_event.affiliate_record.has_incented_card_registration
      else
        false
      end
    end

    def incentivized_on_join?
      if email_capture_event && email_capture_event.affiliate_record
        email_capture_event.affiliate_record.has_incented_join
      else
        false
      end
    end

    def registration_affiliate_id
      email_capture_event ? email_capture_event.affiliate_id : 0
    end

    def registration_date
      email_capture_event ? email_capture_event.created_at : nil
    end
  end
end
