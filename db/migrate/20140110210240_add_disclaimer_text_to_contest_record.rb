class AddDisclaimerTextToContestRecord < ActiveRecord::Migration
  def change
    add_column :contests, :disclaimer_text, :text
  end
end
