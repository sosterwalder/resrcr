class ConstraintsController < ApplicationController
  include SubjobsHelper
  include TimetableHelper
  respond_to :html, :json
  
  def index
    @constraints = Constraint.find(:all)
  end
  
  def new
    @constraint = Constraint.new
    @constraint_types = ConstraintType.find(:all)
    @end_subjobs =  get_end_subjobs    
    @first_subjobs = Subjob.where('id not in(?)', @end_subjobs).order('name asc').all
  end
  
  def create
    check_for_cycles = params[:check_for_cycles]
    @constraint = Constraint.new(params[:constraint])    
    @constraint_types = ConstraintType.find(:all)
    @end_subjobs =  get_end_subjobs    
    @first_subjobs = Subjob.where('id not in(?)', @end_subjobs).order('name asc').all
 
    if check_for_cycles      
      logger.debug "Checking for cycles was enabled"
      is_cycle_free = false
      
      # Save constraint temporarily
      @constraint.save
    
      unless params[:constraint][:subjob_one_id].blank?
        logger.debug "Searching for subjob one with id #{params[:constraint][:subjob_one_id]}"
        @first_subjob = Subjob.find(params[:constraint][:subjob_one_id])
        unless @first_subjob.blank?
          # Start jobs can never contain cycles
          if @first_subjob.is_start_subjob?
            is_cycle_free = true
          else
            logger.debug "Found subjob one: #{@first_subjob.name}"
            is_cycle_free = search_cycles(@first_subjob)
          end
          logger.debug "Found no cycles? #{is_cycle_free}"
        end
      end
      
      if not is_cycle_free
        # Destroy constraint
        @constraint.destroy
      end
    end
 
    respond_to do |format|
      if check_for_cycles and is_cycle_free
        logger.debug "Checked for cycles but none were found, saved constraint"
        format.html  { redirect_to(:constraints,
                      :notice => 'Constraint was successfully created.') }
      elsif check_for_cycles and not is_cycle_free
        logger.debug "Checked for cycles and some were found"
        # Add error
        @constraint.errors[:base] << 'Constraint can`t be saved as it leads to cycles. Please remove them first.'
        format.html  {  render :action => "new" }
      else
        logger.debug "Not checked for cycles, trying to save constraint"
        if @constraint.save        
          format.html  { redirect_to(:constraints,
                        :notice => 'Constraint was successfully created.') }
        else
          format.html  { render :action => "new" }
        end
      end
    end
  end
  
  def destroy
    @constraint = Constraint.find(params[:id])
    @constraint.destroy
    flash[:notice] = "Successfully destroyed constraint."
    redirect_to constraints_url
  end
  
  def get_first_subjobs    
    # Define excluded subjob ids
    excluded_subjob_ids = []
    # Define excluded subjobs for getting successors
    excluded_successor_subjob_ids = []
    # Get constraint type
    @current_constraint_type = ConstraintType.find_by_id(params[:constraint][:constraint_type_id])
    # Save selected constraint type in session (for later usage)
    session[:constraint_type] = @current_constraint_type
    # Get types of start and end constraints
    @start_constraint_type = ConstraintType.where(:name => "Start").first
    @end_constraint_type = ConstraintType.where(:name => "End").first   
    
    #Get all subjobs which have the start constraint type
    start_subjobs = get_start_subjobs.map{|sj| sj.id}
    
    # Check constraint type
    if @current_constraint_type == @start_constraint_type
      # User chose start constraint, so first subjob can only be
      # one of the start subjobs 
      @first_subjobs = Subjob.where('id in(?)', start_subjobs).order('name asc').all
    else
      #Get all subjobs which have the end constraint type
      end_subjobs = get_end_subjobs.map{|sj| sj.id}
      
      # No start subjobs for first as well as successor subjobs
      excluded_successor_subjob_ids.concat(start_subjobs)
      excluded_subjob_ids.concat(start_subjobs)
      
      # No end subjobs for first as well as successor subjobs
      excluded_subjob_ids.concat(end_subjobs)
      excluded_successor_subjob_ids.concat(end_subjobs)
      
      # Get all subjobs without ones in excluded list
      @first_subjobs = Subjob.where('id not in(?)', excluded_subjob_ids).order('name asc').all
    end    
    
    # Return first subjobs
    respond_with(@first_subjobs)
  end
  
  def get_second_subjobs
    # Define excluded subjob ids
    excluded_subjob_ids = []
    # Get current subjob
    @current_subjob = Subjob.find(params[:constraint][:subjob_one_id])
    # Get constraint type
    @current_constraint_type = session[:constraint_type]
    # Get types of start constraints
    @start_constraint_type = ConstraintType.where(:name => "Start").first
    # Get types of end constraints
    @end_constraint_type = ConstraintType.where(:name => "End").first
    #Get all subjobs which have the end constraint types
    start_subjobs = get_start_subjobs.map{|sj| sj.id}    
    #Get all subjobs which have the end constraint type
    end_subjobs = get_end_subjobs.map{|sj| sj.id}
    
    # Check constraint type
    if @current_constraint_type == @end_constraint_type
      # User chose end constraint, so the second subjob can only be
      # one of the end subjobs
      
      # Check if the current subjob has successors
      successors = []
      get_all_successors(@current_subjob, successors)
      if successors.blank?
        # No successors, so allow constraint
        @second_subjobs = Subjob.where('id in(?)', end_subjobs).order('name asc').all
      end
    else
      # Exclude all start subjobs
      excluded_subjob_ids.concat(start_subjobs)
      
      # If the user chose the start constraint type,
      # Exclude the end subjobs as a relation to an
      # end subjob is only allowed with constraint type
      # end
      excluded_subjob_ids.concat(end_subjobs)
      
      # Exclude all predecessors (from the same job)
      predecessors = []
      get_all_predecessors(@current_subjob, predecessors)
      unless predecessors.blank?
        excluded_subjob_ids.concat(predecessors.map{|sj| sj.id})
      end
      
      # Exclude all successors (from the same job) and end subjobs
      successors = []
      get_all_successors(@current_subjob, successors, false)
      unless successors.blank?
        excluded_subjob_ids.concat(successors.map{|sj| sj.id})
        excluded_subjob_ids.concat(end_subjobs)
      end        
     
      # Exclude selected subjob from first subjob field (no constraint to itself allowed)
      excluded_subjob_ids.push((params[:constraint][:subjob_one_id]).to_i)
      
      # Get all subjobs without ones in excluded list
      @second_subjobs = Subjob.where('id not in(?)', excluded_subjob_ids).order('name asc').all
    end
    
    # Return second subjobs
    respond_with(@second_subjobs)
  end
end