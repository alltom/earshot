include Gl
include Glu

module Gosu
  class Color
    def to_gl
      [red/255.0, green/255.0, blue/255.0, alpha/255.0]
    end
  end
end

module Math
  Tau = 2 * PI
end

class UI < Gosu::Window
  attr_accessor :sim

  def initialize
    w = CONFIG[:width_px] + CONFIG[:left_margin_px] + CONFIG[:right_margin_px]
    h = CONFIG[:height_px] + CONFIG[:top_margin_px] + CONFIG[:bottom_margin_px]
    super(w, h, false)
    self.caption = "earshot - #{CONFIG[:title]}"
    
    @circle = GCircle.new(40)
    @arc = GArc.new(40)
    @droplet = Gosu::Sample.new(self, 'droplet.wav')

    @draw_time = 0.0

    
    @text_color = Gosu::Color.new(200, 100, 100, 100)
    @fg_color = Gosu::Color.new(158, 240, 216)
    @grid_color = Gosu::Color.new(20, 100, 100, 100)
    @range_color = Gosu::Color.new(20, 158, 240, 216)
    @error_color = Gosu::Color.new(10, 255, 60, 32)
    @bg_color = Gosu::Color.new(40, 40, 40)
    @agent_color = Gosu::Color.new(160, 240, 234)

    @state_idle_color = Gosu::Color.new(20, 158, 240, 216)
    @state_length_color = Gosu::Color.new(40, 255, 249, 119)
    @state_checksum_color = Gosu::Color.new(40, 255, 194, 88)
    @state_message_color = Gosu::Color.new(40, 232, 152, 92)
    @state_sending_color = Gosu::Color.new(20, 158, 240, 216)
  end

  def update
    tic = Gosu::milliseconds
    @sim.advance unless @sim.nil?
    toc = Gosu::milliseconds
    #puts "update time: #{toc-tic}ms"
  end

  def needs_cursor?
    true # this makes the mouse cursor visible inside the window
  end

  def button_up(id)
    return unless id == Gosu::MsLeft
    x_px, y_px = screen2world(mouse_x, mouse_y)

    # shift click position to account for margins
    x_px -= CONFIG[:left_margin_px]
    y_px -= CONFIG[:top_margin_px]

    # ignore clicks outside of the simulation area
    return unless (0...CONFIG[:width_px]) === x_px \
              and (0...CONFIG[:height_px]) === y_px

    @sim.add_agent(Loc.new(x_px, y_px))
  end

  def world2screen(x_m, y_m)
    x_px_per_m = 1.0*CONFIG[:width_px]/CONFIG[:width_m] 
    y_px_per_m = 1.0*CONFIG[:height_px]/CONFIG[:height_m]
    [x_m*x_px_per_m, y_m*y_px_per_m]
  end

  def screen2world(x_px, y_px)
    x_m_per_px = 1.0*CONFIG[:width_m]/CONFIG[:width_px] 
    y_m_per_px = 1.0*CONFIG[:height_m]/CONFIG[:height_px]
    [x_px*x_m_per_px, y_px*y_m_per_px]
  end

  def draw_circle(cx, cy, radius, color, filled=true)
    if filled
      @circle.draw cx, cy, radius, color
    else
      @arc.draw cx, cy, radius, Math::Tau, color
    end
  end

  def draw_logo
    @icon ||= Gosu::Image.new(self, 'icon.png', false)
    @icon.draw(-20, -3, 1)
  end

  def draw_clock
    @clock_font ||= Gosu::Font.new(self, "./fonts/unispace bd.ttf", 20)  # from http://www.dafont.com/theme.php?cat=503
    m, s = $shreduler.now.round.divmod(60)
    @clock_font.draw(sprintf("%02dm%02ds", m, s), 20, 80, 0, 1, 1, @text_color)
  end

  def draw_analyzer_stats
    @label_font ||= Gosu::Font.new(self, "./fonts/unispace bd.ttf", 18)  # from http://www.dafont.com/theme.php?cat=503
    @value_font ||= Gosu::Font.new(self, "./fonts/unispace bd.ttf", 16)  # from http://www.dafont.com/theme.php?cat=503

    x, y = 20, 120
    @label_font.draw("Tx", x, y, 0, 1, 1, @fg_color)
    @value_font.draw(sprintf("%03d", ANALYZER.messages_sent), x+30, y+2, 0, 1, 1, @text_color)

    x, y = 20, 140
    @label_font.draw("Rx", x, y, 0, 1, 1, @fg_color)
    @value_font.draw(sprintf("%03d", ANALYZER.messages_delivered), x+30, y+2, 0, 1, 1, @text_color)

    x, y = 10, 160
    @label_font.draw("ADT", x, y, 0, 1, 1, @fg_color)
    adt = ANALYZER.avg_delivery_time
    t = (adt.nil? && "N/A") || sprintf("%03ds", ANALYZER.avg_delivery_time)
    @value_font.draw(t, x+40, y+2, 0, 1, 1, @text_color)

    x, y = 10, 180
    @label_font.draw("Clx", x, y, 0, 1, 1, @fg_color)
    @value_font.draw(sprintf("%03d", ANALYZER.collisions), x+40, y+2, 0, 1, 1, @text_color)

    x, y = 10, 200
    @label_font.draw("Rlx", x, y, 0, 1, 1, @fg_color)
    @value_font.draw(sprintf("%03d", ANALYZER.relays), x+40, y+2, 0, 1, 1, @text_color)

    x, y = 30, 220
    @label_font.draw("N", x, y, 0, 1, 1, @fg_color)
    @value_font.draw(sprintf("%03d", ANALYZER.num_agents), x+20, y+2, 0, 1, 1, @text_color)
  end

  def draw_grid_dimensions
    @grid_dim_font ||= Gosu::Font.new(self, "./fonts/unispace bd.ttf", 10)  # from http://www.dafont.com/theme.php?cat=503
    font_height = 10
    lm = CONFIG[:left_margin_px]
    tm = CONFIG[:top_margin_px]
    @grid_dim_font.draw("0", lm-10, tm-10, 0, 1, 1, @text_color)
    @grid_dim_font.draw("#{CONFIG[:width_m]}m", lm+CONFIG[:width_px], tm-10, 0, 1, 1, @text_color)
    @grid_dim_font.draw("#{CONFIG[:height_m]}m", lm-font_height*2, tm+CONFIG[:height_px] - 0.5*font_height, 0, 1, 1, @text_color)
  end

  def draw_grid
    x_m, y_m = 0, 0
    while x_m <= CONFIG[:width_m]
      glColor4f(*@grid_color.to_gl)
      glLineWidth 2
      glBegin(GL_LINES)
        glVertex2f(x_m, 0)
        glVertex2f(x_m, CONFIG[:height_m])
      glEnd
      x_m += CONFIG[:grid_m]
    end

    while y_m <= CONFIG[:height_m]
      glColor4f(*@grid_color.to_gl)
      glLineWidth 2
      glBegin(GL_LINES)
        glVertex2f(0, y_m)
        glVertex2f(CONFIG[:width_m], y_m)
      glEnd
      y_m += CONFIG[:grid_m]
    end
  end

  def draw_agent(a, loc)
    r = CONFIG[:agent_radius_m]
    draw_circle(loc.x, loc.y, r, @agent_color)
  end

  def draw_agent_range(a, loc)
    r = CONFIG[:transmission_radius_m] 
    case a.state
    when :idle
      color = @state_idle_color
    when :reading_length
      color = @state_length_color
    when :reading_checksum
      color = @state_checksum_color
    when :reading_message
      color = @state_message_color
    when :sending
      color = @state_sending_color
    end
    draw_circle(loc.x, loc.y, r, color)
  end

  def draw_broadcast_progress(a, loc)
    r = CONFIG[:transmission_radius_m] 
    angle = a.broadcast_progress * Math::Tau
    @arc.draw loc.x, loc.y, r, angle, @fg_color
  end

  def sonify_broadcast()
    @droplet.play
  end

  def draw_failed_broadcast(a, loc)
    draw_circle(loc.x, loc.y, CONFIG[:transmission_radius_m], @error_color)
  end

  def draw_transmission_links(a, loc)
    a.outgoing_broadcast.receivers.each do |rxer|
      glColor4f(*@fg_color.to_gl)
      glLineWidth 2
      glBegin(GL_LINES)
        glVertex2f(loc.x, loc.y)
        glVertex2f(rxer.loc.x, rxer.loc.y)
      glEnd
    end
  end

  def draw
    return if @sim.nil?

    tic = Gosu::milliseconds
    
    gl do
      glClearColor *@bg_color.to_gl
      glClearDepth 0
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      
      glEnable(GL_BLEND)

      draw_logo
      draw_clock
      draw_analyzer_stats
      draw_grid_dimensions

      # translate drawing to leave a margin around the edges
      glPushMatrix
      glTranslate(CONFIG[:left_margin_px], CONFIG[:top_margin_px], 0)

      # move into world coordinate system
      glPushMatrix
      w_scale, h_scale = world2screen(1.0, 1.0)
      glScale(w_scale, h_scale, 1)

      draw_grid
      
      # merge each broadcast's failed receivers into one big array of failures
      failed_receivers = @sim.airspace.collisions

      (@sim.agents - failed_receivers).each do |a|
        loc = a.loc
        
        draw_agent(a, loc)
        draw_agent_range(a, loc)
        draw_broadcast_progress(a, loc) if a.broadcasting?
        #draw_transmission_links(a, loc) if a.broadcasting?
        sonify_broadcast if a.broadcasting? and a.broadcast_progress == 0
      end

      failed_receivers.each do |a|
        loc = a.loc

        draw_agent(a, loc)
        draw_failed_broadcast(a, loc)
        draw_broadcast_progress(a, loc) if a.broadcasting?
        #draw_transmission_links(a, loc) if a.broadcasting?
        sonify_broadcast if a.broadcasting? and a.broadcast_progress == 0
      end

      # return to screen coordinates
      glPopMatrix

      # untranslate
      glPopMatrix
    end

    toc = Gosu::milliseconds
    #puts "draw time: #{toc-tic}ms"
  end
