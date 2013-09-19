class RemoveYodleeColumnsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :yodleeUsername
    remove_column :users, :yodleePassword
    remove_column :users, :yodleePasswordVersion
  end

  def down
    add_column :users, :yodleeUsername, :string
    add_column :users, :yodleePassword, :string
    add_column :users, :yodleePasswordVersion, :integer
  end
end
