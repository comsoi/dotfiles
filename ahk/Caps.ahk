CapsLock::
KeyWait, CapsLock, T0.45
if (ErrorLevel)
SetCapsLockState, % (t:=!t) ? "On" : "Off"
else
Send ^{Space}
KeyWait, CapsLock
return
