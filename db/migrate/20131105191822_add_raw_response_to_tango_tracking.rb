class AddRawResponseToTangoTracking < ActiveRecord::Migration
  def change
    add_column :tangotracking, :raw_response, :varchar_max
  end
end
