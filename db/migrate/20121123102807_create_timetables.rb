class CreateTimetables < ActiveRecord::Migration
  def change
    create_table :timetables do |t|
      t.references :resource
      t.references :subjob
      t.integer :start_time
      t.integer :end_time 
      t.timestamps
    end
  end
end
