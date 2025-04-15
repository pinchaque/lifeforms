# Factory that generates valid random expressions of different types.
class ExprFactory
  def initialize(ctx)
    @ctx = ctx
  end

  # Generates a random Skill Expr
  def skill
    Expr::Skill.new(@ctx.lifeform.skills.skills.keys.sample)
  end

  # Generates a statement - something that is executed for its side benefits
  # rather than return value.
  def statement
    case [:if, :seq, :skill, :skill, :skill].sample
    when :if
      Expr::If(bool, skill, skill)

    when :seq
      Expr::Sequence(skill, skill)

    when :skill
      skill
    end
  end

  # Generates a numeric comparison Expr that will evaluate to bool. This 
  # allows for both computed numbers and simple const/lookup.
  def numcmp
    case [:equal, :gt, :gte, :lt, :lte].sample
    when :equal
      Expr::Equal.new(numop, number)

    when :gt
      Expr::GT.new(numop, number)

    when :gte
      Expr::GTE.new(numop, number)

    when :lt
      Expr::LT.new(numop, number)

    when :lte
      Expr::LTE.new(numop, number)
    end
  end

  # Generates an expression that evaluates to a boolean value, e.g. for use in
  # if statements.
  def bool
    # allow both for nested and non-nested options
    case [:and, :or, :not, :and_num, :or_num, :numcmp].sample
    when :and
      Expr::And.new(bool, bool)

    when :or
      Expr::Or.new(bool, bool)

    when :not
      Expr::Not.new(bool)

    when :and_num
      Expr::And.new(numcmp, numcmp)

    when :or_num
      Expr::Or.new(numcmp, numcmp)

    when :numcmp
      numcmp
    end
  end

  # Generates an Expr that evalutes directly to a number - either ocnst or
  # lookup.
  def number
    case [:const, :lookup].sample
    when :const
      Expr::Const.new(Random.rand(0.0..100.0))

    when :lookup
      Expr::Lookup.new(@ctx.keys.sample)
    end
  end

  # Generates an expression that evaluates to a numeric value, e.g. for use in
  # comparison statements. We only allow one level of nesting to keep it simple.
  def numop
    # choose evenly between a constant, lookup, and an operation
    case [:number, :add, :div, :mul, :sub].sample
    when :number
      number

    when :add
      Expr::Add.new(number, number)

    when :div
      Expr::Div.new(number, number)

    when :mul
      Expr::Mul.new(number, number)

    when :sub
      Expr::Sub.new(number, number)
    end

    # NOTE we're not allowing :pow now because fractional exponents don't
    # work well. e.g. -1.2 ^ 2.13 will be imaginary. Maybe could fix this
    # by adding abs()
    # when :pow
    #   Expr::Pow.new(number, number)
  end
end