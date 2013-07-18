module Plink
  class UserService
    def find_by_id(id)
      create_user(Plink::UserRecord.find_by_id(id))
    end

    def find_by_email(email)
      create_user(Plink::UserRecord.where(emailAddress: email).first)
    end

    def update(id, attributes={})
      user = find_by_id(id)
      user.update_attributes(attributes)
      create_user(user)
    end

    def verify_password(user_id, password)
      user = find_by_id(user_id)

      if user
        hashed_password = Password.new(unhashed_password: password, salt: user.salt).hashed_value
        user.password_hash == hashed_password
      else
        false
      end
    end

    private

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