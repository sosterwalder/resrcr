class CreateConstraints < ActiveRecord::Migration
  def change
    create_table :constraints do |t|
      t.references :subjob_one
      t.references :subjob_two
      t.references :constraint_type
      t.timestamps
    end
  end
end
