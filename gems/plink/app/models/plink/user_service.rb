module Plink
  class UserService
    def find_by_id(id)
      User.find_by_id(id)
    end

    def find_by_email(email)
      User.where(emailAddress: email).first
    end
  end
end