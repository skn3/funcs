Strict

'version 2
' - added DrawThickLine function
' - added DrawCircleOutline function
'version 1
' - seperated into graphics.monkey

Import mojo

Import skn3.callbacks
Import maths

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
Const MAX_VERTS:Int = 1024
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

'draw api
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

Function DrawCircleOutline:Void(x:Float, y:Float, radius:Float, detail:Int = -1)
	' --- draw outline of cirlce ---
	'do auto detail
	If detail < 0
		detail = radius / 2.0
		If detail < 3
			detail = 3
		ElseIf detail > MAX_VERTS
			detail = MAX_VERTS
		EndIf
	ElseIf detail < 3
		detail = 3
	EndIf
	
	Local angleStep:Float = 360.0 / detail
	Local angle:Float
	Local offsetX:Float
	Local offsetY:float
	Local first:Bool = True
	Local firstX:Float
	Local firstY:float
	Local thisX:Float
	Local thisY:float
	Local lastX:Float
	Local lastY:Float
	
	For Local vertIndex:= 0 Until detail
		offsetX = Sin(angle) * radius
		offsetY = Cos(angle) * radius
		If first
			first = False
			firstX = x + offsetX
			firstY = y + offsetY
			lastX = firstX
			lastY = firstY
		Else
			thisX = x + offsetX
			thisY = y + offsetY
			DrawLine(lastX, lastY, thisX, thisY)
			lastX = thisX
			lastY = thisY
		EndIf
		angle += angleStep
	Next
	DrawLine(lastX, lastY, firstX, firstY)
End

Function DrawThickLine:Void(x1:Float, y1:Float, x2:Float, y2:Float, size:Float, filled:Bool = False, detail:Int = -1)
	' --- draw a moving circle ---
	Local radius:Float = size / 2.0
	
	'do auto detail
	If detail < 0
		detail = size / 5.0
		If detail < 12
			detail = 12
		ElseIf detail > MAX_VERTS
			detail = MAX_VERTS
		EndIf
	EndIf

	Local movementAngle:Float = ATan2ToDegrees(x1 - x2, y1 - y2)
	Local offsetX:Float = (Sin(movementAngle + 90) * radius)
	Local offsetY:Float = (Cos(movementAngle + 90) * radius)
	Local circleIndex:Int
	Local circleAngleStep:Float = 180.0 / (detail + 1)
	Local circleAngle:Float
	
	If filled = False
		'just draw lines
		Local firstX:Float
		Local firstY:Float
		Local lastX:Float
		Local lastY:Float
		Local thisX:Float
		Local thisY:float
		
		'edge
		firstX = x1 + offsetX
		firstY = y1 + offsetY
		lastX = x2 + offsetX
		lastY = y2 + offsetY
		DrawLine(firstX, firstY, lastX, lastY)
		
		'end circle
		If detail > 0
			circleAngle = movementAngle + 90 + circleAngleStep
			For circleIndex = 0 Until detail
				thisX = x2 + (Sin(circleAngle) * radius)
				thisY = y2 + (Cos(circleAngle) * radius)
				DrawLine(lastX, lastY, thisX, thisY)
				lastX = thisX
				lastY = thisY
				circleAngle += circleAngleStep
			Next
		EndIf
		
		'top/end circle last
		offsetX = (Sin(movementAngle - 90) * radius)
		offsetY = (Cos(movementAngle - 90) * radius)
		
		thisX = x2 + offsetX
		thisY = y2 + offsetY
		DrawLine(lastX, lastY, thisX, thisY)
		lastX = thisX
		lastY = thisY
		
		'edge
		thisX = x1 + offsetX
		thisY = y1 + offsetY
		DrawLine(lastX, lastY, thisX, thisY)
		lastX = thisX
		lastY = thisY
		
		'start circle
		If detail > 0
			circleAngle = movementAngle - 90 + circleAngleStep
			For circleIndex = 0 Until detail
				thisX = x1 + (Sin(circleAngle) * radius)
				thisY = y1 + (Cos(circleAngle) * radius)
				DrawLine(lastX, lastY, thisX, thisY)
				lastX = thisX
				lastY = thisY
				circleAngle += circleAngleStep
			Next
		EndIf
		
		'top/end circle last
		DrawLine(lastX, lastY, firstX, firstY)
	Else
		'setup verts array
		Local verts:Float[8 + (detail * 2 * 2)]
		Local index:Int
		
		'edge
		verts[0] = x1 + offsetX
		verts[1] = y1 + offsetY
		verts[2] = x2 + offsetX
		verts[3] = y2 + offsetY
		index = 4
		
		'end circle
		If detail > 0
			circleAngle = movementAngle + 90 + circleAngleStep
			For circleIndex = 0 Until detail
				verts[index] = x2 + (Sin(circleAngle) * radius)
				verts[index + 1] = y2 + (Cos(circleAngle) * radius)
				index += 2
				circleAngle += circleAngleStep
			Next
		EndIf
		
		'edge
		offsetX = (Sin(movementAngle - 90) * radius)
		offsetY = (Cos(movementAngle - 90) * radius)
		
		verts[index] = x2 + offsetX
		verts[index + 1] = y2 + offsetY
		verts[index + 2] = x1 + offsetX
		verts[index + 3] = y1 + offsetY
		index += 4
		
		'start circle
		If detail > 0
			circleAngle = movementAngle - 90 + circleAngleStep
			For circleIndex = 0 Until detail
				verts[index] = x1 + (Sin(circleAngle) * radius)
				verts[index + 1] = y1 + (Cos(circleAngle) * radius)
				index += 2
				circleAngle += circleAngleStep
			Next
		EndIf
		
		'draw it
		DrawPoly(verts)
	EndIf
End