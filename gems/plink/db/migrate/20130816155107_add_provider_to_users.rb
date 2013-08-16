class AddProviderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :provider, :string, limit: 15
  end
end
