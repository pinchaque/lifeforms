class Environment

  attr_accessor :width, :height
  attr_accessor :lifeforms
  attr_accessor :time

  def initialize(w, h)
    @width = w
    @height = h
    @lifeforms = []
    @time = 0
  end

  def add_lifeform(l)
    l.env = self
    l.x, l.y = rnd_loc
    @lifeforms << l
  end

  def rnd_loc
    r = Random.new
    return r.rand(0.0..@width.to_f), r.rand(0.0..@height.to_f)
  end

  def run_step
    # TODO: randomize order
    @lifeforms.each do |l|
      l.run_step
    end

    @time += 1
  end

  def to_s
    str = "[#{@lifeforms.count} Lifeforms | Size #{@width}x#{@height} | Time #{@time}]\n"
    str += @lifeforms.map{ |l| "  * #{l.to_s}" }.join("\n")
    str
  end
end