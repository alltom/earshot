
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
    super(CONFIG[:width], CONFIG[:height], false)
    self.caption = "earshot"
    
    @circle = GCircle.new(40)
    @arc = GArc.new(40)
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

  def draw_circle(cx, cy, radius, color, filled=true)
    if filled
      @circle.draw cx, cy, radius, color
    else
      @arc.draw cx, cy, radius, Math::Tau, color
    end
  end

  def draw
    fg = Gosu::Color.new(158, 240, 216)
    range = Gosu::Color.new(60, 158, 240, 216)
    bg = Gosu::Color.new(40, 40, 40)
    agent = Gosu::Color.new(160, 240, 234)

    return if @sim.nil?
    
    glClearColor *bg.to_gl
    glClearDepth 0
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    
    gl do
      glEnable(GL_BLEND)
      
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
          angle = t.outgoing_broadcast.progress * Math::Tau
          @arc.draw loc.x, loc.y, r, angle, fg
        end
      end
    end
  end
end

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
