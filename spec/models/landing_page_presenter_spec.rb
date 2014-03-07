require 'spec_helper'

describe LandingPagePresenter do
  let(:landing_page_record) { double(Plink::LandingPageRecord) }

  subject(:landing_page_presenter) { LandingPagePresenter.new(landing_page_record, false) }

  describe 'initialize' do
    it 'initializes with a landing page record, and if the user is linked' do
      landing_page_presenter = LandingPagePresenter.new(landing_page_record, false)
      landing_page_presenter.landing_page.should == landing_page_record
      landing_page_presenter.user_has_account.should be_false
    end
  end

  describe '#partial' do
    context 'with a CMS landing page' do
      let(:landing_page_record) { double(Plink::LandingPageRecord, cms?: true) }

      it 'returns the partial name cms' do
        landing_page_presenter.partial.should == 'cms'
      end
    end

    context 'with a HAML landing page' do
      let(:landing_page_record) { double(Plink::LandingPageRecord, cms?: false, partial_path: 'awesomeness') }

      it 'returns the partial name associated to the landing page record' do
        landing_page_presenter.partial.should == 'awesomeness'
      end
    end
  end

  describe '#background_image_url' do
    let(:landing_page_record) { double(Plink::LandingPageRecord, background_image_url: 'https://herp.derp') }

    it 'returns the value of background_image_url on the landing_page_record' do
      landing_page_presenter.background_image_url.should == 'https://herp.derp'
    end
  end

  describe '#logged_in_action_button' do
    context 'when a user has not linked a card' do
      it 'returns a link my card button with styles' do
        landing_page_presenter.logged_in_action_button.should == "<a href='/institutions/search' class='button primary-action large'>Link my card</a>"
      end
    end

    context 'when a user has linked a card'do
      subject(:landing_page_presenter) { LandingPagePresenter.new(landing_page_record, true) }

      it 'returns a go to wallet button with styles' do
        landing_page_presenter.logged_in_action_button.should == "<a href='/wallet' class='button primary-action large'>Go to my wallet</a>"
      end
    end
  end

  describe '#logged_out_action_button' do
    let(:landing_page_record) { double(Plink::LandingPageRecord, button_text_one: 'my button!') }

    it 'returns the join button with styles' do
      landing_page_presenter.logged_out_action_button.should == "<a href='#' class='button primary-action large' data-reveal-id='registration-form'>my button!</a>"
    end
  end

  describe '#header' do
    let(:landing_page_record) {
      double(
        Plink::LandingPageRecord,
        header_text_one: 'one',
        header_text_styles: 'color:red; height:100px;',
        header_text_two: nil
      )
    }

    context 'when there is not header_text_two content' do
      it 'returns an h1 tag with styles' do
        landing_page_presenter.header.should == "<h1 style='color:red; height:100px;'>one</h1>"
      end
    end

    context 'when there is header_text_two content' do
      before do
        landing_page_record.stub(:header_text_two).and_return('two')
      end

      it 'returns an h1 tag with styles and a line break between the content' do
        landing_page_presenter.header.should == "<h1 style='color:red; height:100px;'>one<br />two</h1>"
      end
    end
  end

  describe '#sub_header' do
    let(:landing_page_record) {
      double(
        Plink::LandingPageRecord,
        sub_header_text_one: 'one',
        sub_header_text_styles: 'color:red; height:100px;',
        sub_header_text_two: nil
      )
    }

    context 'when there is not sub_header_text_two content' do
      it 'returns an h2 tag with styles' do
        landing_page_presenter.sub_header.should == "<h2 class='light' style='color:red; height:100px;'>one</h2>"
      end
    end

    context 'when there is sub_header_text_two content' do
      before do
        landing_page_record.stub(:sub_header_text_two).and_return('two')
      end

      it 'returns an h2 tag with styles and a line break between the content' do
        landing_page_presenter.sub_header.should == "<h2 class='light' style='color:red; height:100px;'>one<br />two</h2>"
      end
    end
  end

  describe '#details' do
    let(:landing_page_record) {
      double(
        Plink::LandingPageRecord,
        detail_text_four: nil,
        detail_text_one: 'one',
        detail_text_styles: 'color:red; height:100px;',
        detail_text_three: nil,
        detail_text_two: nil
      )
    }

    context 'when there is not detail_text_two content' do
      it 'returns a div tag with styles' do
        landing_page_presenter.details.should == "<div class='offer-details' style='color:red; height:100px;'>one</div>"
      end
    end

    context 'when there is detail_text_two content' do
      before do
        landing_page_record.stub(:detail_text_two).and_return('two')
      end

      it 'returns a div tag with styles and a line break between the content' do
        landing_page_presenter.details.should == "<div class='offer-details' style='color:red; height:100px;'>one<br />two</div>"
      end
    end

    context 'when there is detail_text_two and detail_text_three content' do
      before do
        landing_page_record.stub(:detail_text_two).and_return('two')
        landing_page_record.stub(:detail_text_three).and_return('three')
      end

      it 'returns a div tag with styles and a line break between the content' do
        landing_page_presenter.details.should == "<div class='offer-details' style='color:red; height:100px;'>one<br />two<br />three</div>"
      end
    end

    context 'when there is detail_text_two, detail_text_three, and detail_text_four content' do
      before do
        landing_page_record.stub(:detail_text_two).and_return('two')
        landing_page_record.stub(:detail_text_three).and_return('three')
        landing_page_record.stub(:detail_text_four).and_return('four')
      end

      it 'returns a div tag with styles and a line break between the content' do
        landing_page_presenter.details.should == "<div class='offer-details' style='color:red; height:100px;'>one<br />two<br />three<br />four</div>"
      end
    end
  end

  describe '#how_plink_works_left' do
    let(:landing_page_record) {
      double(
        Plink::LandingPageRecord,
        how_plink_works_one_text_one: 'one',
        how_plink_works_one_text_styles: 'color:red; height:100px;',
        how_plink_works_one_text_three: nil,
        how_plink_works_one_text_two: nil
      )
    }

    context 'when there is not how_plink_works_one_text_two content' do
      it 'returns an h4 tag with styles' do
        landing_page_presenter.how_plink_works_left.should == "<h4 style='color:red; height:100px;'>one</h4>"
      end
    end

    context 'when there is how_plink_works_one_text_two content' do
      before do
        landing_page_record.stub(:how_plink_works_one_text_two).and_return('two')
      end

      it 'returns an h4 tag with styles and a line break between the content' do
        landing_page_presenter.how_plink_works_left.should == "<h4 style='color:red; height:100px;'>one<br />two</h4>"
      end
    end

    context 'when there is how_plink_works_one_text_two and how_plink_works_one_text_three content' do
      before do
        landing_page_record.stub(:how_plink_works_one_text_two).and_return('two')
        landing_page_record.stub(:how_plink_works_one_text_three).and_return('three')
      end

      it 'returns an h4 tag with styles and a line break between the content' do
        landing_page_presenter.how_plink_works_left.should == "<h4 style='color:red; height:100px;'>one<br />two<br />three</h4>"
      end
    end
  end

  describe '#how_plink_works_center' do
    let(:landing_page_record) {
      double(
        Plink::LandingPageRecord,
        how_plink_works_two_text_one: 'one',
        how_plink_works_two_text_styles: 'color:red; height:100px;',
        how_plink_works_two_text_three: nil,
        how_plink_works_two_text_two: nil
      )
    }

    context 'when there is not how_plink_works_two_text_two content' do
      it 'returns an h4 tag with styles' do
        landing_page_presenter.how_plink_works_center.should == "<h4 style='color:red; height:100px;'>one</h4>"
      end
    end

    context 'when there is how_plink_works_two_text_two content' do
      before do
        landing_page_record.stub(:how_plink_works_two_text_two).and_return('two')
      end

      it 'returns an h4 tag with styles and a line break between the content' do
        landing_page_presenter.how_plink_works_center.should == "<h4 style='color:red; height:100px;'>one<br />two</h4>"
      end
    end

    context 'when there is how_plink_works_two_text_two and how_plink_works_two_text_three content' do
      before do
        landing_page_record.stub(:how_plink_works_two_text_two).and_return('two')
        landing_page_record.stub(:how_plink_works_two_text_three).and_return('three')
      end

      it 'returns an h4 tag with styles and a line break between the content' do
        landing_page_presenter.how_plink_works_center.should == "<h4 style='color:red; height:100px;'>one<br />two<br />three</h4>"
      end
    end
  end

  describe '#how_plink_works_right' do
    let(:landing_page_record) {
      double(
        Plink::LandingPageRecord,
        how_plink_works_three_text_one: 'one',
        how_plink_works_three_text_styles: 'color:red; height:100px;',
        how_plink_works_three_text_three: nil,
        how_plink_works_three_text_two: nil
      )
    }

    context 'when there is not how_plink_works_three_text_two content' do
      it 'returns an h4 tag with styles' do
        landing_page_presenter.how_plink_works_right.should == "<h4 style='color:red; height:100px;'>one</h4>"
      end
    end

    context 'when there is how_plink_works_three_text_two content' do
      before do
        landing_page_record.stub(:how_plink_works_three_text_two).and_return('two')
      end

      it 'returns an h4 tag with styles and a line break between the content' do
        landing_page_presenter.how_plink_works_right.should == "<h4 style='color:red; height:100px;'>one<br />two</h4>"
      end
    end

    context 'when there is how_plink_works_three_text_two and how_plink_works_three_text_three content' do
      before do
        landing_page_record.stub(:how_plink_works_three_text_two).and_return('two')
        landing_page_record.stub(:how_plink_works_three_text_three).and_return('three')
      end

      it 'returns an h4 tag with styles and a line break between the content' do
        landing_page_presenter.how_plink_works_right.should == "<h4 style='color:red; height:100px;'>one<br />two<br />three</h4>"
      end
    end
  end
end
