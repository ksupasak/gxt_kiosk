
register_app 'dtac', 'gxt-kiosk'

require 'serialport'
require 'nokogiri'
require_relative 'lib'


module GxtKiosk
  
    #
  # class CameraSetting
  #   include MongoMapper::Document
  #   key :name, String
  #
  #   key :servo1_name, String
  #   key :servo2_name, String
  #   key :servo3_name, String
  #   key :servo4_name, String
  #   key :servo5_name, String
  #   key :servo6_name, String
  #
  #   key :servo1, String
  #   key :servo2, String
  #   key :servo3, String
  #   key :servo4, String
  #   key :servo5, String
  #   key :servo6, String
  #
  #   key :power_gpio, String # 13
  #
  #   key :power_schedule_1, String
  #   key :power_schedule_2, String
  #   key :power_schedule_3, String
  #   key :power_schedule_4, String
  #   key :power_schedule_5, String
  #   key :power_schedule_6, String
  #   key :power_schedule_7, String
  #
  #
  #
  # end
  #
  # class CameraSettingController < GXTDocument
  #
  # end
  
   class HomeController < GXT
     
     
     
     def websocket request

       @seq_no = 1000
       
           request.websocket do |ws|

             puts 'init websocket '
             

              ws.onopen do
                puts 'init websocket '
                @context.settings.apps_ws[@context.settings.name] << ws
                @context.settings.apps_ws_rv[ws] = @context.settings.name
                
              end
              
              ws.onclose do
                warn("websocket closed")
                @context.settings.apps_ws[@context.settings.name].delete(ws)
              end
              
              ws.onmessage do |msg|
                name =  @context.settings.apps_ws_rv[ws]
                switch name
                puts  "msg from #{@context.settings.name} #{msg}"

                 
                t = msg.split(" ")
                
                cmd = t[0]
                
                case cmd
                  
                when "PAYMENT"
                  
                  method = t[1]
                  
                      case method
                  
                      when "START"
                    
                        amount = t[2].to_i
                       payment_start amount,0, @seq_no
                       @seq_no += 2
                    
                      when "END"
                        payment_end 0, @seq_no
                        @seq_no += 1
                    
                      when "CANCEL"
                        payment_cancel 0, @seq_no
                        @seq_no +=1
                      end
                

                      # $('#refill-start-btn').click(function(){
     #                    ws.send("REFILL START")
     #                  })
     #                  $('#refill-stop-btn').click(function(){
     #                    ws.send("REFILL END")
     #                  })
     #
     #                  $('#cashout-btn').click(function(){
     #                    ws.send("CASHOUT 20 1")
     #                  })
     #
     #                  $('#collect-btn').click(function(){
     #                    ws.send("COLLECT ALL")
     #                  })
     #
     #                  $('#collect-btn').click(function(){
     #                    ws.send("DOOR OPEN")
     #                  })
     #
                  
                 when "REFILL"
                    method = t[1]
                    case method
                      
                    when 'START'
                      refill_start 0, @seq_no
                      @seq_no+=1
                    when 'END'
                      refill_end 0, @seq_no
                      @seq_no+=1
                    end
                   
                   
                   
                 when "CASHOUT"
                   
                   cash_out 20, 1, 0, @seq_no
                   @seq_no+=1
                   
                  
                 when "COLLECT"
                   
                   collect_money 0, @seq_no
                   @seq_no+=1
                   
                 when "DOOR"
                   
                  
                   
                    door_open 0, @seq_no
                    @seq_no+=1
                   
                  
                else  
                  
                end
                 
                 
                 
                 
                for i in @context.settings.apps_ws[@context.settings.name]
                    # if ws!=i
                      i.send(msg)
                    # end
                 end
              # end

     
             end
           end
            
      end      
     
   end
  
  
  
def self.settings
      @@settings
end

def self.process s
  
  # <BbxEventRequest><StatusChangeEvent>
  #     <Status>4</Status>
  #     <Amount>1500</Amount>
  #     <Error>0</Error>
  #     <RecoveryURL />
  #     <User />
  #     <SeqNo />
  # </StatusChangeEvent>
  # </BbxEventRequest>      
  
  doc  = xml_doc  = Nokogiri::XML(s)
  status = doc.xpath("//BbxEventRequest//StatusChangeEvent//Status")
  
  if status.text=='4'
    
    amount = doc.xpath("//BbxEventRequest//StatusChangeEvent//Amount").text
    puts "CASHIN #{amount}"
    for ws in settings.apps_ws[settings.name]
        ws.send "CASHIN #{amount.to_f/100}"
    end
    
    
  end
  
  
