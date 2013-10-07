class AutoLoginService
  def self.find_by_user_token(user_token)
    auto_login = Plink::UserAutoLoginRecord.existing(user_token).first

    auto_login.present? ? Plink::UserService.new.find_by_id(auto_login.user_id) : nil
  end
end
