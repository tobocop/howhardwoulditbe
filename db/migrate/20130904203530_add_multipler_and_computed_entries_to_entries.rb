class AddMultiplerAndComputedEntriesToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :computed_entries, :integer
    add_column :entries, :multiplier, :integer
  end
end
