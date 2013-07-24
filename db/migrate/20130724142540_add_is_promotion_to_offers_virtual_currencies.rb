class AddIsPromotionToOffersVirtualCurrencies < ActiveRecord::Migration
  def change
    add_column :offersVirtualCurrencies, :is_promotion, :boolean
  end
end
