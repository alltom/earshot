
class Airspace
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
    spork_loop(SECONDS_PER_BIT) do
      # all_receivers = @broadcast.inject([]) { |a, b| a |= b.receivers }
      # ensure that no transceiver is receiving two broadcasts at once
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
      
      @broadcasts.each do |broadcast|
        broadcast.bits_left -= 1
        broadcast.sender.progress_oval.width = broadcast.progress * TRANSMISSION_RADIUS * 2
        if broadcast.bits_left == 0
          LOG.info "#{broadcast} from #{broadcast.sender} done"
          broadcast.sender.progress_oval.width = 2
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
