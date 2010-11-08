
require "helper"

# UID = '123123'
# TEXT = 'hi there'

class TestMessage < Test::Unit::TestCase
  def setup
    @text = "hi there"
  end
  
  def test_init
    assert_nothing_thrown do
      sender_uid = '1'*128
      target_uid = '0'*128
      
      m = Message.new(sender_uid, target_uid, @text)
    end

    assert_raise Message::InvalidUidException do
      sender_uid = '1'
      target_uid = '0'*128
      m = Message.new(sender_uid, target_uid, @text)
    end
  end

  def test_length
    sender_uid = '1'*128
    target_uid = '0'*128
    m = Message.new(sender_uid, target_uid, @text)
    assert_equal string2binary(@text).length, m.length
  end

  def test_equals
    sender_uid = '1'*128
    target_uid = '0'*128
    m = Message.new(sender_uid, target_uid, @text)
    assert m == m
  end

  def test_to_bits_and_from_bits
    sender_uid = '1'*128
    target_uid = '0'*128
    message_uid = '10'*(128/2)
    m = Message.new(sender_uid, target_uid, @text, message_uid)
    m2 = Message.from_bits(m.to_bits)

    assert m == m2
  end
end
