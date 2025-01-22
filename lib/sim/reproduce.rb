class Reproduce
  def initialize(parent)
    @parent = parent
  end

  def generate(num = 1)
    # energy is divided evenly among parent and children
    e_new = @parent.energy / (num + 1)
    @parent.energy = e_new # update parent energy

    children = []
    (0...num).each do
      child = @parent.class.new
      child.copy_from(@parent)
      child.energy = e_new
      child.set_random_name
      child.parent_id = @parent.id
      yield child if block_given? 
      children << child
    end
    block_given? ? nil : children
  end
end