Import mojo
Import skn3.funcs.graphics
Import skn3.callbacks
Import skn3.imagecache

Function Main:Int()
	New Demo
	Return 0
End

Class Demo Extends App Implements Skn3CallbackReciever
	Field fullScreen:= False
	Field image:ImageCache
	
	Method OnCreate:Int()
		' --- app is created ---
		SetUpdateRate(60)
		
		'add callbacks
		AddCallbackReciever(Self, CALLBACK_GRAPHICS_MODE_CHANGING)
		AddCallbackReciever(Self, CALLBACK_GRAPHICS_MODE_CHANGED)
		
		image = LoadImageCache("monkey1.png")
		
		Return 0
	End Method
	
	Method OnUpdate:Int()
		' --- app is updated ---
		If KeyHit(KEY_SPACE)
			fullScreen = Not fullScreen
			
			If fullScreen
				If GraphicsModeExists(1024, 768, 32) SetGraphics(1024, 768, 32, fullScreen)
			Else
				SetGraphics(640, 480, 0, fullScreen)
			EndIf
		EndIf
		
		Return 0
	End Method
	
	Method OnRender:Int()
		' --- app is rendered ---
		Cls(0, 0, 0)
		
		DrawImageCache(image, 50, 50)
		DrawText("press space to toggle screen mode", 5, 5)
		
		Return 0
	End Method
	
	Method OnCallback:Int(id:Int, source:Object, data:Object)
		Select id
			Case CALLBACK_GRAPHICS_MODE_CHANGING
				'null all image data
				FreeImageSources(True)
				
			Case CALLBACK_GRAPHICS_MODE_CHANGED
				'reload image data
				ReloadImageSources()
		End Select
	End
End