class AddNoticeAndPrizeDescriptionFieldsToContest < ActiveRecord::Migration
  def change
    add_column :contests, :entry_notification, :string
    add_column :contests, :prize_description, :string
  end
end
