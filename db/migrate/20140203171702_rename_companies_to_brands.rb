class RenameCompaniesToBrands < ActiveRecord::Migration
  def up
    rename_table :companies, :brands
    remove_column :brands, :advertiser_id
  end

  def down
    rename_table :brands, :companies
    add_column :companies, :advertiser_id, :integer
  end
end
