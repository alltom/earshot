require 'test/unit'
require './agent'


# Mock classes
TRANSMITTER_UID = '10010101010'
OTHER_UID = '11110101010'

class UIDGenerator
  def initialize(prefix)
  end

  def next
    TRANSMITTER_UID
  end
end

NOW = 8736
class Shreduler
  def now() NOW end

  def shredule(shred)
  end
end

class Message
  attr_reader :target_uid
  def initialize(target_uid)
    @target_uid = target_uid
  end

  def to_bits
    MESSAGE
  end
  
  def self.setup_mock_from_bits(target_uid)
    @@target_uid = target_uid
  end

  def self.from_bits(bits)
    Message.new(@@target_uid)
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

class EARLOG
  @@messages_received = 0

  def self.messages_received
    @@messages_received
  end

  def self.recv(agent, message)
    @@messages_received += 1
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
    m = Message.new(TRANSMITTER_UID)
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
    Message::setup_mock_from_bits(TRANSMITTER_UID)
    len_bits = sprintf("%0#{NUM_LENGTH_BITS}d", MESSAGE.length.to_s(2))

    assert_equal :idle, t.state
    t.length = MESSAGE.length
    t.read_checksum
    checksum(MESSAGE).each_char { |bit| t.recv_bit(bit) }
    MESSAGE.each_char { |bit| t.recv_bit(bit) }
    assert_equal :idle, t.state
  end

  def test_store_message_by_target
    t = Transmitter.new(loc=nil, airspace=nil)
    Message::setup_mock_from_bits(TRANSMITTER_UID)

    n = EARLOG::messages_received
    t.store_message(MESSAGE)
    assert_equal n+1, EARLOG::messages_received
  end

  def test_store_message_by_relayer
    t = Transmitter.new(loc=nil, airspace=nil)
    Message::setup_mock_from_bits(OTHER_UID)

    n = EARLOG::messages_received
    t.store_message(MESSAGE)
    assert_equal n, EARLOG::messages_received
  end
end
