module Interfacess::Subjob
  # Inherit from interface
  include Interfaces::AbstractInterface

  # Relations
  has_one :resource


  # Class variables
  @@amount = 1

  # Getters
  attr_accessor :amount
end
