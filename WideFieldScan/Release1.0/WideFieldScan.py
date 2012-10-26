#! /usr/bin/env python

testing = False

import sys
import os.path
import string
import commands
import math

path_arg_at = 1
if len(sys.argv) - path_arg_at != 1:
  print "Usage: widefieldsscan.py Parameterfile.txt"
  print "The ParameterFile should have been made with"
  print "widefieldscan.m (MATLAB) and for each subscan contain one line with"
  print "'Number of Projections' 'InBeamPosition' 'StartAngle' 'StopAngle'"
  print "separated by a space."
  print 
  print "If this is so, I will setup EPICS, and start all the"
  print "scans with the desired parameters."
  sys.exit(1)
else:
  filename=sys.argv[1]

#---------------------------------------------------------------------------
#---------------------------------
#----------------------------------------------
# Make sure we are running at least python level 2.
# CaChannel seems to give troubles otherwise!
if sys.version[0:1] == "1":
  python2 = commands.getoutput ("type -p python2")
  if python2 == "":
    print "\n\aThe default python version is", sys.version
    print     "and this script needs python level 2 or higher."
    print     " Python level 2 cannot be found."
    os.system ("xkbbell")
    os.system ("xmessage -nearmouse -timeout 30 -buttons '' Python level 2 cannot be found")
    sys.exit (1)
  #endif
  sys.argv.insert (0, python2)
  os.execv (python2, sys.argv)
#endif
if sys.version[0:1] == "1":
  print "\n\aThe loading of a higher level of python seems to have failed!"
  sys.exit (1)
#endif
#---------------------------------------------------------------------------
try:
  from CaChannel import *
except:
  #try:
  #  sys.path.insert (0, os.path.expandvars ("$SLSBASE/sls/lib/python22/CaChannel"))
  #  from CaChannel import *
  #except:
  os.system ("xkbbell")
  os.system ("xmessage -nearmouse -timeout 30 -buttons '' CaChannel module cannot be found")
  sys.exit (1)
  #endtry
#endtry

from CaChannel import CaChannelException

#---------------------------------------------------------------------------

class EpicsChannel:
    def __init__(self,pvName):
        self.pvName=pvName
        try:
            self.chan=CaChannel()
            self.chan.search(self.pvName)
            self.chan.pend_io()
            self.connected=1
        except CaChannelException, status:
            print ca.message(status)
            self.connected=0

    def getVal(self):
        try:
                val=self.chan.getw()
        except:
                self.connected=0
                val=""
        return val

    def getValCHK(self, connected):
        if connected==1:
            return self.getVal()
        else:
            self.reconnect()

    def putVal(self,val):
        try:
            self.chan.putw(val)
        except:
            self.connected=0

    def putValCHK(self, val, connected):
        if connected==1:
            self.putVal(val)
        else:
            self.reconnect()

    def reconnect(self):
        try:
            self.chan=CaChannel()
            self.chan.search(self.pvName)
            self.chan.pend_io()
            self.connected=1
        except CaChannelException, status:
            print ca.message(status)
            self.connected=0        

#---------------------------------
print "hey ho, let's go!"
print

#-----------------------------------------------------------------
#
# Define relevant epics channels
#
#-----------------------------------------------------------------
print "Setting up the necessary EpicsChannels!"
EPICS_Trigger=EpicsChannel("X02DA-SCAN-SCN1:GO")
EPICS_FileName=EpicsChannel("X02DA-SCAN-CAM1:FILPRE")
EPICS_NumProj=EpicsChannel("X02DA-SCAN-SCN1:NPRJ")
EPICS_StartAngle=EpicsChannel("X02DA-SCAN-SCN1:ROTSTA")
EPICS_StopAngle=EpicsChannel("X02DA-SCAN-SCN1:ROTSTO")
EPICS_InBeamPosition=EpicsChannel("X02DA-SCAN-SCN1:SMPIN")
print "done!"
print

# save stuff for being nice at the end
wasnumprj=EPICS_NumProj.getValCHK(EPICS_NumProj.connected)
wasstartangle=EPICS_StartAngle.getValCHK(EPICS_StartAngle.connected)
wasstopangle=EPICS_StopAngle.getValCHK(EPICS_StopAngle.connected)
wasinbeampos=EPICS_InBeamPosition.getValCHK(EPICS_InBeamPosition.connected)

parameterfile = open(filename)
counter = 1

print "reading SampleName from Panel"
if testing:
  SampleName = "SampleNameForTesting"
