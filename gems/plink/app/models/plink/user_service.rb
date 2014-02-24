module Plink
  class UserService
    attr_accessor :unscoped

    def initialize(unscoped = false)
      @unscoped = unscoped
    end

    def find_by_id(id)
      create_user(find_user_record(id))
    end

    def find_by_email(email)
      create_user(plink_user_record.where(emailAddress: email).first)
    end

    def search_by_email(email, max_results = 25)
      create_users(plink_user_record.where("emailAddress LIKE ?", "#{email}%").limit(max_results))
    end

    def find_by_password_hash(password_hash)
      create_user(plink_user_record.where(password: password_hash.chomp).first)
    end

    def update(id, attributes={})
      user = find_by_id(id)
      user.update_attributes(attributes)
      create_user(user)
    end

    def update_password(id, attributes={})
      user = find_user_record(id)

      user.new_password = attributes.fetch(:new_password)
      user.new_password_confirmation = attributes.fetch(:new_password_confirmation)

      user.save

      create_user(user)
    end

    def verify_password(user_id, password)
      user = find_user_record(user_id)

      if user
        hashed_password = Password.new(unhashed_password: password, salt: user.salt).hashed_value
        user.password_hash == hashed_password
      else
        false
      end
    end

    def update_subscription_preferences(user_id, attributes)
      user_record = find_user_record(user_id)
      is_subscribed = attributes[:is_subscribed]
      user_record.update_attribute(:is_subscribed, is_subscribed) if is_subscribed.present?
      user_record.update_attribute(:unsubscribe_date, Time.zone.now) if is_subscribed == '0'

      daily_contest_reminder = attributes[:daily_contest_reminder]
      user_record.update_attribute(:daily_contest_reminder, daily_contest_reminder) if daily_contest_reminder.present?

      create_user(user_record)
    end

    private

    def find_user_record(id)
      plink_user_record.find_by_id(id)
    end

    def plink_user_record
      @plink_user_record ||= @unscoped ? Plink::UserRecord.unscoped : Plink::UserRecord
    end

    def create_users(user_records)
      user_records.map { |user_record| create_user(user_record) }
    end

    def create_user(user_record)
      user_record ? new_user(user_record) : nil
    end

    def new_user(user_record)
      Plink::User.new(
        new_user: false,
        user_record: user_record,
        errors: user_record.errors
      )
    end
  end
end
