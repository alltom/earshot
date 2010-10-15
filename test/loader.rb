require 'test/unit'
require './loader'


# Mock classes

class Simulation
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
end
