class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :name, :limit => 50
      t.integer :capacity, :null => false, :default => 1
      t.integer :steps_per_time_unit, :null => false, :default => 1
      t.timestamps
    end
  end
end
