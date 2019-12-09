module Semantic
    def self.included base
        base.send :include, InstanceMethods
    end

    module InstanceMethods
        def semantic_check()
            #raise NotImplementedError.
            #new("#{self.class.name} is an abstract class.")
        end

        def get_type()
            raise NotImplementedError.
                new("#{self.class.name} is an abstract class.")
        end

        def set_type(meta_type)
            raise NotImplementedError.
                new("#{self.class.name} is an abstract class.")
        end
    end
end