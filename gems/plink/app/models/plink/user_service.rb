module Plink
  class UserService
    def find_by_id(id)
      User.find_by_id(id)
    end
  end
end