Strict

Class Url
	Field url:String
	Field protocol:String
	Field username:String
	Field password:String
	Field server:String
	Field port:int
	Field path:String
	Field query:String
	Field anchor:String
	
	'constructor/destructor
	Method New(url:String)
		SetUrl(url)
	End
	
	'api
	Method ToString:String()
		Return "url: " + url + "~nprotocol: " + protocol + "~nusername: " + username + "~npassword: " + password + "~nserver: " + server + "~nport: " + port + "~npath: " + path + "~nquery: " + query + "~nanchor: " + anchor
	End
	
	Method SetUrl:Void(url:String)
		' --- parse a new url ---
		'reset the url components
		Self.url = url
		protocol = "http"
		username = ""
		password = ""
		server = ""
		port = 80
		path = "/"
		query = ""
		anchor = ""
		
		'start parsing url
		Local pos1:Int
		Local pos2:Int
		Local cursor:Int = 0
		
		'find query and anchor
		Local queryPos:= url.Find("?")
		Local anchorPos:= url.Find("#")
		
		'find non data length
		Local nonDataLength:Int
		If queryPos = -1 And anchorPos = -1
			'has no query or anchor
			nonDataLength = url.Length
		ElseIf queryPos > - 1 And anchorPos > - 1
			If queryPos < anchorPos
				'has query and anchor
				nonDataLength = queryPos
			Else
				'has just anchor
				nonDataLength = anchorPos
				queryPos = -1
			EndIf
		ElseIf queryPos > - 1
			'has query
			nonDataLength = queryPos
		Else
			'has just anchor
			nonDataLength = anchorPos
		EndIf
		
		'find protocol
		pos1 = url.Find("://", cursor)
		If pos1 > - 1 And pos1 < nonDataLength
			protocol = url[cursor .. pos1]
			'move cursor
			cursor = pos1 + 3
		EndIf
		
		'find username/password
		pos1 = url.Find("@", cursor)
		If pos1 > - 1 And pos1 < nonDataLength
			'find split
			pos2 = url.Find(":", cursor)
			If pos2 > - 1 And pos2 < pos1
				'username and password
				username = url[cursor .. pos2]
				password = url[pos2 + 1 .. pos1]
			Else
				'just username
				username = url[cursor .. pos1]
			EndIf
			
			'move cursor
			cursor = pos1 + 1
		EndIf
		
		'find path and port so we can figure out the address part
		Local portStart:= url.Find(":", cursor)
		Local pathStart:= url.Find("/", cursor)
		Local serverLength:Int
		
		'fix port/path start to be within non data section of url
		If portStart > - 1 And portStart >= nonDataLength portStart = -1
		If pathStart > - 1 And pathStart >= nonDataLength pathStart = -1
		
		If portStart = -1 And pathStart = -1
			'has no port or path
			server = url[cursor .. nonDataLength]
		ElseIf portStart > - 1 And pathStart > - 1
			If portStart < pathStart
				'has port and path
				server = url[cursor .. portStart]
				port = Int(url[portStart + 1 .. pathStart])
				path = url[pathStart .. nonDataLength]
			Else
				'has just path
				server = url[cursor .. pathStart]
				path = url[pathStart .. nonDataLength]
			EndIf
		ElseIf portStart > - 1
			'has just port
			server = url[cursor .. portStart]
			port = Int(url[portStart + 1 .. nonDataLength])
		Else
			'has just path
			server = url[cursor .. pathStart]
			path = url[pathStart .. nonDataLength]
		EndIf
		
		'find query
		If queryPos > - 1
			If anchorPos > - 1
				'query up until anchor
				query = url[queryPos + 1 .. anchorPos]
			Else
				'just up until end
				query = url[queryPos + 1 ..]
			EndIf
		EndIf
		
		'find anchor
		If anchorPos > - 1 anchor = url[anchorPos + 1 ..]
	End
End