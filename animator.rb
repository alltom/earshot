
QT_FULL_CIRCLE = 360 * 16  # Qt measures angles in 1/16ths of a degree

class Animator < Gosu::Window
  attr_accessor :sim

  def initialize
    super(CONFIG[:width], CONFIG[:height], false)
  end

  def update
    @sim.advance unless @sim.nil?
  end

  def mouseReleaseEvent(mouse_event)
    loc = Loc.new(mouse_event.x, mouse_event.y)
    @sim.add_transceiver(loc)
  end

  def draw_pie(cx, cy, radius, radians, color)
    tau = 2*Math::PI
    rez = tau/400
    
    angle = 0
    while angle + rez <= radians do
      end_angle = angle + rez
      x1 = cx + radius * Math::cos(angle)
      y1 = cy + radius * Math::sin(angle)
      x2 = cx + radius * Math::cos(end_angle)
      y2 = cy + radius * Math::sin(end_angle)
      draw_triangle(x1, y1, color, x2, y2, color, cx, cy, color)
      angle = end_angle
    end
    x1 = radius * Math::cos(angle)
    y1 = radius * Math::sin(angle)
    x2 = radius * Math::cos(radians)
    y2 = radius * Math::sin(radians)
    draw_triangle(x1, y1, color, x2, y2, color, cx, cy, color)
  end

  def draw_circle(cx, cy, radius, color)
    draw_pie(cx, cy, radius, Math::PI*2, color)
  end

  def draw
    fg = Gosu::Color.new(158, 240, 216)
    range = Gosu::Color.new(60, 158, 240, 216)
    bg = Gosu::Color.new(40, 40, 40)
    agent = Gosu::Color.new(160, 240, 234)

    return if @sim.nil?

    # fill background. there's probably a better way to do this...
    draw_quad(0, 0, bg, 0, CONFIG[:height], bg, CONFIG[:width], CONFIG[:height], bg, CONFIG[:width], 0, bg)

    @sim.transceivers.each do |t|
      loc = t.loc

      # visualize transceiver
      r = CONFIG[:transceiver_radius]
      draw_circle(loc.x, loc.y, r, agent)

      # visualize transceiver's range
      r = CONFIG[:transmission_radius] 
      draw_circle(loc.x, loc.y, r, range)

      # visualize broadcast progress
      #if t.broadcasting?
      #  r = CONFIG[:transmission_radius] 
      #  angle = t.outgoing_broadcast.progress * QT_FULL_CIRCLE
      #  pen = Qt::Pen.new(fg)
      #  pen.setWidth(4)
      #  p.setPen(pen)
      #  p.drawArc(Qt::Rect.new(loc.x-r, loc.y-r, r*2, r*2), 0, angle)
      #end
    end
  end
end
