module Plink
  class UserCreationService

    attr_accessor :avatar_thumbnail_url, :birthday, :city, :email, :first_name, :is_male,
      :ip, :number_of_locked_slots, :password_hash, :provider, :salt, :state, :username,
      :user_agent, :user_record, :zip

    def initialize(options = {})
      self.avatar_thumbnail_url = options.fetch(:avatar_thumbnail_url, nil)
      self.birthday = options[:birthday]
      self.city = options[:city]
      self.email = options.fetch(:email)
      self.first_name = options.fetch(:first_name)
      self.is_male = options[:is_male]
      self.ip = options.fetch(:ip, '0.0.0.0')
      self.number_of_locked_slots = options.fetch(:number_of_locked_slots, 2)
      self.password_hash = options.fetch(:password_hash)
      self.provider = options.fetch(:provider)
      self.salt = options.fetch(:salt)
      self.state = options[:state]
      self.username = options[:username]
      self.user_agent = options[:user_agent]
      self.zip = options[:zip]

      set_user_record
    end

    def create_user
      Plink::UserRecord.transaction do
        user_record.save
        Plink::UsersVirtualCurrencyRecord.create(user_id: user_record.id, start_date: Time.zone.today, virtual_currency_id: user_record.primary_virtual_currency_id)
        Plink::WalletCreationService.new(user_id: user_id).create_for_user_id(number_of_locked_slots: number_of_locked_slots)
        new_user(user_record)
      end
    end

    def valid?
      user_record.valid?
    end

    def errors
      user_record.errors
    end

    def user_id
      user_record.id
    end

  private

    def set_user_record
      user_params = {
        avatar_thumbnail_url: self.avatar_thumbnail_url,
        birthday: self.birthday,
        city: self.city,
        email: self.email,
        first_name: self.first_name,
        ip: self.ip,
        is_male: self.is_male,
        password_hash: self.password_hash,
        provider: self.provider,
        salt: self.salt,
        state: self.state,
        user_agent: self.user_agent,
        username: self.username,
        zip: self.zip
      }

      self.user_record = Plink::UserRecord.new(user_params)
    end

    def new_user(user_record)
      Plink::User.new(
        new_user: true,
        user_record: user_record
      )
    end

  end
end
