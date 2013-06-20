Strict

'version 5
' - tweaked LinesCross and added overload version to return intersection point
'version 4
' - added some more collision tests
'version 3
' - moved some bits to private!
'version 2
' - imported many more functions from an old project
' - tweaked naming convention to use camel case instead of underscores!
'version 1
' - seperated into colliions.monkey

Import monkey.math
Import maths

'internal
Private
Global tempPoint1:Float[2]
Global tempPoint2:Float[2]
Public

Function GetQuad:Int(axisX:Float, axisY:Float, vertX:Float, vertY:Float)
	If vertX<axisX
		If vertY<axisY
			Return 1
		Else
			Return 4
		EndIf
	Else
		If vertY<axisY
			Return 2
		Else
			Return 3
		EndIf	
	EndIf

End Function
Public

'helpers
Function TransformPoly:Float[] (xy:Float[], transformedX:Float = 0, transformedY:Float = 0, rot:Float = 0, scaleX:Float = 1, scaleY:Float = 1, handleX:Float = 0, handleY:Float = 0, originX:Float = 0, originY:Float = 0)
	
	If xy.Length<6 Or (xy.Length&1) Return []
	
	Local transformedXy:Float[]=xy[0..xy.Length]
	
	For Local i:= 0 Until transformedXy.Length Step 2
		tempPoint1[0] = transformedXy[i]
		tempPoint1[1] = transformedXy[i+1]
		TransformLocalToGlobal(tempPoint1,transformedX,transformedY,rot,scaleX,scaleY,handleX,handleY,originX,originY)
		transformedXy[i] = tempPoint1[0]
		transformedXy[i+1] = tempPoint1[1]
	Next
	
	Return transformedXy
End Function

Function TransformGlobalToLocal:Void(point:Float[], transformedX:Float = 0, transformedY:Float = 0, rot:Float = 0, scaleX:Float = 1, scaleY:Float = 1, handleX:Float = 0, handleY:Float = 0, originX:Float = 0, originY:Float = 0)
	
	point[0]-=originX
	point[1] -= originY
	
	point[0]-=transformedX
	point[1]-=transformedY
	
	Local mag:Float=Sqr(point[0]*point[0]+point[1]*point[1])
	Local ang:Float=ATan2(point[1],point[0])
	point[0]=Cos(ang-rot)*mag
	point[1]=Sin(ang-rot)*mag
	
	point[0]/=scaleX
	point[1]/=scaleY
	
	point[0]+=handleX
	point[1]+=handleY
End Function

Function TransformLocalToGlobal:Void(point:Float[], transformedX:Float = 0, transformedY:Float = 0, rot:Float = 0, scaleX:Float = 1, scaleY:Float = 1, handleX:Float = 0, handleY:Float = 0, originX:Float = 0, originY:Float = 0)
	
	point[0]-=handleX
	point[1]-=handleY
	
	point[0]*=scaleX
	point[1]*=scaleY
	
	Local mag:Float=Sqrt(point[0]*point[0]+point[1]*point[1])
	Local ang:Float=ATan2(point[1],point[0])
	point[0]=Cos(ang+rot)*mag
	point[1]=Sin(ang+rot)*mag
	
	point[0]+=transformedX
	point[1]+=transformedY
	
	point[0]+=originX
	point[1]+=originY
End Function

'point
Function DistanceBetweenPoints:Float(x1:Float, y1:Float, x2:Float, y2:Float)
	Local dx:Float = x1-x2
	Local dy:Float = y1-y2
	Return Sqrt(dx*dx + dy*dy)
End Function

Function PointInTransformPoly:Bool(pointX:Float, pointY:Float, xy:Float[], polyX:Float = 0, polyY:Float = 0, rot:Float = 0, scaleX:Float = 1, scaleY:Float = 1, handleX:Float = 0, handleY:Float = 0, originX:Float = 0, originY:Float = 0)
	
	If xy.Length<6 Or (xy.Length&1) Return False
	
	tempPoint1[0] = pointX
	tempPoint1[1] = pointY
	TransformGlobalToLocal(tempPoint1,polyX,polyY,rot,scaleX,scaleY,handleX,handleY,originX,originY)
	
	Return PointInPoly(tempPoint1[0],tempPoint1[1],xy)
