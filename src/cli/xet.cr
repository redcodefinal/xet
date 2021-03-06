require "clim"
require "colorize"

require "../app"

require "../app/routes/**"


macro xsock_opts_parse(name, type)
  if %name = opts.{{name.id}}
    value = 0
    begin
      if %name =~ /^0x[0-9a-fA-f]{1,8}$/
        value = %name[2..].to_i64(16)
      elsif  %name =~ /^0b[01]{8,32}$/
        value = %name[2..].to_i64(2)
      else
        value = %name.to_i64
      end

      {% if name.id == "size" %}
      msg.use_custom_size = true
      {% end %}
        
      {% r_type = type.resolve %}
      {% if r_type == ::UInt8 %}
      msg.{{name.id}} = value.to_u8 
      {% elsif r_type == ::UInt16 %}
      msg.{{name.id}} = value.to_u16
      {% elsif r_type == ::UInt32 %}
      msg.{{name.id}} = value.to_u32
      {% elsif r_type == ::String %}
      msg.{{name.id}} = value
      {% else %}
        raise "{{type}} not supported"
      {% end %}

    rescue e
      puts "ERROR: #{e.inspect} {{name}} was not a {{type}}(min:#{{{type}}::MIN},max:#{{{type}}::MAX}), instead was #{opts.{{name.id}}}|#{value}"
      exit
    end
  end
end

def print_msg(msg : XET::Message)
  puts "#{"type".colorize.red.bold}: #{msg.type} | 0x#{msg.type.to_s(16).rjust(2, '0')}"
  puts "#{"version".colorize.green.bold}: #{msg.version} | 0x#{msg.version.to_s(16).rjust(2, '0')}"
  puts "#{"reserved1".colorize.yellow.bold}: #{msg.reserved1} | 0x#{msg.reserved1.to_s(16).rjust(2, '0')}"
  puts "#{"reserved2".colorize.blue.bold}: #{msg.reserved2} | 0x#{msg.reserved2.to_s(16).rjust(2, '0')}"
  puts "#{"session_id".colorize.magenta.bold}: #{msg.session_id} | 0x#{msg.session_id.to_s(16).rjust(8, '0')}"
  puts "#{"sequence".colorize.cyan.bold}: #{msg.sequence} | 0x#{msg.sequence.to_s(16).rjust(8, '0')}"
  puts "#{"total_packets".colorize.light_red.bold}: #{msg.total_packets} | 0x#{msg.total_packets.to_s(16).rjust(2, '0')}"
  puts "#{"current_packet".colorize.light_green.bold}: #{msg.current_packet} | 0x#{msg.current_packet.to_s(16).rjust(2, '0')}"
  puts "#{"id".colorize.light_yellow.bold}: #{msg.id} | 0x#{msg.id.to_s(16).rjust(4, '0')}"
  puts "#{"size".colorize.light_gray.bold}: #{msg.size} | 0x#{msg.size.to_s(16).rjust(8, '0')}"
  puts "#{`echo '#{msg.message}' | jq .`}"
end


