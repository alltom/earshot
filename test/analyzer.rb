require 'test/unit'
require './analyzer'


LOC_X, LOC_Y = 15, 27
AGENT_UID = '1234'
MESSAGE_UID = '9076'
MESSAGE_LENGTH = 27
NOW = 8736

class Loc
end

class Tester < Test::Unit::TestCase
  def test_born
    a = Analyzer.new
    n = a.num_agents
    a.puts("#{NOW}\tborn\t#{AGENT_UID}\t#{LOC_X}\t#{LOC_Y}")
    assert_equal n+1, a.num_agents
  end

  def test_xmit
    a = Analyzer.new
    n = a.messages_sent
    dest_uid = '408971692'
    a.puts("#{NOW}\tborn\t#{AGENT_UID}\t#{LOC_X}\t#{LOC_Y}")
    a.puts("#{NOW}\txmit\t#{AGENT_UID}\t#{dest_uid}\t#{MESSAGE_UID}\t#{MESSAGE_LENGTH}")
    assert_equal n+1, a.messages_sent
  end

  def test_recv
    assert false
  end

  def test_move
    assert false
  end

  def test_bump
    assert false
  end

  def test_relay
    assert false
  end
end
