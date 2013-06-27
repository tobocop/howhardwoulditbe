require 'spec_helper'

describe UserPresenter do
  describe '#initialize' do
    it 'requires a user to be initialized' do
      expect { UserPresenter.new }.to raise_error(KeyError, 'key not found: :user')
    end
  end

  it 'returns the user id' do
    presenter = UserPresenter.new(user: stub(id: 234))
    presenter.id.should == 234
  end

  it 'returns the user primary_virtual_currency_id' do
    presenter = UserPresenter.new(user: stub(primary_virtual_currency_id: 456))
    presenter.primary_virtual_currency_id.should == 456
  end

  it 'returns the user current_balance' do
    presenter = UserPresenter.new(user: stub(current_balance: 123.45))
    presenter.current_balance.should == 123.45
  end

  it 'returns a first_name of the provided user' do
    presenter = UserPresenter.new(user: stub(first_name: 'Brian'))
    presenter.first_name.should == 'Brian'
  end

  describe '.avatar_thumbnail_url' do
    it 'returns a default avatar url if no profile image is in the user' do
      presenter = UserPresenter.new(user: stub(avatar_thumbnail_url: nil))
      presenter.avatar_thumbnail_url.should == 'silhouette.jpg'
    end

    it 'returns a default avatar url if profile image on the user is blank' do
      presenter = UserPresenter.new(user: stub(avatar_thumbnail_url: ''))
      presenter.avatar_thumbnail_url.should == 'silhouette.jpg'
    end

    it 'returns the users image if set' do
      presenter = UserPresenter.new(user: stub(avatar_thumbnail_url: 'http://s3.amazonaws.com/blah/my-great-face.png'))
      presenter.avatar_thumbnail_url.should == 'http://s3.amazonaws.com/blah/my-great-face.png'
    end
  end

  it 'is logged in' do
    UserPresenter.new(user: stub).should be_logged_in
  end
end