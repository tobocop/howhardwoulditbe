class CreateCompanies < ActiveRecord::Migration
  def up
    create_table :companies do |t|
      t.integer :advertiser_id
      t.string :name
      t.boolean :prospect
      t.integer :sales_rep_id
      t.string :vanity_url

      t.timestamps
    end
  end

  def down
    drop_table :companies
  end
end
