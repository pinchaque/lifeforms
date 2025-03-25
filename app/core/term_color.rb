class TermColor
  def initialize
    @codes = []
  end

  def add_codes(*codes)
    @codes = @codes + codes
    self
  end

  def fg(r, g, b)
    add_codes(38, 2, r, g, b)
  end

  def bg(r, g, b)
    add_codes(48, 2, r, g, b)
  end

  def black
    add_codes(30)
  end

  def red
    add_codes(91)
  end

  def green
    add_codes(92)
  end

  def yellow
    add_codes(93)
  end

  def blue
    add_codes(94)
  end

  def magenta
    add_codes(95)
  end

  def cyan
    add_codes(96)
  end

  def white
    add_codes(97)
  end

  def grey
    fg(128, 128, 128)
  end

  def bold
    add_codes(1)
  end

  def underline
    add_codes(4)
  end

  def reset
    @codes = []
    add_codes(0)
  end

  def to_s
    "\033[" + @codes.join(";") + "m"
  end
end