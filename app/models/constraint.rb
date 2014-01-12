class Constraint < ActiveRecord::Base
  # Relations
  belongs_to :constraint_type
  belongs_to :subjob_one, :class_name => "Subjob"
  belongs_to :subjob_two, :class_name => "Subjob"
  
  # Validations
  validates_presence_of :subjob_one_id
  validates_presence_of :subjob_two_id
  validates_presence_of :constraint_type_id
  validates_uniqueness_of :subjob_one_id, :scope => [:subjob_two_id, :constraint_type_id]
  validates_uniqueness_of :subjob_two_id, :scope => [:subjob_one_id, :constraint_type_id]

  # Attributes
  attr_accessible :subjob_one, :subjob_two, :constraint_type
  attr_accessible :subjob_one_id, :subjob_two_id, :constraint_type_id
end
