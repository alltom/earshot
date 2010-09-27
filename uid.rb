
class UIDGenerator
  def initialize(prefix = "")
    @prefix = prefix
    @next = 1
  end
  
  def next
    id = "#{@prefix}-#{@next}"
    @next += 1
    id
  end
end
