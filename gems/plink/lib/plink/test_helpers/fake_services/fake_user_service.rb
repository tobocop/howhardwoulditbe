module Plink
  class FakeUserService
    def initialize(users)
      @users = users
    end

    def find_by_id(id)
      @users[id]
    end
  end
end
