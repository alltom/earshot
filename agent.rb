# Protocol-related constants
START = '10101010'
NUM_START_BITS = 8
NUM_LENGTH_BITS = 16
NUM_CHECKSUM_BITS = 16
SAFETY_FACTOR = 2 # this controls how long an agent waits after receiving a bit from someone else before starting a broadcast

def checksum(message)
  # TODO: implement a better checksum algorithm. maybe http://en.wikipedia.org/wiki/Pearson_hashing
  num_ones = message.count('1')
  sprintf("%0#{NUM_CHECKSUM_BITS}d", num_ones.to_s(2)[0...NUM_CHECKSUM_BITS])
end

  
# This class models a device that communicates using the networking protocol.
# The protocol is big-endian (MSB first)

class Transmitter
  attr_accessor :airspace
  attr_reader   :loc
  attr_reader   :state
  attr_reader   :uid
  
  def self.uid
    (@uuid_generator ||= UIDGenerator.new("AGENT")).next
  end
 
  def initialize(loc, airspace)
    @loc = loc
    @airspace = airspace
    @uid = Agent.uid
    @last_receive_time = -1.0/0.0
    @stored_messages = []

    @xmit_shred = nil

    @state = nil
    @i = 0
    @bits = nil
    idle
  end

  # State-change functions
  def idle
    @state = :idle
    @i = 0
  end

  def read_length
    @state = :reading_length
    @i = 0
    @bits = ' ' * NUM_LENGTH_BITS
  end

  def read_checksum
    @state = :reading_checksum
    @i = 0
    @bits = ' ' * NUM_CHECKSUM_BITS
  end

  def read_message
    @state = :reading_message
    @i = 0
    @bits = ' ' * @length
  end

  def store_message(bits)
    message = Message::from_bits(bits)
    if message.target_uid == self.uid
      EARLOG::recv(self, message) unless @stored_messages.member? message
    else
      puts 'got a message for someone else'
      puts "me: #{@uid}\ntarget: #{message.target_uid}"
    end
  end

  def recv_bit(bit)
    @last_receive_time = $shreduler.now

    unless ['0', '1'].member?(bit)
      LOG.error "#{self} received an invalid bit: #{bit}"
      return
    end

    idle if recv_timeout?

    case @state
    when :idle
      if bit != START[@i]
        # There's been a deviation from the protocol, so start over
        puts 'argh'
        idle
      else
        @i += 1
        read_length if @i == NUM_START_BITS
      end
    when :reading_length
      @bits[@i] = bit
      @i += 1
      if @i == NUM_LENGTH_BITS
        @length = @bits.to_i(2)
        read_checksum
      end
    when :reading_checksum
      @bits[@i] = bit
      @i += 1
      if @i == NUM_CHECKSUM_BITS
        @checksum = @bits
        read_message
      end
    when :reading_message
      @bits[@i] = bit
      @i += 1
      if @i == @length
        if @checksum == checksum(@bits)
          store_message(@bits)
        else
          puts "checksum failed #{@checksum} != #{checksum(@bits)}"
          # the message was corrupted somehow
        end
        
        idle
      end
    when :sending
      #puts 'collision'
    else
    end
  end

  def send_bit(bit)
    @airspace.send_bit(self, CONFIG[:transmission_radius_m], bit)
  end

  def broadcast_message(message)
    @state = :sending

    # marshall message into a bit string:
    mbits = message.to_bits
    @bits = START + sprintf("%0#{NUM_LENGTH_BITS}d", mbits.length.to_s(2)) + checksum(mbits) + mbits
    @i = 0

    @xmit_shred = Ruck::Shred.new do 
      loop do
        send_bit(@bits[@i])
        @i += 1
        if @i == @bits.length
          transmission_finished
          break
        end
        Ruck::Shred.yield(CONFIG[:seconds_per_bit])
      end
    end
    $shreduler.shredule(@xmit_shred)
  end

  def transmission_finished
    @xmit_shred.kill unless @xmit_shred.nil?
    idle
  end
  
  def broadcasting?
    @state == :sending
  end

  def broadcast_progress
    return 0 unless broadcasting?

    1.0 * @i / @bits.length
  end

  def air_clear?
    ($shreduler.now - @last_receive_time) > CONFIG[:seconds_per_bit]*SAFETY_FACTOR
  end

  def recv_timeout?
    ($shreduler.now - @last_receive_time) > CONFIG[:seconds_per_bit]*SAFETY_FACTOR
  end
end


# This class models an Agent that can meet and communicate with other Agents.

class Agent < Transmitter
 
  def initialize(loc, airspace)
    super(loc, airspace)
    @friend_uids = []
  end

  def meet(other)
    return if @friend_uids.include? other.uid
    @friend_uids << other.uid
    LOG.info "#{self} met #{other}"
  end
  
  def start
    # every so often, broadcast stored messages
    spork_loop do
      Ruck::Shred.yield(rand * 10)
      
      if !broadcasting? && @stored_messages.length > 0 && air_clear?
        msg = @stored_messages[rand @stored_messages.length]
        broadcast_message(msg)
        EARLOG::relay(self, msg)
      end
    end

    # every so less often, broadcast a novel message
    spork_loop do
      Ruck::Shred.yield(rand * 50)
      if !broadcasting? and !@friend_uids.empty? && air_clear?
        target_uid = @friend_uids[rand @friend_uids.length]
        body = CONFIG[:messages][rand CONFIG[:messages].length]
        msg = Message.new(@uid, target_uid, body)
        @stored_messages << msg
        EARLOG::xmit(self, target_uid, msg)
        broadcast_message(msg)
      end
    end
  end
  
  def to_s
    "<Agent:#{@uid} @ #{loc}>"
  end
end


class MovingAgent < Agent
  def initialize(loc, airspace)
    super(loc, airspace)
    @old_loc = loc
    @new_loc = nil    # the agent's new destination
    @speed = nil      # the agent's speed
    @move_start = nil # the time at which the agent started moving
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

  def start
    super

    # every so often, start moving towards some random destination
    spork_loop do
      Ruck::Shred.yield(rand * 20)

      new_loc = Loc.new((rand * CONFIG[:width_m]).to_i, (rand * CONFIG[:height_m]).to_i) 
      speed = CONFIG[:speed_mps]
      move(new_loc, speed)
      #LOG.info "#{self} started moving to #{new_loc} with speed #{speed}"
      EARLOG::move(self, new_loc.x, new_loc.y, speed)
    end
  end
end
