
class Message
  attr_reader :uid
  attr_reader :text
  
  def self.uid
    (@uuid_generator ||= UIDGenerator.new("AGENT")).next
  end
  
  def initialize text
    @uid = Message.uid
    @text = text
  end
  
  def length
    @text.length
  end
  
  def to_s
    "<Message:#{@uid}, #{@text}"
  end
end
