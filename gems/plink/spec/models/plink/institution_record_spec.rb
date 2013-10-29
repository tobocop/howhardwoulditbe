require 'spec_helper'

describe Plink::InstitutionRecord do
  let(:valid_params) {
    {
      hash_value: 'val',
      name: 'freds',
      intuit_institution_id: 3
    }
  }

  subject { Plink::InstitutionRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    create_institution(valid_params).should be_persisted
  end

  it { should allow_mass_assignment_of(:hash_value)}
  it { should allow_mass_assignment_of(:intuit_institution_id)}
  it { should allow_mass_assignment_of(:is_active)}
  it { should allow_mass_assignment_of(:is_supported)}
  it { should allow_mass_assignment_of(:logo_url)}
  it { should allow_mass_assignment_of(:name)}

  describe '.search' do
    before do
      Plink::InstitutionRecord.index_name('test_' + Plink::InstitutionRecord.model_name.plural)
      Plink::InstitutionRecord.index.delete
      Plink::InstitutionRecord.create_elasticsearch_index
    end

    let!(:chase) { create_institution(name: 'Chase Bank') }
    let!(:fifth_third_bank_of_america) { create_institution(name: 'Fifth Third Bank of America') }

    it 'returns all institutions when not given a search string' do
      Plink::InstitutionRecord.index.refresh
      institutions = Plink::InstitutionRecord.search('Chase')

      institutions.length.should == 1

      institutions.should include chase
      institutions.should_not include fifth_third_bank_of_america
    end

    it 'returns a list of institutions' do
      Plink::InstitutionRecord.index.refresh
      institutions = Plink::InstitutionRecord.search('Bank')

      institutions.length.should == 2
      institutions.should include chase
      institutions.should include fifth_third_bank_of_america
    end

    it 'optionally limits the size of the result set' do
      Plink::InstitutionRecord.index.refresh
      institutions = Plink::InstitutionRecord.search('Bank', 1)

      institutions.length.should == 1
    end

    it 'ignores case when searching' do
      Plink::InstitutionRecord.index.refresh
      institutions = Plink::InstitutionRecord.search('bAnK')

      institutions.length.should == 2
    end
  end

  describe 'named scopes' do
    describe '.most_popular' do
      let!(:popular_institution) do
        institution = create_institution(name: 'Chase Bank')
        create_users_institution(institution_id: institution.id)
        create_users_institution(institution_id: institution.id)
        institution
      end

      let!(:semi_popular_institution) do
        institution = create_institution(name: 'Big Hands Bank')
        create_users_institution(institution_id: institution.id)
        institution
      end

      let!(:unpopular_institution) do
        institution = create_institution(name: 'Little Hands Bank')
        create_users_institution(institution_id: institution.id)
        institution
      end

      it 'limits the number of results based on an optional argument' do
        banks = Plink::InstitutionRecord.most_popular(2)

        banks.length.should == 2
        banks.first[:frequency].should == 2
      end

      it 'returns a list of institutions with frequencies' do
        banks = Plink::InstitutionRecord.most_popular

        banks.map(&:frequency).should == [2,1,1]
      end

      it 'returns institutions that are supported' do
        unpopular_institution.update_attribute(:is_supported, 0)

        banks = Plink::InstitutionRecord.most_popular

        banks.should_not include unpopular_institution
      end

      it 'returns institutions that are active' do
        unpopular_institution.update_attribute(:is_active, 0)

        banks = Plink::InstitutionRecord.most_popular

        banks.should_not include unpopular_institution
      end
    end
  end
end
