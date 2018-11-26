require  'rpi_gpio'


require 'net/http'
require 'json'
require 'websocket-client-simple'
require 'eventmachine'
require 'em-http-server'



def connect solution, host, port
  connect_url = "ws://#{host}:#{port}/#{solution}/Home/index"
  puts connect_url
  WebSocket::Client::Simple.connect connect_url
end


RPi::GPIO.set_numbering :board

#RPi::GPIO.set_warnings(false)


#RPi::GPIO.clean_up pin
#RPi::GPIO.reset


require 'rubygems'
require 'websocket-client-simple'
require 'json'
require 'eventmachine'
require 'active_support'
require 'serialport'



def connect solution
  WebSocket::Client::Simple.connect "ws://localhost:1792/#{solution}/Home/index"
end

def bind_event ws


ser = SerialPort.new("/dev/serial0", 9600, 8, 1, SerialPort::NONE)


ws.on :message do |msg|
  puts msg.data
  
  begin  
  
  
    t = msg.data.split(",")
    cmd = t[0]
  
    if cmd=='gpio'
        pin = t[1].to_i
        status = t[2]
        RPi::GPIO.setup pin, :as => :output
        if status=='1'
          RPi::GPIO.set_high pin
        else
          RPi::GPIO.set_low pin
        end
    elsif cmd=='servo12' or cmd=='servo34' or cmd=='servo56'
        
        p = t[1].to_i
        t = t[2].to_i
        
        def ptz ser, ch, target

        v = target
        ch = ch

        v1 = v&127
        v2 = (v>>7)&127
        c = [170,12,4,ch,v1,v2]

        for i in c
        ser.write i.chr
        end
        ser.flush

        end
        
        a = cmd[-2].to_i-1
        b = cmd[-1].to_i-1
        
        ptz ser, a, p
        ptz ser, b, t
        
        
        
        
    end
  
  rescue Exception=>e
  
	puts e
end

end

ws.on :open do

end

ws.on :close do |e|
  p e
  exit 1
end

ws.on :error do |e|d
  p "ERROR #{e}"
   puts 'will retry connect ..'
   sleep 1
   puts 'retry connect ..'
   ws = connect() 
   bind_event ws
   puts 'retry connect ..'
end

end


while true


begin 


  solution = 'ptz'
  solution = ARGV[0] if ARGV[0] 

  ws = connect(solution)
  puts 'connect'

bind_event ws

sleep(1)


# protocols = ['Alert station_id=*']
# # protocols << 'Data.Sensing device_id=Bed01'
# # protocols << 'ZoneUpdate zone_id=*'
#  
#  msg = "WS.Select name=1234\n#{protocols.to_json}"
#  puts msg
#  ws.send msg


 EventMachine.run {
   
    EM.add_periodic_timer(5) do
       
       # msg = "WS.Alive name=1234\n#{Time.now}"
       # ws.send msg
        
   end


 }

rescue Exception=>e
  puts "Try to connect in 5 seconds due to : #{e}"
  sleep(5)
end
  

end

 

