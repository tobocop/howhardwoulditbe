module Plink
  class UserService
    def find_by_id(id)
      create_user(Plink::UserRecord.find_by_id(id))
    end

    def find_by_email(email)
      create_user(Plink::UserRecord.where(emailAddress: email).first)
    end

    def update(id, attributes={})
      find_by_id(id).update_attributes(attributes)
    end

    private

    def create_user(user_record)
      user_record ? new_user(user_record) : nil
    end

    def new_user(user_record)
      Plink::User.new(
        new_user: false,
        user_record: user_record
      )
    end
  end
end