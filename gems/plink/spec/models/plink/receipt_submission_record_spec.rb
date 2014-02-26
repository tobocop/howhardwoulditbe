require 'spec_helper'

describe Plink::ReceiptSubmissionRecord do
  it { should allow_mass_assignment_of(:body) }
  it { should allow_mass_assignment_of(:from) }
  it { should allow_mass_assignment_of(:headers) }
  it { should allow_mass_assignment_of(:raw_body) }
  it { should allow_mass_assignment_of(:raw_html) }
  it { should allow_mass_assignment_of(:raw_text) }
  it { should allow_mass_assignment_of(:subject) }
  it { should allow_mass_assignment_of(:to) }
  it { should allow_mass_assignment_of(:user_id) }

  let(:valid_params) {
    {
      body: 'some body',
      from: 'testing@example.com',
      headers: '{"some":"json"}',
      raw_body: 'some raw body',
      raw_html: 'some raw html',
      raw_text: 'some raw text',
      subject: 'pepsi promotion',
      to: '{"some":"json"}',
      user_id: 23
    }
  }

  it 'can be persisted' do
    Plink::ReceiptSubmissionRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    it { should validate_presence_of(:from) }
  end
end
