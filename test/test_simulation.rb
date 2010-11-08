
require "helper"

CONFIG[:width_m] = 100
CONFIG[:height_m] = 100

class TestSimulation < Test::Unit::TestCase
  def test_add_agent
    sim = Simulation.new
    
    assert_equal true, sim.agents.empty?
    sim.add_agent
    assert_equal false, sim.agents.empty?
  end
end