else:
  SampleName=EPICS_FileName.getValCHK(EPICS_FileName.connected)
print "The base-filename for all the scans is: `" + str(SampleName) + "'."

while 1:
  line = parameterfile.readline()
  if line == "":
    break
  line = string.strip(line)
  if line == "" or string.find(line,"#") == 0:
    continue
  scanparameters = string.split(line," ")
  # print scanparameters
  if len(scanparameters) != 4:
    parameterfile.close()
    print "not 4 parameters"
    sys.exit(1)
  try:
    NumberOfProjections = int(scanparameters[0])
  except:
    parameterfile.close()
    print "The Number of Projections is not an Integer! Don't know what to do, so I quit!"
    sys.exit(1)
  try:
    InBeamPosition = float(scanparameters[1])
  except:
    parameterfile.close()
    print "The InBeamPosition is not a float! Don't know what to do, so I quit!"
    sys.exit(1)
  try:
    StartAngle = float(scanparameters[2])
  except:
    parameterfile.close()
    print "The StartAngle is not a float! Don't know what to do, so I quit!"
    sys.exit(1)
  try:
    StopAngle = float(scanparameters[3])
  except:
    parameterfile.close()
    print "The StopAngle is not a float! Don't know what to do, so I quit!"
    sys.exit(1)
  
  print "I'm now setting the parameters for SubScan Nr. " + str(counter)
  print "Number of Projections = " + str(NumberOfProjections)
  EPICS_NumProj.putValCHK(NumberOfProjections,EPICS_NumProj.connected)

  print "InBeamPosition = " + str(InBeamPosition)
  EPICS_InBeamPosition.putValCHK(InBeamPosition,EPICS_InBeamPosition.connected)

  print "Start- and Stop-Angles are " + str(StartAngle) + " and " + str(StopAngle)
  EPICS_StartAngle.putValCHK(StartAngle,EPICS_StartAngle.connected)
  EPICS_StopAngle.putValCHK(StopAngle,EPICS_StopAngle.connected)    

  print "I've setup the Parameters for SubScan Nr. " + str(counter) + " on the EPICS-Panel."
  print 
  print "sooooooo, let's scan!!!"
  print "------------------------------------------------------------------"
  
  # set filename
  SubScanName = SampleName + "_s" + str(counter)
  print "The FileName for the current SubScan is " + SubScanName
  
  #Start scanning
  EPICS_FileName.putValCHK(SubScanName,EPICS_FileName.connected)
  print "I've set the FileName for the current SubScan on the EPICS-Panel"
  
  if testing:
    scanstatus = 1
    testcounter = 10
  else:
    print "I'm waiting 10 sec to make sure EPICS is ready and registered my commands..."
    time.sleep(10)
    print "And press the 'GO'-trigger now"
    print "Acquiring `" + SubScanName + "`..."
    EPICS_Trigger.putValCHK(1,EPICS_Trigger.connected)
    print "I'm waiting a bit for the trigger to be registered (to be on the safe side...)"
    time.sleep(5)
    scanstatus = EPICS_Trigger.getValCHK(EPICS_Trigger.connected)
    print "I'm now scanning the Sample, you can check the progress in the cameraserver window or just wait..."
  
  while scanstatus == 1:
    time.sleep(1)
    if testing:
      print
      print "I would actually perform a scan here, but we're only testing..."
      print
      scanstatus = 0
    else:
      scanstatus = EPICS_Trigger.getValCHK(EPICS_Trigger.connected)

  print "I`m done with subscan " + SubScanName + "!"
  counter = counter + 1
  print "------------------------------------------------------------------"
  print "I'm waiting 10 sec to make sure we don't proceed too fast..."
  time.sleep(10)
  print "I'm done, let's begin with the next SubScan (or finish...)"
print "I'm finished with all the subscans and I'm cleaning up after me now"
parameterfile.close()

#put stuff back (because we're nice)
EPICS_FileName.putValCHK(SampleName,EPICS_FileName.connected)
EPICS_NumProj.putValCHK(wasnumprj,EPICS_NumProj.connected)
EPICS_StartAngle.putValCHK(wasstartangle,EPICS_StartAngle.connected)
EPICS_StopAngle.putValCHK(wasstopangle,EPICS_StopAngle.connected)
EPICS_InBeamPosition.putValCHK(wasinbeampos,EPICS_InBeamPosition.connected)
print
print
print "Thank you for flying TOMCAT!"
print "Please remain seated with your seatbelts fastened until"
print "the machine has come to a complete standstill and the"
print "captain has switched off the seatbelt sign!"
