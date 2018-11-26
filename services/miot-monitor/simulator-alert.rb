require 'rubygems'
require 'websocket-client-simple'
require 'json'
require 'eventmachine'
require 'active_support'

def connect solution
  WebSocket::Client::Simple.connect "ws://localhost:1792/#{solution}/Home/index"
end

def bind_event ws

ws.on :message do |msg|
  puts msg.data
  cmd = `python /home/pi/camera.py`
  
  begin  
  img = Base64.encode64(open("/home/pi/Desktop/image.jpg"){|io|io.read})
  puts img.size
msg = <<MSG
Data.Image station_id=*
#{img.encode('utf-8').to_json}
MSG
  
  ws.send(msg)
 puts 'send'
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


  solution = 'miot'
  solution = ARGV[0] if ARGV[0] 

  ws = connect(solution)
  puts 'connect'

bind_event ws

sleep(1)
protocols = ['Alert station_id=*']
# protocols << 'Data.Sensing device_id=Bed01'
# protocols << 'ZoneUpdate zone_id=*'
 
 msg = "WS.Select name=1234\n#{protocols.to_json}"
 puts msg
 ws.send msg


 EventMachine.run {
   
    EM.add_periodic_timer(5) do
       
       msg = "WS.Alive name=1234\n#{Time.now}"
       ws.send msg
        
   end


 }

rescue Exception=>e
  puts "Try to connect in 5 seconds due to : #{e}"
  sleep(5)
end
  

end

 