end

# wraps an OpenGL vector buffer object (VBO), which is just an array
# in graphics card memory. assign an array of numbers to the vertices
# attribute and it will be written to video memory immediately after
# being packed as single-precision floats.
class VBO
  attr_reader :vertices
  
  def initialize(verts = nil)
    @buffer = glGenBuffers(1)[0]
    self.vertices = verts
  end
  
  def vertices=(verts)
    return unless verts
    @vertices = verts || []
    send_data
  end
  
  protected
    def bind_buffer
      glBindBuffer GL_ARRAY_BUFFER, @buffer
    end
    
    def send_data
      return unless @vertices.length > 0
      packed_verts = @vertices.flatten.pack("e*")
      bind_buffer
      glBufferData GL_ARRAY_BUFFER, packed_verts.length, packed_verts, GL_STATIC_DRAW
    end
end

if CONFIG[:slow_gl]
  
  # draws a circle in immediate mode with the given number of subdivisions.
  class GCircle
    def initialize(subdivisions = 40)
      rez = Math::Tau / subdivisions
      angles = (0..subdivisions).map { |s| s * rez }
      @vertices = angles.map { |angle| [Math::cos(angle), Math::sin(angle)] }

      @gl_colors = { nil => [1, 1, 1, 1] }

      @disp_list = glGenLists(1)
      glNewList(@disp_list, GL_COMPILE)
      glBegin(GL_TRIANGLE_FAN)
        glVertex2f(0, 0) # center
        @vertices.each { |xo, yo| glVertex2f(xo, yo) }
      glEnd
      glEndList
    end
    
    def draw(x = 0, y = 0, radius = 1, color = nil)
      @gl_colors[color] ||= color.to_gl

      glPushMatrix
      glTranslate x, y, 0
      glScale radius, radius, 1
      glColor4f(*@gl_colors[color])
      glCallList(@disp_list)
      glPopMatrix
    end
  end
  
