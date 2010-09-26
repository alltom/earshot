WIDTH, HEIGHT = 900, 600
MIN_SPEED, MAX_SPEED = 5, 20

class Transceiver
  attr_accessor :airspace
  attr_accessor :outgoing_broadcast
  attr_accessor :range_oval
  attr_accessor :progress_oval
  
  def initialize(loc, airspace)
    @old_loc = loc
    @new_loc = nil    # the agent's new destination
    @speed = nil      # the agent's speed
    @move_start = nil # the time at which the agent started moving
    @airspace = airspace
    @stored_messages = []
  end

  def loc
    if @new_loc.nil?
      # self isn't moving
      return @old_loc
    end

    time_to_dest = @old_loc.dist(@new_loc)/@speed
    time_since_move = $shreduler.now - @move_start

    if time_since_move > time_to_dest
      # self already arrived
      @old_loc = @new_loc
      @new_loc = nil
      @speed = nil
      @move_start = nil
      return @old_loc
    end

    # self is moving, so calculate its position
    xv = (@new_loc.x - @old_loc.x)/time_to_dest
    yv = (@new_loc.y - @old_loc.y)/time_to_dest
    cur_x = @old_loc.x + xv*time_since_move
    cur_y = @old_loc.y + yv*time_since_move
    cur_loc = Loc.new(cur_x, cur_y)
    return cur_loc
  end

  def move(new_loc, speed)
    # just in case this agent was already moving, update @old_loc
    @old_loc = loc 

    @new_loc = new_loc
    @speed = speed
    @move_start = $shreduler.now
  end
  
  def broadcast_message(message)
    if @outgoing_broadcast.nil?
      broadcast = Broadcast.new(self, loc, TRANSMISSION_RADIUS, message)
      @airspace.send_broadcast(broadcast)
      @outgoing_broadcast = broadcast
    else
      LOG.error "#{self} cannot broadcast more than one message at once!"
    end
  end
  
  def start
    # every so often, broadcast stored messages
    spork_loop do
      Shred.yield(rand * 10)
      
      if @outgoing_broadcast.nil? && @stored_messages.length > 0
        broadcast = broadcast_message(@stored_messages[rand @stored_messages.length])
        Shred.yield(SECONDS_PER_BIT * broadcast.message.length)
      end
    end

    # every so often, start moving towards some random destination
    spork_loop do
      Shred.yield(rand * 20)

      new_loc = Loc.new((rand * WIDTH).to_i, (rand * HEIGHT).to_i) 
      speed = rand*(MAX_SPEED-MIN_SPEED) + MIN_SPEED
      move(new_loc, speed)
      LOG.info "#{self} started moving to #{new_loc} with speed #{speed}"
    end
  end
  
  def transmission_finished(broadcast)
    LOG.error "ERROR: finished transmitting something #{self} wasn't transmitting: #{broadcast}" if @outgoing_broadcast != broadcast
    @outgoing_broadcast = nil
  end
  
  def received_broadcast(broadcast)
    LOG.info "#{self} received #{broadcast}"
    @stored_messages << broadcast.message unless @stored_messages.include? broadcast.message
  end
  
  def broadcasting?
    !@outgoing_broadcast.nil?
  end
  
  def to_s
    "<Transceiver:#{loc}>"
  end
end

class ChattyTransceiver < Transceiver
  def start
    super
    
    # send one original message in the first few seconds
    spork do
      Shred.yield(rand * 3)
      
      if @outgoing_broadcast.nil?
        broadcast = broadcast_message(MESSAGES[rand MESSAGES.length])
        Shred.yield(SECONDS_PER_BIT * broadcast.message.length)
      end
    end
  end
end
