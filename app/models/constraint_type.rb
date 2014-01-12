class ConstraintType < ActiveRecord::Base
  has_many :constraints

  attr_accessible :name
end
