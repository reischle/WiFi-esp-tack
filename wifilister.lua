
wifi.setmode(wifi.STATION)
-- Print AP list that is easier to read
ssids = {}
bssids = {}
tplink= {}
x=0
mn=1

-- down Button is GPIO4=Pin2
gpio.mode(2, gpio.INPUT, pullup)
-- up Button is GPIO5=Pin1
gpio.mode(1, gpio.INPUT, pullup)
-- selectitem Button is GPIO2=Pin4 (that has the LED attached on the ESP12e)
gpio.mode(4, gpio.INPUT, pullup)


-- setup I2c and connect display
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


function ssid2oled()
     disp:drawStr(0, 0, "Target acquisition")
        if (x>0) then
            for i = 1, x do
                -- print ("OLED " .. i .. " = " .. ssids[i])
                disp:drawStr(10,(0+(10*i)), ssids[i])
            end
        else
             disp:drawStr(10, 20, "Scanning...")
        end
        
    -- draw selection box
    if (x>0) then
    disp:drawFrame(8, (0+(10*mn)), disp:getWidth()-15, 10)
    end

end

function showoled()
disp:firstPage()  
    repeat  
       ssid2oled()  
    until disp:nextPage() == false  
    tmr.wdclr()
end

function listap(t) -- (SSID : Authmode, RSSI, BSSID, Channel)
    --print("\n\t\t\tSSID\t\t\t\t\tBSSID\t\t\t  RSSI\t\tAUTHMODE\t\tCHANNEL")
    x=0
    for bssid,v in pairs(t) do
    x=x+1
        local ssid, rssi, authmode, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
        --print(string.format("%32s",ssid).."\t"..bssid.."\t  "..rssi.."\t\t"..authmode.."\t\t\t"..channel)
        ssids[x]=ssid
        bssids[x]=bssid:gsub(":", "")
        tplink[x]=string.upper(string.sub(bssids[x], -8))
    end
end

function listssids()
print ("SSIDS:")
for i = 1, x do
    --   print ("Number " .. i .. " = ")
      print ("Number " .. i .. " = " .. ssids[i])
    --   print (ssids[i])
end
end


function keydwn()
print ("Pressed down")
mn=mn+1
if mn>x then
 mn=mn-1
end
print ("disable interrupt")
gpio.trig(2)
end

function keyup()
print ("Pressed up")
mn=mn-1
if mn < 1 then
   mn=mn+1
end
print ("disable interrupt")
gpio.trig(1)
end

function selectitem()
print ("Selected item " .. mn)
print ("That is: " .. ssids[mn])
print ("disable all button interrupts")
gpio.trig(4)
gpio.trig(2)
gpio.trig(1)
print ("disable timers")
tmr.stop(1) --disable renew ssid list
tmr.stop(0) --disable menu system
dofile ("autohack.lua")
end
 
--Setup buttons
function setupbuttons()
--print ("Register Interrupt")
gpio.mode(2, gpio.INPUT, pullup)
gpio.trig(2,"down",keydwn)
gpio.mode(1, gpio.INPUT, pullup)
gpio.trig(1,"down",keyup)
gpio.mode(4, gpio.INPUT, pullup)
gpio.trig(4,"down",selectitem)
end


--Here the main stuff starts
--get the OLED ready
init_i2c_display()


-- Populate ssid list
tmr.alarm(1,30000,1, function()
wifi.sta.getap(1, listap)
end)

--display ssids
tmr.alarm(0, 500, 1 , function()
    --listssids()
    showoled()
    setupbuttons()
end)
