class CreateAwardLinkClicks < ActiveRecord::Migration
  def up
    create_table :award_link_clicks do |t|
      t.integer :award_link_id
      t.integer :user_id

      t.timestamps
    end
  end

  def down
    drop_table :award_link_clicks
  end
end
