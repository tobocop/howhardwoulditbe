class EntriesController < ApplicationController
  include ContestHelper

  before_filter :require_authentication

  def create
    new_entries = Plink::ContestEntryService.enter(params[:contest_id], current_user.id, parse_providers_param, {entry_source: session[:contest_source]})
    entry_count = entry_count(valid_entries(new_entries))

    if entry_count > 0
      presenter = EntriesPresenter.new(entries_for_today(current_user.id, params[:contest_id]))
      entries = Plink::ContestEntryService.total_entries_via_share(current_user.id, params[:contest_id], user_linked_card, presenter.unshared_provider_count)

      render json: {
        incremental_entries: entry_count,
        total_entries: total_entries,
        disable_submission: disable_submission,
        providers: presenter.providers,
        button_text: entry_button_text(presenter.share_state),
        sub_text: view_context.entries_subtext(presenter.share_state, entries),
        set_checkbox: set_daily_reminders_for_current_user,
        available_providers: presenter.available_providers
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
    Plink::IntuitAccountService.new.user_has_account?(current_user.id)
  end

  def set_daily_reminders_for_current_user
    current_user.daily_contest_reminder.nil? ?
          current_user.opt_in_to_daily_contest_reminders! : false
  end
end