End Function

Function PointInPoly:Bool(pointX:Float, pointY:Float, xy:Float[])
	
	If xy.Length<6 Or (xy.Length&1) Return False
	
	Local x1:Float=xy[xy.Length-2]
	Local y1:Float=xy[xy.Length-1]
	Local curQuad:Int=GetQuad(pointX,pointY,x1,y1)
	Local nextQuad:Int
	Local total:Int
	
	For Local i:= 0 Until xy.Length Step 2
		Local x2:Float=xy[i]
		Local y2:Float=xy[i+1]
		nextQuad=GetQuad(pointX,pointY,x2,y2)
		Local diff:Int=nextQuad-curQuad
		
		Select diff
		Case 2,-2
			If ( x2 - ( ((y2 - pointY) * (x1 - x2)) / (y1 - y2) ) )<pointX
				diff=-diff
			EndIf
		Case 3
			diff=-1
		Case -3
			diff=1
		End Select
		
		total+=diff
		curQuad=nextQuad
		x1=x2
		y1=y2
	Next
	
	If Abs(total)=4 Then Return True Else Return False
End Function

Function PointInCircle:Bool(pointX:Float, pointY:Float, circleX:Float, circleY:Float, radius:Float)
	' --- return if the point is in teh circle ---
	Return DistanceBetweenPoints(pointX,pointY,circleX,circleY) <= radius
End Function

Function PointInRect:Bool(pointX:Float, pointY:Float, rectX:Float, rectY:Float, rectWidth:Float, rectHeight:Float)
	' --- returns true if point is inside rect ---
	Return pointX >= rectX And pointX < rectX + rectWidth And pointY >= rectY And pointY < rectY + rectHeight
End Function

'line api
Function LineOverlapsRect:Bool(lineX1:Float, lineY1:Float, lineX2:Float, lineY2:Float, rectX:Float, rectY:Float, rectWidth:Float, rectHeight:Float)
	' --- quickest test for line overlapping a rect ---
	'useful for testing if a moving point collided with a rect (without having to return the intersection point)	
	'pre calc rect bottom corner (surely will save a few calculations?)
	Local rectX2:= rectX + rectWidth
	Local rectY2:= rectY + rectHeight
	
	'lets do a rect test first speed things up
	Local lineRectX:= 0.0
	Local lineRectY:= 0.0
	Local lineRectWidth:= 0.0
	Local lineRectHeight:= 0.0
	
	If lineX1 < lineX2
		lineRectX = lineX1
		lineRectWidth = lineX2 - lineX1
	Else
		lineRectX = lineX2
		lineRectWidth = lineX1 - lineX2
	EndIf
	
	If lineY1 < lineY2
		lineRectY = lineY1
		lineRectHeight = lineY2 - lineY1
	Else
		lineRectY = lineY2
		lineRectHeight = lineY1 - lineY2
	EndIf
	
	If lineRectX > rectX2 Or (lineRectX + lineRectWidth) < rectX or lineRectY > rectY2 Or (lineRectY + lineRectHeight) < rectY Return False
	
	'Find min and max X For the segment
	Local minX:= lineX1
	Local maxX:= lineX2
	
	If lineX1 > lineX2
		minX = lineX2
		maxX = lineX1
	EndIf
	
	'Find the intersection of the segment's and rectangle's x-projections
	If maxX > rectX2 maxX = rectX2
	If minX < rectX minX = rectX
	
	If minX > maxX Return False 'If their projections do not intersect return false
	
	'Find corresponding min and max Y for min and max X we found before
	Local minY:= lineY1
	Local maxY:= lineY2
	
	Local temp:= lineX2 - lineX1
	
	If Abs(temp) > 0.0000001
		Local a:= (lineY2 - lineY1) / temp
		Local b:= lineY1 - a * lineX1
		minY = a * minX + b
		maxY = a * maxX + b
	EndIf
	
	If minY > maxY
		temp = maxY
		maxY = minY
		minY = temp
	EndIf
	
	'Find the intersection of the segment's and rectangle's y-projections
	If maxY > rectY2 maxY = rectY2
	If minY < rectY minY = rectY
	
	If minY > maxY Return False' // If Y-projections do not intersect return false
	
	Return True
