class CreateSalesReps < ActiveRecord::Migration
  def up
    create_table :sales_reps do |t|
      t.string :name

      t.timestamps
    end
  end

  def down
    drop_table :sales_reps
  end
end
