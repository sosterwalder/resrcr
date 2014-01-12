module TimetableHelper
  include ConstraintsHelper
  #Helper mit rekursivem Aufruf zum "sortieren" und "zuteilen" der Subjobs auf die Ressourcen.
  def resource_reservations(subjobs, resources)
    if subjobs.length <= 0
      return
    end
    
      subjobs.sort! { |a,b| a.number_of_steps <=> b.number_of_steps }
    
    @array_subjobs = []
    subjobs.each do |subjob|
      subjob.resources.each do |resource|
        resources[resource.id]["subjobs"].push({"subjob" => subjob, "time_needed" => subjob.number_of_steps * resource.steps_per_time_unit})
      end
      subjob.constraints_as_subjob_one.each do |constraint|
        if constraint.subjob_two 
          @array_subjobs.push(constraint.subjob_two)
        end
      end
    end
    
    resource_reservations(@array_subjobs, resources)
  end
  
  def generate_timetable_based_on_subjobs(subjobs, checkbefore = [])    
    # Do we still have subjobs left?
    # (termination criterion for recursion)
    if subjobs.length <= 0
      return true
    end
    
    # Sort subjobs
    subjobs.sort! { |a, b| a.number_of_steps <=> b.number_of_steps }
    
    # Array for remaining subjobs
    @array_subjobs = []
    # Array for subjobs which need prior subjobs which are not yet done
    @array_postponed_subjobs = []
    
    # For each subjob
    subjobs.each do |subjob|
      unless checkbefore.empty?
        if checkbefore.include?(subjob)
          # No need searching for cycle
          $cyclefreesubjobs = checkbefore
        else
          # Check for cycles
          if $cyclefreesubjobs = search_cycles(subjob, [], checkbefore)
            checkbefore.concat($cyclefreesubjobs)
          end
        end
      else
        # Check for cycles the first time
        if $cyclefreesubjobs = search_cycles(subjob)
          checkbefore.concat($cyclefreesubjobs)
        end
      end
      
      if $cyclefreesubjobs
        number_of_prior_subjobs = 0
                
        # Get latest ending time of constraints for current subjob
        # Does any subjob need to be finished before current subjob?
        @prior_subjobs = []
        get_next_predecessors(subjob, @prior_subjobs, false)
        @prior_subjobs.each do |prior_subjob|
          # Subjob seems to have prior needed subjobs, so check if they were already run
          @prior_subjob_timetable = Timetable.find(:first, :conditions => { :subjob_id => prior_subjob.id  } )
          if @prior_subjob_timetable
            # Prior needed subjob was already processed
            number_of_prior_subjobs += 1
          end
        end
        
        logger.debug "Subjob: #{subjob}"
        logger.debug "# of prior subjobs (object): #{@prior_subjobs.size}"
        logger.debug "# of prior subjobs (generated): #{number_of_prior_subjobs}"
        
        # Check if all prior subjobs were processed
        if number_of_prior_subjobs == @prior_subjobs.size          
          # Process subjob
          latest_resources_ending_time = 0
          
          subjob.resources.each do |resource|
            # Get latest ending time of current resource out of timetable
            @resource_timetable = Timetable.find(:first, :conditions => { :resource_id => resource.id }, :order => "end_time DESC")
            if not @resource_timetable.blank? and @resource_timetable.end_time > latest_resources_ending_time 
              latest_resources_ending_time = @resource_timetable.end_time         
            end
          end
           
          # Get latest ending time of job
          @job_timetable = Timetable.find(:first, :include => { :subjob => :job }, :conditions => { "jobs.id" => subjob.job.id }, :order => "end_time DESC")
          if @job_timetable.blank?
            latest_job_ending_time = 0
          else
            latest_job_ending_time = @job_timetable.end_time
          end         
          
          # Get latest ending of prior subjobs
          @prior_subjobs_timetable = Timetable.find(:first, :conditions => ["subjob_id IN(?)", @prior_subjobs], :order => "end_time DESC")
          if @prior_subjobs_timetable.blank?
            latest_prior_subjobs_ending_time = 0
          else
            latest_prior_subjobs_ending_time = @prior_subjobs_timetable.end_time
          end
          
          # Find out and set earliest start time
          ending_times = [latest_job_ending_time, latest_prior_subjobs_ending_time, latest_resources_ending_time].sort_by{|i| -i};
          start_time = ending_times.first
          
          # Save timetable for each resource 
          subjob.resources.each do |resource|
            # Prepare timetable entry
            @timetable = Timetable.new
            @timetable.subjob_id = subjob.id
            @timetable.resource_id = resource.id

            @timetable.start_time = start_time
          
            # Calculate time needed
            @timetable.time_needed = subjob.number_of_steps / resource.steps_per_time_unit
          
            # Calculate and set new end time
            @timetable.end_time = start_time + @timetable.time_needed
          
            # Save entry
            @timetable.save
          end          
          
          # Get siblings of current subjob
          get_next_successors(subjob, @array_subjobs)
        else
          # Not all prior subjobs were processed, so check it later (again)
          @array_postponed_subjobs.push(subjob)
        end        
      else
        # Cancel as cycles were found
        return false
      end
    end
    
    # Add postponed subjobs to array holding current subjobs
    @array_subjobs = @array_subjobs.concat(@array_postponed_subjobs) 
    
    # Recursion \o/
    generate_timetable_based_on_subjobs(@array_subjobs, checkbefore)
  end
  
  def generate_latest_times(subjob)
    logger.debug "Subjob name: #{subjob.name}"
    logger.debug "Subjob ID: #{subjob.id}"
    
    logger.debug "Trying to get earliest of latest starting times"
    
    # Get earliest of latest starting times from all its successors and
    # take it as latest end time
    successors = []
    earliest_latest_starting_time = Float::MAX
    
    unless subjob.is_end_subjob? 
      get_next_successors(subjob, successors, false)
      logger.debug "Number of successors for '#{subjob.name}': #{successors.size}"
    
      successors.each do |successor|
        if successor.is_end_subjob?
          # No timetable entry, get latest end time from it
          @timetable_entry = Timetable.find(:all, :order => "end_time DESC").first
          @timetable_entry.latest_start_time = @timetable_entry.end_time
          @timetable_entry.latest_end_time = @timetable_entry.end_time
          
          logger.debug "Successor #{successor.name} seems to be an end subjob, assuming the following"
          logger.debug "Latest start time: #{@timetable_entry.latest_start_time}"
          logger.debug "Latest end time: #{@timetable_entry.latest_end_time}"
          
          earliest_latest_starting_time = @timetable_entry.latest_start_time
        else
          @timetable_entries = Timetable.find(:all, :conditions => {:subjob_id => successor.id})
          logger.debug "Successor #{successor.name} seems not to be an end subjob, #{YAML::dump(@timetable_entries)}"
          
          @timetable_entries.each do |timetable_entry|            
            if not timetable_entry.blank? and not timetable_entry.latest_start_time.blank?
              logger.debug "Need to set start time? #{timetable_entry.latest_start_time} < #{earliest_latest_starting_time}?"
              if timetable_entry.latest_start_time < earliest_latest_starting_time
                logger.debug "True."
                earliest_latest_starting_time = timetable_entry.latest_start_time
              end
            end
          end
        end
      end
      
      # Assume we have a latest starting time, set it as ending time
      logger.debug "Updating times"
    
      # Get timetable entry for subjobs
      @current_timetable_entries = Timetable.find(:all, :conditions => { :subjob_id => subjob.id })
      logger.debug "Subjob '#{subjob.name}' seems not to be an end subjob, #{YAML::dump(@current_timetable_entries)}"
      
      @current_timetable_entries.each do |current_timetable_entry|
        @next_subjob_on_resource = Timetable.where(
          "resource_id = :resource_id AND latest_start_time < :earliest_latest_starting_time",
          { :resource_id => current_timetable_entry.resource_id, :earliest_latest_starting_time => earliest_latest_starting_time }
        ).order("latest_start_time ASC").first  

        unless @next_subjob_on_resource.blank?
          submission_hash =  { "latest_end_time"   => @next_subjob_on_resource.latest_start_time,
                                "latest_start_time" => @next_subjob_on_resource.latest_start_time - current_timetable_entry.time_needed }
        else
           submission_hash =  { "latest_end_time"   => earliest_latest_starting_time,
                                "latest_start_time" => earliest_latest_starting_time - current_timetable_entry.time_needed }
        end
        
        next_predecessors = []
        get_next_predecessors(current_timetable_entry.subjob, next_predecessors, false)
        logger.debug "Next predecessors:"
        logger.debug YAML::dump(next_predecessors)
        # Get latest ending times of next predecessors
        @latest_predecessors_ending_time = Timetable.where(
          "subjob_id IN(:subjobs)",
          { :subjobs => next_predecessors }
        ).order("latest_end_time DESC").first
        
        if not @latest_predecessors_ending_time.blank? and @latest_predecessors_ending_time.subjob.job_id != current_timetable_entry.subjob.job_id
          logger.debug "Subjob '#{current_timetable_entry.subjob.name}'"
          logger.debug "Subjob job '#{current_timetable_entry.subjob.job_id}'"
          logger.debug "Current predecessor '#{@latest_predecessors_ending_time.subjob.name}'"
          logger.debug "Current predecessorjob '#{@latest_predecessors_ending_time.subjob.job_id}'"
          
          
          logger.debug "Latest predecessor ending time:"
          logger.debug YAML::dump(@latest_predecessors_ending_time)
          
          logger.debug "Comparing:"
          logger.debug "Latest start time < latest start time of predecessor?"
          logger.debug "#{submission_hash["latest_start_time"]} <  #{@latest_predecessors_ending_time.latest_start_time}?"
          
          if submission_hash["latest_start_time"] < @latest_predecessors_ending_time.latest_start_time
            logger.debug "Applying latest start and end times of predecessor"
            submission_hash["latest_start_time"] = @latest_predecessors_ending_time.latest_end_time
            submission_hash["latest_end_time"] = submission_hash["latest_start_time"] + current_timetable_entry.time_needed
          end  
        end
        
        logger.debug "Latest end time #{submission_hash["latest_end_time"]}"
        logger.debug "Latest start time #{submission_hash["latest_start_time"]}"
        current_timetable_entry.update_attributes(submission_hash)
      end
    end
  
    # Get predecessors
    logger.debug "Trying to get predecessors for '#{subjob.name}'"
    predecessors = []
    if subjob.is_end_subjob?
      get_next_predecessors(subjob, predecessors, false)
    else
      get_next_predecessors(subjob, predecessors)
    end
    
    logger.debug "Number of predecessors for '#{subjob.name}': #{predecessors.size}"
    
    # Handle each predecessor
    predecessors.each do |predecessor|
      # Recursion
      logger.debug "Handling predecessor '#{predecessor.name}' of subjob '#{subjob.name}'"
      generate_latest_times(predecessor)
    end
  end
  
  def generate_latest_possible_timetable(subjobs)    
    # Do we still have subjobs left?
    # (termination criterion for recursion)
    if subjobs.length <= 0
      return true
    end
    
    # Sort subjobs
    subjobs.sort! { |a, b| a.number_of_steps <=> b.number_of_steps }
    
    # Array for remaining subjobs
    @array_subjobs = []
    # Array for subjobs which need prior subjobs which are not yet done
    @array_postponed_subjobs = []
    
    # For each subjob
    subjobs.each do |subjob|
      
        number_of_next_subjobs = 0
                
        @next_subjobs = []
        get_next_successors(subjob, @next_subjobs, false)
        @next_subjobs.each do |next_subjob|
          # Subjob seems to have next needed subjobs, so check if they were already run
          @next_subjob_timetable = Timetable.find(:first, :conditions => { :subjob_id => next_subjob.id  } )
          if @next_subjob_timetable or next_subjob.is_end_subjob?
            # Next needed subjob was already processed
            number_of_next_subjobs += 1
          end
        end
        
        logger.debug "Subjob: #{subjob}"
        logger.debug "# of next subjobs (object): #{@next_subjobs.size}"
        logger.debug "# of next subjobs (generated): #{number_of_next_subjobs}"
        
        # Check if all next subjobs were processed
        if number_of_next_subjobs == @next_subjobs.size          
          # Process subjob
          earliest_resources_ending_time = get_latest_end_time
          
          subjob.resources.each do |resource|
            # Get earliest start time of current resource out of timetable
            @resource_timetable = Timetable.find(:first, :conditions => { :resource_id => resource.id }, :order => "latest_start_time ASC")
            if not @resource_timetable.blank? and not @resource_timetable.latest_start_time.blank? 
              if @resource_timetable.latest_start_time < earliest_resources_ending_time 
                earliest_resources_ending_time = @resource_timetable.latest_start_time
              end         
            end
          end
           
          # Get earliest start time of job
          @job_timetable = Timetable.find(:first, :include => { :subjob => :job }, :conditions => { "jobs.id" => subjob.job.id }, :order => "latest_start_time ASC")
          if not @job_timetable.blank? and not @job_timetable.latest_start_time.blank?
            earliest_job_ending_time = @job_timetable.latest_start_time
          else
            earliest_job_ending_time = get_latest_end_time()
          end         
          
          # Get earliest start of next subjobs
          @next_subjobs_timetable = Timetable.find(:first, :conditions => ["subjob_id IN(?)", @next_subjobs], :order => "latest_start_time ASC")
          if  not @next_subjobs_timetable.blank? and not @next_subjobs_timetable.latest_start_time.blank?
            earliest_next_subjobs_ending_time = @next_subjobs_timetable.latest_start_time
          else
            earliest_next_subjobs_ending_time = get_latest_end_time()
          end
          
          logger.debug "Earliest job ending time: #{earliest_job_ending_time}"
          logger.debug "Earliest next subjobs ending time: #{earliest_next_subjobs_ending_time}"
          logger.debug "Earliest resources ending time: #{earliest_resources_ending_time}"
          
          # Find out and set earliest start time
          ending_times = [earliest_job_ending_time, earliest_next_subjobs_ending_time, earliest_resources_ending_time].sort_by{|i| i};
          end_time = ending_times.first
          
          # Update timetable for each resource 
          subjob.resources.each do |resource|
            # Prepare timetable entry
            @timetable = Timetable.find(:first, :conditions => { :subjob_id => subjob.id, :resource_id => resource.id })

            # Set latest end time
            @timetable.latest_end_time = end_time
          
            # Calculate and set new latest start time
            @timetable.latest_start_time = end_time - @timetable.time_needed
          
            # Save entry
            @timetable.save
          end          
          
          # Get parents of current subjob
          get_next_predecessors(subjob, @array_subjobs)
        else
          # Not all next subjobs were processed, so check it later (again)
          @array_postponed_subjobs.push(subjob)
        end        

    end
    
    # Add postponed subjobs to array holding current subjobs
    @array_subjobs = @array_subjobs.concat(@array_postponed_subjobs) 
    
    # Recursion \o/
    generate_latest_possible_timetable(@array_subjobs)
  end
  
  def get_latest_end_time
    @timetable_entry = Timetable.find(:all, :order => "end_time DESC").first
    if not @timetable_entry.blank? and not @timetable_entry.end_time.blank?
      @timetable_entry.end_time
    else
      Float::MAX
    end
  end
  
end
