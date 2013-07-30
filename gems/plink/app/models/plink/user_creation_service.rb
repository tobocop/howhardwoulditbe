module Plink
  class UserCreationService

    attr_accessor :avatar_thumbnail_url,
                  :email,
                  :first_name,
                  :password_hash,
                  :salt,
                  :avatar_thumbnail_url,
                  :user_record,
                  :number_of_locked_slots

    def initialize(options = {})
      self.email = options.fetch(:email)
      self.first_name = options.fetch(:first_name)
      self.password_hash = options.fetch(:password_hash)
      self.salt = options.fetch(:salt)
      self.avatar_thumbnail_url = options.fetch(:avatar_thumbnail_url, nil)
      self.number_of_locked_slots = options.fetch(:number_of_locked_slots, 2)

      set_user_record
    end

    def create_user
      Plink::UserRecord.transaction do
        user_record.save
        Plink::WalletCreationService.new(user_id: user_id).create_for_user_id(number_of_locked_slots: number_of_locked_slots)
        Plink::UsersVirtualCurrencyRecord.create(user_id: user_record.id, start_date: Date.today, virtual_currency_id: user_record.primary_virtual_currency_id)
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
      self.user_record = Plink::UserRecord.new(email: self.email, first_name: self.first_name, password_hash: self.password_hash, salt: self.salt, avatar_thumbnail_url: self.avatar_thumbnail_url)
    end

    def new_user(user_record)
      Plink::User.new(
        new_user: true,
        user_record: user_record
      )
    end


  end
end