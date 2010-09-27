
QT_FULL_CIRCLE = 360 * 16  # Qt measures angles in 1/16ths of a degree

class Animator < Qt::Widget
  attr_accessor :sim
  slots 'advance_sim()'

  def initialize
    super
    resize(WIDTH, HEIGHT)

    # schedule regular breaks from the GUI to run the shreduler
    shreduler_breaks = Qt::Timer.new
    Qt::Object.connect(shreduler_breaks, SIGNAL(:timeout), self, SLOT(:advance_sim)) 
    shreduler_breaks.start(1000.0/60)
  end

  def mouseReleaseEvent(mouse_event)
    loc = Loc.new(mouse_event.x, mouse_event.y)
    @sim.add_transceiver(loc)
  end

  def advance_sim
    return if @sim.nil?
    @sim.advance
    repaint
  end

  def paintEvent(event)
    return if @sim.nil?

    p = Qt::Painter.new(self)
    @sim.transceivers.each do |t|
      loc = t.loc

      # visualize transceiver's transmissions and range
      r = TRANSMISSION_RADIUS 
      if t.broadcasting?
        color = Qt::Color.new(100, 0, 0, 50)
      else
        color = Qt::Color.new(50, 50, 50, 25)
      end
      p.setPen(Qt::Color.new(130, 130, 130, 255))
      p.setBrush(Qt::Brush.new(color))
      p.drawEllipse(Qt::Rect.new(loc.x-r, loc.y-r, r*2, r*2))

      # visualize transceiver
      r = TRANSCEIVER_RADIUS
      color = Qt::blue
      p.setPen(Qt::NoPen)
      p.setBrush(Qt::Brush.new(color))
      p.drawEllipse(Qt::Rect.new(loc.x-r, loc.y-r, r*2, r*2))

      # visualize broadcast progress
      if t.broadcasting?
	r = TRANSMISSION_RADIUS 
	angle = t.outgoing_broadcast.progress * QT_FULL_CIRCLE
	pen = Qt::Pen.new(Qt::Color.new(0, 130, 0, 255))
	pen.setWidth(4)
	p.setPen(pen)
	p.drawArc(Qt::Rect.new(loc.x-r, loc.y-r, r*2, r*2), 0, angle)
      end
    end
    p.end
  end
end
