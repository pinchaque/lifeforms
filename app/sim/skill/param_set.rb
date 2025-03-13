module Skill
  # Represents a set of Params for a Lifeform. Each Param must have a unique
  # ID.
  class ParamSet
    # Initialize empty ParamSet
    def initialize
      @params = {}
      yield self if block_given?
    end

    # Number of Params in this object
    def count
      @params.count
    end

    # Adds a Param to this object
    def add(p)
      raise "Param #{p.id} already exists" if @params.key?(p.id)
      @params[p.id] = p
    end

    # Clears all Params from this object
    def clear
      @params.clear
    end

    # Returns true if the Param with the given ID exists in this object
    def include?(id)
      @params.include?(id)
    end

    # Fetches the Param with the given ID, returning default if it is not found
    def fetch(id, default = nil)
      @params.fetch(id, default)
    end

    # Marshals this ParamSet to built-in objects that can be later converted to JSON
    def marshal
      @params.values.map { |prm| prm.marshal }
    end

    # Creates and returns a new ParamSet from the given object
    def self.unmarshal(obj)
      ParamSet.new do |pset|
        obj.each do |v|
          pset.add(Param.unmarshal(v))
        end
      end
    end
  end
end