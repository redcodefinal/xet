require "kemal"
require "./ipaddr/ipaddr"
require "./xet"

require "./app/macros/**"
require "./app/target/**"
require "./app/broadcaster/**"
require "./app/mitm/handler"



module XET::App
  class_getter interface = ""
  class_property broadcast_ip = ::Socket::IPAddress::BROADCAST
  class_property server_ip = ::Socket::IPAddress::UNSPECIFIED
  class_property bind_ip = ::Socket::IPAddress::UNSPECIFIED #  TODO: FIX THIS IT NEEDS TO BE BETTER
  class_property mac_address = ""

  def self.setup(interface = "enp3s0")
    interface = IPAddr.get_interface(interface, IPAddr::INetType::IPV4)
    XET::App.server_ip = interface.ip
    XET::App.mac_address = interface.mac
    XET::App.broadcast_ip = interface.broadcast_ip
  end

  def self.run(port = 4000, interface = "enp3s0")
    setup(interface)
    
    # Add default broadcaster
    # XET::App::Broadcasters[XET::DEFAULT_DISCOVERY_PORT] = XET::App::Broadcaster.new(XET::DEFAULT_DISCOVERY_PORT)
    # XET::App::Broadcasters[XET::DEFAULT_DISCOVERY_PORT].start_listening

    Kemal.config.port = port.to_i
    Kemal.run
  end
end



