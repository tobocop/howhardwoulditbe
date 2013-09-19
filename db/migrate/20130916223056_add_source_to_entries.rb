class AddSourceToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :source, :string, limit: 50
  end
end
