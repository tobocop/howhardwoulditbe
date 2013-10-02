require 'spec_helper'

describe 'Plink::ContestWinnerPresenter' do
  let(:example_user) { new_user }
  let(:example_winner_record) { new_contest_winner }
  let(:presenter) { Plink::ContestWinnerPresenter }

  describe '.new' do
    it 'raises an ArgumentError exception if not initialized with a Plink::ContestWinnerRecord' do
      expect {
        presenter.new(grand_prize_winner: true, second_prize_winner: false)
      }.to raise_error KeyError
    end

    it 'raises an exception if given true values for both grand prize winner and second prize winner' do
      expect {
        presenter.new(contest_winner_record: example_winner_record, grand_prize_winner: true, second_prize_winner: true)
      }.to raise_error ArgumentError
    end
  end

  describe '.contest_winner_record' do
    it 'returns a Plink::ContestWinnerRecord' do
      presenter.new(contest_winner_record: example_winner_record).contest_winner_record.should == example_winner_record
    end
  end

  describe 'for grand or second prize winners' do
    let(:grand_prize_winner) { presenter.new(contest_winner_record: example_winner_record, grand_prize_winner: true, second_prize_winner: false) }
    let(:second_prize_winner) { presenter.new(contest_winner_record: example_winner_record, grand_prize_winner: false, second_prize_winner: true) }
    let(:another_prize_winner) { presenter.new(contest_winner_record: example_winner_record, grand_prize_winner: false, second_prize_winner: false) }

    describe '.won_grand_prize?' do
      it 'returns true if the contest winner won the grand prize' do
        grand_prize_winner.won_grand_prize?.should be_true
      end

      it 'returns false if the record is not a grand prize winner' do
        second_prize_winner.won_grand_prize?.should be_false
        another_prize_winner.won_grand_prize?.should be_false
      end
    end

    describe '.won_second_prize?' do
      it 'returns true if the record represents a second prize winner' do
        second_prize_winner.won_second_prize?.should be_true
      end

      it 'returns false if the record does not represent a second prize winner' do
        grand_prize_winner.won_second_prize?.should be_false
        another_prize_winner.won_second_prize?.should be_false
      end
    end
  end

  describe '.display_name' do

    let(:first_and_last_name_winner) { new_contest_winner }
    let(:one_word_first_name_only_winner) { new_contest_winner }
    let(:two_word_first_name_only_winner) { new_contest_winner }
    let(:three_word_first_name_only_winner) { new_contest_winner }
    let(:neither_first_or_last_name_winner) { new_contest_winner }

    it 'returns the first name and last initial if both a first name and a last name are defined' do
      Plink::ContestWinnerRecord.any_instance.should_receive(:attributes).exactly(3).times.and_return({ 'first_name' => 'Otto', 'last_name' => 'Octavius' })
      contest_winner_presenter = presenter.new(contest_winner_record: first_and_last_name_winner)
      contest_winner_presenter.display_name.should == 'Otto O.'
    end

    it 'returns the first name and no initial if a one word first name is present' do
      Plink::ContestWinnerRecord.any_instance.should_receive(:attributes).exactly(3).times.and_return({ 'first_name' => 'Electro', 'last_name' => nil })
      contest_winner_presenter = presenter.new(contest_winner_record: one_word_first_name_only_winner)
      contest_winner_presenter.display_name.should == 'Electro'
    end

    it 'returns the first word of the first name and the first initial of the second word if only a two-word first name is defined' do
      Plink::ContestWinnerRecord.any_instance.should_receive(:attributes).exactly(3).times.and_return({ 'first_name' => 'Gwen Stacy' })
      contest_winner_presenter = presenter.new(contest_winner_record: two_word_first_name_only_winner)
      contest_winner_presenter.display_name.should == 'Gwen S.'
    end

    it 'returns the first word of the first name and the first initial of the second word if only a three-word first name is defined' do
      Plink::ContestWinnerRecord.any_instance.should_receive(:attributes).exactly(3).times.and_return({ 'first_name' => 'Mary Jane Watson' })
      contest_winner_presenter = presenter.new(contest_winner_record: three_word_first_name_only_winner)
      contest_winner_presenter.display_name.should == 'Mary Jane W.'
    end

    it 'returns the default string if somehow both the first name and the last name are undefined' do
      Plink::ContestWinnerRecord.any_instance.should_receive(:attributes).exactly(3).times.and_return( {} )
      contest_winner_presenter = presenter.new(contest_winner_record: neither_first_or_last_name_winner)
      contest_winner_presenter.display_name.should == 'Name Not Provided'
    end

  end
end