Set objSysInfo = CreateObject("ADSystemInfo")
strComputer = objSysInfo.ComputerName

Set objComputer = GetObject("LDAP://" & strComputer)

arrOUs = Split(objComputer.Parent, ",")
arrMainOU = Split(arrOUs(0), "=")

Wscript.Echo strComputer
Wscript.Echo arrMainOU(1)