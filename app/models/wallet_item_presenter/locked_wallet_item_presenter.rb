module WalletItemPresenter
  class LockedWalletItemPresenter < BaseWalletItemPresenter
    attr_reader :wallet_item, :view_context

    def initialize(wallet_item, options={})
      @wallet_item = wallet_item
      @view_context = options.fetch(:view_context)
    end

    def partial
      template_name
    end

    def template_name
      'locked_wallet_item'
    end

    def icon_url
      view_context.image_path('icon_lockedslot.png')
    end

    def icon_description
      'Locked Slot'
    end

    def title
      'This slot is locked.'
    end

    def description
      'Complete an offer to unlock this slot.'
    end
  end
end