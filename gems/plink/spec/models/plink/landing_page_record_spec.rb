require 'spec_helper'

describe Plink::LandingPageRecord do
  it { should allow_mass_assignment_of(:background_image_url) }
  it { should allow_mass_assignment_of(:button_text_one) }
  it { should allow_mass_assignment_of(:cms) }
  it { should allow_mass_assignment_of(:detail_text_four) }
  it { should allow_mass_assignment_of(:detail_text_one) }
  it { should allow_mass_assignment_of(:detail_text_styles) }
  it { should allow_mass_assignment_of(:detail_text_three) }
  it { should allow_mass_assignment_of(:detail_text_two) }
  it { should allow_mass_assignment_of(:header_text_one) }
  it { should allow_mass_assignment_of(:header_text_styles) }
  it { should allow_mass_assignment_of(:header_text_two) }
  it { should allow_mass_assignment_of(:how_plink_works_one_text_one) }
  it { should allow_mass_assignment_of(:how_plink_works_one_text_styles) }
  it { should allow_mass_assignment_of(:how_plink_works_one_text_three) }
  it { should allow_mass_assignment_of(:how_plink_works_one_text_two) }
  it { should allow_mass_assignment_of(:how_plink_works_three_text_one) }
  it { should allow_mass_assignment_of(:how_plink_works_three_text_styles) }
  it { should allow_mass_assignment_of(:how_plink_works_three_text_three) }
  it { should allow_mass_assignment_of(:how_plink_works_three_text_two) }
  it { should allow_mass_assignment_of(:how_plink_works_two_text_one) }
  it { should allow_mass_assignment_of(:how_plink_works_two_text_styles) }
  it { should allow_mass_assignment_of(:how_plink_works_two_text_three) }
  it { should allow_mass_assignment_of(:how_plink_works_two_text_two) }
  it { should allow_mass_assignment_of(:name) }
  it { should allow_mass_assignment_of(:partial_path) }
  it { should allow_mass_assignment_of(:sub_header_text_one) }
  it { should allow_mass_assignment_of(:sub_header_text_styles) }
  it { should allow_mass_assignment_of(:sub_header_text_two) }

  let(:valid_params) {
    {
      background_image_url: 'https://example.com/image.png',
      button_text_one: 'join for FREEEEEEE!',
      cms: true,
      detail_text_one: 'Super awesomes!',
      header_text_one: 'not so awesome',
      how_plink_works_one_text_one: 'how one',
      how_plink_works_three_text_one: 'how three',
      how_plink_works_two_text_one: 'how two',
      name: 'my testin derp',
      sub_header_text_one: 'sub_header'
    }
  }

  subject { Plink::LandingPageRecord.new(valid_params) }

  it { should have_many(:registration_link_landing_page_records) }
  it { should have_many(:registration_link_records).through(:registration_link_landing_page_records) }

  it 'can be persisted' do
    Plink::LandingPageRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    it{ should validate_presence_of(:name) }

    context 'when the landing page is cms' do
      it 'validates the presence of a secure background_image_url' do
        landing_page = Plink::LandingPageRecord.new(valid_params.except(:background_image_url))
        landing_page.should_not be_valid
        landing_page.should have(2).errors_on(:background_image_url)

        landing_page.background_image_url = 'http://something.com'
        landing_page.should_not be_valid
        landing_page.should have(1).error_on(:background_image_url)

        landing_page.background_image_url = 'https://something.com'
        landing_page.should be_valid
      end

      it 'validates the presence of button_text_one' do
        landing_page = Plink::LandingPageRecord.new(valid_params.except(:button_text_one))
        landing_page.should_not be_valid
        landing_page.should have(1).error_on(:button_text_one)

        landing_page.button_text_one = 'something'
        landing_page.should be_valid
      end

      it 'validates the presence of header_text_one' do
        landing_page = Plink::LandingPageRecord.new(valid_params.except(:header_text_one))
        landing_page.should_not be_valid
        landing_page.should have(1).error_on(:header_text_one)

        landing_page.header_text_one = 'something'
        landing_page.should be_valid
      end

      it 'validates the presence of how_plink_works_one_text_one' do
        landing_page = Plink::LandingPageRecord.new(valid_params.except(:how_plink_works_one_text_one))
        landing_page.should_not be_valid
        landing_page.should have(1).error_on(:how_plink_works_one_text_one)

        landing_page.how_plink_works_one_text_one = 'something'
        landing_page.should be_valid
      end

      it 'validates the presence of how_plink_works_three_text_one' do
        landing_page = Plink::LandingPageRecord.new(valid_params.except(:how_plink_works_three_text_one))
        landing_page.should_not be_valid
        landing_page.should have(1).error_on(:how_plink_works_three_text_one)

        landing_page.how_plink_works_three_text_one = 'something'
        landing_page.should be_valid
      end

      it 'validates the presence of how_plink_works_two_text_one' do
        landing_page = Plink::LandingPageRecord.new(valid_params.except(:how_plink_works_two_text_one))
        landing_page.should_not be_valid
        landing_page.should have(1).error_on(:how_plink_works_two_text_one)

        landing_page.how_plink_works_two_text_one = 'something'
        landing_page.should be_valid
      end

      it 'validates the presence of sub_header_text_one' do
        landing_page = Plink::LandingPageRecord.new(valid_params.except(:sub_header_text_one))
        landing_page.should_not be_valid
        landing_page.should have(1).error_on(:sub_header_text_one)

        landing_page.sub_header_text_one = 'something'
        landing_page.should be_valid
      end
    end

    context 'when the landing page is not cms' do
      let(:landing_page) { Plink::LandingPageRecord.new(cms: false, name: 'withpartial') }

      it 'validates the presence of a partial_path' do
        landing_page.should_not be_valid
        landing_page.should have(1).error_on(:partial_path)

        landing_page.partial_path = 'asd'
        landing_page.should be_valid
      end
    end
  end
end
