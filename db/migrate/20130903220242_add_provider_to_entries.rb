class AddProviderToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :provider, :string, limit: 25
  end
end
