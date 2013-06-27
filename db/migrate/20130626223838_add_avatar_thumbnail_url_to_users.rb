class AddAvatarThumbnailUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :avatar_thumbnail_url, :string
  end
end
