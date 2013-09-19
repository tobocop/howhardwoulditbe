class ChangeContestsTermsAndConditionsToTextField < ActiveRecord::Migration
  def up
    change_column :contests, :terms_and_conditions, :text
  end

  def down
    change_column :contests, :terms_and_conditions, :string
  end
end
