
require "helper"

# LOC_X, LOC_Y = 15, 27
# AGENT_UID = '1234'
# MESSAGE_UID = '9076'
# MESSAGE_LENGTH = 27
# NOW = 8736
# DEST_UID = '408971692'

class TestAnalyzer < Test::Unit::TestCase
  
  def test_born
    a = Analyzer.new
    n = a.num_agents
    a.puts("#{NOW}\tborn\t#{AGENT_UID}\t#{LOC_X}\t#{LOC_Y}")
    assert_equal n+1, a.num_agents
  end

  def test_xmit
    a = Analyzer.new
    n = a.messages_sent
    a.puts("#{NOW}\tborn\t#{AGENT_UID}\t#{LOC_X}\t#{LOC_Y}")
    a.puts("#{NOW}\txmit\t#{AGENT_UID}\t#{DEST_UID}\t#{MESSAGE_UID}\t#{MESSAGE_LENGTH}")
    assert_equal n+1, a.messages_sent
  end

  def test_recv
    a = Analyzer.new
    n = a.messages_delivered
    a.puts("#{NOW}\tborn\t#{AGENT_UID}\t#{LOC_X}\t#{LOC_Y}")
    a.puts("#{NOW}\txmit\t#{AGENT_UID}\t#{DEST_UID}\t#{MESSAGE_UID}\t#{MESSAGE_LENGTH}")
    a.puts("#{NOW}\trecv\t#{AGENT_UID}\t#{MESSAGE_UID}")
    assert_equal n+1, a.messages_delivered
  end

  def test_move
    # nothing to test here
  end

  def test_bump
    a = Analyzer.new
    n = a.collisions
    a.puts("#{NOW}\tbump")
    assert_equal n+1, a.collisions
  end

  def test_relay
    a = Analyzer.new
    n = a.relays
    a.puts("#{NOW}\trelay\t#{AGENT_UID}\t#{MESSAGE_UID}")
    assert_equal n+1, a.relays
  end
end
