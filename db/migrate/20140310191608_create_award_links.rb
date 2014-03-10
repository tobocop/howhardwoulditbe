class CreateAwardLinks < ActiveRecord::Migration
  def up
    create_table :award_links do |t|
      t.integer :award_type_id
      t.decimal :dollar_award_amount, precision: 8, scale: 2
      t.date :end_date
      t.boolean :is_active
      t.string :redirect_url
      t.date :start_date
      t.string :url_value

      t.timestamps
    end
  end

  def down
    drop_table :award_links
  end
end
