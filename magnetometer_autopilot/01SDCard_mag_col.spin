CON
_clkmode = xtal1 + pll16x                                                    
_xinfreq = 5_000_000

OBJ
  fds           : "FullDuplexSerial"
  system        : "Propeller Board of Education"
  sd            : "PropBOE MicroSD"
  sensor        : "tier3MPUMPL_DCM.spin"

VAR
  long sensorCogId, sensorStack[128], mag[3], time, finish , acc[3], gyro[3]
  long flag, timerStack[100]

  long debugStack[128], dt, prev

  
PUB main     | i

  fds.quickStart
  fds.clear

  flag := 1
  startSensor ' mpu starts
  system.Clock(80_000_000) 'set up sd card

  cognew(timer, @timerStack) ' set up a timer for data collection time span

  
  ' set up a txt file in sd card 
  sd.Mount(0)
  if sd.FileNew(String("data1.txt")) > 0
     fds.strln(String("file name created"))
     
  if sd.FileOpen(String("data1.txt"), "W") >0
    fds.strln(String("file opened")) 


  cognew(debug, @debugStack)
  repeat while (flag) 'write the data here while timer is on (60 sec in this case)
    update   ' updates mag[3]
    repeat i from 0 to 2    
      sd.WriteDec(mag[i])
      sd.WriteStr(String("   ")) 
    sd.newline


    
  waitcnt(cnt + clkfreq)
  
  if sd.FileClose > 0
    fds.strln(String("file closed"))
    
  if sd.Unmount >0
    repeat
      fds.strln(String("sd card unmounted"))
     
PRI startSensor 
  sensor.masterKey_tier3
  
PUB timer
  if flag == 1
    waitcnt(cnt + clkfreq*30)
    waitcnt(cnt + clkfreq*30)
    flag := 0
PRI update
  sensor.getMag(@mag)
'  sensor.getAcc(@Acc)
'  sensor.getGyro(@gyro)

PRI stopSensor
  if sensorCogId
    cogstop(sensorCogId ~ - 1)



PUB debug
  repeat while flag > 0
    fds.clear
    fds.str(string("dt = "))
    fds.decln(dt)
    fds.str(string("freq = "))
    fds.decln(80000000/dt)
    waitcnt(cnt + clkfreq/10)