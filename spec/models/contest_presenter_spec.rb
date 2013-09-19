require 'spec_helper'

describe ContestPresenter do
  let(:start_time) { 3.days.ago }
  let(:end_time) { 6.days.from_now }
  let(:contest) {
    new_contest(
      description: 'This is a great description',
      image: '/assets/profile.jpg',
      prize: 'This is the prize - a brand new, shiny boat!',
      start_time: start_time,
      end_time: end_time,
      terms_and_conditions: 'This is a set of terms and conditions that apply to this contest specifically'
    )
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
      presenter.id.should == contest.id
      presenter.description.should == 'This is a great description'
      presenter.image.should == '/assets/profile.jpg'
      presenter.prize.should == 'This is the prize - a brand new, shiny boat!'
      presenter.start_date.should == start_time.strftime('%_m/%-d/%y')
      presenter.end_date.should == end_time.strftime('%_m/%-d/%y')
      presenter.terms_and_conditions.should == 'This is a set of terms and conditions that apply to this contest specifically'
      presenter.started?.should == true
    end
  end
end