module XET
  class CLI < Clim
    main do
      desc "XET - Xiongmai Exploitation Toolkit"
      usage "xet [sub_command] [arguments] ..."
      version "Version #{XET::VERSION}"
      run do |opts, args|
        puts opts.help_string # => help string.
        exit
      end

      sub "web" do
        desc "Runs the web interface"
        option "-p PORT", "--port=PORT", type: UInt16, desc: "Specifies the port", default: 4000
        option "-i INTERFACE", "--interface=INTERFACE", type: String, desc: "Specifies the port", default: "enp3s0"

        usage "xet web [options]"
        run do |opts, args|
          XET::App.run(port: opts.port, interface: opts.interface)
        end
      end

      sub "send" do
        desc "Sends a message and attempts to receive on back"
        usage "xet send [options] [destination]"

        argument "destination", type: String, desc: "IP to send the message to", required: true

        option "-r PORT", "--port=PORT", type: UInt16, desc: "Specifies the port", default: 34567
        option "-s PORT_TYPE", "--connection=PORT_TYPE", type: String, desc: "Specifies the port type. Either TCP or UDP", default: "tcp"
        option "-t TIMEOUT", "--timeout=TIMEOUT", type: UInt32, desc: "How long to wait for a reply in seconds", default: 5
        option "-l TIMES", "--listen=TIMES", desc: "How many messages the socket should listen for.", type: UInt32, default: 1
        option "-x BIND_IP", "--bind=BIND_IP", desc: "The IP Address to bind to for listening", type: String
        

        option "-u USER", "--user=USER", type: String, desc: "The username for the camera.", default: "admin"
        option "-p PASSWORD", "--password=PASSWORD", type: String, desc: "The password for the camera.", default: ""
        option "-n", "--no-login", type: Bool, desc: "If we should login before sending the command", default: false

        option "-v", "--verbose", type: Bool, desc: "Print more debugging information to STDERR", default: false
        option "-w TEMPLATE", "--template=TEMPLATE", type: String, desc: "Template for the message. Use 'xet info command templates' to see available templates", default: "Blank"

        option "-a TYPE", "--type=TYPE", type: String, desc: "The type field of the packet. You can use decimal (0), hexadecimal(0x), and binary (0b) numbers here."
        option "-b VERSION", "--version=VERSION", type: String, desc: "The version field of the packet You can use decimal (0), hexadecimal(0x), and binary (0b) numbers here."
        option "-c RESERVED1", "--reserved1=RESERVED1", type: String, desc: "The reserved1 field of the packet. You can use decimal (0), hexadecimal(0x), and binary (0b) numbers here."
        option "-d RESERVED2", "--reserved2=RESERVED2", type: String, desc: "The reserved2 field of the packet. You can use decimal (0), hexadecimal(0x), and binary (0b) numbers here."
        option "-e SESSION_ID", "--session_id=SESSION_ID", type: String, desc: "The session_id field of the packet. You can use decimal (0), hexadecimal(0x), and binary (0b) numbers here."
        option "-f SEQUENCE", "--sequence=SEQUENCE", type: String, desc: "The sequence field of the packet. You can use decimal (0), hexadecimal(0x), and binary (0b) numbers here."
        option "-g TOTAL_PACKETS", "--total_packets=TOTAL_PACKETS", type: String, desc: "The total_packets field of the packet. You can use decimal (0), hexadecimal(0x), and binary (0b) numbers here."
        option "-h CURRENT_PACKET", "--current_packet=CURRENT_PACKET", type: String, desc: "The current_packet field of the packet. You can use decimal (0), hexadecimal(0x), and binary (0b) numbers here."
        option "-i ID", "--id=ID", type: String, desc: "The id field of the packet. You can use decimal (0), hexadecimal(0x), and binary (0b) numbers here."
        option "-j SIZE", "--size=SIZE", type: String, desc: "The size field of the packet. You can use decimal (0), hexadecimal(0x), and binary (0b) numbers here."
        option "-m MESSAGE", "--message=MESSAGE", type: String, desc: "The JSON message to send. "

        run do |opts, args|
          unless ["tcp", "udp"].any? { |t| opts.connection == t }
            Log.error { "Invalid port_type -s #{opts.connection} must be tcp or udp" }
            exit
          end

          template_class = XET::Command::Blank
          full_command_name = opts.template =~ /^XET::Command::/ ? opts.template : "XET::Command::#{opts.template}"

          if XET::Commands[full_command_name]?
            template_class = XET::Commands[full_command_name]
          else
            Log.error { "NOT A VALID TEMPLATE #{opts.template}|#{full_command_name}".colorize.red unless opts.template == "?" }
            puts "Available Templates: \n#{XET::Commands.to_h.values.join("\n").gsub(/XET::Command::/, "")}"
            exit
          end

          msg = template_class.new

          xsock_opts_parse(type, UInt8)
          xsock_opts_parse(version, UInt8)
          xsock_opts_parse(reserved1, UInt8)
          xsock_opts_parse(reserved2, UInt8)
          xsock_opts_parse(session_id, UInt32)
          xsock_opts_parse(sequence, UInt32)
          xsock_opts_parse(total_packets, UInt8)
          xsock_opts_parse(current_packet, UInt8)
          xsock_opts_parse(id, UInt16)
          xsock_opts_parse(size, UInt32)
          msg.message = message if message = opts.message

          # Fix size
          if !msg.use_custom_size?
            msg.size = msg.message.size.to_u32
          end

          begin
            # Open up a socket
            if opts.connection == "tcp"
              socket = XET::Socket::TCP.new(args.destination, opts.port)
              socket.broadcast = true
              socket.read_timeout = opts.timeout.seconds

              if opts.listen > 0 
                if bind_ip = opts.bind
                  Log.info {  "Binding to interface #{bind_ip}" }
                  socket.bind(bind_ip, opts.port.to_i)
                  Log.info {  "Bound to interface #{bind_ip}" }
                else
                  Log.info {  "Binding to all interfaces" }
                  socket.bind(opts.port.to_i)
                  Log.info {  "Bound to all interfaces" }
                end
              end

              if !opts.no_login
                socket.login(opts.user, opts.password)
              end

              socket.send_message msg

              Log.info { "Sent Packet!".colorize.green }
              puts
              print_msg(msg)
              opts.listen.times do
                rmsg = socket.receive_message[0]
                puts
                Log.info { "Got Reply!".colorize.green }
                puts
                print_msg(rmsg)
              end
              socket.close
            elsif opts.connection == "udp"
              socket = XET::Socket::UDP.new(args.destination, opts.port)
              socket.broadcast = true
              socket.read_timeout = opts.timeout.seconds
              if opts.listen > 0 
                if bind_ip = opts.bind
                  Log.info {  "Binding to interface #{bind_ip}" }
                  socket.bind(bind_ip, opts.port.to_i)
                  Log.info {  "Bound to interface #{bind_ip}" }
                else
                  Log.info {  "Binding to all interfaces" }
                  socket.bind(opts.port.to_i)
                  Log.info {  "Bound to all interfaces" }
                end
              end
              if !opts.no_login
                socket.login(opts.user, opts.password)
              end
              socket.send_message msg
              Log.info { "Sent Packet!".colorize.green }
              puts
              print_msg(msg)
              opts.listen.times do
                rmsg = socket.receive_message[0]
                puts
                Log.info { "Got Reply!".colorize.green }
                puts
                print_msg(rmsg)
              end
              socket.close
            else
              puts "ERROR: Dont know how you got here".colorize.red.yellow
              exit
            end
          rescue e
            Log.error {  "Error: #{e.inspect}".colorize.red }
          end
        end
      end

      sub "msg" do
        desc "Creates a message and outputs it in various formats"
        usage "xet msg [options]"
        option "-w TEMPLATE", "--template=TEMPLATE", type: String, desc: "Template for the message. Use 'xet info command templates' to see available templates", default: "Blank"

        option "-a TYPE", "--type=TYPE", type: String, desc: "The type field of the packet"
        option "-b VERSION", "--version=VERSION", type: String, desc: "The version field of the packet"
        option "-c RESERVED1", "--reserved1=RESERVED1", type: String, desc: "The reserved1 field of the packet"
        option "-d RESERVED2", "--reserved2=RESERVED2", type: String, desc: "The reserved2 field of the packet"
        option "-e SESSION_ID", "--session_id=SESSION_ID", type: String, desc: "The session_id field of the packet"
        option "-f SEQUENCE", "--sequence=SEQUENCE", type: String, desc: "The sequence field of the packet"
        option "-g TOTAL_PACKETS", "--total_packets=TOTAL_PACKETS", type: String, desc: "The total_packets field of the packet"
        option "-h CURRENT_PACKET", "--current_packet=CURRENT_PACKET", type: String, desc: "The current_packet field of the packet"
        option "-i ID", "--id=ID", type: String, desc: "The id field of the packet"
        option "-j SIZE", "--size=SIZE", type: String, desc: "The size field of the packet"
        option "-m MESSAGE", "--message=MESSAGE", type: String, desc: "The JSON message to send"

        run do |opts, args|
          template_class = XET::Command::Blank
          full_command_name = opts.template =~ /^XET::Command::/ ? opts.template : "XET::Command::#{opts.template}"

          if XET::Commands[full_command_name]?
            template_class = XET::Commands[full_command_name]
          else
            puts "NOT A VALID TEMPLATE #{opts.template}|#{full_command_name}" unless opts.template == "?"
            puts "Available Templates: \n#{XET::Commands.to_h.values.join("\n").gsub(/XET::Command::/, "")}"
            exit
          end

          msg = template_class.new


          xsock_opts_parse(type, UInt8)
          xsock_opts_parse(version, UInt8)
          xsock_opts_parse(reserved1, UInt8)
          xsock_opts_parse(reserved2, UInt8)
          xsock_opts_parse(session_id, UInt32)
          xsock_opts_parse(sequence, UInt32)
          xsock_opts_parse(total_packets, UInt8)
          xsock_opts_parse(current_packet, UInt8)
          xsock_opts_parse(id, UInt16)
          xsock_opts_parse(size, UInt32)
          msg.message = message if message = opts.message
          
          # Fix size
          if !msg.use_custom_size?
            msg.size = msg.message.size.to_u32
          end

          puts msg.to_s.inspect.gsub(/(^\")|(\"$)/, "\'")
        end
      end

      sub "info" do
        desc "Gives an output of various important information for XET"
        usage "xet info [sub_command] [options]"

        run do |o, a|
          puts o.help_string
          exit
        end

        sub "ret" do
          desc "Lists all known Ret codes"
          usage "xet info ret [ret_code]"
          argument "retcode", type: String, desc: "A ret code to look up", default: ""
          run do |o, a|
            if a.retcode.empty?
              puts "Ret Codes:"
              XET::Ret::ALL.each do |ret, ret_hash|
                puts "#{ret_hash[:code]} - #{ret_hash[:msg]}".colorize((ret_hash[:success] ? :green :  :red))
              end
            else
              begin
                if ret_hash = XET::Ret[a.retcode.to_i]?
                  puts "#{ret_hash[:code]} - #{ret_hash[:msg]}".colorize((ret_hash[:success] ? :green :  :red))
                else
                  Log.error {"No code found for #{a.retcode}"}
                end
              rescue e : ArgumentError
                Log.error {"#{a.retcode} was not an Int32!"}
              end
            end
            exit
          end
        end

        sub "command" do
          desc "XET::Command related information"
          usage "xet info command [sub_command] [options]"
          
          run do |o, a|
            puts o.help_string
            exit
          end

          sub "templates" do
            desc "Lists all command templates in XET::Commands"
            usage "xet info command templates [options]"
            run do |o, a|
              puts "Available Commands: \n#{XET::Commands.to_h.values.join("\n").gsub(/XET::Command::/, "")}"
              exit
            end
          end

          sub "bad" do
            desc "Lists all known bad command ids in XET::Commands"
            usage "xet info command bad [options]"
            run do |o, a|
              puts "Bad Command Ids: \n#{XET::Command::Ids::Bad::ALL.to_a.map{|h| "#{h[0]} | 0x#{h[0].to_s(16).rjust(4, '0')} => #{h[1]}"}.join("\n").gsub(/XET::Error::/, "")}"
              exit
            end
          end

          
          sub "ids" do
            desc "Lists all known command ids in XET::Commands"
            usage "xet info command ids [options]"
            run do |o, a|
              puts "Command Ids:"
              XET::Command::Ids::ALL.each do |command_name, command_hash|
                puts "  #{command_name}"
                command_hash.each do |k, v|
                  puts "      #{k} = #{v} | 0x#{v.to_s(16).rjust(4, '0')}"
                end
              end
              exit
            end
          end
        end
      end

      sub "mitm" do
        desc "Creates a mitm handler, who will listen on a port, and attempt to hijack clients/cameras from broadcast"
        usage "xet mitm [options]"
        option "-i", "--interface=INF", type: String, desc: "The interface you would like to bind to.", default: "enp3s0"
        # option "--client-ips=IPS", type: String, desc: "The IPs of clients you would like to hijack"
        # option "--camera-ips=IPS", type: String, desc: "The IPs of cameras you would like to hijack"
        # option "--camera-macs=MACS", type: String, desc: "The MACs of cameras you would like to hijack"
        # option "--camera-sns=SNS", type: String, desc: "The SNs of cameras you would like to hijack"
        # option "--camera-names=NAMES", type: String, desc: "The names of cameras you would like to hijack"
        option "-p PORT", "--port=PORT", type: UInt16, desc: "The discovery port you would like to bind to.", default: 34569_u16

        run do |o, a|
          XET::App.setup(o.interface)
          mitm_handler = XET::App::MITM::Handler.new(o.port)

          sleep 1.day

          exit
        end
      end
    end
  end
end

XET::CLI.start(ARGV)
