class GigyaSocialLoginService
  class GigyaNotificationError < Exception;
  end

  attr_reader :gigya_id, :email, :first_name, :gigya_connection, :avatar_thumbnail_url, :provider

  attr_accessor :user

  def initialize(params)
    @gigya_connection = params.fetch(:gigya_connection)
    @gigya_id = params[:UID]
    @email = params[:email]
    @first_name = params[:firstName]
    @avatar_thumbnail_url = params[:photoURL]
    @provider = params[:provider]
    @new_user = false
  end

  def sign_in_user
    if gigya_id_is_valid_primary_key
      user = Plink::User.find(gigya_id.to_i)
    else
      user = find_or_create_user_by_email(email)
    end

    if user
      update_user_thumbnail(user)
      self.user = user
      GigyaLoginResponse.new(true, @new_user)
    else
      gigya_connection.delete_user(gigya_id)
      GigyaLoginResponse.new(false, false, 'Sorry, that email has already been registered. Please use a different email.')
    end
  end

  class GigyaLoginResponse
    attr_reader :success, :message, :new_user

    def initialize(success, new_user, message = '')
      @success = success
      @new_user = new_user
      @message = message
    end

    def success?
      success
    end

    def new_user?
      new_user
    end
  end

  private

  def find_or_create_user_by_email(email)
    user = Plink::User.find_by_email(email)

    if user && provider == 'twitter'
      nil
    else
      user || create_user_from_gigya
    end
  end

  def create_user_from_gigya
    password = Password.autogenerated

    user = Plink::UserCreationService.new(email: email, first_name: first_name, password_hash: password.hashed_value, salt: password.salt, avatar_thumbnail_url: avatar_thumbnail_url).create_user

    @new_user = true

    response = gigya_connection.notify_registration(gigya_id: gigya_id, site_user_id: user.id)
    raise GigyaNotificationError unless response.successful?

    user
  end

  def update_user_thumbnail(user)
    user.update_attributes(avatar_thumbnail_url: @avatar_thumbnail_url) unless user.avatar_thumbnail_url?
  end

  def gigya_id_is_valid_primary_key
    gigya_id.to_i.to_s == gigya_id
  end
end