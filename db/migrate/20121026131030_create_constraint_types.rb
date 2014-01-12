class CreateConstraintTypes < ActiveRecord::Migration
  def change
    create_table :constraint_types do |t|
      t.string :name
      t.timestamps
    end
  end
end
