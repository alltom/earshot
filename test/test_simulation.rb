
require "helper"
require File.join(File.dirname(__FILE__), "..", "lib", "simulation")

# Mock classes

class MovingAgent
  def initialize(loc, airspace)
  end

  def start
  end
end

class Loc
  def initialize(x, y)
  end
end

class Airspace
  def <<(agent)
  end
end

module Ruck
  class Shreduler
    def make_convenient
    end
  end
end

class EARLOG
  @@birth_given = false

  def EARLOG.born(agent)
    @@birth_given = true
  end

  def EARLOG.birth_given?
    @@birth_given
  end
end

CONFIG = {}
CONFIG[:width_m] = 100
CONFIG[:height_m] = 100


class Tester < Test::Unit::TestCase
  def test_add_agent
    sim = Simulation.new
    
    assert_equal true, sim.agents.empty?
    sim.add_agent
    assert_equal false, sim.agents.empty?
  end
end
