class Array
  def mean
    sum = self.inject{|sum, x| sum + x}
    1.0*sum/self.length
  end
end

class Analyzer
  class Agent
    attr_reader :birthday
    attr_reader :distance_traveled
    attr_accessor :messages_sent
    attr_accessor :messages_received
    attr_accessor :loc
    
    def initialize(birthday, loc)
      @birthday = birthday
      @loc = loc
      @distance_traveled = 0.0
      @messages_sent = 0
      @messages_received = 0
    end
  end

  class Message
    def initialize(birthday)
      @bday = birthday
      @dday = nil
    end

    def deliver(time)
      @dday = time
    end

    def delivered?
      !@dday.nil?
    end

    def time_to_deliver
      @dday - @bday
    end
  end

  attr_reader :messages_sent
  attr_reader :messages_delivered
  attr_reader :avg_delivery_time
  attr_reader :collisions
  attr_reader :relays
  attr_reader :num_agents

  def initialize
    @agents = {} # a mapping from UID => Analyzer::Agent instance
    @messages = {} # a mapping from UID => Analyzer::Message instance

    # interesting statistics
    @time_elapsed = 0.0
    @messages_sent = 0
    @messages_delivered = 0
    @avg_delivery_time = nil
    @collisions = 0
    @relays = 0
    @num_agents = 0
  end

  # puts is defined so EarLog can output to an Analyzer as well as a file
  def puts(entry)
    time, type, *type_args = entry.split(/\t/)
    time = Float time

    case type
    when "born"
      uid, x, y = type_args
      @agents[uid] = Analyzer::Agent.new(time, Loc.new(x, y))
      @num_agents += 1
    when "xmit"
      sender_uid, target_uid, message_uid, message_length = type_args
      @messages[message_uid] = Analyzer::Message.new(time)
      @agents[sender_uid].messages_sent += 1
      @messages_sent += 1
    when "recv"
      agent_uid, message_uid = type_args
      unless @messages[message_uid].delivered?
        @messages[message_uid].deliver(time)
        @messages_delivered += 1
        
        # update the average delivery time statistic
        dlv_msgs = @messages.find_all {|k,v| v.delivered?}
        @avg_delivery_time = (dlv_msgs.map {|k,v| v.time_to_deliver}).mean
      end
    when "move"
      agent_uid, cur_x, cur_y, new_x, new_y, speed = type_args
    when "bump"
      @collisions += 1
    when "relay"
      relay_uid, message_uid = type_args
      @relays += 1
    end

    @time_elapsed = time
  end
end
