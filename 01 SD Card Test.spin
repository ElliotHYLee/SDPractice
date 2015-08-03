OBJ
  usb           : "parallaxSerialTerminal.spin"
  system        : "Propeller Board of Education"
  sd            : "PropBOE MicroSD"
  sensor        : "tier2MPUMPL_Refinery.spin"

VAR
  long sensorCogId, sensorStack[128], mag[3], time, finish , acc[3], gyro[3]
  long flag, timerStack[100]
      
PUB main | dt, ti[2]
  flag := 1
  startSensor ' mpu starts
  system.Clock(80_000_000) 'set up sd card
  cognew(timer, @timerStack) ' set up a timer for data collection time span

  ' set up a txt file in sd card 
  sd.Mount(0)
  sd.FileNew(String("data1.txt"))
  sd.FileOpen(String("data1.txt"), "W") 
  sd.WriteStr(String("x      y      z"))
  sd.newline
       
  repeat while (flag) 'write the data here while timer is on (60 sec in this case)
    update   ' updates mpu data in acc[3], gyro[3], mag[3]
    sd.writeDec(cnt)
    sd.WriteStr(String("   "))
    sd.WriteDec(mag[0])
    sd.WriteStr(String("   "))
    sd.WriteDec(mag[1])
    sd.WriteStr(String("   "))
    sd.WriteDec(mag[2])
    sd.WriteStr(String("   "))
    sd.WriteDec(acc[0])
    sd.WriteStr(String("   "))
    sd.WriteDec(acc[1])
    sd.WriteStr(String("   "))
    sd.WriteDec(acc[2])
    sd.WriteStr(String("   "))
    sd.WriteDec(gyro[0])
    sd.WriteStr(String("   "))
    sd.WriteDec(gyro[1])
    sd.WriteStr(String("   "))
    sd.WriteDec(gyro[2])
    sd.WriteStr(String("   "))
    sd.newline
    if(cnt < (cnt + 3734912))
      waitcnt(cnt + 3734912) 
  sd.FileClose
  sd.Unmount
  
PRI startSensor 
  sensor.initSensor(15,14) ' scl, sda, cFilter portion in %
  sensor.setMpu(%000_00_000, %000_00_000) 
  stopSensor
  sensorCogId:= cognew(runSensor, @sensorStack) + 1
PUB timer
  if flag == 1
    waitcnt(cnt + clkfreq*30)
    waitcnt(cnt + clkfreq*30)
    flag := 0
PRI update
  sensor.getHeading(@mag)
  sensor.getAcc(@Acc)
  sensor.getGyro(@gyro)

PRI stopSensor
  if sensorCogId
    cogstop(sensorCogId ~ - 1)

PRI runSensor
  repeat
    sensor.run