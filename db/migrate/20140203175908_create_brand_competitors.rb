class CreateBrandCompetitors < ActiveRecord::Migration
  def up
    create_table :brand_competitors do |t|
      t.integer :brand_id
      t.integer :competitor_id
      t.boolean :default

      t.timestamps
    end
  end

  def down
    drop_table :brand_competitors
  end
end
