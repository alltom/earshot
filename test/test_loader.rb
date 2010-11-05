
require "helper"
require File.join(File.dirname(__FILE__), "..", "lib", "loader")


# Mock classes

class Simulation
  def add_agent(loc)
    :SECRET_AGENT_MAN
  end
end

class Loc
  def initialize(x, y)
  end
end

CONFIG = {}


class Tester < Test::Unit::TestCase
  def test_init
    assert_nothing_thrown do
      Loader.new
    end
  end

  def test_size
    l = Loader.new
    w, h = 20, 30
    l.size(w, h)
    
    assert_equal w, CONFIG[:width_m]
    assert_equal h, CONFIG[:height_m]
  end

  def test_seconds_per_bit
    l = Loader.new
    spb = 17
    l.seconds_per_bit(spb)
    
    assert_equal spb, CONFIG[:seconds_per_bit]
  end

  def test_agent_radius
    l = Loader.new
    radius = 19
    l.agent_radius(radius)
    
    assert_equal radius, CONFIG[:agent_radius_m]
  end

  def test_transmission_radius
    l = Loader.new
    radius = 19
    l.transmission_radius(radius)
    
    assert_equal radius, CONFIG[:transmission_radius_m]
  end

  def test_messages
    l = Loader.new
    ms = ['a','b','c']
    l.messages(ms)
    
    assert_equal ms, CONFIG[:messages]
  end

  def test_agent
    l = Loader.new
    x, y = 198, 277
    agent = l.agent(x, y)
    
    assert_equal :SECRET_AGENT_MAN, agent
  end

  def test_speed
    l = Loader.new
    speed = 12345
    l.speed(speed)
    
    assert_equal speed, CONFIG[:speed_mps]
  end

  def test_grid
    l = Loader.new
    g = 99
    l.grid(g)
    
    assert_equal g, CONFIG[:grid_m]
  end

  def test_title
    l = Loader.new
    t = 'TITLE'
    l.title(t)
    
    assert_equal t, CONFIG[:title]
  end

  def test_load
    assert false, 'implement me!'
  end
end
