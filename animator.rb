
include Gl
include Glu

class Animator < Gosu::Window
  attr_accessor :sim

  def initialize
    super(CONFIG[:width], CONFIG[:height], false)
    self.caption = "earshot"
    
    @circle = GCircle.new(40)
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

  def draw_pie(cx, cy, radius, color)
    glEnable(GL_BLEND)
    glColor4f(color.red/255.0, color.green/255.0, color.blue/255.0, color.alpha/255.0)
    @circle.draw(cx, cy, radius)
  end

  def draw_arc(cx, cy, radius, radians, color)
    tau = 2*Math::PI
    rez = tau/40
    
    col = [color.red/255.0, color.green/255.0, color.blue/255.0, color.alpha/255.0]
    
    glBegin(GL_LINE_STRIP)
      angle = 0
      while angle + rez <= radians do
        glColor4f(*col)
        glVertex2f(cx + radius * Math::cos(angle), cy + radius * Math::sin(angle))
        angle += rez
      end
    glEnd
  end

  def draw_circle(cx, cy, radius, color, filled=true)
    if filled
      draw_pie(cx, cy, radius, color)
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
    
    gl do
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
  
  def draw(x = 0, y = 0, radius = 1)
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
      tau = 2 * Math::PI
      rez = tau/subdivisions
      
      verts = []
      verts << [0, 0, 0]
      
      angle = 0
      while angle + rez <= tau do
        verts << [Math::cos(angle), Math::sin(angle), 0]
        angle += rez
      end
      
      verts << [Math::cos(0), Math::sin(0), 0]
      
      verts
    end
end
