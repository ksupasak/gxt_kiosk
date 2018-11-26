require 'net/http'

def post_xml url_string, headers, data
  uri = URI.parse url_string
 
  
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = false
  
  

  response = http.post(uri.path, data, headers)
  puts "SOAP : " + headers['SOAPAction']
  puts data
  puts  
  puts response.body
  puts
  
  response.body
end

def call cmd, params=nil, extra=''
  

url = "http://192.168.0.25/axis2/services/BrueBoxService"

headers = {
  'Content-Type' => 'text/xml; charset=utf-8',
  'SOAPAction' => "#{cmd}Operation"
}

p = ""

if params
  
  params.each_pair do |k,v|
  
    p << "<#{k}>#{v}</#{k}>"
    
  end

  
end

xml = <<CMD
<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
<soap:Body>
<#{cmd}Request xmlns="http://www.glory.co.jp/bruebox.xsd">
#{p}
#{extra}
</#{cmd}Request>
</soap:Body>
</soap:Envelope>
CMD


post_xml url, headers, xml
  
end



def payment_start amount, id= 0, seq_no = 1000, session_id=0
  

amount *= 100
  

params = {"Id"=>id, "SeqNo"=>seq_no+1, "SessionID"=>session_id}

call "StartCashin" , params

sleep 0.1

params.merge! "Amount"=>amount, "SeqNo"=>seq_no+2

call "RefreshSalesTotal", params
#
# sleep 5
#
# params.merge! "Amount"=>amount, "SeqNo"=>seq_no+2
#
# call "Change", params, '<Cash d4p1:type="0" xmlns:d4p1="http://www.glory.co.jp/bruebox.xsd" xmlns="" />'

return seq_no+2

end


def payment_end  id= 0, seq_no = 1000, session_id=0

  params = {"Id"=>id, "SeqNo"=>seq_no+1, "SessionID"=>session_id}


call "Change", params, '<Cash d4p1:type="0" xmlns:d4p1="http://www.glory.co.jp/bruebox.xsd" xmlns="" />'

return seq_no+1

end


# pay 4





def payment_cancel timeout = 10, id= 0, seq_no = 1000, session_id=0
  
  
  params = {"Id"=>id, "SeqNo"=>seq_no+1, "SessionID"=>session_id}
  
  call "CashinCancel" , params

  return seq_no+1
end



def status  timeout = 10, id= 0, seq_no = 1000, session_id=0
  
  
  params = {"Id"=>id, "SeqNo"=>seq_no, "SessionID"=>session_id}
  
  call "Status" , params, '<Option d4p1:type="0" xmlns:d4p1="http://www.glory.co.jp/bruebox.xsd" xmlns="" />'
  
  params.merge! "SeqNo"=>seq_no+1
  call "Inventory" , params, '<Option d4p1:type="0" xmlns:d4p1="http://www.glory.co.jp/bruebox.xsd" xmlns="" />' 
  
  
end

# status




def refill timeout = 10, id= 0, seq_no = 1000, session_id=0
  
  
  params = {"Id"=>id, "SeqNo"=>seq_no, "SessionID"=>session_id}
  
  call "StartReplenishmentFromEntrance" , params
  
  sleep timeout
  
  params.merge!  "SeqNo"=>seq_no+1
  call "EndReplenishmentFromEntrance" , params
  
  
end


def cash_out amount, count, timeout = 10, id= 0, seq_no = 1000, session_id=0
  
  
  device_id = 2
  
  device_id = 1 if amount > 10
  
  params = {"Id"=>id, "SeqNo"=>seq_no, "SessionID"=>session_id}
  extra = <<EOF
<Delay d4p1:type="0" d4p1:time="0" xmlns:d4p1="http://www.glory.co.jp/bruebox.xsd" xmlns="" />
<Cash d4p1:type="2" xmlns:d4p1="http://www.glory.co.jp/bruebox.xsd" xmlns="">
<Denomination d4p1:cc="THB" d4p1:fv="#{amount*100}" d4p1:rev="0" d4p1:devid="#{device_id}">
<d4p1:Piece>#{count}</d4p1:Piece>
<d4p1:Status>0</d4p1:Status>
</Denomination>
</Cash>
EOF

  call "Cashout" , params, extra
  
end


# cash_out 5, 1

# refill 


