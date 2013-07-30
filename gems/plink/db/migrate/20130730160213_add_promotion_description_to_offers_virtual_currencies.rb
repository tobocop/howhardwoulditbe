class AddPromotionDescriptionToOffersVirtualCurrencies < ActiveRecord::Migration
  def change
    add_column :offersVirtualCurrencies, :promotion_description, :text
  end
end
