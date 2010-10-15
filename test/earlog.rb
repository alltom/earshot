require 'test/unit'
require './earlog'


# Mock classes

class Logfile
  attr_reader :contents
  def initialize
    @contents = ''
  end

  def puts(string)
    @contents = string
  end
end

LOC_X, LOC_Y = 15, 27
class Loc
  def x() LOC_X end
  def y() LOC_Y end
end

AGENT_UID = '1234'
class Agent
  def loc() Loc.new end
  def uid() AGENT_UID end
end

MESSAGE_UID = '9076'
MESSAGE_LENGTH = 27
class Message
  def uid() MESSAGE_UID end
  def length() MESSAGE_LENGTH end
end

NOW = 8736
class Shreduler
  def now() NOW end
end

class Tester < Test::Unit::TestCase
  def setup
    @log = Logfile.new
    @earlog = EarLog.new(@log)
    @agent = Agent.new
    @message = Message.new
    $shreduler = Shreduler.new
  end

  def test_born
    @earlog.born(@agent)
    assert_equal "#{NOW}\tborn\t#{AGENT_UID}\t#{LOC_X}\t#{LOC_Y}", @log.contents
  end

  def test_xmit
    dest_uid = '408971692'
    @earlog.xmit(@agent, dest_uid, @message)
    assert_equal "#{NOW}\txmit\t#{AGENT_UID}\t#{dest_uid}\t#{MESSAGE_UID}\t#{MESSAGE_LENGTH}", @log.contents
  end

  def test_recv
    @earlog.recv(@agent, @message)
    assert_equal "#{NOW}\trecv\t#{AGENT_UID}\t#{MESSAGE_UID}", @log.contents
  end

  def test_move
    new_x, new_y, speed = 1, 2, 3
    @earlog.move(@agent, new_x, new_y, speed)
    assert_equal "#{NOW}\tmove\t#{AGENT_UID}\t#{LOC_X}\t#{LOC_Y}\t#{new_x}\t#{new_y}\t#{speed}", @log.contents
  end

  def test_bump
    @earlog.bump
    assert_equal "#{NOW}\tbump", @log.contents
  end

  def test_relay
    @earlog.relay(@agent, @message)
    assert_equal "#{NOW}\trelay\t#{AGENT_UID}\t#{MESSAGE_UID}", @log.contents
  end
end
