class Timetable < ActiveRecord::Base
  belongs_to :subjob
  belongs_to :resource
  
  attr_accessible :latest_start_time, :latest_end_time
end
