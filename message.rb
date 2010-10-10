NUM_UID_BITS = 128
NUM_UID_BITS = 12

class Message
  attr_reader :uid
  attr_reader :sender_uid
  attr_reader :target_uid
  attr_reader :text
  
  def self.uid
    (@uuid_generator ||= UIDGenerator.new("AGENT")).next
  end
  
  def initialize sender_uid, target_uid, text, uid=nil
    @sender_uid = sender_uid
    @target_uid = target_uid
    @text = text
    @uid = uid
    @uid ||= Message.uid
  end
  
  def length
    @text.length
  end
  
  def to_s
    "<Message:#{@uid}, #{@sender_uid} => #{@target_uid}, #{@text}"
  end

  def to_bits
    start = START
    len = sprintf("%0#{NUM_LENGTH_BITS}d", length.to_s(2)[0..NUM_LENGTH_BITS])
    body = @sender_uid + @target_uid + @uid + @text
    csum = checksum(body)

    start + len + csum + body
  end

  def self.from_bits(bits)
    sender_uid = bits[0...NUM_UID_BITS]
    target_uid = bits[NUM_UID_BITS...NUM_UID_BITS*2]
    message_uid = bits[NUM_UID_BITS*2...NUM_UID_BITS*3]
    body = bits[NUM_UID_BITS*3...bits.length]

    Message.new(sender_uid, target_uid, body, message_uid)
  end
end
