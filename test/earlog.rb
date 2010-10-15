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
    $shreduler = Shreduler.new
  end

  def test_born
    @earlog.born(@agent)
    assert_equal "#{NOW}\tborn\t#{AGENT_UID}\t#{LOC_X}\t#{LOC_Y}", @log.contents
  end

end
