
MIN_SPEED, MAX_SPEED = 5, 20

class Agent
  attr_accessor :airspace
  attr_accessor :outgoing_broadcast
  attr_accessor :range_oval
  attr_accessor :progress_oval
  attr_reader   :uid
  
  def self.uid
    (@uuid_generator ||= UIDGenerator.new("AGENT")).next
  end
  
  def initialize(loc, airspace)
    @uid = Agent.uid
    @old_loc = loc
    @new_loc = nil    # the agent's new destination
    @speed = nil      # the agent's speed
    @move_start = nil # the time at which the agent started moving
    @airspace = airspace
    @stored_messages = []
    @friend_uids = []
  end

  def meet(other)
    return if @friend_uids.include? other.uid
    @friend_uids << other.uid
    LOG.info "#{self} met #{other}"
  end

  def loc
    if @new_loc.nil?
      # self isn't moving
      return @old_loc
    end

    time_to_dest = @old_loc.dist(@new_loc)/@speed
    time_since_move = $shreduler.now - @move_start

    if time_since_move > time_to_dest
      # this agent already arrived
      @old_loc = @new_loc
      @new_loc = nil
      @speed = nil
      @move_start = nil
      return @old_loc
    end

    # this agent is moving, so calculate its position
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
      broadcast = Broadcast.new(self, loc, CONFIG[:transmission_radius_m], message)
      @airspace.send_broadcast(broadcast)
      @outgoing_broadcast = broadcast
    else
      LOG.error "#{self} cannot broadcast more than one message at once!"
    end
  end
  
  def start
    # every so often, broadcast stored messages
    spork_loop do
      Ruck::Shred.yield(rand * 10)
      
      if @outgoing_broadcast.nil? && @stored_messages.length > 0
        broadcast = broadcast_message(@stored_messages[rand @stored_messages.length])
        Ruck::Shred.yield(CONFIG[:seconds_per_bit] * broadcast.message.length)
      end
    end

    # every so often, start moving towards some random destination
    spork_loop do
      Ruck::Shred.yield(rand * 20)

      new_loc = Loc.new((rand * CONFIG[:width_m]).to_i, (rand * CONFIG[:height_m]).to_i) 
      speed = rand*(MAX_SPEED-MIN_SPEED) + MIN_SPEED
      move(new_loc, speed)
      #LOG.info "#{self} started moving to #{new_loc} with speed #{speed}"
      EARLOG::move(self, new_loc.x, new_loc.y, speed)
    end
  end
  
  def transmission_finished(broadcast)
    LOG.error "ERROR: finished transmitting something #{self} wasn't transmitting: #{broadcast}" if @outgoing_broadcast != broadcast
    @outgoing_broadcast = nil
  end
  
  def received_broadcast(broadcast)
    if broadcast.message.target_uid == @uid
      LOG.info "#{self} received #{broadcast.message} addressed to it! Hooray!"
      EARLOG::recv(self, broadcast.message)
    else
      LOG.info "#{self} received #{broadcast}"
    end
      
    @stored_messages << broadcast.message unless @stored_messages.include? broadcast.message
  end
  
  def broadcasting?
    !@outgoing_broadcast.nil?
  end
  
  def to_s
    "<Agent:#{@uid} @ #{loc}>"
  end
end

class ChattyAgent < Agent
  def start
    super
    
    # send one original message in the first few seconds
    spork do
      Ruck::Shred.yield(rand * 3)
      
      if @outgoing_broadcast.nil? and !@friend_uids.empty?
        target_uid = @friend_uids[rand @friend_uids.length]
        body = CONFIG[:messages][rand CONFIG[:messages].length]
        msg = Message.new(@uid, target_uid, body)
        @stored_messages << msg
        broadcast = broadcast_message(msg)
        Ruck::Shred.yield(CONFIG[:seconds_per_bit] * broadcast.message.length)
      end
    end
  end
end
