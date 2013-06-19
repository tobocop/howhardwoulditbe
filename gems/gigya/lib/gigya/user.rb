class Gigya::User
  attr_accessor :email, :first_name, :id, :is_site_user

  def self.from_redirect_params(params)
    if Gigya::Signature.new(params).valid?
      new(params)
    end
  end

  def initialize(params)
    self.email = params[:email]
    self.first_name = params[:firstName]
    self.id = params[:UID]
    self.is_site_user = params[:isSiteUser]
  end

  def site_user?
    is_site_user
  end
end