require 'spec_helper'

describe Plink::ContestEmailRecord do
  let(:valid_attributes) {
    {
      contest_id: 1,
      day_one_subject: 'enter the first day',
      day_one_preview: 'first day preview',
      day_one_body: 'enter our amazing contest',
      day_one_link_text: 'link to nowhere',
      day_one_image: 'http://image.com'
    }
  }

  subject(:contest_emails) { new_contest_email(valid_attributes) }

  it 'can be persisted' do
    contest_emails.save.should be_true
  end

  it { should belong_to(:contest_record) }

  context 'validations' do
    it { should validate_presence_of(:day_one_subject) }
    it { should validate_presence_of(:day_one_preview) }
    it { should validate_presence_of(:day_one_body) }
    it { should validate_presence_of(:day_one_link_text) }
    it { should validate_presence_of(:day_one_image) }
    it { should validate_presence_of(:three_day_subject) }
    it { should validate_presence_of(:three_day_preview) }
    it { should validate_presence_of(:three_day_body) }
    it { should validate_presence_of(:three_day_link_text) }
    it { should validate_presence_of(:three_day_image) }
  end

  it { should allow_mass_assignment_of(:contest_id) }
  it { should allow_mass_assignment_of(:day_one_subject) }
  it { should allow_mass_assignment_of(:day_one_preview) }
  it { should allow_mass_assignment_of(:day_one_body) }
  it { should allow_mass_assignment_of(:day_one_link_text) }
  it { should allow_mass_assignment_of(:day_one_image) }
  it { should allow_mass_assignment_of(:three_day_subject) }
  it { should allow_mass_assignment_of(:three_day_preview) }
  it { should allow_mass_assignment_of(:three_day_body) }
  it { should allow_mass_assignment_of(:three_day_link_text) }
  it { should allow_mass_assignment_of(:three_day_image) }
end
