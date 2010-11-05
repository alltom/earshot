class Airspace
  def initialize
    @receivers = []
    @collision_agents = []
  end

  def collisions
    # collision_agents hold a superset of the agents involved in collisions. if
    # any of them had a collision on the last transmission of a bit, they would
    # still be in that list after finishing transmission, so here we filter out
    # any of those ones who have finished.

    @collision_agents.select { |a| a.broadcasting? }
  end
  
  def <<(receiver)
    @receivers << receiver
  end

  def send_bit(sender, radius, bit)
    receivers = @receivers.select { |r| r.loc.dist(sender.loc) <= radius } - [sender]
    collision = false
    receivers.each do |r|
      if r.broadcasting?
        collision = true 
        @collision_agents << r unless @collision_agents.member? r
      end
      r.recv_bit(bit)
    end

    # if this send caused a collision, flag this sender as a collision, but if
    # there was no collision, then clear the sender's collision status
    if collision
      EARLOG::bump # NOTE: this counts collisions in terms of bits!
      @collision_agents << sender unless @collision_agents.member? sender
    else
      @collision_agents -= [sender]
    end
  end
end
