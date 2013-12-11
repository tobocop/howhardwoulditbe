class PixelPresenterFactory
  def self.build_by_event(event)
    affiliate = event.affiliate_record
    if affiliate
      PixelPresenter.new(
        institution_authenticated_pixel: affiliate.card_add_pixel,
        email_capture_pixel: affiliate.email_add_pixel,
        sub_id: event.sub_id,
        sub_id_four: event.sub_id_four,
        sub_id_three: event.sub_id_three,
        sub_id_two: event.sub_id_two,
        user_id: event.user_id
      )
    else
      NullPixelPresenter.new
    end
  end
end

class PixelPresenter
  def initialize(options)
    @raw_institution_authenticated_pixel = options.fetch(:institution_authenticated_pixel)
    @raw_email_capture_pixel = options.fetch(:email_capture_pixel)
    @sub_id = options[:sub_id]
    @sub_id_four = options[:sub_id_four]
    @sub_id_three = options[:sub_id_three]
    @sub_id_two = options[:sub_id_two]
    @user_id = options[:user_id]
  end

  def institution_authenticated_pixel
    replace_pixel_vars(@raw_institution_authenticated_pixel)
  end

  def email_capture_pixel
    replace_pixel_vars(@raw_email_capture_pixel)
  end

private

  def replace_pixel_vars(pixel)
    pixel.gsub(/\$\w+\$/) { |matched_param| replace(matched_param) }.html_safe if pixel
  end

  def replace(param)
    value = replace_translation[param.upcase]
    value.nil? ? param : value
  end

  def replace_translation
    {
     '$USERID$' => @user_id,
     '$SUBID$' => @sub_id,
     '$SUBID2$' => @sub_id_two,
     '$SUBID3$' => @sub_id_three,
     '$SUBID4$' => @sub_id_four
    }
  end
end

class NullPixelPresenter
  def institution_authenticated_pixel
    nil
  end

  def email_capture_pixel
    nil
  end
end
