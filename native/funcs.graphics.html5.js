function SetGraphicsNative(width,height,fullScreen) {
	if (typeof(game_canvas) != 'undefined') {
		var popupWidth = game_canvas.width+'px';
		var popupHeight = game_canvas.height+'px';
		
		var popup = document.createElement('div')
		popup.style.width = popupWidth;
		popup.style.height = popupHeight;
		popup.style.position = 'absolute';
		
		var popupBackground = document.createElement('div');
		popupBackground.style.width = popupWidth;
		popupBackground.style.height = popupHeight;
		popupBackground.style.position = 'absolute';
		popupBackground.style.zIndex = '0';
		popupBackground.style.backgroundColor = '#000000';
		popupBackground.style.filter = 'alpha(opacity=75);';
		popupBackground.style.MozOpacity = 0.75;
		popupBackground.style.opacity = 0.75;
		popupBackground.style.KhtmlOpacity = 0.75;
		popup.appendChild(popupBackground);
		
		var popupContents = document.createElement('div');
		popupContents.style.width = popupWidth;
		popupContents.style.height = popupHeight;
		popupContents.style.position = 'absolute';
		popupContents.style.zIndex = '1';
		popupContents.style.textAlign = 'center'
		popupContents.style.color = '#ffffff';
		popupContents.style.fontFamily = 'arial';
		popupContents.style.fontWeight = 'bold';
		popupContents.style.fontSize = '30px';
		popupContents.style.lineHeight = popupHeight;
		popup.appendChild(popupContents);
		
		var popupText = document.createTextNode('CLICK TO GO FULLSCREEN');
		popupContents.appendChild(popupText);
		
		popup.onclick = function() {
			//cludge it with browser vendor check
			if (typeof(game_canvas.requestFullScreen) == 'function') {
				game_canvas.requestFullScreen();
				
			} else if (typeof(game_canvas.webkitRequestFullscreen) == 'function') {
				game_canvas.webkitRequestFullscreen();
				
			} else if (typeof(game_canvas.mozRequestFullScreen) == 'function') {
				game_canvas.mozRequestFullScreen();
				
			} else if (typeof(game_canvas.msRequestFullScreen) == 'function') {
				game_canvas.msRequestFullScreen();
				
			} else if (typeof(game_canvas.oRequestFullScreen) == 'function') {
				game_canvas.oRequestFullScreen();
			}
			
			//destroy the popup
			document.body.removeChild(popup);
		};
		
		//add poup to document
		document.body.insertBefore(popup,game_canvas);
	}
}