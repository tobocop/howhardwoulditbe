class CreateRegistrationLinkMapping < ActiveRecord::Migration
  def up
    create_table :registration_link_mappings do |t|
      t.integer :affiliate_id
      t.integer :campaign_id
      t.integer :registration_link_id
    end
  end

  def down
    drop_table :registration_link_mappings
  end
end
