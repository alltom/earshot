
class Loc
  attr_accessor :x
  attr_accessor :y
  
  def initialize(x, y)
    @x, @y = x, y
  end
  
  def dist(loc)
    Math.sqrt((@x - loc.x) ** 2 + (@y - loc.y) ** 2)
  end
  
  def to_s
    "#{x}, #{y}"
  end
end
