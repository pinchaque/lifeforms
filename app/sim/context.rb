class Context
  attr_reader :lifeform, :env

  # Initializes the context for the specified lifeform
  def initialize(lifeform)
    @lifeform = lifeform
    @env = lifeform.env
    @params = lifeform.params
  end

  # Returns the value for the given ID, which can refer to a parameter,
  # observation, constant, etc. Returns specified default if not found.
  def value(id, default = nil)
    return @params.fetch(id).value if @params.include?(id)
      
    attrs = @lifeform.attrs
    return attrs[id] if attrs.include?(id) 

    # TODO Need to add observations
    default
  end
end