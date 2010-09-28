
class Animator < Gosu::Window
  attr_accessor :sim

  def initialize
    super(CONFIG[:width], CONFIG[:height], false)
    self.caption = 'earshot'
  end

  def update
    @sim.advance unless @sim.nil?
  end

  def needs_cursor?
    true
  end

  def button_up(id)
    return unless id == Gosu::MsLeft
    loc = Loc.new(mouse_x, mouse_y)
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

  def draw_arc(cx, cy, radius, radians, color)
    tau = 2*Math::PI
    rez = tau/400
    
    angle = 0
    while angle + rez <= radians do
      end_angle = angle + rez
      x1 = cx + radius * Math::cos(angle)
      y1 = cy + radius * Math::sin(angle)
      x2 = cx + radius * Math::cos(end_angle)
      y2 = cy + radius * Math::sin(end_angle)
      draw_line(x1, y1, color, x2, y2, color)
      angle = end_angle
    end
    x1 = radius * Math::cos(angle)
    y1 = radius * Math::sin(angle)
    x2 = radius * Math::cos(radians)
    y2 = radius * Math::sin(radians)
    draw_line(x1, y1, color, x2, y2, color)
  end


  def draw_circle(cx, cy, radius, color, filled=true)
    if filled
      draw_pie(cx, cy, radius, Math::PI*2, color)
    else
      draw_arc(cx, cy, radius, Math::PI*2, color)
    end
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
      if t.broadcasting?
        r = CONFIG[:transmission_radius] 
        angle = t.outgoing_broadcast.progress * Math::PI*2
        draw_arc(loc.x, loc.y, r, angle, fg)
      end
    end
  end
end
