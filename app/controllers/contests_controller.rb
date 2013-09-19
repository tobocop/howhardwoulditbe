class ContestsController < ApplicationController
  include CardLinkExtensions
  include Tracking

  def index
    @contest = create_contest_presenter(Plink::ContestRecord.current)
    instantiate_contest_data(@contest.id)

    if params[:card_linked]
      flash.now[:notice] = t('application.contests.card_linked')
    end
  end

  def show
    @contest = create_contest_presenter(Plink::ContestRecord.find(params[:id]))
    instantiate_contest_data(@contest.id)

    if params[:card_linked]
      flash.now[:notice] = t('application.contests.card_linked')
    end
  end

  def toggle_opt_in_to_daily_reminder
    opt_in = params[:daily_contest_reminder] == 'true' ? true : false
    successful = current_user.opt_in_to_daily_contest_reminders!(opt_in)

    status = successful ? :ok : :unprocessable_entity

    render json: {}, status: status
  end

  private

  def instantiate_contest_data(contest_id)
    @current_tab = 'contests'

    @user = current_user
    @card_link_url = plink_card_link_url_generator.create_url(card_link_url_params(contest_id))
    @user_has_linked_card = Plink::IntuitAccountService.new.user_has_account?(current_user.id)

    current_entries = EntriesPresenter.new(user_entries_today(contest_id))

    @entries = {
      total: Plink::ContestEntryService.total_entries(contest_id, current_user.id),
      share_state: current_entries.share_state,
      shared: Plink::ContestEntryService.total_entries_via_share(current_user.id, contest_id, @user_has_linked_card, current_entries.unshared_provider_count)
    }

    session[:tracking_params] = contest_tracking_params(contest_id).to_hash
  end

  def card_link_url_params(contest_id)
    card_link_referral_params.merge(sub_id_two: "contest_id_#{contest_id}")
  end

  def create_contest_presenter(contest_record)
    ContestPresenter.new(contest: contest_record)
  end

  def user_entries_today(contest_id)
    Plink::EntryRecord.entries_today_for_user_and_contest(current_user.id, contest_id)
  end
end
