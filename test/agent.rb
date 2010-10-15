require 'test/unit'
require './agent'


# Mock classes
UID = '123123'

class UIDGenerator
  def initialize(prefix)
  end

  def next
    UID
  end
end




class TransmitterTester < Test::Unit::TestCase
  def test_init
    loc = nil
    airspace = nil
    t = Transmitter.new(loc, airspace)
  end
end
