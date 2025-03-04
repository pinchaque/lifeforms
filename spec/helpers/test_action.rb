class TestAction
  # initialize with the value that executing the action will return
  def initialize(ret)
    @ret = ret
  end

  # No-op and returns the value set upon initialize
  def exec(ctx)
    @ret
  end
end