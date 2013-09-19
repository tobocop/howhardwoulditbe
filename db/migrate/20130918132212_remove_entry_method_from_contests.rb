class RemoveEntryMethodFromContests < ActiveRecord::Migration
  def up
    remove_column :contests, :entry_method
  end

  def down
    add_column :contests, :entry_method, :string
  end
end
