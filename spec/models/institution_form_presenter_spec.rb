require 'spec_helper'

describe InstitutionFormPresenter do
  let(:intuit_response) do
    {:status_code=>"200",
     :result=>
      {:institution_detail=>
        {:institution_id=>"4",
         :institution_name=>"Chase Bank",
         :home_url=>"https://www.chase.com/",
         :phone_number=>"1-877-242-7372",
         :address=>
          {:address1=>"466 Lexington Ave ",
           :city=>"New York",
           :state=>"NY",
           :postal_code=>"10017",
           :country=>"USA"},
         :email_address=>
          "http://www.chase.com/chase/gx.cgi/FTcs?pagename=Chase/Href&urlname=contactus/generalfeedback",
         :special_text=>"Please enter your Chase Bank User ID and Password.",
         :currency_code=>"USD",
         :keys=>
          {:key=>
            [{:name=>"usr_name",
              :status=>"Active",
              :value_length_max=>"32",
              :display_flag=>"true",
              :display_order=>"1",
              :mask=>"false",
              :description=>"User ID"},
             {:name=>"usr_password",
              :status=>"Active",
              :display_flag=>"true",
              :display_order=>"2",
              :mask=>"true",
              :description=>"Password"},
             {:name=>"TAX_AGGR_ENABLED",
              :val=>"true",
              :status=>"Active",
              :display_flag=>"false",
              :display_order=>"20",
              :mask=>"false"}]}}}}
  end
  let(:institution) { double(intuit_institution_id: 10000, logo_url: 'plink.com/logos', name: "First Bank of Death's Head") }
  let(:institution_form_params) { intuit_response[:result].merge(institution: institution) }

  describe 'initialize' do
    subject(:intuit_form) { InstitutionFormPresenter.new(institution_form_params) }

    it 'returns the contact email address' do
      intuit_form.email.should == 'http://www.chase.com/chase/gx.cgi/FTcs?pagename=Chase/Href&urlname=contactus/generalfeedback'
    end

    it 'returns the home URL' do
      intuit_form.home_url.should == 'https://www.chase.com/'
    end

    it 'returns the intuit institution ID' do
      intuit_form.intuit_institution_id.should == 10000
    end

    it 'returns the logo URL' do
      intuit_form.logo_url.should == 'plink.com/logos'
    end

    it 'returns the name' do
      intuit_form.name.should == "First Bank of Death's Head"
    end

    it 'returns the support phone number' do
      intuit_form.phone_number.should == '1-877-242-7372'
    end
  end

  describe '#form_fields' do
    let(:form_fields) { intuit_form.form_fields }
    subject(:intuit_form) { InstitutionFormPresenter.new(institution_form_params) }

    it 'returns an ordered list of form fields' do
      user_name = {
        field_name: 'usr_name',
        label: 'User ID',
        field_tag: {
          method: :text_field_tag,
          arguments: ['auth_1', nil, {
            class: "form-field input",
            placeholder: "User ID",
            length: 32
          }]
        }
      }
      form_fields.first.should == user_name

      password = {
        field_name: "usr_password",
        label: "Password",
        field_tag: {
          method: :password_field_tag,
          arguments: ['auth_2', nil, {
            class: "form-field input",
            placeholder: "Password",
            length: nil
          }]
        }
      }
      form_fields.last.should == password
    end

    it 'returns only fields with display_flag = "true"' do
      form_fields.map{|f| f[:field_name]}.should_not include 'TAX_AGGR_ENABLED'
    end

    it 'returns the Rails form "_tag" method needed for the UI' do
      form_fields.map{|f| f[:field_tag]}.should_not include 'text_tag'
      form_fields.map{|f| f[:field_tag]}.should_not include 'password_field_tag'
    end
  end
end
