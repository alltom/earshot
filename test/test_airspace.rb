
require "helper"

# RADIUS = 50
# NEAR_X, NEAR_Y = 0, 0
# FAR_X, FAR_Y = 100, 100
# BIT = '1'

class TestAirspace < Test::Unit::TestCase
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

  def test_send_bit_simultaneously_in_range
    air = Airspace.new
    a1 = Agent.new(Loc.new(NEAR_X, NEAR_Y))
    a2 = Agent.new(Loc.new(NEAR_X, NEAR_Y), broadcasting=true)
    air << a1
    air << a2

    assert_equal false, EARLOG::collision?
    air.send_bit(a1, RADIUS, BIT)
    assert_equal true, EARLOG::collision?
  end

  def test_send_bit_out_of_range
    air = Airspace.new
    a1 = Agent.new(Loc.new(NEAR_X, NEAR_Y))
    a2 = Agent.new(Loc.new(FAR_X, FAR_Y))
    air << a1
    air << a2

    air.send_bit(a1, RADIUS, BIT)

    assert a1.bit.nil?
    assert a2.bit.nil?
  end

end
