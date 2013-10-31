require 'spec_helper'

describe ContestPresenter do
  let(:start_time) { 3.days.ago }
  let(:end_time) { 6.days.from_now }
  let(:contest) {
    new_contest(
      description: 'This is a great description',
      end_time: end_time,
      image: '/assets/profile.jpg',
      non_linked_image: '/assets/another_image.jpg',
      prize: 'This is the prize - a brand new, shiny boat!',
      start_time: start_time,
      terms_and_conditions: 'This is a set of terms and conditions that apply to this contest specifically'
    )
  }
  let(:valid_params) {
    {
      contest: contest,
      user_has_linked_card: true,
      user_is_logged_in: true,
      card_link_url: 'http://www.herp.derp.com'
    }
  }


  describe 'initialize' do
    it 'initializes with a contest object' do
      presenter = ContestPresenter.new(contest: contest)
      presenter.description.should == 'This is a great description'
    end
  end

  describe 'attributes' do
    it 'should return the correct attributes based on how it was initialized' do
      presenter = ContestPresenter.new(contest: contest)
      presenter.description.should == 'This is a great description'
      presenter.end_date.should == end_time.strftime('%_m/%-d/%y')
      presenter.ended?.should == false
      presenter.id.should == contest.id
      presenter.image.should == '/assets/profile.jpg'
      presenter.non_linked_image.should ==  '/assets/another_image.jpg'
      presenter.prize.should == 'This is the prize - a brand new, shiny boat!'
      presenter.start_date.should == start_time.strftime('%_m/%-d/%y')
      presenter.started?.should == true
      presenter.terms_and_conditions.should == 'This is a set of terms and conditions that apply to this contest specifically'
    end
  end
end
