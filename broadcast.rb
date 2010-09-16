
class Broadcast
  attr_accessor :loc
  attr_accessor :range
  attr_accessor :message
  attr_accessor :bits_left
  attr_accessor :sender
  attr_accessor :receivers
  attr_accessor :failed_receivers
  
  def initialize sender, loc, range, message
    @sender = sender
    @loc = loc
    @range = range
    @message = message
    @bits_left = message.length
    @recievers = []
    @failed_receivers = []
  end
  
  def to_s
    "<Broadcast:#{message}>"
  end
  
  def progress
    (message.length - bits_left) / message.length.to_f
  end
end
