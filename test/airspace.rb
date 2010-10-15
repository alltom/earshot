require 'test/unit'
require './airspace'


# Mock classes
RADIUS = 50
NEAR_X, NEAR_Y = 0, 0
FAR_X, FAR_Y = 100, 100
BIT = '1'

class Loc
  attr_reader :x, :y
  def initialize(x, y)
    @x, @y = x, y
  end

  def dist(loc)
    Math.sqrt((@x - loc.x) ** 2 + (@y - loc.y) ** 2)
  end
end

class Agent
  attr_reader :loc, :bit
  def initialize(loc)
    @loc = loc
    @bit = nil
  end

  def recv_bit(bit)
    @bit = bit
  end

  def broadcasting?
    false
  end
end


class Tester < Test::Unit::TestCase
  def test_send_bit_isolated
    air = Airspace.new
    agent = Agent.new(Loc.new(NEAR_X, NEAR_Y))
    air << agent

    air.send_bit(agent, RADIUS, BIT)

    assert agent.bit.nil?
  end

  def test_send_bit_in_range
    air = Airspace.new
    a1 = Agent.new(Loc.new(NEAR_X, NEAR_Y))
    a2 = Agent.new(Loc.new(NEAR_X, NEAR_Y))
    air << a1
    air << a2

    air.send_bit(a1, RADIUS, BIT)

    assert a1.bit.nil?
    assert_equal BIT, a2.bit
  end

end
