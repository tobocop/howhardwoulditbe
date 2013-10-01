class AfterUserRegistration
  def self.send_complete_your_registration_email(user_id)
    unless Plink::IntuitAccountService.new.user_has_account?(user_id)
      user = Plink::UserService.new.find_by_id(user_id)
      UserRegistrationMailer.complete_registration(first_name: user.first_name, email: user.email).deliver
    end
  end
end
