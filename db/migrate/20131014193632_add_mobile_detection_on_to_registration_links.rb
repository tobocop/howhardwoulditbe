class AddMobileDetectionOnToRegistrationLinks < ActiveRecord::Migration
  def change
    add_column :registration_links, :mobile_detection_on, :boolean
  end
end
