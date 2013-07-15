module PlinkAdmin
  class Admin < ActiveRecord::Base
    devise :database_authenticatable, :trackable, :validatable, :lockable
  end
end
