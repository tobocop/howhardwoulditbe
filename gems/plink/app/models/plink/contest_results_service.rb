module Plink
  class ContestResultsService

    attr_reader :contest_winner_records

    def initialize(contest_id)
      @contest_id = contest_id
      @grand_prize_winners = []
      @second_prize_winners = []
      @prepared_results = []
    end

    def grand_prize_winners
      @grand_prize_winners
    end

    def second_prize_winners
      @second_prize_winners
    end

    def grand_prize_winners_list
      @grand_prize_winners.map { |w| w.display_name }.join(', ')
    end

    def second_prize_winners_list
      @second_prize_winners.map { |w| w.display_name }.join(', ')
    end

    def winners
      return [] unless @prepared_results.size > 0
      amount_group = []
      winners = []

      previous_amount = @prepared_results.first.dollar_amount

      @prepared_results.each do |r|
        next if r.rejected? || ! r.winner?

        if previous_amount != r.dollar_amount
          winners << [ previous_amount, amount_group.dup ]
          amount_group.clear
          previous_amount = r.dollar_amount
        end

        amount_group << r.display_name
      end

      winners << [ previous_amount, amount_group.dup ] if amount_group.size > 0

      winners
    end

    def all_results_for_contest
      Plink::ContestWinnerRecord.for_contest(@contest_id).order('dollar_amount DESC, winner, rejected')
    end

    def prepare_contest_results
      results = all_results_for_contest
      starting_amount = results.first.attributes['dollar_amount']
      grand_prize_amount = results.first.attributes['dollar_amount']
      second_prize_amount = 0

      results.each do |winner_record|
        is_grand_prize = winner_record.attributes['dollar_amount'] == grand_prize_amount ? true : false
        is_second_prize = false

        if winner_record.attributes['dollar_amount'] != starting_amount && second_prize_amount == 0
          second_prize_amount = winner_record.attributes['dollar_amount']
        end

        if second_prize_amount != 0 && winner_record.attributes['dollar_amount'] == second_prize_amount
          is_second_prize = true
        end

        presenter_record = Plink::ContestWinnerPresenter.new(
          contest_winner_record: winner_record,
          grand_prize_winner: is_grand_prize,
          second_prize_winner: is_second_prize,
          attributes: winner_record.attributes
        )

        if is_grand_prize
          @grand_prize_winners << presenter_record
        elsif is_second_prize
          @second_prize_winners << presenter_record
        end

        @prepared_results << presenter_record
      end
    end

  end
end