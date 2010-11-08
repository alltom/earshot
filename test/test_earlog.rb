
require "helper"

# LOC_X, LOC_Y = 15, 27
# AGENT_UID = '1234'
# MESSAGE_UID = '9076'
# MESSAGE_LENGTH = 27
# NOW = 8736

class TestEarLog < Test::Unit::TestCase
  def setup
    @log = StringIO.new("", "w")
    @earlog = EarLog.new(@log)
    @airspace = Airspace.new
    @agent1 = Agent.new(Loc.new(1, 2), @airspace)
    @agent2 = Agent.new(Loc.new(3, 4), @airspace)
    @message = Message.new(@agent1.uid, @agent2.uid, "great text")
    Ruck::Shreduler.new.make_convenient
  end

  def test_born
    @earlog.born(@agent1)
    assert_equal "#{$shreduler.now}\tborn\t#{@agent1.uid}\t#{@agent1.loc.x}\t#{@agent1.loc.y}\n", @log.string
  end

  def test_xmit
    dest_uid = '408971692'
    @earlog.xmit(@agent1, dest_uid, @message)
    assert_equal "#{$shreduler.now}\txmit\t#{@agent1.uid}\t#{dest_uid}\t#{@message.uid}\t#{@message.length}\n", @log.string
  end

  def test_recv
    @earlog.recv(@agent1, @message)
    assert_equal "#{$shreduler.now}\trecv\t#{@agent1.uid}\t#{@message.uid}\n", @log.string
  end

  def test_move
    new_x, new_y, speed = 1, 2, 3
    @earlog.move(@agent1, new_x, new_y, speed)
    assert_equal "#{$shreduler.now}\tmove\t#{@agent1.uid}\t#{@agent1.loc.x}\t#{@agent1.loc.x}\t#{new_x}\t#{new_y}\t#{speed}\n", @log.string
  end

  def test_bump
    @earlog.bump
    assert_equal "#{$shreduler.now}\tbump\n", @log.string
  end

  def test_relay
    @earlog.relay(@agent1, @message)
    assert_equal "#{$shreduler.now}\trelay\t#{@agent1.uid}\t#{@message.uid}\n", @log.string
  end
end
