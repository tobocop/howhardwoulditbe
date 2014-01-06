class AddSocialMessagingToContestAdmin < ActiveRecord::Migration
  def change
    add_column :contests, :entry_post_title, :string
    add_column :contests, :entry_post_body, :string
    add_column :contests, :winning_post_title, :string
    add_column :contests, :winning_post_body, :string
  end
end
