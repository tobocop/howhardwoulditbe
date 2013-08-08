require 'spec_helper'

describe Plink::OfferExclusionRecord do
  it 'Has a table name' do
    Plink::OfferExclusionRecord.table_name.should == 'vw_offerExclusions'
  end
end
