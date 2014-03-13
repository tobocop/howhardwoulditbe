class EntriesController < ApplicationController
  include ContestHelper

  before_filter :require_authentication

  def create
    new_entries = Plink::ContestEntryService.enter(params[:contest_id], current_user.id, parse_providers_param, {entry_source: session[:contest_source]})
    entry_count = entry_count(valid_entries(new_entries))

    if entry_count > 0
      presenter = EntriesPresenter.new(entries_for_today(current_user.id, params[:contest_id]))
      entries = Plink::ContestEntryService.total_entries_via_share(current_user.id, params[:contest_id], user_linked_card, presenter.unshared_provider_count)

      if !user_linked_card
        contest_record = Plink::ContestRecord.find(params[:contest_id])
        show_non_linked_image = contest_record.non_linked_image.present? ?  true : false
      else
        show_non_linked_image = false
      end

      render json: {
        available_providers: presenter.available_providers,
        button_text: entry_button_text(presenter.share_state),
        disable_submission: disable_submission,
        incremental_entries: entry_count,
        show_non_linked_image: show_non_linked_image,
        providers: presenter.providers,
        set_checkbox: set_daily_reminders_for_current_user,
        sub_text: view_context.entries_subtext(presenter.share_state, entries),
        total_entries: total_entries,
        user_linked_card: user_linked_card
      }
    else
      result = {errors: extract_errors(new_entries), disable_submission: disable_submission}

      render json: result, status: :unprocessable_entity
    end
  end

private

  def valid_entries(entries)
    entries.select { |entry| entry.persisted? }
  end

  def disable_submission
    Plink::ContestEntryService.exceeded_daily_submission_limit?(current_user)
  end

  def parse_providers_param
    params["providers"].present? ?
      Array(params["providers"].split(',')).map(&:downcase) : []
  end

  def entry_count(entries)
    entries.inject(0){ |sum, eligible_entries| sum + eligible_entries.computed_entries }
  end

  def total_entries
    Plink::ContestEntryService.total_entries(params[:contest_id], current_user.id)
  end

  def extract_errors(entries)
    entries.map{|entry| entry.errors.full_messages }.join(', ') ||
      'Could not enter contest'
  end

  def entries_for_today(user_id, contest_id)
    Plink::EntryRecord::entries_today_for_user_and_contest(user_id, contest_id)
  end

  def user_linked_card
    @_linked ||= Plink::IntuitAccountService.new.user_has_account?(current_user.id)
  end

  def set_daily_reminders_for_current_user
    current_user.daily_contest_reminder.nil? ?
          current_user.opt_in_to_daily_contest_reminders! : false
  end
end
