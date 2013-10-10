require 'spec_helper'

describe PlinkAdmin::ApplicationHelper do
  describe '#present_as_date' do
    it 'returns a date with the 0s in the date removed' do
      helper.present_as_date(Time.new(2013,9,1).in_time_zone(Time.zone)).should == '9/1/13'
    end

    it 'returns nil if given nil' do
      helper.present_as_date(nil).should be_nil
    end
  end

end
