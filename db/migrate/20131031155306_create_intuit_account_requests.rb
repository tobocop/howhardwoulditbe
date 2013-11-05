class CreateIntuitAccountRequests < ActiveRecord::Migration
  def up
    create_table :intuit_account_requests do |t|
      t.integer :user_id
      t.boolean :processed
      t.text :response

      t.timestamps
    end
  end

  def down
    drop_table :intuit_account_requests
  end
end
