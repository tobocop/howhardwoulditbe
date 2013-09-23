class ChangeStartDateEndDateOnCampaigns < ActiveRecord::Migration
  def up
    rename_column :campaigns, :startDate, :start_date
    rename_column :campaigns, :endDate, :end_date

    change_column :campaigns, :start_date, :date
    change_column :campaigns, :end_date, :date
  end

  def down
    rename_column :campaigns, :start_date, :startDate
    rename_column :campaigns, :end_date, :endDate

    change_column :campaigns, :startDate, :datetime
    change_column :campaigns, :endDate, :datetime
  end
end
