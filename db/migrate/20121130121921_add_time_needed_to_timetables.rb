class AddTimeNeededToTimetables < ActiveRecord::Migration
  def change
    add_column :timetables, :time_needed, :decimal
    change_column :timetables, :start_time, :decimal
    change_column :timetables, :end_time, :decimal
  end
end
