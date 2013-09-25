class CreateRegistrationLinks < ActiveRecord::Migration
  def up
    create_table :registration_links do |t|
      t.integer :affiliate_id
      t.integer :campaign_id
      t.date :start_date
      t.date :end_date
      t.boolean :is_active

      t.timestamps
    end
  end

  def down
    drop_table :registration_links
  end
end
