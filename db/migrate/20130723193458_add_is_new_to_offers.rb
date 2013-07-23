class AddIsNewToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :is_new, :boolean
  end
end
