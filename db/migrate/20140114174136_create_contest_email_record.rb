class CreateContestEmailRecord < ActiveRecord::Migration
  def up
    create_table :contest_emails do |t|
      t.integer :contest_id
      t.string :day_one_subject
      t.string :day_one_preview
      t.text :day_one_body
      t.string :day_one_link_text
      t.string :day_one_image, limit: 100
    end
  end

  def down
    drop_table :contest_emails
  end
end
