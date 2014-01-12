module SubjobsHelper
  def get_all_subjobs_by_constraint(constraint_type)
    @constraint_type_start = ConstraintType.find_by_name("Start")
    @constraint_type_end = ConstraintType.find_by_name("End")
    
    if constraint_type == @constraint_type_start
      @subjobs = Subjob.find(:all, :joins => "JOIN 'constraints' ON constraints.subjob_two_id = subjobs.id",   :conditions => ["constraints.constraint_type_id = ?", constraint_type.id], :order => "subjobs.number_of_steps")
    elsif constraint_type == @constraint_type_end
      @subjobs = Subjob.find(:all, :joins => "JOIN 'constraints' ON constraints.subjob_one_id = subjobs.id",   :conditions => ["constraints.constraint_type_id = ?", constraint_type.id], :order => "subjobs.number_of_steps")
    end
  end 
  
  def get_all_subjobs_by_constraint_by_name(name)
    @constraint_type = ConstraintType.find_by_name(name)
    get_all_subjobs_by_constraint(@constraint_type)
  end
  
  def get_all_subjobs_by_constraint_type_start
    get_all_subjobs_by_constraint_by_name("Start")
  end
  
  def get_all_subjobs_by_constraint_type_end
    get_all_subjobs_by_constraint_by_name("End")
  end
  
  def get_start_subjobs
    @constraint_type = ConstraintType.find_by_name("Start")
    @start_subjobs = Subjob.find(:all, :joins => "JOIN 'constraints' ON constraints.subjob_one_id = subjobs.id",   :conditions => ["constraints.constraint_type_id = ?", @constraint_type.id], :order => "subjobs.number_of_steps").uniq
    return @start_subjobs
  end
  
  def get_end_subjobs
    @constraint_type = ConstraintType.find_by_name("End")
    @end_subjobs = Subjob.find(:all, :joins => "JOIN 'constraints' ON constraints.subjob_two_id = subjobs.id",   :conditions => ["constraints.constraint_type_id = ?", @constraint_type.id], :order => "subjobs.number_of_steps").uniq
    return @end_subjobs
  end
  
  def get_all_predecessors(subjob, subjobs, only_same_job = true)
    if subjob.blank? or subjob.is_start_subjob?
      return
    end    
    
    # Get constraints where current subjob is subjob_two and where the subjobs are in the same job
    if only_same_job
      @constraints_inverted = Constraint.find(:all, :include => { :subjob_two => :job }, :conditions => { "jobs.id" => subjob.job.id, "subjob_two_id" => subjob.id })
    else
      @constraints_inverted = Constraint.find(:all, :include => { :subjob_two => :job }, :conditions => { "subjob_two_id" => subjob.id })
    end
    @constraints_inverted.each do |constraint_inverted|
      # Add subjob, if its not the start subjob
      if not constraint_inverted.subjob_one.is_start_subjob?
        subjobs.push(constraint_inverted.subjob_one)
        # Get predecessors of subjob, recursion \o/
        get_all_predecessors(constraint_inverted.subjob_one, subjobs)
      else
        return
      end
    end
  end
  
  def get_all_successors(subjob, subjobs, only_same_job = true)   
    if subjob.blank? or subjob.is_end_subjob?
      return
    end    
    
    # Get constraints where current the subjob is subjob_one
    if only_same_job
      # The subjobs have to be in the same job
      @constraints = Constraint.find(:all, :include => { :subjob_one => :job }, :conditions => { "jobs.id" => subjob.job.id, "subjob_one_id" => subjob.id })
    else
      @constraints = Constraint.find(:all, :include => { :subjob_one => :job }, :conditions => { "subjob_one_id" => subjob.id })
    end
    @constraints.each do |constraint|
      # Add subjob, if its not the end subjob
      if not constraint.subjob_two.is_end_subjob?
        subjobs.push(constraint.subjob_two)
        # Get successors of subjob, recursion \o/
        get_all_successors(constraint.subjob_two, subjobs)
      else
        return
      end
    end
  end
  
  def get_next_successors(subjob, subjobs, only_same_job = true, include_end_subjob = false)
    if subjob.blank? or subjob.is_end_subjob?
      return
    end    
    
    # Get constraints where the current subjob is subjob_one
    @constraints = subjob.constraints_as_subjob_one
    @constraints.each do |constraint|
      if only_same_job
        if constraint.subjob_one.job_id == subjob.job_id and constraint.subjob_two.job_id == subjob.job_id
          if include_end_subjob
            subjobs.push(constraint.subjob_two)
          else
            unless constraint.subjob_one.is_end_subjob?
              subjobs.push(constraint.subjob_two)
            end
          end
        end
      else
        if include_end_subjob
          subjobs.push(constraint.subjob_two)
        else
          unless constraint.subjob_one.is_end_subjob?
            subjobs.push(constraint.subjob_two)
          end
        end
      end
    end
  end
  
  def get_next_predecessors(subjob, subjobs, only_same_job = true, include_start_subjob = false)
    if subjob.blank? or subjob.is_start_subjob?
      return
    end    
    
    # Get constraints where current the subjob is subjob_two
    @constraints = subjob.constraints_as_subjob_two
    @constraints.each do |constraint|
      if only_same_job
        if constraint.subjob_one.job_id == subjob.job_id and constraint.subjob_two.job_id == subjob.job_id
          if include_start_subjob
            subjobs.push(constraint.subjob_one)
          else
            unless constraint.subjob_one.is_start_subjob?
              subjobs.push(constraint.subjob_one)
            end
          end
        end
      else
        if include_start_subjob
          subjobs.push(constraint.subjob_one)
        else
          unless constraint.subjob_one.is_start_subjob?
            subjobs.push(constraint.subjob_one)
          end
        end
      end
    end
  end  
end