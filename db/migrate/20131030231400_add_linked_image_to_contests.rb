class AddLinkedImageToContests < ActiveRecord::Migration
  def change
    add_column :contests, :non_linked_image, :string
  end
end
