class ChangeDatesOnRegistrationLinksToDatetime < ActiveRecord::Migration
  def up
    change_column :registration_links, :start_date, :datetime
    change_column :registration_links, :end_date, :datetime
  end

  def down
    change_column :registration_links, :start_date, :date
    change_column :registration_links, :end_date, :date
  end
end
