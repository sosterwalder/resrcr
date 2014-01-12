module Interfaces::AbstractJob
  include Interfaces::AbstractInterface

  # Class variables
  @@subjobs = nil
  @@created_at = nil
  @@earliest_start_time = nil
  @@latest_end_time = nil

  attr_accessor :subjobs, :created_at, :earliest_start_time, :latest_end_time
  
  # Methods
end
