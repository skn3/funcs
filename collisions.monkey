Strict

'version 3
' - moved some bits to private!
'version 2
' - imported many more functions from an old project
' - tweaked naming convention to use camel case instead of underscores!
'version 1
' - seperated into colliions.monkey

Import monkey.math

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

Function LinesCross:Bool(x0:Float, y0:Float, x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float)
	'Adapted from Fredborg's code
	Local n:Float = (y0 - y2) * (x3 - x2) - (x0 - x2) * (y3 - y2)
	Local d:Float=(x1-x0)*(y3-y2)-(y1-y0)*(x3-x2)
	
	If Abs(d) < 0.0001 
		' Lines are parallel!
		Return False
	Else
		' Lines might cross!
		Local Sn:Float=(y0-y2)*(x1-x0)-(x0-x2)*(y1-y0)

		Local AB:Float=n/d
		If AB>0.0 And AB<1.0
			Local CD:Float=Sn/d
			If CD>0.0 And CD<1.0
				' Intersection Point
				Local X:= x0 + AB * (x1 - x0)
		       	Local Y:= y0 + AB * (y1 - y0)
				Return True
			End If
		End If
	
		' Lines didn't cross, because the intersection was beyond the end points of the lines
	EndIf

	' Lines do Not cross!
	Return False

End Function

Function LineToCircle:Bool(x1:Float, y1:Float, x2:Float, y2:Float, px:Float, py:Float, r:Float)
	'Adapted from TomToad's code
	Local sx:Float = x2-x1
	Local sy:Float = y2-y1
	
	Local q:Float = ((px-x1) * (x2-x1) + (py - y1) * (y2-y1)) / (sx*sx + sy*sy)
	
	If q < 0.0 Then q = 0.0
	If q > 1.0 Then q = 1.0
	
	Local cx:Float=(1-q)*x1+q*x2
	Local cy:Float=(1-q)*y1 + q*y2
	
	
	If DistanceBetweenPoints(px,py,cx,cy) < r
		
		Return True
		
	Else
		
		Return False
		
	EndIf
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
Function RectsOverlap:Bool(x0:Float, y0:Float, w0:Float, h0:Float, x2:Float, y2:Float, w2:Float, h2:Float)
 	If x0 > (x2 + w2) Or (x0 + w0) < x2 Then Return False
 	If y0 > (y2 + h2) Or (y0 + h0) < y2 Then Return False
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
	
	If PolyToPoly(p1Xy,transformedXy)
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