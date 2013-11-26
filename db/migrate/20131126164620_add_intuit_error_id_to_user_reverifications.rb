class AddIntuitErrorIdToUserReverifications < ActiveRecord::Migration
  def change
    add_column :usersReverifications, :intuit_error_id, :integer
  end
end
