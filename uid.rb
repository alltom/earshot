
class UIDGenerator
  def initialize(prefix = "")
    @prefix = prefix
    @next = 1
  end
  
  def next
    (0...NUM_UID_BITS).map { |i| rand.round.to_s }.join('')
  end
end
