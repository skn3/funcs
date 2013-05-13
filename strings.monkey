Strict

'version 1
' - added ParseQuery function

Import monkey.map

Import skn3.stringbuffer

Private
Global stringBuffer:StringBuffer
Public

Function ParseQuery:StringMap<String>(query:String)
	' --- parse a query and spit out a map of key/value pairs ---
	'query is in the format of 'title1=value1&title2=value2'
	'the = and & character can be escaped with a \ character
	'a value pair can also be shortcut like 'value1&value2&value3'
	Local queryIndex:Int
	Local queryAsc:Int
	
	'create buffer
	If stringBuffer = Null stringBuffer = New StringBuffer(256)
	
	Local isEscaped:= False
	
	Local processBuffer:= False
	Local processItem:= False
	
	Local hasId:= False
	Local hasValue:= False
	Local hasEquals:= False
	Local hasSepcial:= False
	
	Local itemId:String
	Local itemValue:String
	
	Local items:= New StringMap<String>
	
	For queryIndex = 0 Until query.Length
		'looking for title
		queryAsc = query[queryIndex]
		
		If isEscaped
			'escaped character
			isEscaped = False
			stringBuffer.Add(queryAsc)
		Else
			'test character
			Select queryAsc
				Case 38'&
					processBuffer = True
					processItem = True
					
				Case 61'=
					processBuffer = True
					hasEquals = True
					
				Case 64'@
					If hasId = False
						'switch on special value
						If stringBuffer.Length = 0 hasSepcial = True
					Else
						'value so just add it
						stringBuffer.Add(queryAsc)
					EndIf
					
				Case 92'\
					isEscaped = True
					
				Default
					'skip character if we are building id and there is not valid alphanumeric
					If hasId or (queryAsc = 95 or (queryAsc >= 48 and queryAsc <= 57) or (queryAsc >= 65 and queryAsc <= 90) or (queryAsc >= 97 and queryAsc <= 122)) stringBuffer.Add(queryAsc)
			End
		EndIf
		
		'check for end condition
		If queryIndex = query.Length - 1
			processBuffer = True
			processItem = True
			
			'add escape character if it was left over
			If isEscaped And hasId stringBuffer.Add(92)
			
			'check for blank =
			If hasEquals And stringBuffer.Length = 0 hasValue = True
		EndIf
		
		'process the buffer
		If processBuffer
			'unflag process
			processBuffer = False
			
			'check condition
			If hasId = False
				itemId = stringBuffer.value
				stringBuffer.Clear()
				hasId = itemId.Length > 0
			Else
				itemValue = stringBuffer.value
				stringBuffer.Clear()
				hasValue = True
			EndIf
		EndIf
		
		'process the item
		If processItem
			'unflag process
			processItem = False
			
			'check condition
			If hasId
				'insert new item
				items.Insert(itemId, itemValue)
				
				'reset
				itemId = ""
				itemValue = ""
				hasId = False
				hasValue = False
				hasSepcial = False
			EndIf
		EndIf
	Next
	
	'return the items
	Return items
End