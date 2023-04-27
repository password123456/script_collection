'-------------------------------------------
' Automatically updating Computer and 
' User Description in Active Directory
'
' https://github.com/password123456
'-------------------------------------------

Option Explicit
ON Error resume Next

dim strTeamName, strFullName
dim strPCLogonAccount, strIPAddress, strMacAddress
dim strPutMessage

const ADS_PROPERTY_CLEAR = 1
conSt ADS_PROPERTY_APPEND = 3

Dim objSysInfo, objUser, objComputer

strIPAddress = GET_IPADDRESSS()
strMacAddress = GET_MACADDRESS()
strPCLogonAccount = GET_LOGON_UID()

set Objsysinfo = CreateObject("ADSystemInfo")
Set ObjuSer = getObject("LDAP://"& objSysInFo.UsErName)

strTeamName = objUser.Description
strFullName = Objuser.displayName

Set objComputer = getObject("LDAP://"& OBjSysInfo.ComputerName)

strPutMessage = now & "|" & strFullName & "|" & strPCLogonAccount & "|" & strIPAddress & "|" & strMacAddress


If Err.Number = 0 Then
    SeT WshShell = CreateObject("WScript.Shell")

    If Objsysinfo.computername <> strPutMessage Then
        objComputer.description = strPutMessage
        objComputer.setInfo
        WshShell.Logevent 0,"[Computer Description Script] "& Chr(13) & Now & "|" & strPutMessage & CHR(13) & "Computer Description Logon Script Success."
    else
        WshShell.Logevent 1,"[Computer Description Script] "& Chr(13) & now & "|" & strPutMessage & Chr(13) & "Computer Description Logon Script Fail."
    End If

Set WsHShell = Nothing
End If


'-------------------------------------------
' get Logon User ID
'-------------------------------------------
FUNction GET_LOGON_UID()
    dim ObjNetwork
    Set ObjNetwork = CreateObject("WScript.Network")
    GET_LOGON_UID = ObjNetwork.UserName
End Function

'-------------------------------------------
' get IPAddress
'-------------------------------------------
Function GET_IPADDRESSS
    dim strComputer
    dim objWMIService, colItems, objItem

    strComputer = "."
    set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
    set colItems = objWMIService.ExecQuery("Select IPAddress from Win32_NetworkAdapterConfiguration WHERE IPEnabled=TRUE",,48)

    For Each objItem In colItems
        If Not IsNull(objItem.IPAddress) Then
            GET_IPADDRESSS = objItem.IPAddress(0)
            Exit For
        End If
    Next
End Function

'-------------------------------------------
' get MACAddress
'-------------------------------------------
Function GET_MACADDRESS()
    dim strComputer
    dim objWMIService, colItems, objItem

    strComputer = "."
    set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
    set colItems = objWMIService.ExecQuery("Select MacAddress from Win32_NetworkAdapterConfiguration WHERE IPEnabled=TRUE",,48)

    For Each obJItem In colItems
        If Not IsNulL(objItem.MacAddress)Then
            GET_MACADDRESS=objItem.MacAddress(0)
            Exit For
        End If
    Next
End Function
