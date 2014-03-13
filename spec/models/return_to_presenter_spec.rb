require 'spec_helper'

describe ReturnToPresenter do
  subject(:presenter) { ReturnToPresenter.new('some path') }
  let(:contest) { double(Plink::ContestRecord, description: 'greatest' ) }

  before do
    Plink::ContestRecord.stub(:current).and_return(contest)
  end

  describe 'initialize' do
    it 'is initialized with a path' do
      presenter.session_path.should == 'some path'
    end

    it 'gets the current contest' do
      Plink::ContestRecord.should_receive(:current).with().and_return(contest)

      presenter.contest.should == contest
    end
  end

  describe '#show?' do
    it 'returns true' do
      presenter.show?.should be_true
    end
  end

  describe '#description' do
    it 'returns text about contest the current contest' do
      presenter.description.should == "You'll now earn 5X entries every time you enter a contest."
    end
  end

  describe '#link_text' do
    it 'returns the text for the link' do
      presenter.link_text.should == 'Go to greatest'
    end
  end

  describe '#path' do
    it 'returns the given path plus ?card_linked=true' do
      presenter.path.should == 'some path?card_linked=true'
    end
  end
end
