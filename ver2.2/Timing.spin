{{Timing.spin

This object has methods that simplify:

  - Adding delays between commands in your
    program
  - Synchronizing the timing of when certain
    commands get executed
  - Monitoring for when to stop waiting and
    move on to other commands (timeout)

See end of file for author, version,
copyright and terms of use.

Examples in each method's documentation
assumes that this object was declared in a
program and nicknamed time, like this:

  Example Program with time Nickname
 ┌────────────────────────────────────────┐
 │ ''Delays for 1 second between commands │
 │ OJB                                    │
 │   time : "Timing"                      │
 │                                        │
 │ PUB Go                                 │
 │   '...your code                        │
 │   time.Pause(1000)       ' 1 s delay   │
 │   '...more of your code                │
 └────────────────────────────────────────┘

IMPORTANT: This object is a collection of
           "convenience methods".  For more
           precise control over event timing,
           use the WAITCNT command.  To find
           out more about this command and
           examples of how it is used, look
           it up in the Propeller Manual.
}}
CON

  WMin =   381
  offset0 = 5680 - 368  
  offset1 = 3920 - 368

VAR
  
  long  t, dt, time, offset

PUB Pause(duration) 
{{Pause execution for a certain duration.  
   
Parameter:

  duration = number of time increments the
             pause lasts.  (Default time
             icrement is 1 ms.)

Code Example:

  time.Pause(1000)       ' 1 s delay 

Note: You can call the Increment method to
      change the size of the time increment.
}}
  offset := offset1
  ifnot dt
    dt := clkfreq/1000
    offset := offset0
  waitcnt((((duration*dt)-offset)#>WMin) + cnt)                                      
  
PUB Mark                                                                                     
{{Mark the current time for use with
SinceMark, Wait, and Out methods.
}}
  t := cnt                                                                               

PUB SinceMark : duration
{{Report time increments elapsed since last
call to either Mark or Wait.

Returns:

  duration = number of time increments since
             last Mark or Wait call  
}}
  ifnot dt
    dt := clkfreq/1000
  duration := (cnt - t)/dt
  
PUB Wait(aftermark)                                                                          
{{Waits for a certain number of time
increments after a call to either
the Mark method, or a previous wait
method.  Also marks the current time
for the next call to Wait or SinceMark.

Parameter:

  aftermark = the number of time increments
              after a call to either the
              Mark method or a previous
              call to Wait.

Tip: 

  This method is excellent for keeping
  the time between two events precise,
  even if the commands between them take
  variable amounts of time.  It's also
  useful for keeping the timing of certain
  events in a loop occurring at precise
  intervals.

Example: wait from mark

  time.Mark
  '...commands that might
  'vary in execution time
  time.Wait(100)
  'command 0.1 s after mark

Example: precise loop timing

  time.Mark
  repeat
    '...commands might vary in execution time
    time.Wait(100)           
    'command every 0.1 seconds

Caution:

  Don't let the variable execution time
  commands take longer than the target
  time for the Wait command, or the cog
  will get stuck for 2³² clock ticks, which
  is almost 54 seconds at 80 MHz and longer
  at slower system clock speeds.
    
}}                                                                                               
  ifnot dt
    dt := clkfreq/1000
  waitcnt(t += ((aftermark * dt) #> WMin))                                        
                                                                                                 
PUB Out(aftermark) : done
{{Checks for "time.Out" conidition.  In
other words, if this method tells you if
it is called later than aftermark time
increments from a call to Mark (or Wait)

Parameter:
  aftermark = the number of time increments
              after a call to either the
              Mark method or a previous
              call to Wait.

Returns:
  done = true if out of time
       = false if not out of time

}}
  ifnot dt
    dt := clkfreq/1000
  done := cnt-t => (aftermark*dt)

PUB Increment(clockticks)
{{Sets the time increment based on a number
of clock ticks.
 
Parameters:

  clockticks = number of system clock tics a
               time increment should last.

Example:

  'Change duration increment from 1 ms
  'to 0.5 ms.  Before change, default
  'increment is 1 ms.  After, it's 0.5 ms.
  time.Pause(1000)              '1 s delay
  time.Increment(clkfreq/2000)  '0.5 ms
  time.Pause(1000)              '0.5 s delay

}}
  dt := clockTicks
  
DAT
{{
Author: Andy Lindsay
Version: 0.2
Date:   2011.03.23
Copyright (c) 2011 Parallax Inc.

┌──────────────────────────────────────────────────────────────────────────────────────┐
│TERMS OF USE: MIT License                                                             │                                                            
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │ 
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │                                            │
│                                                                                      │                                               │
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │                                                │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     │
│OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        │
│SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}    