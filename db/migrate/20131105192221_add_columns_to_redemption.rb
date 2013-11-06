class AddColumnsToRedemption < ActiveRecord::Migration
  def change
    add_column :redemptions, :tango_tracking_id, :int
    add_column :redemptions, :tango_confirmed, :boolean
  end
end
