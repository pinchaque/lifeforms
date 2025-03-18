module Skill
  # Represents a set of Skills for a Lifeform. Each Skill must have a unique
  # ID.
  class SkillSet
    # Initialize empty SkillSet
    def initialize
      @skills = {}
      yield self if block_given?
    end

    def to_s
      "[SkillSet] " + @skills.values.map{ |s| s.name }.join(", ")
    end

    # Number of Skills in this object
    def count
      @skills.count
    end

    # Adds a Skill to this object
    def add(sk)
      raise "Skill #{sk.id} already exists" if @skills.key?(sk.id)
      @skills[sk.id] = sk
    end

    # Clears all Skills from this object
    def clear
      @skills.clear
    end

    # Returns true if the Skill with the given ID exists in this object
    def include?(id)
      @skills.include?(id)
    end

    # Fetches the Skill with the given ID, returning default if it is not found
    def fetch(id, default = nil)
      @skills.fetch(id, default)
    end

    # Marshals this SkillSet to built-in objects can be later converted to JSON
    def marshal
      @skills.values.map { |sk| sk.marshal }
    end

    # Creates and returns a new SkillSet from the given object
    def self.unmarshal(obj)
      SkillSet.new do |sset|
        obj.each do |v|
          sset.add(Skill::Base.unmarshal(v))
        end
      end
    end
  end
end