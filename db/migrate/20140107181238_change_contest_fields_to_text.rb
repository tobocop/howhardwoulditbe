class ChangeContestFieldsToText < ActiveRecord::Migration
  def self.up
   change_column :contests, :entry_post_title, :text
   change_column :contests, :entry_post_body, :text
   change_column :contests, :winning_post_title, :text
   change_column :contests, :winning_post_body, :text
   change_column :contests, :interstitial_title, :text
   change_column :contests, :interstitial_bold_text, :text
   change_column :contests, :interstitial_body_text, :text
   change_column :contests, :entry_notification, :text
   change_column :contests, :prize_description, :text
  end

  def self.down
   change_column :contests, :entry_post_title, :string
   change_column :contests, :entry_post_body, :string
   change_column :contests, :winning_post_title, :string
   change_column :contests, :winning_post_body, :string
   change_column :contests, :interstitial_title, :string
   change_column :contests, :interstitial_bold_text, :string
   change_column :contests, :interstitial_body_text, :string
   change_column :contests, :entry_notification, :string
   change_column :contests, :prize_description, :string
  end
end
