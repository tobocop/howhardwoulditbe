module Lyris
  class User
    attr_reader :bank_registered, :birthday, :config, :email, :first_name, :gender,
      :incentivized_on_card_reg, :incentivized_on_join, :is_subscribed, :last_name,
      :login_token,:new_email, :registration_affiliate_id, :registration_date, :state,
      :user_id, :user_id_ends_with, :virtual_currency, :zip

    def initialize(config, email, demographic_data={})
      @config = config
      @email = email

      @bank_registered = demographic_data[:bank_registered]
      @birthday = demographic_data[:birthday]
      @first_name = demographic_data[:first_name]
      @gender = demographic_data[:gender]
      @incentivized_on_card_reg = demographic_data[:incentivized_on_card_reg]
      @incentivized_on_join = demographic_data[:incentivized_on_join]
      @is_subscribed = demographic_data[:is_subscribed]
      @last_name = demographic_data[:last_name]
      @login_token = demographic_data[:login_token]
      @new_email = demographic_data[:new_email]
      @registration_affiliate_id = demographic_data[:registration_affiliate_id]
      @registration_date = demographic_data[:registration_date]
      @state = demographic_data[:state]
      @user_id = demographic_data[:user_id]
      @user_id_ends_with = user_id.to_s[-1,1]
      @virtual_currency = demographic_data[:virtual_currency]
      @zip = demographic_data[:zip]
    end

    def add_to_list
      call_lyris('add', demographic_xml)
    end

    def update
      call_lyris('update', demographic_xml)
    end

    def update_email
      call_lyris('update', email_update_xml) if new_email.present?
    end

    def remove_from_list
      call_lyris('update', removal_xml)
    end

  private

    def call_lyris(activity, additional_xml)
      options = {
        email: email,
        additional_xml: additional_xml
      }
      lyris_http_return = Lyris::Http.new(config, 'record', activity, options).perform_request
      Lyris::Response.new(lyris_http_return.body)
    end

    def email_update_xml
      %Q{<DATA type="extra" id="new_email">#{new_email}</DATA>}
    end

    def removal_xml
      %Q{<DATA type="extra" id="state">trashed</DATA>}
    end

    def demographic_xml
      %Q{<DATA type="extra" id="state">#{is_subscribed ? 'active' : 'unsubscribed'}</DATA>
        <DATA type="demographic" id="57722">#{boolean_to_on_off(bank_registered)}</DATA>
        <DATA type="demographic" id="57720">#{parse_lyris_date(birthday)}</DATA>
        <DATA type="demographic" id="1">#{first_name}</DATA>
        <DATA type="demographic" id="11">#{gender}</DATA>
        <DATA type="demographic" id="61623">#{boolean_to_on_off(incentivized_on_card_reg)}</DATA>
        <DATA type="demographic" id="61622">#{boolean_to_on_off(incentivized_on_join)}</DATA>
        <DATA type="demographic" id="35743">#{boolean_to_on_off(is_subscribed)}</DATA>
        <DATA type="demographic" id="2">#{last_name}</DATA>
        <DATA type="demographic" id="64485">#{login_token}</DATA>
        <DATA type="demographic" id="57721">#{registration_affiliate_id}</DATA>
        <DATA type="demographic" id="57728">#{parse_lyris_date(registration_date)}</DATA>
        <DATA type="demographic" id="6">#{state}</DATA>
        <DATA type="demographic" id="35630">#{user_id}</DATA>
        <DATA type="demographic" id="61695">#{user_id_ends_with}</DATA>
        <DATA type="demographic" id="39583">#{virtual_currency}Points</DATA>
        <DATA type="demographic" id="7">#{zip}</DATA>}
    end

    def parse_lyris_date(date)
      date.strftime('%m/%d/%Y') if date
    end

    def boolean_to_on_off(value)
      value ? 'on' : 'off'
    end
  end
end
