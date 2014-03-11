class AddNameToAwardLinks < ActiveRecord::Migration
  def change
    add_column :award_links, :name, :string
  end
end
