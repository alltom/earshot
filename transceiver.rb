
class Transceiver
  attr_accessor :loc
  attr_accessor :airspace
  attr_accessor :outgoing_broadcast
  attr_accessor :range_oval
  attr_accessor :progress_oval
  
  def initialize(loc, airspace)
    @loc = loc
    @airspace = airspace
    @stored_messages = []
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
