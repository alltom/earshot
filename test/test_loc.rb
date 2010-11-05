
require "helper"
require File.join(File.dirname(__FILE__), "..", "lib", "loc")

class Tester < Test::Unit::TestCase
  def test_dist
    l1 = Loc.new(0, 0)
    l2 = Loc.new(0, 1)
    assert_equal 1, l1.dist(l2)
  end
end
