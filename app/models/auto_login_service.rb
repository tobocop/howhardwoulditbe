class AutoLoginService
  def self.find_by_user_token(user_token)
    auto_login = Plink::UserAutoLoginRecord.existing(user_token).first

    auto_login.present? ? Plink::UserService.new.find_by_id(auto_login.user_id) : nil
  end

  def self.generate_token(user_id)
      Plink::UserAutoLoginRecord.create(user_id: user_id, expires_at: 2.days.from_now).user_token
  end
end
