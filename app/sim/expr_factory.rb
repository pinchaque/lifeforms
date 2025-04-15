# Factory that generates valid random expressions of different types.
class ExprFactory
  def initialize(ctx)
    @ctx = ctx
  end

  # Generates a statement - something that is executed for its side benefits
  # rather than return value.
  def statement
    case [:if, :seq, :skill, :skill, :skill].sample
    when :if
      Expr::If(bool, statement, statement)

    when :seq
      Expr::Sequence(statement, statement)

    when :skill
      Expr::Skill.new(@ctx.lifeform.skills.skills.keys.sample)
    end
  end

  # Generates an expression that evaluates to a boolean value, e.g. for use in
  # if statements.
  def bool
    case [:and, :not, :or, :equal, :gt, :gte, :lt, :lte].sample
    when :and
      Expr::And.new(bool, bool)

    when :not
      Expr::Not.new(bool)

    when :or
      Expr::Or.new(bool, bool)

    when :equal
      Expr::Equal.new(numeric, numeric)

    when :gt
      Expr::GT.new(numeric, numeric)

    when :gte
      Expr::GTE.new(numeric, numeric)

    when :lt
      Expr::LT.new(numeric, numeric)

    when :lte
      Expr::LTE.new(numeric, numeric)

    end
  end

  # Generates an expression that evaluates to a numeric value, e.g. for use in
  # comparison statements.
  def numeric
    # choose evenly between a constant, lookup, and an operation
    case [:const, :lookup, :op].sample
    when :const
      Expr::Const.new(Random.rand(0.0..100.0))

    when :lookup
      Expr::Lookup.new(@ctx.keys.sample)

    when :op 
      case [:add, :div, :mul, :sub].sample
      when :add
        Expr::Add.new(numeric, numeric)

      when :div
        Expr::Div.new(numeric, numeric)

      when :mul
        Expr::Mul.new(numeric, numeric)

      # NOTE we're not allowing :pow now because fractional exponents don't
      # work well. e.g. -1.2 ^ 2.13 will be imaginary.
      when :pow
        Expr::Pow.new(numeric, numeric)

      when :sub
        Expr::Sub.new(numeric, numeric)
      end
    end
  end
end