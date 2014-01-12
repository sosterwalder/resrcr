class Resource < ActiveRecord::Base
  has_and_belongs_to_many :subjobs
  has_many :timetables
  
  validates_presence_of :name
  validates_uniqueness_of :name

  attr_accessible :name
end
