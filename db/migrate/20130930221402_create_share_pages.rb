class CreateSharePages < ActiveRecord::Migration
  def up
    create_table :share_pages do |t|
      t.string :name
      t.string :partial_path

      t.timestamps
    end
  end

  def down
    drop_table :share_pages
  end
end
