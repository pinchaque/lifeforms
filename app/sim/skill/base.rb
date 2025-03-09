module Skill
  class Base
    # Generates the id of the skill based on the class name. Override this
    # if you want to use a different ID.
    def self.id
      base_name = self.name.gsub(/^.*::/, '')
      camel_to_snake(base_name)
    end
  end
end