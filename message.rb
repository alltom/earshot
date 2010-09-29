
class Message
  attr_reader :uid
  attr_reader :sender_uid
  attr_reader :target_uid
  attr_reader :text
  
  def self.uid
    (@uuid_generator ||= UIDGenerator.new("AGENT")).next
  end
  
  def initialize sender_uid, target_uid, text
    @uid = Message.uid
    @sender_uid = sender_uid
    @target_uid = target_uid
    @text = text
  end
  
  def length
    @text.length
  end
  
  def to_s
    "<Message:#{@uid}, #{@sender_uid} => #{@target_uid}, #{@text}"
  end
end
