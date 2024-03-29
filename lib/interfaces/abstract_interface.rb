module Interfaces::AbstractInterface
  
  class InterfaceNotImplementedError < NoMethodError
  end
  
  def self.included(klass)
    klass.send(:include, Interfaces::AbstractInterface::Methods)
    klass.send(:extend, Interfaces::AbstractInterface::Methods)
    klass.send(:extend, Interfaces::AbstractInterface::ClassMethods)
  end
  
  module Methods
    
    def api_not_implemented(klass, method_name = nil)
      if method_name.nil?
        caller.first.match(/in \`(.+)\'/)
        method_name = $1
      end
      raise AbstractInterface::InterfaceNotImplementedError.new("#{klass.class.name} needs to implement '#{method_name}' for interface #{self.name}!")
    end
    
  end
  
  module ClassMethods
    
    def needs_implementation(name, *args)
      self.class_eval do
        define_method(name) do |*args|
          Bicycle.api_not_implemented(self, name)
        end
      end
    end
    
  end
  
end
