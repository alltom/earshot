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

NOW = 8736
class Shreduler
  def now() NOW end
end


class TransmitterTester < Test::Unit::TestCase
  def setup
    $shreduler = Shreduler.new
  end

  def test_init
    t = Transmitter.new(loc=nil, airspace=nil)

    assert_equal :idle, t.state
  end

  def test_broadcast_message
    assert false
  end

  def test_receive_start_flag
    t = Transmitter.new(loc=nil, airspace=nil)

    assert_equal :idle, t.state
    START.each_char { |bit| t.recv_bit(bit) }
    assert_equal :reading_length, t.state
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
