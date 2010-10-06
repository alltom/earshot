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
  end

  def update
    tic = Gosu::milliseconds
    @sim.advance unless @sim.nil?
    toc = Gosu::milliseconds
    puts "update time: #{toc-tic}ms"
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

  def draw
    #require 'profiler'
    #Profiler__::start_profile
    tic = Gosu::milliseconds

    fg = Gosu::Color.new(158, 240, 216)
    range = Gosu::Color.new(20, 158, 240, 216)
    error = Gosu::Color.new(10, 255, 60, 32)
    bg = Gosu::Color.new(40, 40, 40)
    grid = Gosu::Color.new(20, 100, 100, 100)
    text = Gosu::Color.new(200, 100, 100, 100)
    agent = Gosu::Color.new(160, 240, 234)

    return if @sim.nil?
    
    gl do
      glClearColor *bg.to_gl
      glClearDepth 0
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      
      glEnable(GL_BLEND)

      # draw logo
      icon = Gosu::Image.new(self, 'icon.png', false)
      icon.draw(-20, -3, 1)

      # draw clock
      clock_font = Gosu::Font.new(self, "./fonts/unispace bd.ttf", 20)  # from http://www.dafont.com/theme.php?cat=503
      m, s = $shreduler.now.round.divmod(60)
      clock_font.draw(sprintf("%02dm%02ds", m, s), 20, 80, 0, 1, 1, text)
      
      # draw analyzer stats
      label_font = Gosu::Font.new(self, "./fonts/unispace bd.ttf", 18)  # from http://www.dafont.com/theme.php?cat=503
      value_font = Gosu::Font.new(self, "./fonts/unispace bd.ttf", 16)  # from http://www.dafont.com/theme.php?cat=503

      x, y = 20, 120
      label_font.draw("Tx", x, y, 0, 1, 1, fg)
      value_font.draw(sprintf("%03d", ANALYZER.messages_sent), x+30, y+2, 0, 1, 1, text)

      x, y = 20, 140
      label_font.draw("Rx", x, y, 0, 1, 1, fg)
      value_font.draw(sprintf("%03d", ANALYZER.messages_delivered), x+30, y+2, 0, 1, 1, text)

      x, y = 10, 160
      label_font.draw("ADT", x, y, 0, 1, 1, fg)
      adt = ANALYZER.avg_delivery_time
      t = (adt.nil? && "N/A") || sprintf("%03ds", ANALYZER.avg_delivery_time)
      value_font.draw(t, x+40, y+2, 0, 1, 1, text)

      x, y = 10, 180
      label_font.draw("Clx", x, y, 0, 1, 1, fg)
      value_font.draw(sprintf("%03d", ANALYZER.collisions), x+40, y+2, 0, 1, 1, text)

      x, y = 10, 200
      label_font.draw("Rlx", x, y, 0, 1, 1, fg)
      value_font.draw(sprintf("%03d", ANALYZER.relays), x+40, y+2, 0, 1, 1, text)

      x, y = 30, 220
      label_font.draw("N", x, y, 0, 1, 1, fg)
      value_font.draw(sprintf("%03d", ANALYZER.num_agents), x+20, y+2, 0, 1, 1, text)

      # draw dimensions for grid
      font_height = 10
      lm = CONFIG[:left_margin_px]
      tm = CONFIG[:top_margin_px]
      font = Gosu::Font.new(self, "./fonts/unispace bd.ttf", 10)  # from http://www.dafont.com/theme.php?cat=503
      font.draw("0", lm-10, tm-10, 0, 1, 1, text)
      font.draw("#{CONFIG[:width_m]}m", lm+CONFIG[:width_px], tm-10, 0, 1, 1, text)
      font.draw("#{CONFIG[:height_m]}m", lm-font_height*2, tm+CONFIG[:height_px] - 0.5*font_height, 0, 1, 1, text)

      # translate drawing to leave a margin around the edges
      glPushMatrix
      glTranslate(CONFIG[:left_margin_px], CONFIG[:top_margin_px], 0)

      # move into world coordinate system
      glPushMatrix
      w_scale, h_scale = world2screen(1.0, 1.0)
      glScale(w_scale, h_scale, 1)

      # draw grid
      x_m, y_m = 0, 0
      while x_m <= CONFIG[:width_m]
        glColor4f(*grid.to_gl)
        glLineWidth 2
        glBegin(GL_LINES)
          glVertex2f(x_m, 0)
          glVertex2f(x_m, CONFIG[:height_m])
        glEnd
        x_m += CONFIG[:grid_m]
      end

      while y_m <= CONFIG[:height_m]
        glColor4f(*grid.to_gl)
        glLineWidth 2
        glBegin(GL_LINES)
          glVertex2f(0, y_m)
          glVertex2f(CONFIG[:width_m], y_m)
        glEnd
        y_m += CONFIG[:grid_m]
      end

      @sim.agents.each do |t|
        loc = t.loc
        
        # visualize agent
        r = CONFIG[:agent_radius_m]
        draw_circle(loc.x, loc.y, r, agent)
        
        # visualize agent's range
        r = CONFIG[:transmission_radius_m] 
        draw_circle(loc.x, loc.y, r, range)
        
        # visualize broadcast progress
        if t.broadcasting?
          r = CONFIG[:transmission_radius_m] 
          angle = t.outgoing_broadcast.progress * Math::Tau
          @arc.draw loc.x, loc.y, r, angle, fg
        end

        # visualize links between tx-ing agent and rx-ing agents
        if t.broadcasting?
          t.outgoing_broadcast.receivers.each do |rxer|
            glColor4f(*fg.to_gl)
            glLineWidth 2
            glBegin(GL_LINES)
              glVertex2f(t.loc.x, t.loc.y)
              glVertex2f(rxer.loc.x, rxer.loc.y)
            glEnd
          end
        end

        # sonify broadcast initiations
        @droplet.play if t.broadcasting? and t.outgoing_broadcast.progress == 0
      end

      # visualize failed broadcasts (due to collisions and moving out-of-range)
      @sim.airspace.broadcasts.each do |b|
        b.failed_receivers.each do |r|
          draw_circle(r.loc.x, r.loc.y, CONFIG[:transmission_radius_m], error)
        end
      end

      # return to screen coordinates
      glPopMatrix

      # untranslate
      glPopMatrix
    end

    toc = Gosu::milliseconds
    puts "draw time: #{toc-tic}ms"
    #Profiler__::stop_profile
    #Profiler__::print_profile($stdout)
    #exit
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
    end
    
    def draw(x = 0, y = 0, radius = 1, color = nil)
      @gl_colors[color] ||= color.to_gl

      glPushMatrix
      glTranslate x, y, 0
      glScale radius, radius, 1
      glBegin(GL_TRIANGLE_FAN)
        glColor4f(*@gl_colors[color])
        glVertex2f(0, 0) # center
        @vertices.each { |xo, yo| glVertex2f(xo, yo) }
      glEnd
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
    @subdivisions = subdivisions
  end
  
  def draw(x = 0, y = 0, radius = 1, radians = 3.14, color = nil)
    rez = Math::Tau/40
    
    if color.nil?
      col = [1, 1, 1, 1]
    else
      col = color.to_gl
    end
    
    glBegin(GL_LINE_STRIP)
      angle = 0
      while angle + rez <= radians do
        glColor4f(*col)
        glVertex2f(x + radius * Math::cos(angle), y + radius * Math::sin(angle))
        angle += rez
      end
    glEnd
  end
end
