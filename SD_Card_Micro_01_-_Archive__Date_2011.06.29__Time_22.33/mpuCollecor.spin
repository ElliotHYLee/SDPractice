CON
  _clkmode = xtal1 + pll16x             ' Set up the clock frequencies
  _xinfreq = 5_000_000

'  CD  = 4       ' Propeller Pin 4 - Uncomment this line if you are using the Chip Detect function on the card. See below. 
  CS  = 8       ' Propeller Pin 3 - Set up these pins to match the Parallax Micro SD Card adapter connections.
  DI  = 11       ' Propeller Pin 2 - For additional information, download and refer to the Parallax PDF file for the Micro SD Adapter.                        
  CLK = 13       ' Propeller Pin 1 - The pins shown here are the correct pin numbers for my Micro SD Card adapter from Parallax                               
  D0  = 12       ' Propeller Pin 0 - In addition to these pins, make the power connections as shown in the following comment block.

OBJ
  sdfat         : "fsrw"                       ' Download the fswr.spin object from the Parallax Propeller Object Exchange (OBEX), accessed from parallax.com
  pst           : "ParallaxSerialTerminal"   ' If you don't already have it in your working directory, you can also download this object from OBEX.
  sensor        : "tier2MPUMPL_Refinery.spin"
  str           : "ASCII0_STREngine_1.spin"
VAR

  long acc[3], mag[3], gyro[3], finish
  long sensorCogId, sensorStack
            
PUB demo | insert_card, text, check, a[3], g[3], q[3]
  pst.Start(115_200) 

  waitcnt(clkfreq*1 + cnt)  

  repeat
    pst.dec(clkfreq)
    pst.newline  
                  
  pst.str(string("starts!"))
  pst.newline
  
  insert_card := \sdfat.mount_explicit(D0, CLK, DI, CS)        ' Here we call the 'mount' method using the 4 pins described in the 'CON' section.
  if insert_card < 0                                           ' If mount returns a zero...
    pst.str(string(13))                                        ' Print a carriage return to get a new line.
    pst.str(string("The Micro SD Card was not found!"))        ' Print the failure message.
    pst.str(string(13))                                        ' Carriage return...
    pst.str(string("Insert card, or check your connections.")) ' Remind user to insert card or check the wiring.
    pst.str(string(13))                                        ' And yet another carriage return.
    abort

  pst.str(string("preparing the file!"))   
  ' create file
  sdfat.popen(string("output.txt"), "w")  ' Open output.txt, a text file, to receive your line of text.
                                          ' Change "a" to "w" if you want to overwrite the text each time.
  

                                                         ' Then we abort the program.
  pst.str(string("starting sensor!"))   
  startSensor
  pst.str(string("sensor at: "))
  pst.dec(sensorCogId)

  repeat 1000
    pst.dec(acc[2])
    pst.newline



  pst.str(string("i here 0"))
  check := 1
  repeat while (check)
    if pst.RxCount > 4
      pst.str(string("i here 1"))  
      check := 0 
    else
      pst.str(string("i here 2"))    
      a[2] := acc[2]
      text := str.integerToDecimal(a[2], 6)   
      pst.Str(text) 
      sdfat.pputs(String("   "))
      sdfat.pputs(text)

      
  sdfat.pclose                            
  pst.str(string(13))                     
  pst.str(string("file closed"))
  pst.str(string(13))
  
  sdfat.unmount                           ' This line dismounts the card so you can safely remove it.
  pst.str(string(13))                     
  pst.str(string("sd unmounted"))
  pst.str(string(13))

PRI update
  sensor.getHeading(@mag)
  sensor.getAcc(@acc)
  sensor.getGyro(@gyro)

PRI stopSensor
  if sensorCogId
    cogstop(sensorCogId ~ - 1)
  
PRI startSensor 
  sensor.initSensor(15,14) ' scl, sda, cFilter portion in %
  sensor.setMpu(%000_00_000, %000_00_000) 
  stopSensor
  sensorCogId:= cognew(runSensor, @sensorStack) + 1

PRI runSensor
  repeat
    sensor.run
    update