class AddShowEndDateToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :show_end_date, :boolean
  end
end
