class PasswordReset < ActiveRecord::Base

  attr_accessible :token, :user_id

  def self.build(attributes={})
    create(attributes.merge({token: generate_uuid}))
  end

  private

  def self.generate_uuid
    token = SecureRandom.uuid

    if where(token: token).count == 0
      token
    else
      generate_uuid
    end
  end

end