End

Function LineToTransformPoly:Bool(lineX1:Float, lineY1:Float, lineX2:Float, lineY2:Float, xy:Float[], polyX:Float = 0, polyY:Float = 0, rot:Float = 0, scaleX:Float = 1, scaleY:Float = 1, handleX:Float = 0, handleY:Float = 0, originX:Float = 0, originY:Float = 0)
	
	If xy.Length<6 Or (xy.Length&1) Return False
	
	tempPoint1[0] = lineX1
	tempPoint1[1] = lineY1
	TransformGlobalToLocal(tempPoint1,polyX,polyY,rot,scaleX,scaleY,handleX,handleY,originX,originY)
	
	tempPoint2[0] = lineX2
	tempPoint2[1] = lineY2
	TransformGlobalToLocal(tempPoint2,polyX,polyY,rot,scaleX,scaleY,handleX,handleY,originX,originY)
	
	Return LineToPoly(tempPoint1[0],tempPoint1[1],tempPoint2[0],tempPoint2[1],xy)
End Function

Function LineToPoly:Bool(lineX1:Float, lineY1:Float, lineX2:Float, lineY2:Float, xy:Float[])
	
	If xy.Length<6 Or (xy.Length&1) Return False
	
	If PointInPoly(lineX1,lineY1,xy) Then Return True
	
	Local polyX1:Float=xy[xy.Length-2]
	Local polyY1:Float=xy[xy.Length-1]
	
	For Local i:Int=0 Until xy.Length Step 2
		Local polyX2:Float=xy[i]
		Local polyY2:Float=xy[i+1]
		
		If LinesCross(lineX1,lineY1,lineX2,lineY2,polyX1,polyY1,polyX2,polyY2) Then Return True
		polyX1=polyX2
		polyY1=polyY2
	Next
	
	Return False
	
End Function

Function LinesCross:Bool(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, x4:Float, y4:Float)
	' --- do lines intersection ---
	'Adapted from Fredborg's code
	Local n:Float = (y1 - y3) * (x4 - x3) - (x1 - x3) * (y4 - y3)
	Local d:Float = (x2 - x1) * (y4 - y3) - (y2 - y1) * (x4 - x3)
	
	'test for lines are parallel!
	If Abs(d) < 0.0001 Return false
		
	'might cross
	Local sn:Float = (y1 - y3) * (x2 - x1) - (x1 - x3) * (y2 - y1)

	Local ab:Float = n / d
	If ab > 0.0 And ab < 1.0
		'check intersection
		Local cd:Float = sn / d
		If cd > 0.0 And cd < 1.0 Return True
	EndIf
	
	'lines didn't cross, because the intersection was beyond the end points of the lines
	'nope
	Return False
End Function

Function LinesCross:Bool(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, x4:Float, y4:Float, intersectionPoint:Float[])
	' --- do lines intersection ---
	'Adapted from Fredborg's code
	Local n:Float = (y1 - y3) * (x4 - x3) - (x1 - x3) * (y4 - y3)
	Local d:Float = (x2 - x1) * (y4 - y3) - (y2 - y1) * (x4 - x3)
	
	'test for lines are parallel!
	If Abs(d) < 0.0001 Return false
		
	'might cross
	Local sn:Float = (y1 - y3) * (x2 - x1) - (x1 - x3) * (y2 - y1)

	Local ab:Float = n / d
	If ab > 0.0 And ab < 1.0
		'check intersection
		Local cd:Float = sn / d
		
		If cd > 0.0 And cd < 1.0
			'set the out intersection point
			intersectionPoint[0] = x1 + ab * (x2 - x1)
	       	intersectionPoint[1] = y1 + ab * (y2 - y1)
			
			'return it
			Return True
		EndIf
	EndIf
	
	'lines didn't cross, because the intersection was beyond the end points of the lines
	'nope
	Return False
End Function

