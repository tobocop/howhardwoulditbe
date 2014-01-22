require 'spec_helper'

describe Plink::ContestEmailRecord do
  let(:valid_attributes) {
    {
      contest_id: 1,
      day_one_subject: 'enter the first day',
      day_one_preview: 'first day preview',
      day_one_body: 'enter our amazing contest',
      day_one_link_text: 'link to nowhere',
      day_one_image: 'http://image.com',
      three_day_subject: 'enter the third day',
      three_day_preview: 'third day preview',
      three_day_body: 'enter our sweet contest',
      three_day_link_text: 'link to somewhere',
      three_day_image: 'http://picture.com',
      winner_subject: 'you won',
      winner_preview: 'winner day preview',
      winner_body: 'you won our amazing contest',
      winner_link_text: 'link to anywhere',
      winner_image: 'http://winner.com'
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
    it { should validate_presence_of(:winner_subject) }
    it { should validate_presence_of(:winner_preview) }
    it { should validate_presence_of(:winner_body) }
    it { should validate_presence_of(:winner_link_text) }
    it { should validate_presence_of(:winner_image) }
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
  it { should allow_mass_assignment_of(:winner_subject) }
  it { should allow_mass_assignment_of(:winner_preview) }
  it { should allow_mass_assignment_of(:winner_body) }
  it { should allow_mass_assignment_of(:winner_link_text) }
  it { should allow_mass_assignment_of(:winner_image) }

  describe '.find_by_contest_id' do
    it 'returns the contest with the given id' do
      contest = create_contest
      contest_email = create_contest_email(contest_id: contest.id)

      Plink::ContestEmailRecord.find_by_contest_id(contest.id).should == contest_email
    end

    it 'returns nil if no user present' do
      Plink::ContestEmailRecord.find_by_contest_id(333).should == nil
    end
  end
end
