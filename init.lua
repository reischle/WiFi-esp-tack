function startup()
    uart.on("data")
    if abort == true then
        print('startup aborted')
        return
        end
    print ("---------------------")
    print('Starting Target acquisition')
    dofile('wifilister.lua')
    print ("---------------------")
    end

 -- prepare abort procedure
    abort = false
    print('Send some xxxx Keystrokes now to abort startup.')
    -- if <CR> is pressed, abort
      uart.on("data", "x", 
      function(data)
        print("receive from uart:", data)
        if data=="x" then
          abort = true 
          uart.on("data") 
        end        
    end, 0)


print ('Will launch prog in 5 seconds...')
tmr.alarm(0,5000,0,startup)
