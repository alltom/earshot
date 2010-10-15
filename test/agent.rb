require 'test/unit'
require './agent'


class TransmitterTester < Test::Unit::TestCase
  def test_init
    t = Transmitter.new
  end
end
