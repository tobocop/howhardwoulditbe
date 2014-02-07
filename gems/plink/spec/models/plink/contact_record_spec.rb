require 'spec_helper'

describe Plink::ContactRecord do
  it { should allow_mass_assignment_of(:brand_id) }
  it { should allow_mass_assignment_of(:email) }
  it { should allow_mass_assignment_of(:first_name) }
  it { should allow_mass_assignment_of(:is_active) }
  it { should allow_mass_assignment_of(:last_name) }
  it { should allow_mass_assignment_of(:password) }
  it { should allow_mass_assignment_of(:password_confirmation) }

  it { should belong_to(:brand) }

  let(:valid_params) {
    {
      brand_id: 2,
      email: 'test@herewego.com',
      first_name: 'first',
      is_active: true,
      last_name: 'last',
      password: 'my_password!',
      password_confirmation: 'my_password!'
    }
  }

  it 'can be persisted' do
    Plink::ContactRecord.create(valid_params).should be_persisted
  end

  describe 'before validations' do
    it 'sets the password and password confirmation if not present' do
      contact_record = Plink::ContactRecord.new

      contact_record.valid?

      contact_record.password.should be_present
      contact_record.password_confirmation.should be_present
    end

    it 'does not set the password and password confirmation if present' do
      contact_record = Plink::ContactRecord.new(password: 'one', password_confirmation: 'two')

      contact_record.valid?

      contact_record.password.should == 'one'
      contact_record.password_confirmation.should == 'two'
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:brand_id) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end

  describe 'named scopes' do
    describe 'find_by_email' do
      let!(:first_contact) { create_contact(email: 'myemail@plink.com') }
      let!(:second_contact) { create_contact(email: 'myemail2@plink.com') }

      it 'looks up contacts by email' do
        Plink::ContactRecord.find_by_email('myemail2@plink.com').first.id.should == second_contact.id
      end
    end
  end
end
