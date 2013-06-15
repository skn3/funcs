Strict

#If LANG = "cpp"
	Import "native/funcs.os.cpp"
	
	Extern
		Function CheckHasAdminAccess:Bool()
	Public
#Else
	Function CheckHasAdminAccess:Bool()
		' --- fake for unsupported platforms ---
		Return True
	End
#End

Function Main:Int()
	If CheckHasAdminAccess()
		Print "has access"
	Else
		Print "nope sorry"
	EndIf
	Return 0
End