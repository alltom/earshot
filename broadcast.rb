
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
    @cur_bit = 0
    @recievers = []
    @failed_receivers = []
  end

  def next_bit
    b = @message.text[@cur_bit]
    @cur_bit += 1
    @bits_left -= 1
    b
  end
  
  def to_s
    "<Broadcast:#{message}>"
  end
  
  def progress
    (message.length - bits_left) / message.length.to_f
  end
end
