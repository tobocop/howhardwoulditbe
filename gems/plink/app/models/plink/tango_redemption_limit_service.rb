module Plink

  class TangoRedemptionLimitService

    MAXIMUM_REDEMPTION_LIMIT = 101

    def initialize(user_id)
      @user_id = user_id
    end

    def user_over_redemption_limit?

      case
        when redemption_limit_record.nil?
          false
        when redemption_limit_record.hold_redemptions == 1
          true
        when redemption_limit_record.redeemed_in_past_24_hours.nil?
          false
        when redemption_limit_record.redeemed_in_past_24_hours >= MAXIMUM_REDEMPTION_LIMIT
          set_redemption_hold
          true
        else
          false
      end

    end

    def user_under_redemption_limit?
      !user_over_redemption_limit?
    end

    private

    def redemption_limit_record
      @redemption_limit_record ||= tango_redemption_limit_record.where('userID = ?', @user_id).first
    end

    def set_redemption_hold
      user = Plink::UserRecord.find(@user_id)
      user.hold_redemptions = 1
      user.save!
    end

    def tango_redemption_limit_record
      Plink::TangoRedemptionLimitRecord
    end

  end

end