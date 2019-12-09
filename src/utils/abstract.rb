require_relative 'scope.rb'
require_relative 'semantic'

module Assemblable
    def self.included base
        base.send :include, InstanceMethods
    end

    module InstanceMethods
        def assemble(memory)
            raise NotImplementedError.
                new("#{self.class.name} is an abstract class.")
        end
    end
end

class HandObject
    include Semantic
    include Scopable
    include Assemblable
end

module Accessible
    def access()
        raise NotImplementedError.
            new("#{self.class.name} is an abstract class.")      
    end
end

class HProcedure < HandObject
    include Accessible
end

