require 'spec_helper'

describe PlinkAdmin::ContestsHelper do
  describe '#present_date' do
    it 'returns a date with the 0s in the date removed' do
      helper.present_date(Time.new(2013,9,1).in_time_zone(Time.zone)).should == '9/1/13'
    end

    it 'returns nil if given nil' do
      helper.present_date(nil).should be_nil
    end
  end

  describe '#present_column_name' do
    it 'removes underscores and replaces them with spaces' do
      helper.present_column_name('two_words').should == 'Two Words'
    end
    it 'titleizes the argument' do
      helper.present_column_name('stuff_thats_cool').should == 'Stuff Thats Cool'
    end
  end
end
