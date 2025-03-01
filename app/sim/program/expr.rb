module Program
  class Expr
    attr_accessor :operator, :left, :right
  end

  class Equal < Expr
    def eval
      @left.value == @right.value
    end
  end
end