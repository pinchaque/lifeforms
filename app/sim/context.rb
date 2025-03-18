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

  # Helps this object behave like a hash
  def fetch(id, default = nil)
    value(id, default)
  end

  # Returns true if this context has the specified key, false otherwise
  def has_key?(id)
    @params.include?(id) ||
    @lifeform.attrs.include?(id)
  end
end