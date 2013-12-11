require 'spec_helper'

describe PixelPresenterFactory do
  let(:affilaite_with_card_add_pixel) {
    double(
      id: 3,
      card_add_pixel: '$useriD$$subId$$subID2$$subiD3$$subId4$'
    )
  }
  let(:valid_event) {
    double(
      affiliate_id: 3,
      affiliate_record: affilaite_with_card_add_pixel,
      sub_id: 'one',
      sub_id_four: 'four',
      sub_id_three: 'three',
      sub_id_two: 'two',
      user_id: 3
    )
  }
  let(:invalid_event) {double(affiliate_record: double(card_add_pixel: nil))}
  let(:pixel_presenter) { double }

  describe '.build_by_event' do
    context 'with an event that have an affiliate with a card add pixel'
    it 'returns a pixel presenter' do
      pixel_attrs = {
        pixel: '$useriD$$subId$$subID2$$subiD3$$subId4$',
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

  context 'with an event that have an affiliate without a card add pixel' do
    it 'returns a null pixel presenter' do
      NullPixelPresenter.should_receive(:new).with().and_return(pixel_presenter)
      presenter = PixelPresenterFactory.build_by_event(invalid_event)
      presenter.should == pixel_presenter
    end
  end
end

describe PixelPresenter do
  let(:pixel_attrs) {
    {
      pixel: 'other$useriD$shit$subId$in$subID2$$subiD3$$subId4$andafter',
      sub_id: 'one',
      sub_id_four: 'four',
      sub_id_three: 'three',
      sub_id_two: 'two',
      user_id: 3
    }
  }

  describe '.initialize' do
    it 'raises if a pixel is not provided' do
      expect {
        PixelPresenter.new(pixel_attrs.except(:pixel))
      }.to raise_error KeyError
    end
  end

  describe '#pixel' do
    it 'returns the translated pixel' do
      presenter = PixelPresenter.new(pixel_attrs)
      presenter.pixel.should == 'other3shitoneintwothreefourandafter'
    end

    it 'does not translate ids that it does not know the values to' do
      presenter = PixelPresenter.new(pixel_attrs.except(:sub_id_two))
      presenter.pixel.should == 'other3shitonein$subID2$threefourandafter'
    end
  end
end

describe NullPixelPresenter do
  describe '#pixel' do
    it 'returns nil' do
      NullPixelPresenter.new.pixel.should be_nil
    end
  end
end
