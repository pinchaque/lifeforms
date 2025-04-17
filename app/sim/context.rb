class Context
  attr_reader :lifeform, :env

  # Initializes the context for the specified lifeform
  def initialize(lifeform)
    @lifeform = lifeform
    @attrs = lifeform.attrs
    @env = lifeform.env
    @params = lifeform.params
    @obs = lifeform.observations
  end

  # Returns the value for the given ID, which can refer to a parameter,
  # observation, constant, etc. Returns specified default if not found.
  def value(id, default = nil)
    # Parameter
    if @params.include?(id)
      @params.fetch(id).value 
    # Lifeform attributes
    elsif @attrs.include?(id)     
      @attrs[id]
    elsif @obs.include?(id)
      @obs[id].calc(self)
    else
      default
    end
  end

  # Returns array of all keys available for lookup
  def keys
    @params.ids.union(@attrs.keys, @obs.keys)
  end

  # Helps this object behave like a hash
  def fetch(id, default = nil)
    value(id, default)
  end

  # Returns true if this context has the specified key, false otherwise
  def has_key?(id)
    @params.include?(id) ||
    @attrs.include?(id) ||
    @obs.include?(id)
  end
end