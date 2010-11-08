
# put lib/ and test/ at front of include path
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require "rubygems"
require "test/unit"
require "earshot"

# config
def default_config
  require File.join(File.dirname(__FILE__), "..", "config", "test")
end

# logging
LOG = Logger.new(@log_stringio = StringIO.new("", "w"))
def log_string
  @log_stringio.string
end
