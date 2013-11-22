require 'spec_helper'

describe 'vw_awards:add_email_message_to_vw_awards', skip_in_build: true do
  include_context 'rake'

  let!(:award_type) { create_award_type(award_type: 'not anymore', email_message: 'for Bananas are awesome') }
  let!(:free_award) {
    create_free_award(
      user_id: 3,
      award_type_id: award_type.id
    )
  }

  it 'sets the award_type to the email message without the for instead of the award_type field' do
    subject.invoke

    Plink::AwardRecord.first.award_display_name.should == 'Bananas are awesome'
  end
end

