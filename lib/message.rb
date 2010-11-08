
class Message
  class InvalidUidException < Exception
  end

  attr_reader :uid
  attr_reader :sender_uid
  attr_reader :target_uid
  attr_reader :text
  
  def self.uid
    (@uuid_generator ||= UID::Generator.new("AGENT")).next
  end
  
  def initialize sender_uid, target_uid, text, uid=nil
    raise InvalidUidException unless UID::valid? sender_uid
    raise InvalidUidException unless UID::valid? target_uid
    unless uid.nil?
      raise InvalidUidException unless UID::valid? uid
    end

    @sender_uid = sender_uid
    @target_uid = target_uid
    @text = text
    @text_binary = Binary::string2binary(@text)
    @uid = uid
    @uid ||= Message.uid
  end
  
  def length
    @text_binary.length
  end
  
  def to_s
    "<Message:#{@uid}, #{@sender_uid} => #{@target_uid}, #{@text}"
  end

  def to_bits
    @sender_uid + @target_uid + @uid + @text_binary
  end

  def self.from_bits(bits)
    sender_uid = bits[0...NUM_UID_BITS]
    target_uid = bits[NUM_UID_BITS...NUM_UID_BITS*2]
    message_uid = bits[NUM_UID_BITS*2...NUM_UID_BITS*3]
    body = bits[NUM_UID_BITS*3...bits.length]

    text = Binary::binary2string(body)

    Message.new(sender_uid, target_uid, text, message_uid)
  end

  def ==(other)
    @uid == other.uid and 
    @sender_uid == other.sender_uid and 
    @target_uid == other.target_uid and 
    @text == other.text
  end
end