Function LineToCircle:Bool(x1:Float, y1:Float, x2:Float, y2:Float, circleX:Float, circleY:Float, circleRadius:Float)
	'Adapted from TomToad's code
	Local sx:Float = x2-x1
	Local sy:Float = y2-y1
	Local q:Float = ( (circleX - x1) * (x2 - x1) + (circleY - y1) * (y2 - y1)) / (sx * sx + sy * sy)
	If q < 0.0 q = 0.0
	If q > 1.0 q = 1.0
	
	'inline the DistanceBetweenPoints function for speed
	sx = circleX - ( (1 - q) * x1 + q * x2)
	sy = circleY - ( (1 - q) * y1 + q * y2)
	Return Sqrt(sx * sx + sy * sy) < circleRadius
End Function

Function GetLineIntersectLine:Void(line1x1:Float, line1y1:Float, line1x2:Float, line1y2:Float, line2x1:Float, line2y1:Float, line2x2:Float, line2y2:Float, result:Float[])
	Local m1:Float, m2:Float, b1:Float, b2:Float
	
	If (line1x2 - line1x1) <> 0
		m1 = (line1y2 - line1y1) / (line1x2 - line1x1)
	Else
		m1 = (line1y2 - line1y1)
	EndIf
	If (line2x2 - line2x1) <> 0
		m2 = (line2y2 - line2y1) / (line2x2 - line2x1)
	Else
		m2 = (line2y2 - line2y1)
	EndIf
	
	b1 = line1y1 - (m1 * line1x1)
	b2 = line2y1 - (m2 * line2x2)

	result[0] = (line2y1 - line1y1 - (line2x1 * m2) + (line1x1 * m1)) / (m1 - m2)
	result[1] = m1 * result[0] + b1
End Function

Function GetLineIntersectRect:Void(linex1:Float, liney1:Float, linex2:Float, liney2:Float, rectX1:Float, rectY1:Float, rectWidth:Float, rectHeight:Float, result:Float[])
	Local rectX2:Float = rectX1 + rectWidth
	Local rectY2:Float = rectY1 + rectHeight
	
	If linex1 < rectX1 And linex2 >= rectX1
		result[1] = liney1 + (liney2 - liney1) * (rectX1-linex1)/(linex2-linex1)
		If result[1]>=rectY1 And result[1]<=rectY2
			result[0] = rectX1
			Return True
		EndIf
	ElseIf linex1 > rectX2 And linex2 <= rectX2
		result[1] = liney1 + (liney2 - liney1) * (rectX2 - linex1)/(linex2 - linex1)
		If result[1]>=rectY1 And result[1]<=rectY2
			result[0] = rectX2
			Return True
		EndIf
	EndIf
	
	If liney1 < rectY1 And liney2 >= rectY1
		result[0] = linex1 + (linex2 - linex1) * (rectY1 - liney1)/(liney2 - liney1)
		If result[0]>=rectX1 And result[0]<=rectX2
			result[1] = rectY1
			Return True
		EndIf
	ElseIf liney1 > rectY2 And liney2 <= rectY2
		result[0] = linex1 + (linex2 - linex1) * (rectY2 - liney1)/(liney2 - liney1)
		If result[0]>=rectX1 And result[0]<=rectX2
			result[1] = rectY2
			Return True
		EndIf
	EndIf
End Function

'rect api
Function RectsOverlap:Bool(x1:Float, y1:Float, width1:Float, height1:Float, x2:Float, y2:Float, width2:Float, height2:Float)
 	If x1 > (x2 + width2) Or (x1 + width1) < x2 or y1 > (y2 + height2) Or (y1 + height1) < y2 Return False
	Return True
End

Function RectInsideRect:Bool(x1:Float, y1:Float, width1:Float, height1:Float, x2:Float, y2:Float, width2:Float, height2:Float)
	' --- return if rect 1 is inside rect 2 ---
	Return x1 >= x2 And y1 >= y2 And x1 < x2+width2 And y1 < y2+height2 And x1+width1 <= x2+width2 And y1+height1 <= y2+height2
End Function

'circle api
Function CircleToTransformPoly:Bool(circleX:Float, circleY:Float, radius:Float, xy:Float[], polyX:Float = 0, polyY:Float = 0, rot:Float = 0, scaleX:Float = 1, scaleY:Float = 1, handleX:Float = 0, handleY:Float = 0, originX:Float = 0, originY:Float = 0)
	
	If xy.Length<6 Or (xy.Length&1) Return False
	
	Local transformedXy:Float[]=TransformPoly(xy,polyX,polyY,rot,scaleX,scaleY,handleX,handleY,originX,originY)
	
	Return CircleToPoly(circleX,circleY,radius,transformedXy)
