class AddShowToCardLinkedUsersToHeroPromotions < ActiveRecord::Migration
  def change
    add_column :hero_promotions, :show_linked_users, :boolean
    add_column :hero_promotions, :show_non_linked_users, :boolean
  end
end
