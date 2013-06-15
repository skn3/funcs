Strict

Import monkey.math

Function RadToDeg:Float(rad:Float)
  Return rad * 180 / PI
End

Function DegToRad:Float(deg:Float)
	Return deg * (PI / 180)
End

Function Bezier:Void(out:Float[], startX:Float, startY:Float, endX:Float, endY:Float, startHandleX:Float, startHandleY:Float, endHandleX:Float, endHandleY:Float, time:Float)
	' --- calculate point along bezier at given time between 0.0 and 1.0 ---
	Local time2:Float = 1 - time
	out[0] = startX * time2 * time2 * time2 + 3 * startHandleX * time2 * time2 * time + 3 * endHandleX * time2 * time * time + endX * time * time * time
	out[1] = startY * time2 * time2 * time2 + 3 * startHandleY * time2 * time2 * time + 3 * endHandleY * time2 * time * time + endY * time * time * time
End

Function WrapAngle:Float(angle:Float)
	' --- wrap an angle round ---
	angle = angle / 360.0
	Return (angle - Floor(angle)) * 360.0	
End

Function ATan2ToDegrees:Float(x:Float, y:float)
	' --- convert atan into sensible angle --
	Local angle:Float = ATan2(x, y)
	If angle < 0 Return 180.0 + (180.0 + angle)
	Return angle
End