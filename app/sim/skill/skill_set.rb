module Skill
  class SkillSet
    attr_reader :skills

    # Initializes empty SkillSet
    def initialize
      @skills = {}
    end

    # Adds Skill to this SkillSet
    def add(s)
      raise "Skill #{s.id} already exists" if @skills.key?(s.id)
      @skills[s.id] = s
    end

    # Returns number of Skills in this SkillSet
    def count
      @skills.count
    end

    # Clears all Skills from this SkillSet
    def clear
      @skills.clear
    end

    # Returns true if this SkillSet has the skill with the given id, false
    # otherwise
    def include?(id)
      @skills.key?(id)
    end
  end
end