require 'spec_helper'

describe InstitutionHelper do
  describe '#authentication_form_link' do
    it 'returns a link to institutions#authentication with class="text-link"' do
      link = '<a href="/institutions/authentication/13" class="text-link">My institution</a>'

      assert_dom_equal(link, helper.authentication_form_link('My institution', 13))
    end
  end

  describe '#display_institution' do
    it 'calls authentication_form_link if supported' do
      institution = double(is_supported?: true, name: 'First Bank of Shakur', institution_id: 1)
      helper.stub(:haml_concat).and_return(true)

      helper.should_receive(:authentication_form_link)

      helper.display_institution(institution)
    end

    it 'returns greyed out text if not' do
      institution = double(is_supported?: false, name: 'Death Row Records Bank')
      helper.should_receive(:haml_tag).
        with(:div, class: 'font-italic font-lightgray').
        and_return(true)

      helper.display_institution(institution)
    end
  end
end
