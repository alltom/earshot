
require "helper"

require "ruck"

require File.join(File.dirname(__FILE__), "..", "lib", "uid")
require File.join(File.dirname(__FILE__), "..", "lib", "loc")
require File.join(File.dirname(__FILE__), "..", "lib", "agent")
require File.join(File.dirname(__FILE__), "..", "lib", "message")
require File.join(File.dirname(__FILE__), "..", "lib", "airspace")
require File.join(File.dirname(__FILE__), "..", "lib", "analyzer")
require File.join(File.dirname(__FILE__), "..", "lib", "earlog")

CONFIG = {}
CONFIG[:transmission_radius_m] = 50
CONFIG[:seconds_per_bit] = 0.001

shreduler = Ruck::Shreduler.new
shreduler.make_convenient

ANALYZER = Analyzer.new
EARLOG = EarLog.new(ANALYZER)


airspace = Airspace.new
t1 = Transmitter.new(Loc.new(0,0), airspace)
t2 = Transmitter.new(Loc.new(0,0), airspace)
airspace << t1
airspace << t2

m = Message.new(t1.uid, t2.uid, '0111')

bits = m.to_bits
bits = bits[NUM_START_BITS+NUM_LENGTH_BITS+NUM_CHECKSUM_BITS...bits.length]
puts m.length
puts bits.length
m2 = Message::from_bits(bits)
puts m.uid
puts m2.uid

t1.broadcast_message(m)

shreduler.run
