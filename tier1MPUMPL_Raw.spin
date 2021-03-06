{{
  9-axis MPU-9150

  I2C address is %1101_0000

  Rewritten to use i2c library exclusively
}}
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  
  'I2C registers for the MPU-9150
  
  MPU_add                       = c#MPU_address
  AKM_address                   = c#AKM_address
            
  pcport                        = c#pcport
  pcrx                          = c#pcrx
  pctx                          = c#pctx
  pcbaud                        = c#pcbaud

  
OBJ

  i2c   :       "basic_i2c_driver"                    '0 COG
  c     :       "constants"                  
  uart    :     "pcFullDuplexSerial4FC"

VAR

  LONG  MPU[10],offset[3],mag[3]        'gains x,y,z; offsets x,y,z
  byte  MPU9150_alive,calibrated,scl,sda
          
  long  ti[2]
  byte addr

  long a[3], g[3], m[3], t
  
PUB MAIN | il


scl := 15
sda := 14
       
'Designed to test the MPU-9150 Magnetic sensor
uart.init
uart.addport(pcport,pcrx,pctx,-1,-1,10,0,pcbaud)
uart.start


initSensor(SCL,SDA)

setMpu(%000_00_000, %000_00_000)  

repeat   
  uart.tx(pcport,16)

  
  uart.tx(pcport,13)
  ti[0] := cnt
             
  Get_MPU_Data(@MPU) 
  Get_AKM_Data(@MAG) 

  ti[1] := clkfreq/(cnt-ti[0])

  uart.str(pcport,string("dt = "))
  uart.dec(pcport,ti[1])
  uart.str(pcport,string(" hz")) 
  uart.tx(pcport,13)    

  uart.str(pcport,string("Raw acc values"))
  uart.tx(pcport,13)                                   
  uart.dec(pcport,MPU[1])
  uart.tx(pcport,13)
  uart.dec(pcport, MPU[0])
  uart.tx(pcport,13)  
  uart.dec(pcport,-MPU[2])
  uart.tx(pcport,13)

  uart.str(pcport,string("Raw gyro values"))
  uart.tx(pcport,13)                                   
  uart.dec(pcport,MPU[5])
  uart.tx(pcport,13)   
  uart.dec(pcport, MPU[4])
  uart.tx(pcport,13)  
  uart.dec(pcport,-MPU[6])
  uart.tx(pcport,13)

  uart.str(pcport,string("Raw mag values"))
  uart.tx(pcport,13)  
    repeat il from 0 to 2
      uart.dec(pcport,mag[il])
      uart.tx(pcport,13)  
           
  waitcnt(clkfreq/10+cnt)   


PUB reportData(accPtr, gyroPtr, magPtr, temPtr)

  Get_MPU_Data(@MPU)
  Get_AKM_Data(@MAG)  
   
  Long[accPtr][0] := MPU[1]   ' my physical setting of mpu differs from mpu's manufacture
  Long[accPtr][1] := MPU[0]    ' my physical setting of mpu differs from mpu's manufacture  
  Long[accPtr][2] := -MPU[2]   ' my physical setting of mpu differs from mpu's manufacture    

  Long[gyroPtr][0] := MPU[5]   ' my physical setting of mpu differs from mpu's manufacture 
  Long[gyroPtr][1] := MPU[4]   ' my physical setting of mpu differs from mpu's manufacture 
  Long[gyroPtr][2] := -MPU[6]  ' my physical setting of mpu differs from mpu's manufacture 


  
  
  Long[magPtr][0] := MAG[0]  '- 17
  Long[magPtr][1] := MAG[1]  '- 20 
  Long[magPtr][2] := MAG[2]                           

  Long[temPtr] := MPU[3] / 340 + 35  

                   
PUB initSensor(sc,sd)
{{
  Initializes MPU-9150 

  parameters:  Addresses and scl/sda lines specified in the constant section. Optional debug ports listed in constant section  
  return:      1 if device found and reported healthy. 0 otherwise.

  example usage:    Init
  expected results: 1
}}
  i2c.initialize(sc,sd)    
  scl := sc
  sda := sd
  
  Alive

