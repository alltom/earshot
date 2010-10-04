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

class Animator < Gosu::Window
  attr_accessor :sim

  def initialize
    super(CONFIG[:width_px], CONFIG[:height_px], false)
    self.caption = "earshot"
    
    @circle = GCircle.new(40)
    @arc = GArc.new(40)
  end

  def update
    @sim.advance unless @sim.nil?
  end

  def needs_cursor?
    true # this makes the mouse cursor visible inside the window
  end

  def button_up(id)
    return unless id == Gosu::MsLeft
    x_px, y_px = screen2world(mouse_x, mouse_y)
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
    fg = Gosu::Color.new(158, 240, 216)
    range = Gosu::Color.new(20, 158, 240, 216)
    error = Gosu::Color.new(10, 255, 60, 32)
    bg = Gosu::Color.new(40, 40, 40)
    grid = Gosu::Color.new(20, 100, 100, 100)
    agent = Gosu::Color.new(160, 240, 234)

    return if @sim.nil?
    
    gl do
      glClearColor *bg.to_gl
      glClearDepth 0
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      
      glEnable(GL_BLEND)

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
      end

      # visualize failed broadcasts (due to collisions and moving out-of-range)
      @sim.airspace.broadcasts.each do |b|
        b.failed_receivers.each do |r|
          draw_circle(r.loc.x, r.loc.y, CONFIG[:transmission_radius_m], error)
        end
      end

      # return to screen coordinates
      glPopMatrix
    end
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
      @subdivisions = subdivisions
    end
    
    def draw(x = 0, y = 0, radius = 1, color = nil)
      rez = Math::Tau / @subdivisions

      if color.nil?
        col = [1, 1, 1, 1]
      else
        col = color.to_gl
      end

      glBegin(GL_TRIANGLE_FAN)
        glColor4f(*col)
        glVertex2f(x, y) # center
        
        angle = 0
        while angle + rez <= Math::Tau do
          glColor4f(*col)
          glVertex2f(x + radius * Math::cos(angle), y + radius * Math::sin(angle))
          angle += rez
        end
        
        glColor4f(*col)
        glVertex2f(x + radius * Math::cos(0), y + radius * Math::sin(0))
      glEnd
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
