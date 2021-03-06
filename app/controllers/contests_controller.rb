class ContestsController < ApplicationController
  include TrackingExtensions
  include AutoLoginExtensions

  def index
    contest_record = Plink::ContestRecord.current || Plink::ContestRecord.last_completed || Plink::ContestRecord.last_finalized
    @contest = create_contest_presenter(contest_record, current_user.id)

    instantiate_contest_data(@contest)

    flash.now[:notice] = t('application.contests.card_linked') if params[:card_linked]
  end

  def show
    @contest = create_contest_presenter(Plink::ContestRecord.find(params[:id]), current_user.id)

    instantiate_contest_data(@contest)

    flash.now[:notice] = t('application.contests.card_linked') if params[:card_linked]
  end

  def toggle_opt_in_to_daily_reminder
    opt_in = params[:daily_contest_reminder] == 'true' ? true : false
    successful = current_user.opt_in_to_daily_contest_reminders!(opt_in)

    status = successful ? :ok : :unprocessable_entity

    render json: {}, status: status
  end

  def results
    redirect_to contest_path(params[:contest_id])
  end

  def results_from_email
    auto_login_user(params[:user_token], contest_results_path)
  end

private

  def instantiate_contest_data(contest)
    @current_tab = 'contests'

    @contest_results_service = create_contest_results_service(contest.id)
    @contest_results_service.prepare_contest_results if contest.finalized?

    @user = current_user
    @user_has_linked_card = Plink::IntuitAccountService.new.user_has_account?(current_user.id)

    current_entries = EntriesPresenter.new(user_entries_today(contest.id))

    @entries = {
      total: Plink::ContestEntryService.total_entries(contest.id, current_user.id),
      share_state: current_entries.share_state,
      shared: Plink::ContestEntryService.total_entries_via_share(current_user.id, contest.id, @user_has_linked_card, current_entries.unshared_provider_count)
    }

    set_session_tracking_params(new_tracking_object(contest_tracking_params(contest.id)))
  end

  def contest_tracking_params(contest_id)
    get_session_tracking_params.merge(
      show_contest_banner: true,
      sub_id_two: "contest_id_#{contest_id}"
    )
  end

  def create_contest_presenter(contest_record, user_id)
    ContestPresenter.new(contest: contest_record, user_id: user_id)
  end

  def user_entries_today(contest_id)
    Plink::EntryRecord.entries_today_for_user_and_contest(current_user.id, contest_id)
  end

  def create_contest_results_service(contest_id)
    Plink::ContestResultsService.new(contest_id)
  end
end
