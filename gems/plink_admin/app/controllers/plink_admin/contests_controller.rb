module PlinkAdmin
  class ContestsController < ApplicationController

    def index
      @contests = Plink::ContestRecord.all
    end

    def new
      @contest = Plink::ContestRecord.new
      setup_contest
    end

    def create
      @contest = Plink::ContestRecord.create(params[:contest])

      if @contest.persisted?
        redirect_to plink_admin.contests_path
      else
        setup_contest
        render 'new'
      end
    end

    def edit
      @contest = Plink::ContestRecord.find(params[:id])
      setup_contest
    end

    def update
      @contest = Plink::ContestRecord.find(params[:id])

      if @contest.update_attributes(params[:contest])
        redirect_to plink_admin.contests_path
      else
        setup_contest
        render 'edit'
      end
    end

    def search
      @search_term = params[:email].present? ? params[:email] : params[:user_id]

      @contest = Plink::ContestRecord.current || Plink::ContestRecord.last_completed || Plink::ContestRecord.last_finalized

      @users = params[:email].present? ?
        plink_user_service.search_by_email(@search_term) :
        Array(plink_user_service.find_by_id(@search_term))
    end

    def user_entry_stats
      setup_entries_data(params[:user_id], params[:contest_id])
    end

    def entries
      setup_entries_data(params[:user_id], params[:contest_id])

      computed_entries = params[:number_of_entries].to_i * @multiplier
      entry = Plink::EntryRecord.create(
        user_id: @user_id,
        contest_id: @contest.id,
        provider: 'admin',
        referral_entries: 0,
        multiplier: @multiplier,
        computed_entries: computed_entries
      )

      flash[:notice] = entry.persisted? ?
        "Successfully awarded #{computed_entries} entries." :
        "Could not add entries: #{entry.errors.full_messages.join(' ')}"

      render :user_entry_stats
    end

    def statistics
      contest_id = params[:change_contest_id] || params[:contest_id] || current_contest_id

      @contest = Plink::ContestRecord.select(contest_select).find(contest_id)
      @contests ||= Plink::ContestRecord.select(contest_select).all
      @statistics = PlinkAdmin::ContestQueryService.get_statistics(contest_id)
    end

    def winners
      setup_winners_data(params[:contest_id])
    end

    def remove_winner
      PlinkAdmin::ContestWinningService.remove_winning_record_and_update_prizes(params[:contest_id], params[:contest_winner_id], current_admin.id)

      setup_winners_data(params[:contest_id])

      render :winners
    end

    def accept_winners
      if params[:user_ids].length < 150
        @errors = {message: 'Must have 150 winners.'}
        render :winners and return
      end

      PlinkAdmin::ContestWinningService.finalize_results!(params[:contest_id], params[:user_ids], current_admin.id)
      PlinkAdmin::ContestWinningService.notify_winners!(params[:contest_id])

      flash[:notice] = 'Winners accepted.'
      redirect_to plink_admin.contests_path
    end

  private

    def setup_contest
      @contest.build_contest_emails if @contest.contest_emails.blank?
      @contest.contest_prize_levels.build if @contest.contest_prize_levels.blank?
    end

    def plink_user_service
      @plink_user_service ||= Plink::UserService.new
    end

    def setup_entries_data(user_id, contest_id)
      @contest = Plink::ContestRecord.find(contest_id)
      @user_id = user_id
      @multiplier = Plink::ContestEntryService.user_multiplier(@user_id)
      @entries = Plink::EntryRecord.where(user_id: @user_id, contest_id: @contest.id)
    end

    def current_contest_id
      @contest_id ||= Plink::ContestRecord.current.id
    end

    def contest_select
      [:description, :end_time, :id, :start_time]
    end

    def setup_winners_data(contest_id)
      @prize_levels = Plink::ContestPrizeLevelRecord.where(contest_id: contest_id)
      @winners = PlinkAdmin::ContestWinningQueryService.winning_users_grouped_by_prize_level(contest_id)
      @alternates = PlinkAdmin::ContestWinningQueryService.alternates(contest_id)
      @rejected = PlinkAdmin::ContestWinningQueryService.rejected(contest_id)
    end
  end
end
