module Plink
  class TangoLimitService
    DAILY_LIMIT = 2500

    def self.past_daily_limit?
      tracking_records = Plink::TangoTrackingRecord.from_past_day
      calculate_total(tracking_records) >= DAILY_LIMIT
    end

  private

    def self.calculate_total(tracking_records)
      tracking_records.reduce(0) do |sum, tracking_record|
        sum + tracking_record.card_value
      end
    end
  end
end
