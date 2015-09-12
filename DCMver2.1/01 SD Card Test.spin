OBJ
  usb           : "parallaxSerialTerminal.spin"
  system        : "Propeller Board of Education"
  sd            : "PropBOE MicroSD"
  sensor        : "tier3MPUMPL_DCM.spin"

VAR
  long sensorCogId, sensorStack[128], mag[3], time, finish , acc[3], gyro[3], euler[3]
  long flag, timerStack[100] , time1, time2
  long dStack[128]
  
      
PUB main | dt, ti[2]
  flag := 1


  sensor.turnOnMpu
  sensor.startDcm
  
  system.Clock(80_000_000) 'set up sd card
  cognew(timer, @timerStack) ' set up a timer for data collection time span
  cognew(debug, @dStack)
  ' set up a txt file in sd card 
  sd.Mount(0)
  sd.FileNew(String("data1.txt"))
  sd.FileOpen(String("data1.txt"), "W") 
  sd.WriteStr(String("x      y      z"))
  sd.newline
       
  repeat while (flag) 'write the data here while timer is on (60 sec in this case)
    update   ' updates mpu data in acc[3], gyro[3], mag[3]
    time1 := cnt
    sd.writeDec(time1)
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
    sd.WriteDec(euler[0])
    sd.WriteStr(String("   "))
    sd.WriteDec(euler[1])
    sd.WriteStr(String("   "))
    sd.WriteDec(euler[2])
    sd.WriteStr(String("   "))
    sd.newline
    time2 := cnt
    if(time2 < (time1 + 1379310))
      waitcnt(cnt + time1+1379310-time2) 
  sd.FileClose
  sd.Unmount
  
PUB timer
  if flag == 1
    waitcnt(cnt + clkfreq*30)
    waitcnt(cnt + clkfreq*30)
    flag := 0


PUB debug  | localTime

  localTime := cnt
  repeat while cnt < (localTime + clkfreq*30)
    usb.dec(gyro[0])
    


    
PRI update
  sensor.getMag(@mag)
  sensor.getAcc(@Acc)
  sensor.getGyro(@gyro)
  sensor.getEulerAngles(@euler)