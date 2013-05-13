Import mojo
Import skn3.funcs.graphics

Function Main:Int()
	New Demo
	Return 0
End

Class Demo Extends App
	Field image:Image
	
	Method OnCreate:Int()
		' --- app is created ---
		SetUpdateRate(60)
		
		image = LoadImage("monkey1.png")
		
		Return 0
	End Method
	
	Method OnUpdate:Int()
		' --- app is updated ---
		
		If KeyHit(KEY_SPACE)
			image.DiscardTexture()
			SetGraphics(1024, 768, False)
			image.ReloadTexture()
		EndIf
		
		Return 0
	End Method
	
	Method OnRender:Int()
		' --- app is rendered ---
		Cls(0, 0, 0)
		
		DrawImage(image, 50, 50)
		
		Return 0
	End Method
End