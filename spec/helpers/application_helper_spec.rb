require 'spec_helper'

describe ApplicationHelper do
  describe '#class_for_nav_tab' do
    it 'returns a blank string if the specified tab name does not match the current tab' do
      @current_tab = 'wallet'
      helper.class_for_nav_tab(@current_tab, 'dashboard').should be_blank
    end

    it 'returns "selected" if the specified tab name matches the current tab' do
      @current_tab = 'wallet'
      helper.class_for_nav_tab(@current_tab, 'wallet').should == 'selected'
    end
  end
end