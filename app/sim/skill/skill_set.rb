module Skill
  class SkillSet
    attr_reader :skills

    def initialize
      @skills = {}
    end

    def add(s)
      raise "Skill #{s.id} already exists" if @skills.key?(s.id)
      @skills[s.id] = s
    end

    def clear
      @skills.clear
    end
  end
end