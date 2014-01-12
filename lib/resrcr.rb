 # This class holds what is the project specific code configuration. There has been no need to make 
 # any of these variables user configurable, so they are just held here, in the class ReSrcR. If this
 # should be made configurable, care must be taken whether the value being changed is not cached 
 # elsewhere. 
 #
 class Resrcr
  # The minimum required number of steps a subjob must have
  class_attribute :minimum_number_of_steps
  self.minimum_number_of_steps = 1
   
  # The maximum number of steps a subjob can have
  class_attribute :maximum_number_of_steps
  self.maximum_number_of_steps = 10
 end