else
  
  # VBO-backed circle mesh with the given number of subdivisions.
  class GCircle < VBO
    def initialize(subdivisions = 40)
      super()
      self.vertices = make_verts(subdivisions)
    end
  
    def draw(x = 0, y = 0, radius = 1, color = nil)
      glColor4f(*color.to_gl) if color
    
      glPushMatrix
    
        glTranslate x, y, 0
        glScale radius, radius, 0
      
        bind_buffer
        glVertexPointer 3, GL_FLOAT, 0, 0
        glEnableClientState GL_VERTEX_ARRAY
        glDrawArrays GL_TRIANGLE_FAN, 0, self.vertices.length
        glDisableClientState GL_VERTEX_ARRAY
      
      glPopMatrix
    end
  
    protected
      def make_verts(subdivisions)
        rez = Math::Tau/subdivisions
      
        verts = []
        verts << [0, 0, 0]
      
        angle = 0
        while angle + rez <= Math::Tau do
          verts << [Math::cos(angle), Math::sin(angle), 0]
          angle += rez
        end
      
        verts << [Math::cos(0), Math::sin(0), 0]
      
        verts
      end
  end
  
end

# renders OpenGL immediate mode arcs using LINE_LOOP.
class GArc
  attr_accessor :subdivisions
  
  def initialize(subdivisions)
    @rez = Math::Tau/40
    @angles = (0..subdivisions).map { |s| s * @rez }
    @vertices = @angles.map { |angle| [Math::cos(angle), Math::sin(angle)] }
    @gl_colors = { nil => [1, 1, 1, 1] }
  end
  
  def draw(x = 0, y = 0, radius = 1, radians = 3.14, color = nil)
    slices = (radians/@rez).round
    
    @gl_colors[color] ||= color.to_gl
    
    glColor4f(*@gl_colors[color])
    glPushMatrix
    glTranslate x, y, 0
    glScale radius, radius, 1
    glBegin(GL_LINE_STRIP)
      @vertices[(0..slices)].each { |xo, yo| glVertex2f(xo, yo) }
    glEnd
    glPopMatrix
  end
end
