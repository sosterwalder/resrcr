class TimetableController < ApplicationController
  include SubjobsHelper
  include TimetableHelper
  
  def generate
    @array_resources = {}
    logger.debug @array_resources.length
    
    @resources = Resource.find(:all, :order => "resources.id ASC")
    @resources.each do |resource|
      
      logger.debug "Resource-ID: #{resource.id}"
      logger.debug @array_resources.length
      logger.debug "-->"
      @array_resources[resource.id] = {"resource" => resource, "subjobs" => []}
      logger.debug @array_resources.length
    end
    
    @subjobs = get_all_subjobs_by_constraint_type_start
    
    resource_reservations(@subjobs, @array_resources)
  end
  
  def generate_v2
    # Delete current timetable (if there's any)
    Timetable.destroy_all
    
    @subjobs = get_all_subjobs_by_constraint_type_start
    
    # Generate/fill timetable
    @result = generate_timetable_based_on_subjobs(@subjobs)
    
    # If there are no cycles
    if @result
      # Predecessors of end subjobs
      end_subjobs_predecessors = []
      
      # Get all end subjobs
      @end_subjobs = get_end_subjobs
      
      # Get predecessors of first end subjob
      # get_next_predecessors(@end_subjobs.first, end_subjobs_predecessors, false)
      
      # Generate timetable with latest possible times
      # generate_latest_possible_timetable(end_subjobs_predecessors)
      
      @end_subjobs.each do |end_subjob|
        generate_latest_times(end_subjob)
      end
    end
  end
  
  def show_table
    @timetable = Timetable.find(:all, :order => "resource_id asc")
  end
  
  def show_plan
    @timetable = Timetable.find(:all, :order => "resource_id asc")
    @timetable_resources = @timetable.group_by { |t| t.resource_id }
  end
end
