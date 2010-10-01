class EarLog
  def initialize(outfile)
    @outfile = outfile
  end

  def xmit(relay, dest, message)
    @outfile.puts "#{$shreduler.now}\t#{relay.uid}\txmit\t#{dest.uid}\t#{message.uid}\t#{message.length}"
  end

  def recv(agent, message)
    @outfile.puts "#{$shreduler.now}\t#{agent.uid}\trecv\t#{message.uid}"
  end

  def move(agent, xo, yo, speed)
    @outfile.puts "#{$shreduler.now}\t#{agent.uid}\tmove\t#{xo}\t#{yo}\t#{speed}"
  end
end
