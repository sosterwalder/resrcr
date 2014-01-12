class Job < ActiveRecord::Base
  # Relations
  has_many :subjobs
  
  # Validations
  validates_presence_of :name
  
  # Attributes
  attr_accessible :name
end
