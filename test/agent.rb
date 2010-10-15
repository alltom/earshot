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

  def shredule(shred)
  end
end

class Message
  def to_bits
    MESSAGE
  end

  def self.from_bits(bits)
    Message.new
  end

  def target_uid
    '10010101010'
  end

  def length
    MESSAGE.length
  end
end

MESSAGE = "101111101010100010101"

module Ruck
  class Shred
    def initialize
      yield
    end

    def self.yield(time)
    end
  end
end

CONFIG = {}
CONFIG[:seconds_per_bit] = 10

class Airspace
  attr_reader :bits
  def initialize
    @bits = ''
  end

  def send_bit(sender, radius, bit)
    @bits += bit
  end
end


# override of Transmitter class to make it more testable
class Transmitter
  attr_accessor :length
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
    air = Airspace.new
    t = Transmitter.new(loc=nil, airspace=air)
    m = Message.new
    t.broadcast_message(m)

    len_bits = sprintf("%0#{NUM_LENGTH_BITS}d", MESSAGE.length.to_s(2))
    bits = START + len_bits + checksum(MESSAGE) + MESSAGE
    assert_equal bits, air.bits
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
    t.read_length
    len_bits.each_char { |bit| t.recv_bit(bit) }
    assert_equal :reading_checksum, t.state
    assert_equal MESSAGE.length, t.length
  end

  def test_receive_checksum
    t = Transmitter.new(loc=nil, airspace=nil)

    assert_equal :idle, t.state
    t.length = MESSAGE.length
    t.read_checksum
    checksum(MESSAGE).each_char { |bit| t.recv_bit(bit) }
    assert_equal :reading_message, t.state
  end

  def test_receive_message
    t = Transmitter.new(loc=nil, airspace=nil)
    len_bits = sprintf("%0#{NUM_LENGTH_BITS}d", MESSAGE.length.to_s(2))

    assert_equal :idle, t.state
    t.length = MESSAGE.length
    t.read_checksum
    checksum(MESSAGE).each_char { |bit| t.recv_bit(bit) }
    MESSAGE.each_char { |bit| t.recv_bit(bit) }
    assert_equal :idle, t.state
  end
end
