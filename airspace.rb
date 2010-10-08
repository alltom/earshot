class Airspace
  attr_reader :broadcasts

  def initialize
    @broadcasts = []
    @receivers = []
  end
  
  def <<(receiver)
    @receivers << receiver
  end

  def send_bit(sender, radius, message)
    receivers = @receivers.select { |r| r.loc.dist(sender.loc) <= radius } - [sender]
    receivers.each { |r| r.recv_bit(message) }
  end
end
