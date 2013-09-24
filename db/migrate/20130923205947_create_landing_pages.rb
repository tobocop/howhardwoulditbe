class CreateLandingPages < ActiveRecord::Migration
  def up
    create_table :landing_pages do |t|
      t.string :name
      t.string :partial_path

      t.timestamps
    end
  end

  def down
    drop_table :landing_pages
  end
end
