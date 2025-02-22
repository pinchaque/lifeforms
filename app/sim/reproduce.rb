class Reproduce
  def initialize(parent)
    @parent = parent
  end

  # Generates num offspring each with the specified energy
  def generate(energy, num = 1)
    children = []
    (0...num).each do
      child = @parent.class.new
      child.copy_from(@parent)
      child.energy = energy
      child.set_random_name
      child.parent_id = @parent.id
      child.generation = @parent.generation + 1
      child.created_step = @parent.env.time_step
      child.size = 1.0
      # TODO should use some kind of "initial size" to set size and distance
      yield child if block_given? 
      children << child
    end
    block_given? ? nil : children
  end
end