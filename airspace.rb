class Airspace
  attr_reader :broadcasts

  def initialize
    @broadcasts = []
    @receivers = []
    @successful_receipt = {}
  end
  
  def <<(receiver)
    @receivers << receiver
  end
  
  def send_broadcast(broadcast)
    @broadcasts << broadcast
    broadcast.receivers = @receivers.select { |r| r.loc.dist(broadcast.loc) <= broadcast.range } - [broadcast.sender]
    LOG.info "#{broadcast} from #{broadcast.sender} start (#{broadcast.receivers.length} receivers)"
  end
  
  def start
    spork_loop(CONFIG[:seconds_per_bit]) do
      # ensure that no agent is receiving two broadcasts at once
      all_receivers = []
      collision_receivers = []
      @broadcasts.each do |broadcast|
        broadcast.receivers.each do |receiver|
          collision_receivers << receiver if all_receivers.include?(receiver) || receiver.broadcasting?
        end
        all_receivers += broadcast.receivers
      end

      collision_receivers.each do |r|
        @broadcasts.each do |b|
          b.failed_receivers << r
          b.receivers -= [r]
          LOG.info "Broadcast #{b} to #{r} failed due to collision"
        end
      end
      
      # cull any broadcast receivers who are no longer in range
      @broadcasts.each do |b|
        goners = b.receivers.select { |r| r.loc.dist(b.loc) > b.range }
        next if goners.empty?
        b.failed_receivers += goners
        b.receivers -= [goners]
        goners.each { |g| LOG.info "Broadcast #{b} to #{g} failed due to range" }
      end

      @broadcasts.each do |broadcast|
        broadcast.bits_left -= 1
        if broadcast.bits_left == 0
          LOG.info "#{broadcast} from #{broadcast.sender} done"
          broadcast.receivers.each do |receiver|
            receiver.received_broadcast(broadcast)
          end
          broadcast.sender.transmission_finished(broadcast)
        end
      end
      
      @broadcasts.delete_if { |b| b.bits_left == 0 }
    end
  end
end
