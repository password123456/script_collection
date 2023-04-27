'-------------------------------------------
' deleting domain admins group from local administrators
'
' https://github.com/password123456
'-------------------------------------------

Option Explicit

Dim WshShell, objNet
Dim strDomainAdmins, strDomainName, objLocalGroup, objDomainAdmins

Set objNet = CreateObject("WScript.Network")
strDomainName = objNet.UserDomain
strDomainAdmins = "Domain Admins"

Set objLocalGroup = GetObject("WinNT://./Administrators,group")
Set objDomainAdmins = GetObject("WinNT://" & strDomainName & "/" & strDomainAdmins & ",group")

If Err.Number = 0 Then
	Set WshShell = CreateObject("WScript.Shell")
	If objLocalGroup.IsMember(objDomainAdmins.ADsPath) Then
	    objLocalGroup.Remove(objDomainAdmins.ADsPath)
	    WshShell.LogEvent 0, "[Domain Admins Removal Script] " & vbNewLine & Now & " / " & strDomainName & "\" & strDomainAdmins & " / Removal Success."
	Else
	    WshShell.LogEvent 0, "[Domain Admins Removal Script] " & vbNewLine & Now & " / " & strDomainName & "\" & strDomainAdmins & " / Already Removed."
	End If
			
	Set WshShell = Nothing
	
End If
