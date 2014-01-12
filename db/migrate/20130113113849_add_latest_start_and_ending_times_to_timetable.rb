class AddLatestStartAndEndingTimesToTimetable < ActiveRecord::Migration
  def change
    add_column :timetables, :latest_start_time, :decimal
    add_column :timetables, :latest_end_time, :decimal
  end
end
