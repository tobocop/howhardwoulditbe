module Plink
  class ContestWinnerPresenter

    def initialize(options={})
      @contest_winner_record = options.fetch(:contest_winner_record)
      @grand_prize_winner = options[:grand_prize_winner]
      @second_prize_winner = options[:second_prize_winner]
      @first_name = @contest_winner_record.attributes['first_name'] || ''
      @last_name = @contest_winner_record.attributes['last_name'] || ''
      @dollar_amount = @contest_winner_record.attributes['dollar_amount']
      raise ArgumentError if @grand_prize_winner && @second_prize_winner
    end

    def contest_winner_record
      @contest_winner_record
    end

    def dollar_amount
      @dollar_amount
    end

    def first_name
      @first_name
    end

    def last_name
      @last_name
    end

    def rejected?
      @contest_winner_record.rejected
    end

    def winner?
      @contest_winner_record.winner
    end

    def won_grand_prize?
      @grand_prize_winner
    end

    def won_second_prize?
      @second_prize_winner
    end

    def display_name
      if @last_name.present? && @first_name.present?
        "#{@first_name} #{@last_name[0]}."
      elsif @first_name.present?
        @first_name.sub(/(.+\b.).+\z/, '\1.')
      else
        'Name Not Provided'
      end
    end
  end
end