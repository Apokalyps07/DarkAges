# unifinished

class SystemOptions
  attr_accessor :language
  attr_accessor :fullscreen
  attr_accessor :graphics
  attr_accessor :dynamic_shadows
  attr_accessor :dynamic_ligthing
  
  attr_reader :port
  
  UPDATE_PORT = 49553
  
  def initialize
    @language = :de
    @fullscreen = false
    @graphics = :normal
    @dynamic_shadows = true
    @dynamic_ligthing = true
    @port = 49552
  end
  
  def port=(value)
    return nil if value == UPDATE_PORT or value <= 1023 or value > 65535
    @port = value
  end
end
