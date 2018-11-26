require 'rubygems'
require 'websocket-client-simple'
require 'json'
require 'eventmachine'
require 'active_support'

def incomming solution, host='localhost', port=1792
  WebSocket::Client::Simple.connect "ws://#{host}:#{port}/#{solution}/Home/index"
end

def outgoing solution, host='localhost', port=1792
  WebSocket::Client::Simple.connect "ws://#{host}:#{port}/#{solution}/Home/index"
end

def bind_event ws_in, ws_out

ws_in.on :message do |msg|
  puts msg.data

  
  msg = <<MSG
Zone.Data zone=default
#{msg.data.split("\n")[-1]}
MSG
  # begin
  ws_out.send msg
  # rescue Exception=>e
  # puts e
  # end
#   cmd = `python /home/pi/camera.py`
#   
#   begin  
#   img = Base64.encode64(open("/home/pi/Desktop/image.jpg"){|io|io.read})
#   puts img.size
# msg = <<MSG
# Data.Image station_id=*
# #{img.encode('utf-8').to_json}
# MSG
#   
#   ws.send(msg)
#  puts 'send'
#   rescue Exception=>e
#   
#   puts e
# end

end

ws_in.on :open do

end

ws_in.on :close do |e|
  p e
  exit 1
end

ws_out.on :close do |e|
  puts '** out close'
  
  exit 1
end

ws_out.on :error do |e|d
  p "ERROR #{e}"
   puts 'will retry connect ..'
   sleep 1
   puts 'retry connect ..'
   ws_in = incomming 'miot' 
   bind_event ws_in, ws_out
   puts 'retry connect ..'
end

ws_in.on :error do |e|d
  p "ERROR #{e}"
   puts 'will retry connect ..'
   sleep 1
   puts 'retry connect ..'
   ws_in = incomming 'miot' 
   bind_event ws_in, ws_out
   puts 'retry connect ..'
end

end


while true


begin 


  solution = 'miot'
  
  solution = ARGV[0] if ARGV[0] 
  
  outgoing = 'localhost:1793'
  
  outgoing = ARGV[1] if ARGV[1]
  
  outgoing_host, outgoing_port = outgoing.split(':')
  
  incoming = 'localhost:1793'
  
  incoming = ARGV[2] if ARGV[2]
  
  incoming_host, incoming_port = incoming.split(':')

  ws_in = incomming(solution, incoming_host, incoming_port)
  
  ws_out = outgoing(solution, outgoing_host, outgoing_port)
  
  puts 'connect'

  ws_out.on :open do
    
  puts 'connect...'  

  end
  
  bind_event ws_in , ws_out

 sleep(1)


 protocols = ['ZoneUpdate zone_id=*']
 msg = "WS.Select name=*\n#{protocols.to_json}"
 puts msg
 ws_in.send msg
 
 

 EventMachine.run {
   
    EM.add_periodic_timer(5) do
       
       msg = "WS.Alive name=1234\n#{Time.now}"
       ws_in.send msg
        
   end


 }

rescue Exception=>e
  puts "Try to connect in 5 seconds due to : #{e}"
  sleep(5)
end
  

end

 

