
module UID
  def self.valid?(uid)
    return false unless uid.length == CONFIG[:num_uid_bits]
    return false unless uid =~ /^[01]*$/

    true
  end

  class Generator
    def initialize(prefix = "")
      @prefix = prefix
      @next = 1
    end

    def next
      (1..CONFIG[:num_uid_bits]).map { |i| rand.round.to_s }.join('')
    end
  end
end
