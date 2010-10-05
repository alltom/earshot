class EarLog
  def initialize(outfile)
    @outfile = outfile
  end

  def born(agent)
    l = agent.loc
    @outfile.puts "#{$shreduler.now}\tborn\t#{agent.uid}\t#{l.x}\t#{l.y}"
  end

  def xmit(sender, dest_uid, message)
    @outfile.puts "#{$shreduler.now}\txmit\t#{sender.uid}\t#{dest_uid}\t#{message.uid}\t#{message.length}"
  end

  def recv(agent, message)
    @outfile.puts "#{$shreduler.now}\trecv\t#{agent.uid}\t#{message.uid}"
  end

  def move(agent, new_x, new_y, speed)
    l = agent.loc
    @outfile.puts "#{$shreduler.now}\tmove\t#{agent.uid}\t#{l.x}\t#{l.y}\t#{new_x}\t#{new_y}\t#{speed}"
  end

  def bump()
    @outfile.puts "#{$shreduler.now}\tbump"
  end

  def relay(relay, message)
    @outfile.puts "#{$shreduler.now}\trelay\t#{relay.uid}\t#{message.uid}"
  end
end
