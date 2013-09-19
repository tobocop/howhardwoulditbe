module PlinkAdmin
  class ContestsController < ApplicationController

    def index
      @contests = Plink::ContestRecord.all
    end

    def new
      @contest = Plink::ContestRecord.new
    end

    def create
      @contest = Plink::ContestRecord.create(params[:contest])

      if @contest.persisted?
        redirect_to contests_path
      else
        render 'new'
      end
    end

    def edit
      @contest = Plink::ContestRecord.find(params[:id])
    end

    def update
      @contest = Plink::ContestRecord.find(params[:id])

      if @contest.update_attributes(params[:contest])
        redirect_to contests_path
      else
        render 'edit'
      end
    end

    def search
      @search_term = params[:email].present? ? params[:email] : params[:user_id]

      @contest = Plink::ContestRecord.first

      @users = params[:email].present? ?
        plink_user_service.search_by_email(@search_term) :
        Array(plink_user_service.find_by_id(@search_term))
    end

    def stats
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

      render :stats
    end

  private

    def plink_user_service
      @plink_user_service ||= Plink::UserService.new
    end

    def setup_entries_data(user_id, contest_id)
      @contest = Plink::ContestRecord.find(contest_id)
      @user_id = user_id
      @multiplier = Plink::ContestEntryService.user_multiplier(@user_id)
      @entries = Plink::EntryRecord.where(user_id: @user_id, contest_id: @contest.id)
    end

  end
end
