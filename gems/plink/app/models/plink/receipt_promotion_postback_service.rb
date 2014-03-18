module Plink
  class ReceiptPromotionPostbackService
    attr_reader :event_record, :receipt_postback_record, :receipt_promotion_postback_url_record

    def initialize(receipt_postback_record)
      @event_record = Plink::EventRecord.find(receipt_postback_record.event_id)
      @receipt_postback_record = receipt_postback_record
      @receipt_promotion_postback_url_record = Plink::ReceiptPromotionPostbackUrlRecord.find(receipt_postback_record.receipt_promotion_postback_url_id)
    end

    def process!
      perform_get
      receipt_postback_record.update_attributes({
        processed: true,
        posted_url: replace_postback_url_variables
      })
    end

  private

    def perform_get
      uri = URI(replace_postback_url_variables)
      Net::HTTP.get(uri)
    end

    def replace_postback_url_variables
      @receipt_promotion_postback_url_record.postback_url.gsub(/\$\w+\$/) {|var| @event_record.send(var.gsub(/\$/, ''))}
    end
  end
end
