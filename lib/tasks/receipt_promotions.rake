namespace :receipt_promotions do
  desc 'Runs conversion urls for processed receipts'
  task process_postback: :environment do
    begin
      stars; puts "[#{Time.zone.now}] Beginning receipt_promotions:process_postback"
      Plink::ReceiptSubmissionRecord.map_postback_data.each do |data|
        Plink::ReceiptPostbackRecord.create(
          receipt_promotion_postback_url_id: data[:receipt_promotion_postback_url_id],
          event_id: data[:event_id]
        )
      end

      Plink::ReceiptPostbackRecord.
        where(processed: false).
        where('created_at > ?', 1.day.ago).each do |receipt_postback|
        begin
          puts "[#{Time.zone.now}] Processing postback for receipt_postback_id #{receipt_postback.id}"

          Plink::ReceiptPromotionPostbackService.new(receipt_postback).process!
        rescue Exception => e
          puts "[#{Time.zone.now}] Processing postback failed for receipt_postback.id: #{receipt_postback.id} with #{$!}"
          ::Exceptional::Catcher.handle($!, "receipt_promotions:process_postback failed on postback")
        end
      end
      puts "[#{Time.zone.now}] Ending receipt_promotions:process_postback"; stars
    rescue Exception => e
      ::Exceptional::Catcher.handle($!, "receipt_promotions:process_postback Rake task failed")
    end
  end
end

def stars
  puts '*' * 150
end
