class Subjob < ActiveRecord::Base
  # Relations
  belongs_to :job
  has_and_belongs_to_many :resources
  has_many :constraints_as_subjob_one, :class_name => 'Constraint', :foreign_key => 'subjob_one_id'
  has_many :constraints_as_subjob_two, :class_name => 'Constraint', :foreign_key => 'subjob_two_id'
  has_many :timetables

  # Validations
  validates_presence_of :name
  validates_presence_of :job_id
  validates_presence_of :number_of_steps
  validates_uniqueness_of :name, :scope => [:job_id]

  # Attributes
  attr_accessible :name
  attr_accessible :number_of_steps
  attr_accessible :job_id
  attr_accessible :resource_ids
  
  def is_start_subjob?
    # Is there any constraint where the type is start and this subjob is subjob one?
    @constraint_type_start = ConstraintType.where(:name => "Start").first
    @constraint = Constraint.where(:constraint_type_id => @constraint_type_start.id, :subjob_one_id => self.id).all
    
    unless @constraint.blank?
      return true
    else
      return false
    end
  end
  
  def is_end_subjob?
    # Is there any constraint where the type is end and this subjob is subjob two?
    @constraint_type_end = ConstraintType.where(:name => "End").first
    @constraint = Constraint.where(:constraint_type_id => @constraint_type_end.id, :subjob_two_id => self.id).all
    
    unless @constraint.blank?
      return true
    else
      return false
    end
  end
end
