require 'spec_helper'

describe AccountHelper do
  describe '#show_change_link_for_provider' do
    it 'renders HAML if the provider is organic' do
      Haml::Engine.should_receive(:new)
        .with("%a{data: {'toggleable-selector' => '.change'}} Change")\
        .and_return(double(render: 'output'))

      helper.show_change_link_for_provider(:organic).should == 'output'
    end

    it 'returns nil if the provider is not organic' do
      helper.show_change_link_for_provider(:stuff).should be_nil
    end
  end
end
