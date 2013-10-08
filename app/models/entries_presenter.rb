class EntriesPresenter

  attr_reader :entry_records

  def initialize(entry_records)
    @entry_records = entry_records
  end

  def share_state
    already_shared_on = entry_records.map(&:provider).uniq

    if already_shared_on.include?('twitter') && already_shared_on.include?('facebook')
      'enter_tomorrow'
    elsif already_shared_on.include?('twitter')
      "share_on_facebook"
    elsif already_shared_on.include?('facebook')
      "share_on_twitter"
    else
      'share_to_enter'
    end
  end

  def providers
    entry_records.map(&:provider)
  end

  def available_providers
    (social_providers - providers.uniq).join(',')
  end

  def unshared_provider_count
    (social_providers - providers.uniq).length
  end

private

  def social_providers
    Plink::EntryRecord::PROVIDERS.values - [Plink::EntryRecord::PROVIDERS[:admin]]
  end

end
