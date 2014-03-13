require 'spec_helper'

describe NullReturnToPresenter do
  subject(:presenter) { NullReturnToPresenter.new }

  describe 'initialize' do
    it 'is initialized' do
      presenter.should be_a NullReturnToPresenter
    end
  end

  describe '#show?' do
    it 'returns false' do
      presenter.show?.should be_false
    end
  end

  describe '#description' do
    it 'returns nil' do
      presenter.description.should be_nil
    end
  end

  describe '#link_text' do
    it 'returns nil' do
      presenter.link_text.should be_nil
    end
  end
end
