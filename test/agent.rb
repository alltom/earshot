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

    assert_equal :idle, t.state
  end

  def test_broadcast_message
    assert false
  end

  def test_receive_start_flag
    assert false
  end

  def test_receive_length
    assert false
  end

  def test_receive_checksum
    assert false
  end

  def test_receive_message
    assert false
  end
end
