require 'test/unit'
require './airspace'


# Mock classes
class Loc
  attr_reader :x, :y
  def initialize(x, y)
    @x, @y = x, y
  end
end

class Agent
  attr_reader :loc
  def initialize(loc)
    @loc = loc
  end
end

class Tester < Test::Unit::TestCase
  def test_send_bit
    assert false
  end
end
