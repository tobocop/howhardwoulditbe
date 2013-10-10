require 'spec_helper'

describe PlinkAdmin::ContestsHelper do
  describe '#present_column_name' do
    it 'removes underscores and replaces them with spaces' do
      helper.present_column_name('two_words').should == 'Two Words'
    end

    it 'titleizes the argument' do
      helper.present_column_name('stuff_thats_cool').should == 'Stuff Thats Cool'
    end
  end
end
