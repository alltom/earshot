require "rubygems"
require "test/unit"
# require "mocha"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require "earshot"

# logging

LOG = Logger.new(@log_stringio = StringIO.new("", "w"))

def log_string
  @log_stringio.string
end
