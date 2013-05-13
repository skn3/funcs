Strict

Import mojo

Private
Global ms:Int
Global msSet:Bool
Public

Function SetMillisecs:Void(newMs:Int)
	' --- update global ms ---
	ms = newMs
	msSet = True
End

Function GetMillisecs:Int()
	' --- return global ms ---
	If msSet Return ms
	Return Millisecs()
End