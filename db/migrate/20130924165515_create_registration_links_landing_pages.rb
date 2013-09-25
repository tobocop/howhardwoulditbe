class CreateRegistrationLinksLandingPages < ActiveRecord::Migration
  def up
    create_table :registration_links_landing_pages do |t|
      t.integer :registration_link_id
      t.integer :landing_page_id

      t.timestamps
    end
  end

  def down
    drop_table :registration_links_landing_pages
  end
end
