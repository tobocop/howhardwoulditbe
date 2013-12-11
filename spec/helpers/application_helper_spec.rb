require 'spec_helper'

describe ApplicationHelper do
  describe '#class_for_nav_tab' do
    it 'returns a blank string if the specified tab name does not match the current tab' do
      @current_tab = 'wallet'
      helper.class_for_nav_tab(@current_tab, 'dashboard').should be_blank
    end

    it 'returns "selected" if the specified tab name matches the current tab' do
      @current_tab = 'wallet'
      helper.class_for_nav_tab(@current_tab, 'wallet').should == 'selected'
    end
  end

  describe '#plink_currency_format' do
    it 'returns the entire string when there is a decimal that is not .00' do
      helper.plink_currency_format(1.23).should == "$1.23"
    end

    it 'returns the amount with the decimal truncated when it is .00' do
      helper.plink_currency_format(1.00).should == "$1"
    end
  end

  describe '#email_capture_pixel' do
    before do
      session[:email_capture_pixel] = 'my_pixel'
    end

    it 'returns the pixel string stored in session' do
      helper.email_capture_pixel.should == 'my_pixel'
    end

    it 'returns nil if there is nothing in the session' do
      session.delete(:email_capture_pixel)
      helper.email_capture_pixel.should be_nil
    end

    it 'clears the pixel from the session after it has been returned' do
      helper.email_capture_pixel
      session[:email_capture_pixel].should be_nil
    end
  end

  describe '#refer_a_friend_data' do
    it 'returns a hash with the keys title, description, image, share-widget' do
      refer_a_friend_data = helper.refer_a_friend_data
      refer_a_friend_data.should have_key 'title'
      refer_a_friend_data.should have_key 'description'
      refer_a_friend_data.should have_key 'image'
      refer_a_friend_data.should have_key 'share-widget'
    end
  end
end
