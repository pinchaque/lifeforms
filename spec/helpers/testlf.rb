class TestLF < Lifeform
  attr_accessor :val1, :val2

  def marshal_to_h
    super.merge({
      val1: val1,
      val2: val2
    })
  end

  def marshal_from_h(h)
    @val1 = h[:val1]
    @val2 = h[:val2]
    super(h)
  end

  def to_s
    super + " val1:#{@val1} val2:#{@val2}"
  end
end