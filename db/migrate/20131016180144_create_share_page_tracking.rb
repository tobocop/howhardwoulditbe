class CreateSharePageTracking < ActiveRecord::Migration
  def up
    create_table :share_page_tracking do |t|
      t.integer :registration_link_id
      t.integer :share_page_id
      t.integer :user_id
      t.boolean :shared

      t.timestamps
    end
  end

  def down
    drop_table :share_page_tracking
  end
end