End Function

Function CircleToPoly:Bool(circleX:Float, circleY:Float, radius:Float, xy:Float[])
	
	If xy.Length<6 Or (xy.Length&1) Return False
	
	If PointInPoly(circleX,circleY,xy) Then Return True
	
	Local x1:Float=xy[xy.Length-2]
	Local y1:Float=xy[xy.Length-1]
	
	For Local i:Int=0 Until xy.Length Step 2
		Local x2:Float=xy[i]
		Local y2:Float=xy[i+1]
		
		If LineToCircle(x1,y1,x2,y2,circleX,circleY,radius) Then Return True
		x1=x2
		y1=y2
	Next
	
	Return False
End Function

Function CircleOverlapsRect:Bool(circleX:Float, circleY:Float, circleRadius:Float, rectX:Float, rectY:Float, rectWidth:Float, rectHeight:Float)
	' --- is circle overlapping rect ---
	'do simple test
	If circleX >= rectX And circleX < rectX + rectWidth And circleY >= rectY And circleY < rectY + rectHeight Return True
	
	'do complete test
	Local rectHalfWidth:Float = rectWidth / 2.0
	Local rectHalfHeight:Float = rectHeight / 2.0
	Local circleDistanceX:Float = Abs(circleX - (rectX + rectHalfWidth))
	Local circleDistanceY:Float = Abs(circleY - (rectY + rectHalfHeight))
	
	If circleDistanceX > rectHalfWidth + circleRadius Return False
	If circleDistanceY > rectHalfHeight + circleRadius Return False
	
	If circleDistanceX <= rectHalfWidth Return True
	If circleDistanceY <= rectHalfHeight Return True
	
	Return Pow(circleDistanceX - rectHalfWidth, 2.0) + Pow(circleDistanceY - rectHalfHeight, 2.0) <= Pow(circleRadius, 2.0)
End

Function MovingCircleOverlapsRect:Bool(circleX1:Float, circleY1:Float, circleX2:Float, circleY2:Float, circleRadius:Float, rectX:Float, rectY:Float, rectWidth:Float, rectHeight:Float)
	' --- this will check if a moving circle overlaps a rect ---
	'first do a simple tests
	If circleRadius = 0.0 or rectWidth = 0.0 or rectHeight = 0.0 or rectWidth = 0.0 Return False
	
	'and rect bound test
	Local tempX:Float
	Local tempY:Float
	Local tempWidth:Float
	Local tempHeight:Float
	If circleX1 < circleX2
		tempX = circleX1 - circleRadius
		tempWidth = circleX2 - circleX1 + circleRadius + circleRadius
	Else
		tempX = circleX2 - circleRadius
		tempWidth = circleX1 - circleX2 + circleRadius + circleRadius
	EndIf
	If circleY1 < circleY2
		tempY = circleY1 - circleRadius
		tempHeight = circleY2 - circleY1 + circleRadius + circleRadius
	Else
		tempY = circleY2 - circleRadius
		tempHeight = circleY1 - circleY2 + circleRadius + circleRadius
	EndIf
	If tempX > (rectX + rectWidth) Or (tempX + tempWidth) < rectX or tempY > (rectY + rectHeight) Or (tempY + tempHeight) < rectY Return False
	
	'now test end circles
	If CircleOverlapsRect(circleX1, circleY1, circleRadius, rectX, rectY, rectWidth, rectHeight) or CircleOverlapsRect(circleX2, circleY2, circleRadius, rectX, rectY, rectWidth, rectHeight) Return True
	
	'finally we should test two outer edges
	'this is expensive :/
	Local angle:Float = ATan2ToDegrees(circleX2 - circleX1, circleY2 - circleY1)
	Local offsetX:Float = (Sin(angle + 90) * circleRadius)
	Local offsetY:Float = (Cos(angle + 90) * circleRadius)
	If LineOverlapsRect(circleX1 + offsetX, circleY1 + offsetY, circleX2 + offsetX, circleY2 + offsetY, rectX, rectY, rectWidth, rectHeight) Return True
	
	offsetX = -offsetX
	offsetY = -offsetY
	If LineOverlapsRect(circleX1 + offsetX, circleY1 + offsetY, circleX2 + offsetX, circleY2 + offsetY, rectX, rectY, rectWidth, rectHeight) Return True
	
	'nope
	Return False
