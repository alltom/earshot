
require "helper"

CONFIG[:seconds_per_bit] = 0.1

class TestAgent < Test::Unit::TestCase
  def setup
    Ruck::Shreduler.new.make_convenient
    
    @airspace = Airspace.new
    @t1 = Transmitter.new(Loc.new(1, 2), @airspace)
    @t2 = Transmitter.new(Loc.new(3, 4), @airspace)
    @t3 = Transmitter.new(Loc.new(5, 6), @airspace)
    @message = Message.new(@t1.uid, @t2.uid, "crazy great text")
  end

  def test_init
    t = Transmitter.new(loc=nil, airspace=nil)
    assert_equal :idle, t.state
  end

  def test_broadcast_message
    @t1.broadcast_message(@message)

    len_bits = sprintf("%0#{NUM_LENGTH_BITS}d", @message.to_bits.length.to_s(2))
    bits = START + len_bits + checksum(@message.to_bits) + @message.to_bits
    assert_equal bits, @t1.bits_transmitting
  end

  def test_receive_start_flag
    t = Transmitter.new(loc=nil, airspace=nil)

    assert_equal :idle, t.state
    START.each_char { |bit| t.recv_bit(bit) }
    assert_equal :reading_length, t.state
  end

  def test_receive_length
    t = Transmitter.new(loc=nil, airspace=nil)
    len_bits = sprintf("%0#{NUM_LENGTH_BITS}d", @message.length.to_s(2))
  
    assert_equal :idle, t.state
    t.read_length
    len_bits.each_char { |bit| t.recv_bit(bit) }
    assert_equal :reading_checksum, t.state
    assert_equal @message.length, t.length
  end

  def test_receive_checksum
    t = Transmitter.new(loc=nil, airspace=nil)
  
    assert_equal :idle, t.state
    t.length = @message.length
    t.read_checksum
    checksum(MESSAGE).each_char { |bit| t.recv_bit(bit) }
    assert_equal :reading_message, t.state
  end

  def test_receive_message
    t = Transmitter.new(loc=nil, airspace=nil)
    Message::setup_mock_from_bits(TRANSMITTER_UID)
    len_bits = sprintf("%0#{NUM_LENGTH_BITS}d", @message.length.to_s(2))
  
    assert_equal :idle, t.state
    t.length = @message.length
    t.read_checksum
    checksum(@message).each_char { |bit| t.recv_bit(bit) }
    @message.each_char { |bit| t.recv_bit(bit) }
    assert_equal :idle, t.state
  end

  def test_store_message_by_target
    @message = Message.new(@t1.uid, @t3.uid, "crazy great text")
    
    n = EARLOG::messages_received
    @t2.store_message(@message.to_bits)
    assert_equal n, EARLOG::messages_received
  end

  def test_store_message_by_relayer
    @message = Message.new(@t1.uid, @t3.uid, "crazy great text")
    
    n = EARLOG::messages_received
    @t3.store_message(@message.to_bits)
    assert_equal n, EARLOG::messages_received
  end
end