PUB setMpu(gyroSense, accSense) 

  if MPU9150_alive
    i2c.writeLocation(SCL,SDA,MPU_ADD, $6B, %0000_0001) '100Hz output at 1kHz sample
    i2c.writeLocation(SCL,SDA,MPU_ADD, $37, %0000_0010) 'i2c Passthrough
    i2c.writeLocation(SCL,SDA,MPU_ADD, $6A, %0000_0000) 'Disable i2cMaster mode    
      
    i2c.writeLocation(SCL,SDA,MPU_ADD, $19, 19) '50Hz output at 1kHz sample
    i2c.writeLocation(SCL,SDA,MPU_ADD, $1A, %0000_0001)'184Hz lowpass
    i2c.writeLocation(SCL,SDA,MPU_ADD, $1B, gyroSense)'250 deg/s                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
    i2c.writeLocation(SCL,SDA,MPU_ADD, $1C, accSense)'2G
     
    i2c.writeLocation(SCL,SDA,AKM_address, $0A, %0000_0001)'2Gauss   

  uart.dec(pcport,MPU9150_alive)
  waitcnt(cnt + clkfreq*3)
  
  if MPU9150_alive
    Calc_bias
    result := MPU9150_alive

PUB Alive
  MPU9150_alive := i2c.devicePresent(SCL,SDA,MPU_add)
  result := MPU9150_alive
  
PUB STATUS(address,register) 

  return i2c.readLocation8(SCL,SDA,address, register)

PUB Get_AKM_Data(XPtr)
  i2c.writeLocation(SCL,SDA,AKM_address, $0A, %0000_0001)'2 Gauss  
  i2c.ReadSensors(SCL,SDA, AKM_address, $03, Xptr, 3, 0)
  i2c.ReadSensors(SCL,SDA, AKM_address, $03, Xptr, 3, 0) ' don't know why 2 iterations are needed

PUB Get_MPU_Data(XPtr)  


  i2c.ReadSensors(SCL,SDA, MPU_ADD,$3B, XPtr, 7, 1)
  
  Scale_data(XPtr)
  
PUB Scale_data(XPtr)

if calibrated                   'Subtract gyro bias vector 
  MPU[4] -= offset[0]
  MPU[5] -= offset[1]
  MPU[6] -= offset[2]    

'M_MULT_INT(@MPU[0],@ACCEL_CAL,@MPU[0],@ACCEL_OFF,15)
'M_MULT_INT(@MPU[7],@MAG_CAL,@MPU[7],@MAG_OFF,15)

'longmove(Xptr,@MPU,7)    



PUB Calc_bias | il

  repeat 256
    Get_MPU_Data(@MPU)
    repeat il from 4 to 6     '4~6 : gyro information
      offset[il] += MPU[il]      
    'waitcnt(clkfreq*2/256 + cnt)                        '2 second window

  repeat il from 0 to 2
    offset[il] /= 256

  calibrated := true

PUB M_MULT_INT(M1,M2,M3,M4,shift)  | RTEMP[3]

RTEMP[0] := ((LONG[M1][0]*LONG[M2][0]+LONG[M1][1]*LONG[M2][3]+LONG[M1][2]*LONG[M2][6])~>shift)-LONG[M4][0]
RTEMP[1] := ((LONG[M1][0]*LONG[M2][1]+LONG[M1][1]*LONG[M2][4]+LONG[M1][2]*LONG[M2][7])~>shift)-LONG[M4][1]
RTEMP[2] := ((LONG[M1][0]*LONG[M2][2]+LONG[M1][1]*LONG[M2][5]+LONG[M1][2]*LONG[M2][8])~>shift)-LONG[M4][2]
longmove(M3,@RTEMP,3)

DAT

GYRO_CAL      long      33250,321,-211,-373,33092,-396,206,109,33440      
ACCEL_CAL     long      33006,-175,172,186,32889,84,-112,0,32629'33007,0,0,11,32890,0,62,83,32629
ACCEL_OFF     long      34,35,63'34,35,63      
MAG_CAL       long      54181,0,0,-7664,51226,0,7208,-10321,50167
MAG_OFF       long      -79,123,-33
     
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLD ERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,  │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}