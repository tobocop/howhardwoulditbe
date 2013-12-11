require 'spec_helper'

describe PixelPresenterFactory do
  let(:institution_authenticated_pixel) { 'card-$useriD$$subId$$subID2$$subiD3$$subId4$' }
  let(:email_capture_pixel) { 'email-$useriD$$subId$$subID2$$subiD3$$subId4$' }
  let(:affiliate_with_pixels) {
    double(id: 3, card_add_pixel: institution_authenticated_pixel, email_add_pixel: email_capture_pixel)
  }
  let(:valid_event) {
    double(
      affiliate_id: 3,
      affiliate_record: affiliate_with_pixels,
      sub_id: 'one',
      sub_id_four: 'four',
      sub_id_three: 'three',
      sub_id_two: 'two',
      user_id: 3
      )
  }
  let(:invalid_event) { double(affiliate_record: nil) }
  let(:pixel_presenter) { double }

  describe '.build_by_event' do
    context 'with an event that has an affiliate' do
      it 'returns a pixel presenter' do
        pixel_attrs = {
          institution_authenticated_pixel: institution_authenticated_pixel,
          email_capture_pixel: email_capture_pixel,
          sub_id: 'one',
          sub_id_four: 'four',
          sub_id_three: 'three',
          sub_id_two: 'two',
          user_id: 3
        }
        PixelPresenter.should_receive(:new).with(pixel_attrs).and_return(pixel_presenter)

        presenter = PixelPresenterFactory.build_by_event(valid_event)
        presenter.should == pixel_presenter
      end
    end

    context 'with an event that does not have an affiliate' do
      it 'returns a null pixel resenter' do
        NullPixelPresenter.should_receive(:new).with().and_return(pixel_presenter)
        presenter = PixelPresenterFactory.build_by_event(invalid_event)
        presenter.should == pixel_presenter
      end
    end
  end
end

describe PixelPresenter do
  let(:pixel_attrs) {
    {
      institution_authenticated_pixel: 'card-other$useriD$shit$subId$in$subID2$$subiD3$$subId4$andafter',
      email_capture_pixel: 'email-other$useriD$shit$subId$in$subID2$$subiD3$$subId4$andafter',
      sub_id: 'one',
      sub_id_four: 'four',
      sub_id_three: 'three',
      sub_id_two: 'two',
      user_id: 3
    }
  }
  describe '.initialize' do
    it 'raises if a card add pixel is not provided' do
      expect {
        PixelPresenter.new(pixel_attrs.except(:institution_authenticated_pixel))
      }.to raise_exception(KeyError, 'key not found: :institution_authenticated_pixel')
    end

    it 'raises if an email capture pixel is not provided' do
      expect {
        PixelPresenter.new(pixel_attrs.except(:email_capture_pixel))
      }.to raise_exception(KeyError, 'key not found: :email_capture_pixel')
    end
  end

  context 'pixels' do
    describe '#institution_authenticated_pixel' do
      it 'returns the translated institution_authenticated_pixel pixel' do
        presenter = PixelPresenter.new(pixel_attrs)
        presenter.institution_authenticated_pixel.should == 'card-other3shitoneintwothreefourandafter'
      end

      it 'does not translate ids that it does not know the values to' do
        presenter = PixelPresenter.new(pixel_attrs.except(:sub_id_two))
        presenter.institution_authenticated_pixel.should == 'card-other3shitonein$subID2$threefourandafter'
      end
    end

    describe '#email_capture_pixel' do
      it 'returns the translated email_capture_pixel pixel' do
        presenter = PixelPresenter.new(pixel_attrs)
        presenter.email_capture_pixel.should == 'email-other3shitoneintwothreefourandafter'
      end

      it 'does not translate ids that it does not know the values to' do
        presenter = PixelPresenter.new(pixel_attrs.except(:sub_id_two))
        presenter.email_capture_pixel.should == 'email-other3shitonein$subID2$threefourandafter'
      end
    end
  end
end

describe NullPixelPresenter do
  describe '#institution_authenticated_pixel' do
    it 'returns nil' do
      NullPixelPresenter.new.institution_authenticated_pixel.should be_nil
    end
  end

  describe '#email_capture_pixel' do
    it 'returns nil' do
      NullPixelPresenter.new.email_capture_pixel.should be_nil
    end
  end
end
