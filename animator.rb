
QT_FULL_CIRCLE = 360 * 16  # Qt measures angles in 1/16ths of a degree

class Animator < Qt::Widget
  attr_accessor :sim
  slots 'advance_sim()'

  def initialize
    super
    resize(CONFIG[:width], CONFIG[:height])

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
    fg = Qt::Color.new(158, 240, 216)
    range = Qt::Color.new(158, 240, 216, 60)
    bg = Qt::Color.new(40, 40, 40)
    agent = Qt::Color.new(160, 240, 234)

    return if @sim.nil?

    p = Qt::Painter.new(self)
    p.setRenderHint(Qt::Painter::Antialiasing, true);

    # fill background. there's probably a better way to do this...
    p.setBrush(Qt::Brush.new(bg))
    p.drawRect(0, 0, WIDTH, HEIGHT)

    @sim.transceivers.each do |t|
      loc = t.loc

      # visualize transceiver
      r = CONFIG[:transceiver_radius]
      color = agent
      p.setPen(Qt::NoPen)
      p.setBrush(Qt::Brush.new(color))
      p.drawEllipse(Qt::Rect.new(loc.x-r, loc.y-r, r*2, r*2))

      # visualize transceiver's range
      r = CONFIG[:transmission_radius] 
      color = range
      p.setPen(Qt::NoPen)
      p.setBrush(Qt::Brush.new(color))
      p.drawEllipse(Qt::Rect.new(loc.x-r, loc.y-r, r*2, r*2))

      # visualize broadcast progress
      if t.broadcasting?
        r = CONFIG[:transmission_radius] 
        angle = t.outgoing_broadcast.progress * QT_FULL_CIRCLE
        pen = Qt::Pen.new(fg)
        pen.setWidth(4)
        p.setPen(pen)
        p.drawArc(Qt::Rect.new(loc.x-r, loc.y-r, r*2, r*2), 0, angle)
      end
    end
    p.end
  end
end