End

'poly
Function TransformPolyToTransformPoly:Bool(p1Xy:Float[], p1X:Float = 0, p1Y:Float = 0, p1Rot:Float = 0, p1ScaleX:Float = 1, p1ScaleY:Float = 1, p1HandleX:Float = 0, p1HandleY:Float = 0, p1OriginX:Float = 0, p1OriginY:Float = 0, p2Xy:Float[], p2X:Float = 0, p2Y:Float = 0, p2Rot:Float = 0, p2ScaleX:Float = 1, p2ScaleY:Float = 1, p2HandleX:Float = 0, p2HandleY:Float = 0, p2OriginX:Float = 0, p2OriginY:Float = 0)
	
	If p1Xy.Length<6 Or (p1Xy.Length&1) Return False
	If p2Xy.Length < 6 Or (p2Xy.Length & 1) Return False
	
	Local tform1Xy:Float[]=TransformPoly(p1Xy,p1X,p1Y,p1Rot,p1ScaleX,p1ScaleY,p1HandleX,p1HandleY,p1OriginX,p1OriginY)
	
	Local tform2Xy:Float[]=TransformPoly(p2Xy,p2X,p2Y,p2Rot,p2ScaleX,p2ScaleY,p2HandleX,p2HandleY,p2OriginX,p2OriginY)
	
	If PolyToPoly(tform1Xy,tform2Xy)
		Return True
	Else
		Return False
	EndIf
	
End Function

Function PolyToTransformPoly:Bool(p1Xy:Float[], p2Xy:Float[], p2X:Float = 0, p2Y:Float = 0, rot:Float = 0, scaleX:Float = 1, scaleY:Float = 1, handleX:Float = 0, handleY:Float = 0, originX:Float = 0, originY:Float = 0)
	
	If p1Xy.Length<6 Or (p1Xy.Length&1) Return False
	If p2Xy.Length<6 Or (p2Xy.Length&1) Return False
	
	Local transformedXy:Float[]=TransformPoly(p2Xy,p2X,p2Y,rot,scaleX,scaleY,handleX,handleY,originX,originY)
	
	If PolyToPoly(p1Xy, transformedXy)
		Return True
	Else
		Return False
	EndIf
	
End Function

Function PolyToPoly:Bool(p1Xy:Float[], p2Xy:Float[])
	
	If p1Xy.Length<6 Or (p1Xy.Length&1) Return False
	If p2Xy.Length<6 Or (p2Xy.Length&1) Return False
	
	For Local i:Int=0 Until p1Xy.Length Step 2
		If PointInPoly(p1Xy[i],p1Xy[i+1],p2Xy) Then Return True
	Next
	For Local i:Int=0 Until p2Xy.Length Step 2
		If PointInPoly(p2Xy[i],p2Xy[i+1],p1Xy) Then Return True
	Next
	
	Local l1X1:Float=p1Xy[p1Xy.Length-2]
	Local l1Y1:Float=p1Xy[p1Xy.Length-1]
	For Local i1:Int=0 Until p1Xy.Length Step 2
		Local l1X2:= p1Xy[i1]
		Local l1Y2:= p1Xy[i1 + 1]
		
		Local l2X1:Float=p2Xy[p2Xy.Length-2]
		Local l2Y1:Float=p2Xy[p2Xy.Length-1]
		For Local i2:Int=0 Until p2Xy.Length Step 2
			Local l2X2:= p2Xy[i2]
			Local l2Y2:= p2Xy[i2 + 1]
			
			If LinesCross(l1X1,l1Y1,l1X2,l1Y2,l2X1,l2Y1,l2X2,l2Y2)
				Return True
			EndIf
			
			l2X1=l2X2
			l2Y1=l2Y2
		Next
		l1X1=l1X2
		l1Y1=l1Y2
	Next
	Return False
End Function