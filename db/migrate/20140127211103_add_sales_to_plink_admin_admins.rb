class AddSalesToPlinkAdminAdmins < ActiveRecord::Migration
  def change
    add_column :plink_admin_admins, :sales, :boolean
  end
end
