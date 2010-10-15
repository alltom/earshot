require 'test/unit'
require './message'


# Mock classes
UID = '123123'
SENDER_UID = '087126'
TARGET_UID = '761923'
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
    m = Message.new(SENDER_UID, TARGET_UID, TEXT)
  end
end
