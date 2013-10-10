class CreateRegistrationLinksSharePages < ActiveRecord::Migration
  def up
    create_table :registration_links_share_pages do |t|
      t.integer :registration_link_id
      t.integer :share_page_id

      t.timestamps
    end
  end

  def down
    drop_table :registration_links_share_pages
  end
end
