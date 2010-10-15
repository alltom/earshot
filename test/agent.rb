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

MESSAGE = "these aren't the droids you're looking for."


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
    t = Transmitter.new(loc=nil, airspace=nil)
    len_bits = sprintf("%0#{NUM_LENGTH_BITS}d", MESSAGE.length.to_s(2))

    assert_equal :idle, t.state
    START.each_char { |bit| t.recv_bit(bit) }
    len_bits.each_char { |bit| t.recv_bit(bit) }
    assert_equal :reading_checksum, t.state
  end

  def test_receive_checksum
    assert false
  end

  def test_receive_message
    assert false
  end
end
