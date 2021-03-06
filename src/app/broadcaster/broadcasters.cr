module XET::App
  module Error
    abstract class Broadcasters < XET::Error
      class PortAlreadyExists < Broadcasters
      end
    end
  end
end

class XET::App::Broadcasters
  @@broadcasters_mutex = Mutex.new
  @@broadcasters = {} of UInt16 => XET::App::Broadcaster

  def self.[](port)
    @@broadcasters_mutex.synchronize do
      @@broadcasters[port]
    end
  end

  def self.[]=(port : UInt16, other : XET::App::Broadcaster)
    @@broadcasters_mutex.synchronize do
      @@broadcasters[port] = other
    end
  end

  def self.[]?(port : UInt16)
    @@broadcasters_mutex.synchronize do
      @@broadcasters[port]?
    end
  end

  def self.dup
    @@broadcasters_mutex.synchronize do
      @@broadcasters.dup
    end
  end

  def self.add(port : UInt16)
    @@broadcasters_mutex.synchronize do
      if !(@@broadcasters.keys.any? { |o_port| port == o_port })
        @@broadcasters[port] = XET::App::Broadcaster.new port
      else
        raise XET::App::Error::Broadcasters::PortAlreadyExists.new
      end
    end
  end

  def self.add?(port : UInt16)
    begin
      add(port)
      true
    rescue e : XET::App::Error::Broadcasters::PortAlreadyExists
      false
    end
  end

  def self.add(broadcaster : XET::App::Broadcaster)
    @@broadcasters_mutex.synchronize do
      if !(@@broadcasters.keys.any? { |broadcaster| port == broadcaster.port })
        @@broadcasters[broadcaster.port] = broadcaster
      else
        raise XET::App::Error::Broadcasters::PortAlreadyExists.new
      end
    end
  end

  def self.add?(broadcaster : XET::App::Broadcaster)
    begin
      add(broadcaster)
      true
    rescue e : XET::App::Error::Broadcasters::PortAlreadyExists
      false
    end
  end

  def self.delete(port)
    @@broadcasters_mutex.synchronize do
      if broadcaster = @@broadcasters[port]
        broadcaster.stop_listening
        broadcaster.stop_broadcasting
        broadcaster.close
        @@broadcasters.delete port
      end
    end
  end
end

