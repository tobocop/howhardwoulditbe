module PlinkAdmin
  class WalletItemsController < ApplicationController
    layout 'plink_admin/application'

    before_filter :authenticate_admin!

    def unlock_wallet_item_with_reason
      wallet_item_record = Plink::WalletItemRecord.find(params[:id])

      if ::Plink::WalletItemUnlockingService.unlock_wallet_item_record(wallet_item_record, params[:unlock_reason])
        render json: {message: "Successfully set for reason of #{params[:unlock_reason]}"}
      else
        errors = wallet_item_record.errors.full_messages.join(', ').strip
        msg = "Unable to unlock wallet item record. This wallet item has the following "\
          "validation errors: #{errors.present? ? msg : '(none)'}"

        render json: {message: msg}, status: :unprocessable_entity
      end
    end

    def give_open_wallet_item_with_reason
      if Plink::WalletItemService.create_open_wallet_item(params[:id], params[:unlock_reason])
        render json: {message: "Successfully opened item for reason of #{params[:unlock_reason]}"}
      else
        msg = 'Unable to open wallet item record'
        render json: {message: msg}, status: :unprocessable_entity
      end
    end
  end
end
