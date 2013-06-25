require 'spec_helper'

describe Plink::OfferService do

  describe 'get_offers' do

    it 'returns offers by subdomain' do
      offer = create_offer
      offers = Plink::OfferService.new.get_offers('doesnt_matter_yet')
      offers.should == [offer]
    end

  end

end