end



def self.stamp text
  
  t = text.split(':').collect{|i| i.to_i}
  t = t[0]*60+t[1]
  
end


module GloryCallBackServer
  def post_init
    puts "-- someone connected to the echo server!"
  end

  def receive_data data
    
    puts self.inspect 
    puts data
    
    GxtKiosk::process data
    # send_data ">>> you sent: #{data}"
  end
end



def self.registered(app)
  
  
  puts 'Start Kiosk'
  
  
  
  
  @@settings = app.settings
  settings.set :ws_map, {}
  
  
   EM.next_tick do
  
     EM.add_periodic_timer(5) do
     
       puts 'tick '+app.settings.apps_ws[app.settings.name].size.to_s

       
       msg = <<EOF
<BbxEventRequest><StatusChangeEvent>
   <Status>4</Status>
   <Amount>15000</Amount>
   <Error>0</Error>
   <RecoveryURL />
   <User />
   <SeqNo />
</StatusChangeEvent>
</BbxEventRequest>
EOF

    # process msg
       
       # for ws in app.settings.apps_ws[app.settings.name]
       #     ws.send "tick #{Time.now}"
       # end
       
     end
     
   end
   
   #. glory api
  EM.next_tick do 
   EventMachine::start_server "192.168.0.10", 55561, GloryCallBackServer
    puts 'running GloryCallBackServer on 55561'
  end
   # EM.next_tick do
   #
   #   EM.add_timer(1) do
   #   require 'socket'
   #
   #   server = TCPServer.new 55561
   #
   #   puts 'start server'
   #   loop do
   #     Thread.start(server.accept) do |client|
   #
   #       while (s=client.gets)
   #
   #         puts s
   #         process(s)
   #
   #       end
   #
   #     end
   #   end
   #
   # end
   #
   # end
     
     # puts 'PTZ Ctrl Daemon'
 #     @@settings = app.settings
 #
 #     settings.set :ws_map, {}
 #     settings.set :cmd_map, {}
 #
 #
 #     gpio_stage = 1
 #     flush = true
 #
 #
 #     EM.next_tick {
 #        EM.add_periodic_timer(1) do
 #
 #
 #          if app.settings.apps_rv
 #
 #
 #
 #
 #
 #          for name in app.settings.apps_rv['gxt-ptz']
 #          switch name
 #
 #
 #
 #          if app.settings.apps_ws[app.settings.name]
 #
 #
 #            setting = CameraSetting.first
 #
 #            if setting
 #              # gpio,13,0
 #
 #              day = Time.now.wday
 #              period = setting["power_schedule_#{day}"]
 #              if period and period.size > 0 and t = period.split("-") and t.size==2
 #                puts "Today Power Schdule : #{period} - Now : #{Time.now.strftime('%H:%M')} #{gpio_stage}"
 #
 #
 #                now = stamp(Time.now.strftime('%H:%M'))
 #                   for ws in app.settings.apps_ws[app.settings.name]
 #                     ws.send "schedule,#{Time.now.strftime('%H:%M:%S')},#{period}"
 #                    end
 #
 #                start = stamp(t[0])
 #                stop = stamp(t[1])
 #
 #                if now >= start and now <= stop
 #                  flush = true if gpio_stage == 0
 #                  gpio_stage = 1
 #                else
 #                  flush = true if gpio_stage == 1
 #                  gpio_stage = 0
 #                end
 #
 #                if flush
 #                if gpio_stage == 1
 #                  for ws in app.settings.apps_ws[app.settings.name]
 #                    puts "Power On"
 #                    ws.send "gpio,#{setting.power_gpio},1"
 #                  end
 #                else
 #                  for ws in app.settings.apps_ws[app.settings.name]
 #                    puts "Power Off"
 #                    ws.send "gpio,#{setting.power_gpio},0"
 #                  end
 #                end
 #
 #                end
 #                    flush = false
 #
 #
 #                # for ws in app.settings.apps_ws[app.settings.name]
 #                #                  ws.send "alive now #{now} : start #{start} - stop #{stop}"
 #                #  end
 #
 #              else
 #                puts "Schedule is not Set"
 #
 #              end
 #
 #
 #
 #            else
 #                # gpio,13,0
 #            end
 #
 #
 #
 #          end
 #
 #
 #
 #          end
 #
 #          end
 #
 #        end
 #      }

end
end

module Sinatra


 register GxtKiosk

end