require 'test/unit'
require './message'


# Mock classes
UID = '123123'
TEXT = 'hi there'

class UIDGenerator
  def initialize(prefix)
  end

  def next
    UID
  end
end


class Tester < Test::Unit::TestCase
  def test_init
    assert_nothing_thrown do
      sender_uid = '1'*128
      target_uid = '0'*128
      m = Message.new(sender_uid, target_uid, TEXT)
    end

    assert_raise Message::InvalidUidException do
      sender_uid = '1'
      target_uid = '0'*128
      m = Message.new(sender_uid, target_uid, TEXT)
    end
  end

  def test_length
    sender_uid = '1'*128
    target_uid = '0'*128
    m = Message.new(sender_uid, target_uid, TEXT)
    assert_equal string2binary(TEXT).length, m.length
  end

  def test_equals
    sender_uid = '1'*128
    target_uid = '0'*128
    m = Message.new(sender_uid, target_uid, TEXT)
    assert m == m
  end

  def test_to_bits
    sender_uid = '1'*128
    target_uid = '0'*128
    message_uid = '10'*(128/2)
    m = Message.new(sender_uid, target_uid, TEXT, message_uid)
    m2 = Message.from_bits(m.to_bits)

    assert m == m2
  end
end
