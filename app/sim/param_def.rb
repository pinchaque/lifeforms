class ParamDef
  # Unique identifier - convention is a snake_case symbol
  attr_reader :id

  # User-friendly description
  attr_accessor :desc

  # Distribution function to use
  attr_accessor :distrib

  # Constraint functions to use; array that's executed in order
  attr_accessor :constraints

  # Initialize the parameter definition with an id to use. This ID is used
  # to refer to this parameter throughout the project.
  def initialize(id)
    @id = id.to_sym
    @constraints = Array.new
  end

  # Generates and returns a default value for the parameter given the
  # distribution and other parameters that have been configured.
  def generate_default
    if @distrib.nil?
      constrain(0.0)
    else
      constrain(@distrib.rnd)
    end
  end

  # Constrains the specified value to be within min..max, if available.
  def constrain(v)
    @constraints.each do |c|
      v = c.constrain(v)
    end
    v
  end

  # Validates the specified value to ensure it is within range. Returns an
  # error message if invalid and nil if valid.
  def check_validity(v)
    ret = @constraints.map { |c| c.check_validity(v) }
    ret.empty? ? nil : ret.join(", ")
  end

  # Validates the specified value to ensure it is within range. Returns true
  # if valid and false otherwise.
  def valid?(v)
    @constraints.all? { |c| c.valid?(v) }
  end

  # Creates a mutation of the specified value using the assigned distirbution.
  # Constrains the mutation to be within our min/max.
  def mutate(v)
    constrain(@distrib.mutate(v))
  end

  # Marshals this object into built-in classes
  def marshal
    {
      id: @id,
      desc: @desc,
      distrib: @distrib.marshal,
      constraints: @constraints.map { |c| c.marshal }
    }
  end

  # Unmarshals from an object and returns a new ParamDef object
  def self.unmarshal(obj)
    pd = ParamDef.new(obj[:id].to_sym)
    pd.desc = obj[:desc]
    pd.distrib = Distrib::unmarshal(obj[:distrib])
    pd.constraints = obj[:constraints].map{ |c| Constraint.unmarshal(c) }
    pd
  end
end

# Helper function to create a ParamDef with Linear distribution. 
def ParamDefLinear(id:, min:, max:, **opts)
  pd = ParamDef.new(id)
  pd.desc = opts[:desc]
  pd.constraints << ConstraintMinMax.new(min, max)
  pd.distrib = DistribLinear.new(min, max)
  pd
end

# Helper function to create a ParamDef with Normal distribution. 
def ParamDefNormal(id:, mean:, stddev:, **opts)
  pd = ParamDef.new(id)
  pd.desc = opts[:desc]
  pd.constraints << ConstraintMinMax.new(opts[:min], opts[:max])
  pd.distrib = DistribNormal.new(mean, stddev)
  pd
end

# Helper function to create a ParamDef with Normal distribution with min and 
# max set to 0 and 1 by default. This min/max can be overridden but can't be out
# of this range.
def ParamDefNormalPerc(id:, mean:, stddev:, **opts)
  pd = ParamDef.new(id)
  pd.desc = opts[:desc]

  msg = "min and max must be in range 0..1"

  opts[:min] ||= 0.0
  raise(ArgumentError.new(msg)) unless (0.0..1.0) === opts[:min]

  opts[:max] ||= 1.0
  raise(ArgumentError.new(msg)) unless (0.0..1.0) === opts[:max]

  pd.constraints << ConstraintMinMax.new(opts[:min], opts[:max])

  pd.distrib = DistribNormal.new(mean, stddev)
  pd
end

# Helper function to create a ParamDef with Normal distribution. 
def ParamDefNormalInt(id:, mean:, stddev:, **opts)
  pd = ParamDef.new(id)
  pd.desc = opts[:desc]
  pd.constraints << ConstraintMinMax.new(opts[:min], opts[:max])
  pd.constraints << ConstraintInt.new
  pd.distrib = DistribNormal.new(mean, stddev)
  pd
end