def collect timeout = 10, id= 0, seq_no = 1000, session_id=0
  
  
  params = {"Id"=>id, "SeqNo"=>seq_no, "SessionID"=>session_id}

extra = <<EOF 
<Option d4p1:type="0" xmlns:d4p1="http://www.glory.co.jp/bruebox.xsd" xmlns="" />
<Mix d4p1:type="1" xmlns:d4p1="http://www.glory.co.jp/bruebox.xsd" xmlns="" />
<IFCassette d4p1:type="1" xmlns:d4p1="http://www.glory.co.jp/bruebox.xsd" xmlns="" />

<Cash d4p1:type="5" xmlns:d4p1="http://www.glory.co.jp/bruebox.xsd" xmlns="">
<Denomination d4p1:cc="THB" d4p1:fv="2000" d4p1:rev="0" d4p1:devid="1"><d4p1:Piece>10</d4p1:Piece><d4p1:Status>0</d4p1:Status></Denomination>
<Denomination d4p1:cc="THB" d4p1:fv="10000" d4p1:rev="0" d4p1:devid="1"><d4p1:Piece>10</d4p1:Piece><d4p1:Status>0</d4p1:Status></Denomination>
<Denomination d4p1:cc="THB" d4p1:fv="50000" d4p1:rev="0" d4p1:devid="1"><d4p1:Piece>10</d4p1:Piece><d4p1:Status>0</d4p1:Status></Denomination>
<Denomination d4p1:cc="THB" d4p1:fv="500" d4p1:rev="0" d4p1:devid="2"><d4p1:Piece>10</d4p1:Piece><d4p1:Status>0</d4p1:Status></Denomination>
<Denomination d4p1:cc="THB" d4p1:fv="100" d4p1:rev="0" d4p1:devid="2"><d4p1:Piece>10</d4p1:Piece><d4p1:Status>0</d4p1:Status></Denomination>
<Denomination d4p1:cc="THB" d4p1:fv="1000" d4p1:rev="0" d4p1:devid="2"><d4p1:Piece>10</d4p1:Piece><d4p1:Status>0</d4p1:Status></Denomination>
</Cash>
EOF
  
  
  call "Collect" , params, extra
  
  sleep 10
  
  
  params.merge!  "SeqNo"=>seq_no+1
  call "UnLockUnit" , params, '<Option d4p1:type="1" xmlns:d4p1="http://www.glory.co.jp/bruebox.xsd" xmlns="" />'
   params.merge!  "SeqNo"=>seq_no+2
  call "UnLockUnit" , params, '<Option d4p1:type="2" xmlns:d4p1="http://www.glory.co.jp/bruebox.xsd" xmlns="" />'
  
  
end

# payment_end

# sleep 5
# refill
# sleep 5
# cash_out 20, 1
# sleep 10
# pay 5
# sleep 5
# collect

# 
# collect


# 'fì÷,³ßEñù5@@¼]À¨À¨
# PúîÂA!08pPþ$õHTTP/1.1 200 OK
# Date: Sun, 25 Nov 2018 05:59:00 GMT
# Server: Apache/2.2.29 (Unix) mod_ssl/2.2.29 OpenSSL/1.0.1u Axis2C/1.5.0
# Content-Length: 795
# Content-Type: text/xml
# 
# <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header></soapenv:Header><soapenv:Body><n:ChangeResponse xmlns:n="http://www.glory.co.jp/bruebox.xsd" n:result="0"><n:Id>0</n:Id><n:SeqNo>1006</n:SeqNo><n:User></n:User><n:Amount>500</n:Amount><n:ManualDeposit>0</n:ManualDeposit><Status><n:Code>19</n:Code><DevStatus n:devid="1" n:val="0" n:st="1500"></DevStatus><DevStatus n:devid="2" n:val="0" n:st="3000"></DevStatus></Status><Cash n:type="1"><Denomination n:cc="THB" n:fv="1000" n:rev="0" n:devid="2"><n:Piece>1</n:Piece><n:Status>0</n:Status></Denomination></Cash><Cash n:type="2"><Denomination n:cc="THB" n:fv="500" n:rev="0" n:devid="2"><n:Piece>1</n:Piece><n:Status>0</n:Status></Denomination></Cash></n:ChangeResponse></soapenv:Body></soapenv:Envelope>
