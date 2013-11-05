require 'spec_helper'

describe InstitutionHelper do
  describe '#authentication_form_link' do
    it 'returns a link to institutions#authentication with class="text-link"' do
      link = '<a href="/institutions/authentication/13" class="text-link">My institution</a>'

      assert_dom_equal(link, helper.authentication_form_link('My institution', 13))
    end
  end
end
