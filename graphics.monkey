Strict

Import mojo

Import skn3.callbacks

#if TARGET = "glfw"
Import "native/funcs.graphics.${TARGET}.${LANG}"

Extern
	Class GraphicsMode = "graphicsModeNative"
		Field width:Int
		Field height:Int
		Field depth:Int
	End
Extern Private
	Function SetGraphicsNative:Void(width:Int, height:Int, depth:Int, fullSreen:Bool) = "SetGraphicsNative"
	Function GetGraphicsModesNative:GraphicsMode[] () = "GetGraphicsModesNative"
	Function GraphicsModeExistsNative:bool(width:Int, height:Int, depth:Int) = "GraphicsModeExistsNative"
Public
#end

Private
Global tempMatrix:Float[6]
Public

'callbacks
Global CALLBACK_GRAPHICS_MODE_CHANGING:= RegisterCallbackId("Graphics Mode Changing")
Global CALLBACK_GRAPHICS_MODE_CHANGED:= RegisterCallbackId("Graphics Mode Changed")

'functions
Function SetGraphics:Void(width:Int, height:Int, depth:Int, fullScreen:Bool)
	' --- this will change the resolution of the running app ---
	#if TARGET = "glfw"
	FireCallback(CALLBACK_GRAPHICS_MODE_CHANGING)
	SetGraphicsNative(width, height, depth, fullScreen)
	FireCallback(CALLBACK_GRAPHICS_MODE_CHANGED)
	#end
End

Function GetGraphicsModes:GraphicsMode[] ()
	' --- get list of all graphics modes ---
	#if TARGET = "glfw"
	Return GetGraphicsModesNative()
	#else
	Return New GraphicsMode[] ()
	#end
End

Function GraphicsModeExists:Bool(width:Int, height:Int, depth:Int)
	' --- return true if a graphics mode exists ---
	#if TARGET = "glfw"
	Return GraphicsModeExistsNative(width, height, depth)
	#else
	Return False
	#end	
End

Function DrawRectOutline:Void(x:Float, y:Float, width:Float, height:Float)
	' --- draw a line rect ---
	DrawLine(x, y, x + width, y)
	DrawLine(x + width, y, x + width, y + height)
	DrawLine(x + width, y + height, x, y + height)
	DrawLine(x, y + height, x, y)
End

Function DrawRectOutline:Void(position:Float[], size:Float[])
	' --- draw a line rect ---
	DrawLine(position[0], position[1], position[0] + size[0], position[1])
	DrawLine(position[0] + size[0], position[1], position[0] + size[0], position[1] + size[1])
	DrawLine(position[0] + size[0], position[1] + size[1], position[0], position[1] + size[1])
	DrawLine(position[0], position[1] + size[1], position[0], position[1])
End

Function ResetMatrix:Void()
	' --- reset the current matrix ---
	SetMatrix(1, 0, 0, 1, 0, 0)
End

Function ResetScissor:Void()
	' --- reset the scissor ---
	SetScissor(0, 0, DeviceWidth(), DeviceHeight())
End

Function OverrideMatrix:Void(x:Float, y:Float, angle:Float, scaleX:Float, scaleY:Float)
	' --- change the matrix all at once ---
	SetMatrix(scaleX * Cos(angle), -Sin(angle), Sin(angle), scaleY * Cos(angle), x, y)
End

Function AddMatrix:Void(x:Float, y:Float, angle:Float, scaleX:Float, scaleY:Float)
	' --- multiply existing matrix all at once ---
	Transform(scaleX*Cos(angle),-Sin(angle),Sin(angle),scaleY*Cos(angle),x,y)
End

Function InvertTransform:Void(coords:Float[], out:Float[])
	GetMatrix(tempMatrix)
	Local det:Float = tempMatrix[0] * tempMatrix[3] - tempMatrix[1] * tempMatrix[2]
	Local idet:Float=  1.0/det
	Local r00:Float =  tempMatrix[3] * idet
	Local r10:Float = -tempMatrix[2] * idet
	Local r20:Float = (tempMatrix[2]*tempMatrix[5] - tempMatrix[3]*tempMatrix[4]) * idet
	Local r01:Float = -tempMatrix[1] * idet
	Local r11:Float =  tempMatrix[0] * idet
	Local r21:Float = (tempMatrix[1]*tempMatrix[4] - tempMatrix[0]*tempMatrix[5]) * idet
	'Local r22:Float = (tempMatrix[0]*tempMatrix[3] - tempMatrix[1]*tempMatrix[2]) * idet		'what do I do with this?
	Local ix:Float=r00,jx:Float=r10,tx:Float=r20,iy:Float=r01,jy:Float=r11,ty:Float=r21

	Local x:Float
	Local y:float
	For Local i:Int = 0 Until coords.Length - 1 Step 2
		x = coords[i]
		y = coords[i + 1]
		out[i]=   x*ix + y*jx + tx
		out[i+1]= x*iy + y*jy + ty
	Next
End

Function InvertTransform:Void(x:Float, y:float, out:Float[])
	GetMatrix(tempMatrix)
	Local det:Float = tempMatrix[0] * tempMatrix[3] - tempMatrix[1] * tempMatrix[2]
	Local idet:Float=  1.0/det
	Local r00:Float =  tempMatrix[3] * idet
	Local r10:Float = -tempMatrix[2] * idet
	Local r20:Float = (tempMatrix[2]*tempMatrix[5] - tempMatrix[3]*tempMatrix[4]) * idet
	Local r01:Float = -tempMatrix[1] * idet
	Local r11:Float =  tempMatrix[0] * idet
	Local r21:Float = (tempMatrix[1]*tempMatrix[4] - tempMatrix[0]*tempMatrix[5]) * idet
	'Local r22:Float = (tempMatrix[0]*tempMatrix[3] - tempMatrix[1]*tempMatrix[2]) * idet		'what do I do with this?
	Local ix:Float = r00, jx:Float = r10, tx:Float = r20, iy:Float = r01, jy:Float = r11, ty:Float = r21

	out[0] = x * ix + y * jx + tx
	out[1] = x * iy + y * jy + ty
End

#rem
Function GetRotation:Float()
	' --- get matrix rotation ---
	Return GetRotation(GetMatrix())
End

Function GetRotation:Float(matrix:Float[])
	' --- get matrix rotation ---
	return ATan(matrix[2] / matrix[3])
End

Function GetScale:Void(out:Float[])
	' --- get matrix scale ---
	GetScale(GetMatrix(), out)
End

Function GetScale:Void(matrix:float[], out:Float[])
	' --- get matrix scale ---
	out[0] = Sqrt(Pow(matrix[0], 2) + Pow(matrix[1], 2))
	out[1] = Sqrt(Pow(matrix[2], 2) + Pow(matrix[3], 2))
End

Function GetTranslation:Void(out:Float[])
	' --- get matrix translation ---
	GetTranslation(GetMatrix(), out)
End

Function GetTranslation:Void(matrix:Float[], out:Float[])
	' --- get matrix translation ---
	out[0] = matrix[4]
	out[1] = matrix[5]
End
#rem